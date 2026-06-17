import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';

class RatingBreakdown extends StatelessWidget {
  final double averageRating;
  final int totalRatings;
  final Map<int, int> ratingBreakdown;

  const RatingBreakdown({
    Key? key,
    required this.averageRating,
    required this.totalRatings,
    required this.ratingBreakdown,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Average Rating Section
        Column(
          children: [
            Text(
              averageRating.toStringAsFixed(1),
              style: AppTextStyle.headlineLarge.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
                fontSize: 48.sp,
              ),
            ),
            Text(
              '$totalRatings ratings',
              style: AppTextStyle.bodySmall.copyWith(
                color: Colors.grey.shade600,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),

        SizedBox(width: 30.w),

        // Rating Bars
        Expanded(
          child: Column(
            children: List.generate(5, (index) {
              final stars = 5 - index;
              final count = ratingBreakdown[stars] ?? 0;
              final total = ratingBreakdown.values.reduce((a, b) => a + b);
              final percentage = total > 0 ? count / total : 0.0;

              return Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Row(
                  children: [
                    // Stars
                    Row(
                      children: List.generate(
                        5,
                        (starIndex) => Icon(
                          Icons.star,
                          size: 14.sp,
                          color: starIndex < stars
                              ? Colors.amber
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),

                    SizedBox(width: 10.w),

                    // Progress Bar
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFFF6B9D),
                          ),
                          minHeight: 6.h,
                        ),
                      ),
                    ),

                    SizedBox(width: 10.w),

                    // Count
                    SizedBox(
                      width: 12.w,
                      child: Text(
                        stars.toString(),
                        style: AppTextStyle.bodySmall.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
