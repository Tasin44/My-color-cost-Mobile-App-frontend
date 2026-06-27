import 'package:color_os/app/controllers/working_hours_controller.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/models/working_hours_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:color_os/app/views/screens/main_base_screen.dart';
import 'package:color_os/app/controllers/appointment_controller.dart';

class WorkingHoursSetupSheet extends StatelessWidget {
  final bool isFromSignup;
  const WorkingHoursSetupSheet({super.key, this.isFromSignup = false});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WorkingHoursController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Working Hours',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        actions: [
          if (isFromSignup)
            TextButton(
              onPressed: () => Get.offAll(() => MainBaseScreen()),
              child: Text(
                'Skip',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          // Staff read-only badge
          if (!controller.canEdit)
            Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: Center(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'View Only',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final canEdit = controller.canEdit;

        return Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 4.h),
                  child: Text(
                    'Set Your Availability',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ),

                // Staff notice banner
                if (!canEdit)
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 16.sp, color: Colors.blue.shade700),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'Only the salon owner can edit working hours.',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                        16.w, 8.h, 16.w, canEdit ? 100.h : 20.h),
                    itemCount: controller.days.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final day = controller.days[index];
                      return _DayCard(
                        day: day,
                        controller: controller,
                        canEdit: canEdit,
                      );
                    },
                  ),
                ),
              ],
            ),

            // Floating Save Button — only for owner/self_employed
            if (canEdit)
              Positioned(
                bottom: 24.h,
                left: 24.w,
                right: 24.w,
                child: Obx(
                  () => ElevatedButton.icon(
                    onPressed: controller.isSaving.value
                        ? null
                        : () async {
                            final success = await controller.saveWorkingHours();
                            if (success) {
                              // Refresh AppointmentController's working hours
                              // so the appointments screen updates immediately.
                              try {
                                if (Get.isRegistered<AppointmentController>()) {
                                  await Get.find<AppointmentController>().refreshWorkingHours();
                                }
                              } catch (_) {}
                              if (isFromSignup) {
                                Get.offAll(() => MainBaseScreen());
                              } else {
                                Get.back();
                              }
                              Get.snackbar(
                                'Success',
                                'Working hours saved successfully!',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.green.shade400,
                                colorText: Colors.white,
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      disabledBackgroundColor:
                          AppColors.primaryColor.withOpacity(0.6),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      elevation: 4,
                      shadowColor: AppColors.primaryColor.withOpacity(0.4),
                    ),
                    icon: controller.isSaving.value
                        ? SizedBox(
                            width: 18.w,
                            height: 18.h,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(Icons.save_rounded,
                            color: Colors.white, size: 20.sp),
                    label: Text(
                      controller.isSaving.value ? 'Saving...' : 'Save Changes',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _DayCard extends StatelessWidget {
  final WorkingDayModel day;
  final WorkingHoursController controller;
  final bool canEdit;

  const _DayCard({
    required this.day,
    required this.controller,
    required this.canEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Trigger rebuild when days change
      final _ = controller.days.length;
      final isWorking = !day.isOff;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Day header row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  // Check circle
                  Container(
                    width: 36.w,
                    height: 36.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isWorking
                          ? AppColors.primaryColor.withOpacity(0.15)
                          : Colors.grey.shade100,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 18.sp,
                      color: isWorking
                          ? AppColors.primaryColor
                          : Colors.grey.shade400,
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Day name & status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          day.weekdayName,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          isWorking ? 'Working Day' : 'Day Off',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: isWorking
                                ? AppColors.primaryColor
                                : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Toggle switch — disabled for staff
                  Transform.scale(
                    scale: 0.9,
                    child: Switch(
                      value: isWorking,
                      onChanged: canEdit
                          ? (_) => controller.toggleDay(day.weekday)
                          : null,
                      activeColor: Colors.white,
                      activeTrackColor: AppColors.primaryColor,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
            ),

            // Time pickers row (only visible when working)
            if (isWorking) ...[
              Divider(height: 1, color: Colors.grey.shade100),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                child: Row(
                  children: [
                    // Opens
                    Expanded(
                      child: _TimeBox(
                        label: 'Opens',
                        timeStr: day.startTime ?? '09:00',
                        canEdit: canEdit,
                        onTap: canEdit
                            ? () => _pickTime(
                                  context,
                                  isStart: true,
                                  currentStr: day.startTime ?? '09:00',
                                  day: day,
                                )
                            : null,
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Text(
                        'to',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),

                    // Closes
                    Expanded(
                      child: _TimeBox(
                        label: 'Closes',
                        timeStr: day.endTime ?? '18:00',
                        canEdit: canEdit,
                        onTap: canEdit
                            ? () => _pickTime(
                                  context,
                                  isStart: false,
                                  currentStr: day.endTime ?? '18:00',
                                  day: day,
                                )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Future<void> _pickTime(
    BuildContext context, {
    required bool isStart,
    required String currentStr,
    required WorkingDayModel day,
  }) async {
    final parts = currentStr.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? (isStart ? 9 : 18),
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';
      if (isStart) {
        controller.updateDayTime(
            day.weekday, formatted, day.endTime ?? '18:00:00');
      } else {
        controller.updateDayTime(
            day.weekday, day.startTime ?? '09:00:00', formatted);
      }
    }
  }
}

class _TimeBox extends StatelessWidget {
  final String label;
  final String timeStr;
  final VoidCallback? onTap;
  final bool canEdit;

  const _TimeBox({
    required this.label,
    required this.timeStr,
    required this.canEdit,
    this.onTap,
  });

  String _formatDisplay(String raw) {
    final parts = raw.split(':');
    if (parts.length >= 2) {
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: canEdit ? Colors.grey.shade100 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: canEdit
              ? null
              : Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 14.sp,
                  color: canEdit
                      ? AppColors.primaryColor
                      : Colors.grey.shade400,
                ),
                SizedBox(width: 4.w),
                Text(
                  _formatDisplay(timeStr),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: canEdit ? Colors.black87 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
