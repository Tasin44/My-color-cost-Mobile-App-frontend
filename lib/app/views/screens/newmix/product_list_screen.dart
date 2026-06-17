import 'package:color_os/app/controllers/new_mix_controller.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/views/screens/newmix/add_manual_product_screen.dart';
import 'package:color_os/app/views/screens/newmix/widgets/step_progress_header.dart';
import 'package:color_os/app/views/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ProductListScreen extends GetView<NewMixController> {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Select Product',
          style: AppTextStyle.titleLarge.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        actions: const [],
      ),
      body: Obx(() {
        if (controller.isLoadingInventory.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.inventoryProducts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No products found',
                  style: AppTextStyle.bodyLarge.copyWith(color: Colors.grey),
                ),
                SizedBox(height: 16.h),
                PrimaryButton(
                  text: 'Add Product',
                  onPressed: controller.scanBarcode,
                  width: 150.w,
                  height: 48.h,
                  borderRadius: 12,
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: const StepProgressHeader(
                currentStep: 1,
                totalSteps: 5,
                title: 'Select Product',
              ),
            ),

            // Scan / Manual add row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              child: Row(
                children: [
                  // Scan barcode
                  Expanded(
                    child: InkWell(
                      onTap: () => controller.scanBarcode(),
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.primaryColor.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.qr_code_scanner,
                              color: AppColors.primaryColor,
                              size: 22.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Scan Product',
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  // Add manually
                  Expanded(
                    child: InkWell(
                      onTap: () => Get.to(() => const AddManualProductScreen()),
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_box_outlined,
                              color: Colors.grey.shade700,
                              size: 22.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Add Manually',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.all(16.w),
                itemCount: controller.inventoryProducts.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final product = controller.inventoryProducts[index];
                  final weight =
                      double.tryParse(product.currentWeightGrams) ?? 0.0;
                  final isAvailable = weight > 0;

                  return InkWell(
                    onTap: isAvailable
                        ? () {
                            controller.openAddToBowlSheet(product);
                          }
                        : null,
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: isAvailable ? Colors.white : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: isAvailable
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        children: [
                          // Product Image
                          Opacity(
                            opacity: isAvailable ? 1.0 : 0.5,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: Container(
                                width: 60.w,
                                height: 60.w,
                                color: Colors.grey.shade100,
                                child: product.productImage != null
                                    ? Image.network(
                                        product.productImage!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey.shade400,
                                        ),
                                      )
                                    : Icon(
                                        Icons.inventory_2_outlined,
                                        color: Colors.grey.shade400,
                                      ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          // Product Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.productName,
                                  style: AppTextStyle.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isAvailable
                                        ? Colors.black87
                                        : Colors.grey,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4.h),
                                Row(
                                  children: [
                                    Text(
                                      isAvailable
                                          ? '${product.currentWeightGrams}g left'
                                          : 'Out of Stock (${product.currentWeightGrams}g)',
                                      style: AppTextStyle.bodySmall.copyWith(
                                        color: isAvailable
                                            ? Colors.grey.shade600
                                            : Colors.red.shade300,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '\$${product.userPrice ?? product.marketPrice ?? '0.00'}',
                                      style: AppTextStyle.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: isAvailable
                                            ? AppColors.primaryColor
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
