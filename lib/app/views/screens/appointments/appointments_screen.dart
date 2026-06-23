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

          // Appointments timeline
          Expanded(
            child: Obx(() {
              if (controller.isLoadingAppointments.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final appointments = controller.appointmentsForSelectedDate;

              if (appointments.isEmpty) {
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
                        'No appointments for this day',
                        style: AppTextStyle.bodyLarge.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return _buildTimeline(controller, appointments);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(AppointmentController controller, List appointments) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      itemCount: 24, // 24 hours
      itemBuilder: (context, index) {
        final hour = index;
        final hourAppointments = appointments.where((appointment) {
          return appointment.dateTime.hour == hour;
        }).toList();

        return _buildTimeSlot(
          controller: controller,
          hour: hour,
          appointments: hourAppointments,
        );
      },
    );
  }

  Widget _buildTimeSlot({
    required AppointmentController controller,
    required int hour,
    required List appointments,
  }) {
    final isEnabled = controller.isTimeSlotEnabled(hour);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time label
          SizedBox(
            width: 70.w,
            child: Text(
              controller.getHourLabel(hour),
              style: AppTextStyle.bodyMedium.copyWith(
                color: isEnabled ? Colors.black54 : Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          SizedBox(width: 16.w),

          // Appointments or empty space
          Expanded(
            child: appointments.isEmpty
                ? Container(
                    height: 60.h,
                    decoration: !isEnabled
                        ? BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: Colors.grey.shade200),
                          )
                        : null,
                    alignment: Alignment.centerLeft,
                    padding: !isEnabled ? EdgeInsets.only(left: 16.w) : null,
                    child: !isEnabled
                        ? Text(
                            'Off',
                            style: AppTextStyle.bodySmall.copyWith(
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : null,
                  )
                : Column(
                    children: appointments
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

          // Divider
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Container(
              width: 1,
              height: 14.h,
              color: Colors.grey.shade300,
            ),
          ),

          // Off days
          Icon(Icons.event_busy_outlined,
              size: 14.sp, color: Colors.grey.shade500),
          SizedBox(width: 4.w),
          Text(
            'Off: ${controller.offDaysText}',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade600,
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
      if (!Get.isRegistered<WorkingHoursController>()) {
        Get.to(() => const CreateAppointmentScreen());
        return;
      }

      final workingHoursController = Get.find<WorkingHoursController>();
      if (!workingHoursController.isLocked.value) {
        showSetupRequiredDialog(context);
        return;
      }
    }

    Get.to(() => const CreateAppointmentScreen());
  }
}
