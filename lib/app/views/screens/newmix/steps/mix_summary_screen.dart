import 'package:color_os/app/controllers/new_mix_controller.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/views/screens/newmix/product_list_screen.dart';
import 'package:color_os/app/views/screens/newmix/widgets/step_progress_header.dart';
import 'package:color_os/app/views/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MixSummaryScreen extends GetView<NewMixController> {
  const MixSummaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Mix Summary',
          style: AppTextStyle.titleLarge.copyWith(color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress Header
            const StepProgressHeader(
              currentStep: 3,
              totalSteps: 4,
              title: 'Review Items',
            ),

            // Header
            Text(
              'Your Mix Details',
              style: AppTextStyle.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20.h),

            // List of Items
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Obx(() {
                if (controller.mixItems.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No items added',
                      style: TextStyle(color: Colors.black54),
                    ),
                  );
                }
                return Column(
                  children: controller.mixItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Column(
                      children: [
                        ListTile(
                          title: Text(
                            item.bowlName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          trailing: Text(
                            '${item.grams}g',
                            style: const TextStyle(color: Colors.black87),
                          ),
                          subtitle: Text(
                            '\$${item.cost.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                        if (index < controller.mixItems.length - 1)
                          const Divider(height: 1),
                      ],
                    );
                  }).toList(),
                );
              }),
            ),

            SizedBox(height: 30.h),

            // Total Cost Section
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Cost',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      '\$${controller.totalMixCost.value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Add another product to the same bowl
            OutlinedButton.icon(
              onPressed: () {
                // Flag tells addGramsToCurrentBowl to pop back here instead
                // of pushing a new summary screen (avoids a growing stack).
                controller.isAddingToExistingBowl.value = true;
                controller.fetchInventory();
                Get.to(() => const ProductListScreen());
              },
              icon: Icon(
                Icons.add_circle_outline,
                color: AppColors.primaryColor,
                size: 20.sp,
              ),
              label: Text(
                'Add Another Product to Bowl',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 15.sp,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                side: BorderSide(color: AppColors.primaryColor, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // Continue to pricing once all products are in the bowl
            PrimaryButton(
              text: 'Bowl Complete — Set Charge',
              onPressed: () {
                controller.continueToPricing();
              },
              height: 56.h,
              borderRadius: 12,
            ),
          ],
        ),
      ),
    );
  }
}
