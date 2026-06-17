import 'package:color_os/app/views/screens/onboarding/working_hours_setup_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:color_os/app/core/constant/api_endpoints.dart';
import 'package:color_os/app/core/services/api_services.dart';
import 'package:color_os/app/models/api_response.dart';
import 'package:color_os/app/models/appointment_model.dart';
import 'package:color_os/app/models/working_hours_model.dart';

class AppointmentController extends GetxController {
  // Observable variables
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<DateTime> selectedMonth = DateTime.now().obs;
  final RxList<AppointmentModel> appointments = <AppointmentModel>[].obs;
  final Rx<WorkingHoursModel?> workingHours = Rx<WorkingHoursModel?>(null);
  final RxBool isLoadingWorkingHours = false.obs;
  final RxBool isLoadingAppointments = false.obs;

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
  }

  // Get appointments for selected date
  List<AppointmentModel> get appointmentsForSelectedDate {
    return appointments.where((appointment) {
      return appointment.dateTime.year == selectedDate.value.year &&
          appointment.dateTime.month == selectedDate.value.month &&
          appointment.dateTime.day == selectedDate.value.day;
    }).toList()..sort((a, b) => a.dateTime.compareTo(b.dateTime));
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
    if (hour == 0 || hour == 12) {
      return '12 ${hour < 12 ? 'Am' : 'Pm'}';
    }
    return '${hour % 12} ${hour < 12 ? 'Am' : 'Pm'}';
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

        // If working hours have not been set yet, force the user to complete setup.
        // WorkingHoursSetupSheet has canPop: false so it cannot be dismissed.
        if (!wh.isLocked) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.to(() => const WorkingHoursSetupSheet());
          });
        }
      }
    } catch (e) {
      debugPrint('[AppointmentController] Error fetching working hours: $e');
    } finally {
      isLoadingWorkingHours.value = false;
    }
  }

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

      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      debugPrint('[AppointmentController] Fetching appointments for $dateStr');

      final response = await ApiServices.getData(
        '${ApiEndpoints.appointmentList}?date=$dateStr',
      );

      debugPrint(
        '[AppointmentController] Response: statusCode=${response?.statusCode} '
        'data=${response?.data}',
      );

      if (response != null &&
          ApiResponse.isSuccessfulHttpStatus(response.statusCode) &&
          response.data != null) {
        // ApiResponse already unwraps json['data'], so response.data =
        // { "appointments": [...], "total_count": N }
        final rawData = response.data;
        List? items;

        if (rawData is List) {
          // Flat list (legacy shape)
          items = rawData;
        } else if (rawData is Map) {
          // Current API shape: { "appointments": [...], "total_count": N }
          if (rawData['appointments'] is List) {
            items = rawData['appointments'] as List;
          } else if (rawData['data'] is List) {
            // Fallback for any other wrapper
            items = rawData['data'] as List;
          }
        }

        if (items != null) {
          appointments.value = items
              .whereType<Map<String, dynamic>>()
              .map(AppointmentModel.fromJson)
              .toList();
          debugPrint(
            '[AppointmentController] Loaded ${appointments.length} appointments for $dateStr',
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
}
