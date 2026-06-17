import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:color_os/app/controllers/shop_controller.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';

class ShopFilterBottomSheet extends StatelessWidget {
  final ShopController controller;

  const ShopFilterBottomSheet({Key? key, required this.controller})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: AppTextStyle.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp,
                  color: Colors.black,
                ),
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close, color: Colors.black),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Sort By Section
          Text(
            'Sort By',
            style: AppTextStyle.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12.h),
          Obx(
            () => Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: [
                _buildSortOption('rating', 'Highest Rated'),
                _buildSortOption('price_asc', 'Price: Low to High'),
                _buildSortOption('price_desc', 'Price: High to Low'),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Availability Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Only',
                style: AppTextStyle.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                  color: Colors.black,
                ),
              ),
              Obx(
                () => Switch(
                  value: controller.isAvailableOnly.value,
                  onChanged: (val) => controller.isAvailableOnly.value = val,
                  activeColor: AppColors.primaryColor,
                ),
              ),
            ],
          ),

          SizedBox(height: 32.h),

          // Apply Button
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: () {
                Get.back();
                controller.applyFilters();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Apply Filters',
                style: AppTextStyle.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildSortOption(String value, String label) {
    final isSelected = controller.selectedSort.value == value;
    return GestureDetector(
      onTap: () => controller.selectedSort.value = value,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyle.bodyMedium.copyWith(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
