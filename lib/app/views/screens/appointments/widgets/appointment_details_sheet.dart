import 'package:color_os/app/core/constant/app_textstyle.dart';
import 'package:color_os/app/models/appointment_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AppointmentDetailsSheet extends StatelessWidget {
  final AppointmentModel appointment;

  const AppointmentDetailsSheet({Key? key, required this.appointment})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Header handle
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // Header with Client Info
          Row(
            children: [
              Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                  image: appointment.clientImage != null
                      ? DecorationImage(
                          image: NetworkImage(appointment.clientImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: appointment.clientImage == null
                    ? Icon(
                        Icons.person,
                        size: 30.sp,
                        color: Colors.grey.shade400,
                      )
                    : null,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.clientName,
                      style: AppTextStyle.headlineSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87, // Fix theme issue
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      appointment.clientContact.isNotEmpty
                          ? appointment.clientContact
                          : 'No contact info',
                      style: AppTextStyle.bodyMedium.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: appointment.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: appointment.color),
                ),
                child: Text(
                  appointment.status.toUpperCase(),
                  style: AppTextStyle.bodySmall.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Divider(color: Colors.grey.shade200),
          SizedBox(height: 24.h),

          // Appointment Details
          _buildDetailRow(
            icon: Icons.calendar_today,
            label: 'Date',
            value:
                '${appointment.dateTime.day}/${appointment.dateTime.month}/${appointment.dateTime.year}',
          ),
          SizedBox(height: 16.h),
          _buildDetailRow(
            icon: Icons.access_time,
            label: 'Time',
            value: appointment.time,
          ),
          SizedBox(height: 16.h),
          _buildDetailRow(
            icon: Icons.cut,
            label: 'Service',
            value: appointment.serviceType,
          ),

          if (appointment.bookingInfo.isNotEmpty &&
              appointment.bookingInfo != appointment.serviceType) ...[
            SizedBox(height: 16.h),
            _buildDetailRow(
              icon: Icons.info_outline,
              label: 'Details',
              value: appointment.bookingInfo,
            ),
          ],

          SizedBox(height: 32.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Get.back(); // Close sheet
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: AppTextStyle.bodyLarge.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              // Only show Edit if NOT scheduled (as per user request "cant edit scheduled")
              // Or if user meant "I want to edit", we'd enable it.
              // Assuming "restriction" based on phrasing.
              if (appointment.status != 'scheduled') ...[
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to edit or perform other action
                      Get.back();
                      Get.snackbar(
                        'Coming Soon',
                        'Edit functionality not implemented yet',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Edit',
                      style: AppTextStyle.bodyLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 20.h),
        ],
      ),
    ),
  );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: Colors.grey.shade600, size: 20.sp),
        ),
        SizedBox(width: 16.w),
        Expanded(
          // Added Expanded to avoid overflow
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyle.bodySmall.copyWith(
                  color: Colors.grey.shade500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: AppTextStyle.bodyLarge.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
