import 'package:color_os/app/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class TodayAppointments extends StatelessWidget {
  const TodayAppointments({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today Appointments',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 16.h),
        Obx(() => _buildAppointmentsList(controller)),
      ],
    );
  }

  Widget _buildAppointmentsList(HomeController controller) {
    final appointments = controller.todayAppointments;

    if (appointments.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.h),
          child: Text(
            'No appointments today',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
          ),
        ),
      );
    }

    return Column(
      children: appointments.map((appointment) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _buildAppointmentCard(
            time: appointment.time,
            booking: appointment.bookingInfo,
            color: appointment.color,
            clientImages: appointment.clientImages,
            additionalClients: appointment.additionalClients,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAppointmentCard({
    required String time,
    required String booking,
    required Color color,
    required List<String> clientImages,
    required int additionalClients,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time column
        SizedBox(
          width: 50.w,
          child: Text(
            time,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        // Appointment card
        Expanded(
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                // Client images stack
                _buildClientAvatars(clientImages, additionalClients),
                SizedBox(width: 8.w),
                // Appointment details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Client appointment',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.black54,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClientAvatars(List<String> images, int additionalCount) {
    final displayImages = images.take(3).toList();

    return SizedBox(
      width: 60.w,
      height: 24.h,
      child: Stack(
        children: [
          ...displayImages.asMap().entries.map((entry) {
            return Positioned(
              left: (entry.key * 12.0).w,
              child: _buildAvatar(entry.value),
            );
          }).toList(),
          if (additionalCount > 0)
            Positioned(
              left: 36.w,
              child: _buildCountBadge('+$additionalCount'),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String imageUrl) {
    return Container(
      width: 24.w,
      height: 24.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        color: Colors.grey[300],
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildCountBadge(String count) {
    return Container(
      width: 24.w,
      height: 24.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[700],
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Center(
        child: Text(
          count,
          style: TextStyle(
            fontSize: 9.sp,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
