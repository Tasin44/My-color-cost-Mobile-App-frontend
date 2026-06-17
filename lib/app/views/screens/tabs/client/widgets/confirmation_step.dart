import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ConfirmationStep extends StatelessWidget {
  final String name;
  final String? phone;
  final String? email;

  const ConfirmationStep({
    super.key,
    required this.name,
    this.phone,
    this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 40.h),
        // Success Icon
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(Icons.check, color: Colors.white, size: 30.sp),
            ),
          ),
        ),
        SizedBox(height: 24.h),
        // Title
        Text(
          'Client Added Successfully!',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 32.h),

        // Client Info Card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Client Details',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 16.h),
              _buildInfoRow(Icons.person_outline, 'Name', name),
              if (phone != null && phone!.isNotEmpty) ...[
                Divider(height: 24.h, color: Colors.grey[200]),
                _buildInfoRow(Icons.phone_outlined, 'Phone', phone!),
              ],
              if (email != null && email!.isNotEmpty) ...[
                Divider(height: 24.h, color: Colors.grey[200]),
                _buildInfoRow(Icons.email_outlined, 'Email', email!),
              ],
            ],
          ),
        ),
        SizedBox(height: 40.h),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey[100]!),
          ),
          child: Icon(icon, color: AppColors.primaryColor, size: 18.sp),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: Colors.black,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
