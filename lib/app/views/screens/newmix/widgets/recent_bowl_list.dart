import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';

import 'package:color_os/app/views/screens/newmix/all_recent_bowls_screen.dart';
import 'package:color_os/app/models/mix_model.dart';

class RecentBowlList extends StatelessWidget {
  final List<MixModel> bowls;
  final Function(MixModel) onBowlTap;

  const RecentBowlList({Key? key, required this.bowls, required this.onBowlTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (bowls.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Bowl',
            style: AppTextStyle.titleMedium.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 20.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.history, size: 40.sp, color: Colors.grey.shade400),
                SizedBox(height: 8.h),
                Text(
                  'No recent mixes found',
                  style: AppTextStyle.bodyMedium.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Bowl',
              style: AppTextStyle.titleMedium.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
              ),
            ),
            GestureDetector(
              onTap: () {
                // Navigate to all bowls
                Get.to(() => const AllRecentBowlsScreen());
              },
              child: Text(
                'See all',
                style: AppTextStyle.titleSmall.copyWith(
                  color: const Color(0xFFFF6B9D),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // Bowl items
        ...bowls.map((bowl) => _buildBowlItem(bowl)).toList(),
      ],
    );
  }

  Widget _buildBowlItem(MixModel bowl) {
    return GestureDetector(
      onTap: () => onBowlTap(bowl),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bowl.mixName,
                    style: AppTextStyle.bodyMedium.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    '${bowl.serviceType} • £${bowl.chargedAmount.toStringAsFixed(2)}',
                    style: AppTextStyle.bodySmall.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 22.sp),
          ],
        ),
      ),
    );
  }
}
