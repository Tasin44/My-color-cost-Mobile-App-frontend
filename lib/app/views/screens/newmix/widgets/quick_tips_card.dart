import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';

class QuickTipsCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const QuickTipsCard({
    Key? key,
    this.title = 'Quick Tips',
    this.description =
        'Use the barcode scanner for faster product selection. Make sure the barcode is clearly visible.',
    this.icon = Icons.lightbulb_outline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFC8DD).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFFFC8DD), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B9D),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Icon(icon, color: Colors.white, size: 22.sp),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyle.titleSmall.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  description,
                  style: AppTextStyle.bodySmall.copyWith(
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
