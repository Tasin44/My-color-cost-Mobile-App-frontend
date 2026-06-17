import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';

class ShopSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onFilterTap;

  const ShopSearchBar({
    Key? key,
    required this.controller,
    required this.onFilterTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey.shade600, size: 22.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: controller,
              style: AppTextStyle.bodyMedium.copyWith(color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Search by name...',
                hintStyle: AppTextStyle.bodyMedium.copyWith(
                  color: Colors.grey.shade500,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14.h),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              padding: EdgeInsets.all(8.w),
              child: Icon(Icons.tune, color: Colors.grey.shade700, size: 22.sp),
            ),
          ),
        ],
      ),
    );
  }
}
