import 'package:color_os/app/controllers/auth_controller.dart';
import 'package:color_os/app/core/constant/api_endpoints.dart';
import 'package:color_os/app/core/services/api_services.dart';
import 'package:color_os/app/models/working_hours_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WorkingHoursController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final Rx<WorkingHoursModel?> workingHours = Rx<WorkingHoursModel?>(null);
  final RxBool isLocked = false.obs;

  // Local per-day state: list of 7 days (0=Monday...6=Sunday)
  final RxList<WorkingDayModel> days = <WorkingDayModel>[].obs;

  /// Whether the current user can edit working hours
  /// Only owner and self_employed roles can edit. Staff is read-only.
  bool get canEdit {
    try {
      final user = Get.find<AuthController>().user.value;
      if (user == null) return false;
      return user.isSalonOwner || user.isSelfEmployed;
    } catch (_) {
      return false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initDefaultDays();
    fetchWorkingHours();
  }

  void _initDefaultDays() {
    days.value = List.generate(7, (i) => WorkingDayModel.defaultDay(i));
  }

  Future<void> fetchWorkingHours() async {
    try {
      isLoading.value = true;
      final response =
          await ApiServices.getData(ApiEndpoints.workingHoursSetup);

      if (response != null && response.success && response.data != null) {
        final model = WorkingHoursModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        workingHours.value = model;
        // Treat as locked if backend says so, OR if working_days is already
        // populated (backend bug: is_locked stays false even after setup).
        final hasWorkingDays = model.workingDays.isNotEmpty;
        isLocked.value = model.isLocked || hasWorkingDays;
        // Populate the local days list from the fetched data
        days.value = List.from(model.workingDays);
      }
    } catch (e) {
      debugPrint('[WorkingHoursController] Error fetching: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleDay(int weekday) {
    if (!canEdit) return; // Staff cannot edit
    final idx = days.indexWhere((d) => d.weekday == weekday);
    if (idx == -1) return;
    final day = days[idx];
    day.isOff = !day.isOff;
    // If turning ON, set default times if null
    if (!day.isOff) {
      day.startTime ??= '09:00:00';
      day.endTime ??= '18:00:00';
    }
    days.refresh();
  }

  void updateDayTime(int weekday, String startTime, String endTime) {
    if (!canEdit) return; // Staff cannot edit
    final idx = days.indexWhere((d) => d.weekday == weekday);
    if (idx == -1) return;
    days[idx].startTime = startTime;
    days[idx].endTime = endTime;
    days.refresh();
  }

  Future<bool> saveWorkingHours() async {
    if (!canEdit) {
      Get.snackbar(
        'Access Denied',
        'Only owners and self-employed users can edit working hours.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return false;
    }

    try {
      isSaving.value = true;

      final List<Map<String, dynamic>> payload = days.map((day) {
        if (day.isOff) {
          return <String, dynamic>{'weekday': day.weekday, 'is_off': true};
        } else {
          return <String, dynamic>{
            'weekday': day.weekday,
            'start_time': _formatTime(day.startTime ?? '09:00:00'),
            'end_time': _formatTime(day.endTime ?? '18:00:00'),
            'is_off': false,
          };
        }
      }).toList();

      final data = {'days': payload};

      // Use POST when is_locked = false (working hours never set up before)
      // Use PATCH when is_locked = true (already set up, user is editing)
      final response = isLocked.value
          ? await ApiServices.updateData(ApiEndpoints.workingHoursSetup, data)
          : await ApiServices.postData(ApiEndpoints.workingHoursSetup, data);

      if (response != null && response.success) {
        // Mark as locked immediately — don't wait for the GET to confirm,
        // because the backend sometimes doesn't persist is_locked=true.
        isLocked.value = true;
        // Refresh to get the latest state from the server
        await fetchWorkingHours();
        return true;
      } else {
        Get.snackbar(
          'Error',
          response?.message ?? 'Failed to save working hours',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      debugPrint('[WorkingHoursController] Error saving: $e');
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // Format HH:MM:SS or HH:MM → HH:MM (API expects HH:MM)
  String _formatTime(String time) {
    final parts = time.split(':');
    if (parts.length >= 2) {
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
    }
    return time;
  }

  // Legacy method aliases for backward compatibility
  Future<void> fetchWorkingHoursStatus() => fetchWorkingHours();
  Future<void> submitWorkingHours() => saveWorkingHours();
}
