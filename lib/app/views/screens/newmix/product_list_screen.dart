import 'package:color_os/app/controllers/new_mix_controller.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/views/screens/newmix/add_manual_product_screen.dart';
import 'package:color_os/app/views/screens/newmix/widgets/product_entry_sheet.dart';
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
                Icon(
                  Icons.inventory_2_outlined,
                  size: 60.sp,
                  color: Colors.grey[300],
                ),
                SizedBox(height: 16.h),
                Text(
                  'No products found',
                  style: AppTextStyle.bodyLarge.copyWith(color: Colors.grey),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Scan or add products to get started',
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[400]),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _actionButton(
                      icon: Icons.qr_code_scanner,
                      label: 'Scan',
                      onTap: controller.scanBarcode,
                      isPrimary: true,
                    ),
                    SizedBox(width: 12.w),
                    _actionButton(
                      icon: Icons.add_box_outlined,
                      label: 'Add Manually',
                      onTap: () =>
                          Get.to(() => const AddManualProductScreen()),
                      isPrimary: false,
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Bowl context header
            Obx(() {
              final bowl = controller.currentBowlData;
              final addedCount = bowl?.products.length ?? 0;
              return Container(
                margin:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.15),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.layers_outlined,
                        color: AppColors.primaryColor, size: 20.sp),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        bowl != null
                            ? '${bowl.mixName} — $addedCount product${addedCount != 1 ? 's' : ''} added'
                            : 'Select products for your bowl',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (addedCount > 0)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          '$addedCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),

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
                      onTap: () =>
                          Get.to(() => const AddManualProductScreen()),
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

            // Product list
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
                            // Show the new product entry bottom sheet
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) =>
                                  ProductEntrySheet(product: product),
                            );
                          }
                        : null,
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color:
                            isAvailable ? Colors.white : Colors.grey.shade50,
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
                                          : 'Out of Stock',
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

            // Review Bowl Button (appears when products are added)
            Obx(() {
              final bowl = controller.currentBowlData;
              final addedCount = bowl?.products.length ?? 0;
              if (addedCount == 0) return const SizedBox.shrink();

              return Container(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 54.h,
                  child: ElevatedButton.icon(
                    onPressed: () => controller.reviewCurrentBowl(),
                    icon: const Icon(Icons.checklist, color: Colors.white),
                    label: Text(
                      'Review Bowl ($addedCount products)',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      }),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.primaryColor.withOpacity(0.08)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isPrimary
                ? AppColors.primaryColor.withOpacity(0.2)
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: isPrimary
                    ? AppColors.primaryColor
                    : Colors.grey.shade700,
                size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                color: isPrimary
                    ? AppColors.primaryColor
                    : Colors.grey.shade700,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
