import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:color_os/app/core/constant/api_endpoints.dart';
import 'package:color_os/app/core/services/api_services.dart';
import 'package:color_os/app/models/api_response.dart';
import 'package:color_os/app/models/appointment_model.dart';
import 'package:color_os/app/models/working_hours_model.dart';
import 'package:color_os/app/models/available_slot_model.dart';

class AppointmentController extends GetxController {
  // Observable variables
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<DateTime> selectedMonth = DateTime.now().obs;
  final RxList<AppointmentModel> appointments = <AppointmentModel>[].obs;
  final RxList<AppointmentModel> allAppointments = <AppointmentModel>[].obs;
  final Rx<WorkingHoursModel?> workingHours = Rx<WorkingHoursModel?>(null);
  final RxBool isLoadingWorkingHours = false.obs;
  final RxBool isLoadingAppointments = false.obs;
  final RxBool isLoadingAllAppointments = false.obs;
  final RxSet<String> cancellingIds = <String>{}.obs;

  final RxList<AvailableSlotModel> availableSlots = <AvailableSlotModel>[].obs;
  final RxBool isLoadingSlots = false.obs;

  // PageView controller for weeks
  late PageController pageController;
  final int initialPage = 1000;
  final RxInt currentPage = 1000.obs;
  late DateTime _anchorDate;

  @override
  void onInit() {
    super.onInit();
    _anchorDate = DateTime.now();
    // Align anchor to start of the week (Sunday)
    _anchorDate = _anchorDate.subtract(Duration(days: _anchorDate.weekday % 7));
    // Remove time components
    _anchorDate = DateTime(
      _anchorDate.year,
      _anchorDate.month,
      _anchorDate.day,
    );

    pageController = PageController(initialPage: initialPage);

    // Sync initial selected date page
    _syncPageWithDate(selectedDate.value);

    _fetchWorkingHours();
    fetchAppointments(selectedDate.value);
    fetchAvailableSlots(selectedDate.value);
  }

  // Get appointments for selected date
  List<AppointmentModel> get appointmentsForSelectedDate {
    return appointments.where((appointment) {
      return appointment.dateTime.year == selectedDate.value.year &&
          appointment.dateTime.month == selectedDate.value.month &&
          appointment.dateTime.day == selectedDate.value.day;
    }).toList()..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  /// True when the selected date is an off-day per working hours
  bool get isSelectedDateOff {
    final wh = workingHours.value;
    if (wh == null) return false;
    // Flutter weekday: Mon=1..Sun=7 → map to 0=Mon..6=Sun
    final weekdayIndex = selectedDate.value.weekday - 1;
    final dayEntry = wh.workingDays.firstWhere(
      (d) => d.weekday == weekdayIndex,
      orElse: () => WorkingDayModel.defaultDay(weekdayIndex),
    );
    return dayEntry.isOff;
  }

  void onPageChanged(int index) {
    currentPage.value = index;
    // Update selected month based on the visible week (using Thursday as middle of week)
    final weekStart = getWeekDaysForPage(index).first;
    final weekMiddle = weekStart.add(const Duration(days: 3));

    if (weekMiddle.month != selectedMonth.value.month ||
        weekMiddle.year != selectedMonth.value.year) {
      selectedMonth.value = DateTime(weekMiddle.year, weekMiddle.month);
    }
  }

  List<DateTime> getWeekDaysForPage(int pageIndex) {
    final daysToAdd = (pageIndex - initialPage) * 7;
    final startOfWeek = _anchorDate.add(Duration(days: daysToAdd));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  // Get week days for the CURRENTLY FOCUSED page
  List<DateTime> get currentWeekDays => getWeekDaysForPage(currentPage.value);

  // Sync the page controller to a specific date
  void _syncPageWithDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final daysDiff = dateOnly.difference(_anchorDate).inDays;
    final pageOffset = (daysDiff / 7).floor();
    final targetPage = initialPage + pageOffset;

    if (currentPage.value != targetPage) {
      currentPage.value = targetPage;
      if (pageController.hasClients) {
        pageController.jumpToPage(targetPage);
      }
    }
  }

  // Select a specific date
  void selectDate(DateTime date) {
    final newDate = DateTime(date.year, date.month, date.day);
    // Only update if changed
    if (selectedDate.value != newDate) {
      selectedDate.value = newDate;
      // Sync page if necessary (e.g. if selected from month picker)
      _syncPageWithDate(newDate);

      if (date.month != selectedMonth.value.month ||
          date.year != selectedMonth.value.year) {
        selectedMonth.value = DateTime(date.year, date.month);
      }
      fetchAppointments(newDate);
      fetchAvailableSlots(newDate);
    }
  }

  // Navigate to previous month
  void previousMonth() {
    selectedMonth.value = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month - 1,
    );
    // Jump to first day of that month
    final firstDay = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month,
      1,
    );
    selectDate(firstDay);
  }

  // Navigate to next month
  void nextMonth() {
    selectedMonth.value = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month + 1,
    );
    // Jump to first day of that month
    final firstDay = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month,
      1,
    );
    selectDate(firstDay);
  }

  // Get month name
  String get monthName {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    // Use selectedMonth assuming it tracks the visible month
    return months[selectedMonth.value.month - 1];
  }

  // Get day name abbreviation
  String getDayName(int weekday) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[weekday % 7];
  }

  // Get hour label for timeline
  String getHourLabel(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$h12:00 $period';
  }

  // Update appointment
  void updateAppointment(AppointmentModel updatedAppointment) {
    final index = appointments.indexWhere((a) => a.id == updatedAppointment.id);
    if (index != -1) {
      appointments[index] = updatedAppointment;
    }
  }

  Future<void> _fetchWorkingHours() async {
    try {
      isLoadingWorkingHours.value = true;
      final response = await ApiServices.getData(ApiEndpoints.workingHoursSetup);

      if (response != null &&
          ApiResponse.isSuccessfulHttpStatus(response.statusCode) &&
          response.data != null) {
        final wh = WorkingHoursModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        workingHours.value = wh;
        // Working hours stored; the UI layer (AppointmentsScreen) reads this
        // and shows a banner prompt if setup is not yet done.
      }
    } catch (e) {
      debugPrint('[AppointmentController] Error fetching working hours: $e');
    } finally {
      isLoadingWorkingHours.value = false;
    }
  }

  /// Public method — allows other controllers (e.g., WorkingHoursController)
  /// to trigger a working hours refresh after saving.
  Future<void> refreshWorkingHours() => _fetchWorkingHours();

  // ── Working hours display helpers ──────────────────────────────────────────

  /// "9:00 AM – 8:00 PM" — uses the selected date's working day hours
  String get formattedWorkingHours {
    final wh = workingHours.value;
    if (wh == null) return '';
    // Find the working day for the selected date
    final weekdayIdx = selectedDate.value.weekday - 1; // 0=Monday..6=Sunday
    final day = wh.workingDays.firstWhere(
      (d) => d.weekday == weekdayIdx && !d.isOff,
      orElse: () => wh.workingDays.firstWhere(
        (d) => !d.isOff,
        orElse: () => wh.workingDays.first,
      ),
    );
    if (day.isOff || day.startTime == null || day.endTime == null) return 'Day Off';
    return '${_fmtTime(day.startTime!)} – ${_fmtTime(day.endTime!)}';
  }

  /// "Mon, Sun" (off days)
  String get offDaysText {
    final wh = workingHours.value;
    if (wh == null) return '';
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (wh.offDays.isEmpty) return 'All days';
    return wh.offDays.map((d) => names[d.clamp(0, 6)]).join(', ');
  }

  static String _fmtTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final period = h >= 12 ? 'PM' : 'AM';
      final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
      return '$h12:${m.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return timeStr;
    }
  }

  bool isTimeSlotEnabled(int hour) {
    final wh = workingHours.value;
    if (wh == null) return true;

    // Map Flutter weekday (1=Mon..7=Sun) to app index (0=Mon..6=Sun)
    final weekdayIndex = selectedDate.value.weekday - 1;

    // Find the day entry
    final dayEntry = wh.workingDays.firstWhere(
      (d) => d.weekday == weekdayIndex,
      orElse: () => WorkingDayModel.defaultDay(weekdayIndex),
    );

    if (dayEntry.isOff) return false;
    if (dayEntry.startTime == null || dayEntry.endTime == null) return true;

    try {
      final startHour = int.parse(dayEntry.startTime!.split(':')[0]);
      final endHour = int.parse(dayEntry.endTime!.split(':')[0]);
      return hour >= startHour && hour < endHour;
    } catch (_) {
      return true;
    }
  }

  Future<void> fetchAppointments(DateTime date) async {
    try {
      isLoadingAppointments.value = true;

      debugPrint('[AppointmentController] Fetching all appointments');

      final response = await ApiServices.getData(ApiEndpoints.createAppointment);

      debugPrint(
        '[AppointmentController] Response: statusCode=${response?.statusCode} '
        'data=${response?.data}',
      );

      if (response != null &&
          ApiResponse.isSuccessfulHttpStatus(response.statusCode) &&
          response.data != null) {
        final rawData = response.data;
        List? items;

        if (rawData is List) {
          items = rawData;
        } else if (rawData is Map) {
          if (rawData['appointments'] is List) {
            items = rawData['appointments'] as List;
          } else if (rawData['data'] is List) {
            items = rawData['data'] as List;
          }
        }

        if (items != null) {
          appointments.value = items
              .whereType<Map<String, dynamic>>()
              .map(AppointmentModel.fromJson)
              .toList();
          debugPrint(
            '[AppointmentController] Loaded ${appointments.length} total appointments',
          );
        } else {
          debugPrint(
            '[AppointmentController] No appointment list found in response.',
          );
          appointments.clear();
        }
      } else {
        appointments.clear();
      }
    } catch (e) {
      debugPrint('[AppointmentController] Error fetching appointments: $e');
      appointments.clear();
    } finally {
      isLoadingAppointments.value = false;
    }
  }

  /// Fetch all appointments (all dates) for the profile view
  Future<void> fetchAllAppointments() async {
    try {
      isLoadingAllAppointments.value = true;
      final response = await ApiServices.getData(ApiEndpoints.createAppointment);
      if (response != null &&
          ApiResponse.isSuccessfulHttpStatus(response.statusCode) &&
          response.data != null) {
        final rawData = response.data;
        List? items;
        if (rawData is List) {
          items = rawData;
        } else if (rawData is Map) {
          if (rawData['appointments'] is List) {
            items = rawData['appointments'] as List;
          } else if (rawData['data'] is List) {
            items = rawData['data'] as List;
          }
        }
        if (items != null) {
          allAppointments.value = items
              .whereType<Map<String, dynamic>>()
              .map(AppointmentModel.fromJson)
              .toList();
        }
      }
    } catch (e) {
      debugPrint('[AppointmentController] Error fetching all appointments: $e');
    } finally {
      isLoadingAllAppointments.value = false;
    }
  }

  /// Cancel an appointment by ID using DELETE endpoint.
  /// Keeps the appointment in the list but updates status to 'cancelled'.
  Future<void> cancelAppointment(String appointmentId) async {
    if (cancellingIds.contains(appointmentId)) return;
    try {
      cancellingIds.add(appointmentId);
      final id = int.tryParse(appointmentId) ?? 0;
      final response =
          await ApiServices.deleteData(ApiEndpoints.cancelAppointment(id));
      if (response != null &&
          ApiResponse.isSuccessfulHttpStatus(response.statusCode)) {
        // Update in appointments list
        final idx = appointments.indexWhere((a) => a.id == appointmentId);
        if (idx != -1) {
          appointments[idx] = appointments[idx].copyWith(status: 'cancelled');
          appointments.refresh();
        }
        // Update in allAppointments list
        final idx2 = allAppointments.indexWhere((a) => a.id == appointmentId);
        if (idx2 != -1) {
          allAppointments[idx2] =
              allAppointments[idx2].copyWith(status: 'cancelled');
          allAppointments.refresh();
        }
        // Refresh available slots for the affected date
        await fetchAvailableSlots(selectedDate.value);
        Get.snackbar(
          'Cancelled',
          'Appointment cancelled successfully. Time slot is now available.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to cancel appointment. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('[AppointmentController] Error cancelling appointment: $e');
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      cancellingIds.remove(appointmentId);
    }
  }

  Future<void> fetchAvailableSlots(DateTime date) async {
    try {
      isLoadingSlots.value = true;
      availableSlots.clear();

      final dateStr =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      final response = await ApiServices.getData(
        '${ApiEndpoints.availableSlots}?date=$dateStr',
      );

      if (response != null &&
          ApiResponse.isSuccessfulHttpStatus(response.statusCode) &&
          response.data != null) {
        
        List dataList = [];
        if (response.data is List) {
          dataList = response.data as List;
        } else if (response.data is Map) {
          if (response.data.containsKey('available_slots')) {
            dataList = response.data['available_slots'] as List;
          } else if (response.data.containsKey('data') && response.data['data'] is List) {
            dataList = response.data['data'] as List;
          }
        }

        availableSlots.value = dataList
            .map((e) => AvailableSlotModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      debugPrint('[AppointmentController] Error fetching slots: $e');
    } finally {
      isLoadingSlots.value = false;
    }
  }
}
