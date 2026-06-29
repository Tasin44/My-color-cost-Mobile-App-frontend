import 'package:color_os/app/controllers/appointment_controller.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/models/appointment_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AllAppointmentsScreen extends StatefulWidget {
  const AllAppointmentsScreen({super.key});

  @override
  State<AllAppointmentsScreen> createState() => _AllAppointmentsScreenState();
}

class _AllAppointmentsScreenState extends State<AllAppointmentsScreen> {
  late final AppointmentController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AppointmentController>();
    _controller.fetchAllAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              size: 18.sp, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'All Appointments',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
      body: Obx(() {
        if (_controller.isLoadingAllAppointments.value) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        final appointments = _controller.allAppointments;

        if (appointments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 64.sp, color: Colors.grey.shade300),
                SizedBox(height: 16.h),
                Text(
                  'No appointments yet',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Appointments you create will appear here',
                  style: TextStyle(
                      fontSize: 13.sp, color: Colors.grey.shade400),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: () => _controller.fetchAllAppointments(),
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            itemCount: appointments.length,
            separatorBuilder: (_, _i) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final appt = appointments[index];
              return _AppointmentListTile(
                appointment: appt,
                controller: _controller,
              );
            },
          ),
        );
      }),
    );
  }
}

class _AppointmentListTile extends StatelessWidget {
  const _AppointmentListTile({
    required this.appointment,
    required this.controller,
  });

  final AppointmentModel appointment;
  final AppointmentController controller;

  @override
  Widget build(BuildContext context) {
    final isCancelled = appointment.status == 'cancelled';
    final statusColor = isCancelled ? Colors.red.shade400 : Colors.green.shade600;
    final statusBg =
        isCancelled ? Colors.red.shade50 : Colors.green.shade50;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date + Status row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 14.sp, color: AppColors.primaryColor),
                    SizedBox(width: 6.w),
                    Text(
                      _formatDate(appointment.dateTime),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Icon(Icons.access_time,
                        size: 14.sp, color: Colors.grey.shade500),
                    SizedBox(width: 4.w),
                    Text(
                      _formatTime(appointment.dateTime),
                      style: TextStyle(
                          fontSize: 13.sp, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    isCancelled ? 'Cancelled' : 'Scheduled',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 10.h),
            Divider(height: 1, color: Colors.grey.shade100),
            SizedBox(height: 10.h),

            // Client name
            Row(
              children: [
                CircleAvatar(
                  radius: 18.r,
                  backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                  child: Icon(Icons.person,
                      color: AppColors.primaryColor, size: 18.sp),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.clientName,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      if (appointment.clientContact.isNotEmpty)
                        Text(
                          appointment.clientContact,
                          style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade500),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 10.h),

            // Service info
            Row(
              children: [
                Icon(Icons.design_services_outlined,
                    size: 14.sp, color: Colors.grey.shade500),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    appointment.serviceType,
                    style: TextStyle(
                        fontSize: 13.sp, color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(Icons.timer_outlined,
                    size: 14.sp, color: Colors.grey.shade500),
                SizedBox(width: 4.w),
                Text(
                  '${appointment.totalDurationMinutes} min',
                  style: TextStyle(
                      fontSize: 12.sp, color: Colors.grey.shade600),
                ),
              ],
            ),

            // Cancel button — only for non-cancelled appointments
            if (!isCancelled) ...[
              SizedBox(height: 12.h),
              Obx(() {
                final isCancelling =
                    controller.cancellingIds.contains(appointment.id);
                return SizedBox(
                  width: double.infinity,
                  height: 40.h,
                  child: OutlinedButton.icon(
                    onPressed: isCancelling
                        ? null
                        : () => _showCancelDialog(context),
                    icon: isCancelling
                        ? SizedBox(
                            width: 14.w,
                            height: 14.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.red.shade400,
                            ),
                          )
                        : Icon(Icons.cancel_outlined,
                            size: 16.sp, color: Colors.red.shade400),
                    label: Text(
                      isCancelling ? 'Cancelling…' : 'Cancel Appointment',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade400,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side:
                          BorderSide(color: Colors.red.shade300, width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Cancel Appointment?',
          style: TextStyle(
              fontSize: 17.sp, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to cancel this appointment for ${appointment.clientName}? The time slot will become available again.',
          style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Keep',
              style: TextStyle(
                  fontSize: 14.sp, color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.cancelAppointment(appointment.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade500,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r)),
              elevation: 0,
            ),
            child: Text(
              'Cancel Appointment',
              style:
                  TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayName = days[dt.weekday - 1];
    return '$dayName, ${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$h12:$m $period';
  }
}
