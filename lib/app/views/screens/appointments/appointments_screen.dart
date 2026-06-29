import 'package:color_os/app/views/screens/appointments/create_appointment_screen.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:color_os/app/controllers/appointment_controller.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';
import 'package:color_os/app/views/screens/appointments/widgets/appointment_card.dart';
import 'package:color_os/app/views/screens/appointments/widgets/appointment_details_sheet.dart';
import 'package:color_os/app/views/screens/appointments/widgets/month_selector.dart';
import 'package:color_os/app/views/screens/appointments/widgets/week_calendar.dart';
import 'package:color_os/app/controllers/auth_controller.dart';
import 'package:color_os/app/controllers/working_hours_controller.dart';
import 'package:color_os/app/views/screens/onboarding/working_hours_setup_sheet.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AppointmentController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const SizedBox(),
        title: Text(
          'Appointments',
          style: AppTextStyle.headlineSmall.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _handleCreateAppointmentNavigation(context);
            },
            icon: Icon(Icons.add, color: Colors.black87, size: 28.sp),
          ),
        ],
      ),
      body: Column(
        children: [
          // Month selector
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Obx(
                () => MonthSelector(
                  monthName: controller.monthName,
                  onTap: () {
                    // Handle month selection
                    _showMonthPicker(context, controller);
                  },
                ),
              ),
            ),
          ),

          // Week calendar
          SizedBox(
            height: 100.h,
            child: PageView.builder(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              itemBuilder: (context, index) {
                return Obx(
                  () => WeekCalendar(
                    weekDays: controller.getWeekDaysForPage(index),
                    selectedDate: controller.selectedDate.value,
                    onDateSelected: controller.selectDate,
                    getDayName: controller.getDayName,
                  ),
                );
              },
            ),
          ),

          // Working hours summary row
          Obx(() => _WorkingHoursRow(controller: controller)),

          // Divider
          Divider(height: 1, thickness: 1, color: Colors.grey.shade200),

          // Available Slots section
          Obx(() {
            if (controller.isLoadingSlots.value || controller.availableSlots.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  child: Text('Available Slots', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  height: 40.h,
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.availableSlots.length,
                    separatorBuilder: (_, __) => SizedBox(width: 10.w),
                    itemBuilder: (context, index) {
                      final slot = controller.availableSlots[index];
                      if (!slot.isAvailable) return const SizedBox.shrink();
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          slot.timeSlot.substring(0, 5),
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 12.h),
                Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
              ],
            );
          }),

          // Appointments timeline
          Expanded(
            child: Obx(() {
              if (controller.isLoadingAppointments.value) {
                return const Center(child: CircularProgressIndicator());
              }

              // Off day: show message instead of timeline
              if (controller.isSelectedDateOff) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 64.sp,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'This day is off',
                        style: AppTextStyle.bodyLarge.copyWith(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'No appointments scheduled on off days',
                        style: AppTextStyle.bodyMedium.copyWith(
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final appointments = controller.appointmentsForSelectedDate;

              return _buildTimeline(controller, appointments);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(AppointmentController controller, List appointments) {
    final slots = controller.availableSlots;

    // If no slot data yet, fall back to a simple message
    if (slots.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Text(
            'No slot data available for this day.',
            style: AppTextStyle.bodyMedium.copyWith(color: Colors.grey.shade400),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        // e.g. "09:15" → hour=9, minute=15
        final parts = slot.timeSlot.split(':');
        final slotHour = int.tryParse(parts[0]) ?? 0;
        final slotMinute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

        // Show the hour label only on the first slot of each hour
        final showHourLabel = slotMinute == 0;

        // Find an appointment starting at exactly this slot
        final matchingAppt = appointments.cast<dynamic>().where((a) {
          return a.dateTime.hour == slotHour && a.dateTime.minute == slotMinute;
        }).toList();

        // Determine if slot is booked (not available) and has a matching appointment
        final isBooked = !slot.isAvailable;

        return _buildSlotRow(
          controller: controller,
          slotLabel: slot.timeSlot,
          showHourLabel: showHourLabel,
          isAvailable: slot.isAvailable,
          isBooked: isBooked,
          matchingAppts: matchingAppt,
        );
      },
    );
  }

  Widget _buildSlotRow({
    required AppointmentController controller,
    required String slotLabel,
    required bool showHourLabel,
    required bool isAvailable,
    required bool isBooked,
    required List matchingAppts,
  }) {
    // Format label: "09:00" → "9:00 AM" or "9:15"
    final parts = slotLabel.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts.length > 1 ? parts[1] : '00';
    final period = h >= 12 ? 'PM' : 'AM';
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    
    String formattedLabel = '';
    if (showHourLabel) {
      formattedLabel = '$h12:00 $period';
    } else {
      formattedLabel = '$h12:$m';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Time label column — fixed width
          SizedBox(
            width: 70.w,
            child: Text(
              formattedLabel,
              style: AppTextStyle.bodySmall.copyWith(
                color: showHourLabel ? Colors.black54 : Colors.grey.shade400,
                fontWeight: showHourLabel ? FontWeight.w500 : FontWeight.w400,
                fontSize: showHourLabel ? 12.sp : 10.sp,
              ),
            ),
          ),

          SizedBox(width: 8.w),

          // Slot content
          Expanded(
            child: matchingAppts.isNotEmpty
                ? Column(
                    children: matchingAppts
                        .map(
                          (appointment) => AppointmentCard(
                            appointment: appointment,
                            onTap: () {
                              Get.bottomSheet(
                                AppointmentDetailsSheet(
                                  appointment: appointment,
                                ),
                                isScrollControlled: true,
                              );
                            },
                          ),
                        )
                        .toList(),
                  )
                : isAvailable
                    ? Container(
                        height: 28.h,
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                              color: Colors.green.shade100, width: 0.8),
                        ),
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: 10.w),
                        child: Text(
                          'Available',
                          style: AppTextStyle.bodySmall.copyWith(
                            color: Colors.green.shade600,
                            fontWeight: FontWeight.w400,
                            fontSize: 11.sp,
                          ),
                        ),
                      )
                    : Container(
                        height: 28.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                              color: Colors.grey.shade200, width: 0.8),
                        ),
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: 10.w),
                        child: Text(
                          'Booked',
                          style: AppTextStyle.bodySmall.copyWith(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w400,
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _showMonthPicker(
    BuildContext context,
    AppointmentController controller,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.w),
          height: 400.h,
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 20.h),

              // Title
              Text(
                'Select Month',
                style: AppTextStyle.titleLarge.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 20.h),

              // Month grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12.h,
                    crossAxisSpacing: 12.w,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
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

                    final isSelected =
                        controller.selectedMonth.value.month == index + 1;

                    return GestureDetector(
                      onTap: () {
                        controller.selectedMonth.value = DateTime(
                          controller.selectedMonth.value.year,
                          index + 1,
                        );
                        controller.selectedDate.value = DateTime(
                          controller.selectedMonth.value.year,
                          index + 1,
                          1,
                        );
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFF6B9D)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Center(
                          child: Text(
                            months[index],
                            style: AppTextStyle.bodyMedium.copyWith(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _WorkingHoursRow({required AppointmentController controller}) {
    if (controller.isLoadingWorkingHours.value) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Row(
          children: [
            SizedBox(
              width: 14.w,
              height: 14.w,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: Colors.grey.shade400,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'Loading working hours…',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    final wh = controller.workingHours.value;
    final authController = Get.find<AuthController>();
    final user = authController.user.value;
    final isStaff = user?.isStaff == true;

    // Treat as locked if backend says so, OR if working_days is already
    // populated (backend bug: is_locked stays false even after setup).
    final hasWorkingDays = wh != null && wh.workingDays.any((d) => !d.isOff || d.startTime != null);
    final effectivelyLocked = wh != null && (wh.isLocked || hasWorkingDays);

    // Not set yet — show a setup prompt banner
    if (wh == null || !effectivelyLocked) {
      if (isStaff) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline,
                  size: 18.sp, color: Colors.grey.shade600),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'Working hours have not been set by the owner yet.',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return GestureDetector(
        onTap: () => Get.to(() => const WorkingHoursSetupSheet()),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 18.sp, color: Colors.orange.shade700),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'Working hours not set. Tap to complete setup.',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.chevron_right,
                  size: 18.sp, color: Colors.orange.shade600),
            ],
          ),
        ),
      );
    }

    // Working hours are set — show the summary row
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          // Clock + hours
          Icon(Icons.access_time_rounded,
              size: 16.sp, color: AppColors.primaryColor),
          SizedBox(width: 6.w),
          Text(
            controller.formattedWorkingHours,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _handleCreateAppointmentNavigation(BuildContext context) {
    final authController = Get.find<AuthController>();
    final user = authController.user.value;
    final isOwnerOrSelf =
        user?.isSalonOwner == true || user?.isSelfEmployed == true;

    // Only owners and self-employed need working hours check
    if (isOwnerOrSelf) {
      // Primary check: use AppointmentController's already-fetched working hours
      final appointmentController = Get.find<AppointmentController>();
      final wh = appointmentController.workingHours.value;
      if (wh != null) {
        final hasWorkingDays = wh.workingDays.any((d) => !d.isOff || d.startTime != null);
        final effectivelyLocked = wh.isLocked || hasWorkingDays;
        if (!effectivelyLocked) {
          showSetupRequiredDialog(context);
          return;
        }
        // Working hours are set — navigate
        Get.to(() => const CreateAppointmentScreen());
        return;
      }

      // Secondary check: WorkingHoursController if registered
      if (Get.isRegistered<WorkingHoursController>()) {
        final workingHoursController = Get.find<WorkingHoursController>();
        if (!workingHoursController.isLocked.value) {
          showSetupRequiredDialog(context);
          return;
        }
      }
      // If still loading or no data yet, allow navigation (controller will handle it)
    }

    Get.to(() => const CreateAppointmentScreen());
  }
}
