import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/controllers/new_mix_controller.dart';
import 'package:color_os/app/views/widgets/primary_button.dart';

class BowlPriceBottomSheet extends StatefulWidget {
  final BowlProduct bowl;

  const BowlPriceBottomSheet({Key? key, required this.bowl}) : super(key: key);

  @override
  State<BowlPriceBottomSheet> createState() => _BowlPriceBottomSheetState();
}

class _BowlPriceBottomSheetState extends State<BowlPriceBottomSheet> {
  final TextEditingController marketPriceController = TextEditingController();
  final TextEditingController costController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set default values
    marketPriceController.text = '5.00';
    costController.text = '5.00';
  }

  @override
  void dispose() {
    marketPriceController.dispose();
    costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),

            // Title
            Text(
              '1st Bowl Price',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20.h),

            // Bowl Info Card
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Color(0xFFFFF0F6),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  // Bowl Icon
                  Container(
                    width: 50.w,
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.water_drop,
                      color: AppColors.primaryColor,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Bowl Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.bowl.name,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Bowl 1',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Market Price Field
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Market Price 100g',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: marketPriceController,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 15.sp, color: Colors.black87),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                prefixText: '£',
                prefixStyle: TextStyle(fontSize: 15.sp, color: Colors.black87),
                suffixIcon: Icon(
                  Icons.lock_outline,
                  color: Colors.grey[400],
                  size: 20.sp,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: AppColors.primaryColor,
                    width: 1.5,
                  ),
                ),
              ),
            ),

            SizedBox(height: 18.h),

            // Your Cost Field
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Your Cost per 100g',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: costController,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 15.sp, color: Colors.black87),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixText: '£',
                prefixStyle: TextStyle(fontSize: 15.sp, color: Colors.black87),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: AppColors.primaryColor,
                    width: 1.5,
                  ),
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Continue Button
            PrimaryButton(
              text: 'Continue',
              onPressed: () {
                final marketPrice =
                    double.tryParse(marketPriceController.text) ?? 5.0;
                final cost = double.tryParse(costController.text) ?? 5.0;

                Get.back();
                // Navigate to step 2
                final controller = Get.find<NewMixController>();
                controller.startNewMix(widget.bowl, marketPrice, cost);
              },
              height: 50.h,
              borderRadius: 12,
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
