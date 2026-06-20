import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/controllers/new_mix_controller.dart';
import 'package:color_os/app/models/inventory_product_model.dart';

/// Bottom sheet for entering market_price, user_price, and used_weight
/// when adding a product to the current bowl.
class ProductEntrySheet extends StatefulWidget {
  final InventoryProduct product;

  const ProductEntrySheet({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductEntrySheet> createState() => _ProductEntrySheetState();
}

class _ProductEntrySheetState extends State<ProductEntrySheet> {
  late TextEditingController marketPriceCtrl;
  late TextEditingController userPriceCtrl;
  late TextEditingController usedWeightCtrl;

  @override
  void initState() {
    super.initState();
    marketPriceCtrl =
        TextEditingController(text: widget.product.marketPrice ?? '');
    userPriceCtrl =
        TextEditingController(text: widget.product.userPrice ?? '');
    usedWeightCtrl = TextEditingController();
  }

  @override
  void dispose() {
    marketPriceCtrl.dispose();
    userPriceCtrl.dispose();
    usedWeightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final available =
        double.tryParse(widget.product.currentWeightGrams) ?? 0.0;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          top: 16.h,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Product header
            Row(
              children: [
                // Product image
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    width: 55.w,
                    height: 55.w,
                    color: Colors.grey.shade100,
                    child: widget.product.productImage != null
                        ? Image.network(
                            widget.product.productImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.inventory_2_outlined,
                              color: Colors.grey.shade400,
                            ),
                          )
                        : Icon(
                            Icons.inventory_2_outlined,
                            color: Colors.grey.shade400,
                            size: 28.sp,
                          ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.productName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Available: ${available.toStringAsFixed(1)}g',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // Market Price
            _buildLabel('Market Price'),
            SizedBox(height: 6.h),
            _buildPriceField(
              controller: marketPriceCtrl,
              hint: 'Enter market price',
              icon: Icons.storefront_outlined,
            ),

            SizedBox(height: 16.h),

            // User Price
            _buildLabel('User Price (Your Cost)'),
            SizedBox(height: 6.h),
            _buildPriceField(
              controller: userPriceCtrl,
              hint: 'Enter your price',
              icon: Icons.attach_money,
            ),

            SizedBox(height: 16.h),

            // Used Weight
            _buildLabel('Used Weight (grams)'),
            SizedBox(height: 6.h),
            TextField(
              controller: usedWeightCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              style: TextStyle(fontSize: 15.sp, color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Enter grams used',
                hintStyle: TextStyle(
                    fontSize: 14.sp, color: Colors.grey[400]),
                prefixIcon: Icon(Icons.scale_outlined,
                    color: Colors.grey[400], size: 20.sp),
                suffixText: 'g',
                suffixStyle: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 14.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                      color: AppColors.primaryColor, width: 1.5),
                ),
              ),
            ),

            SizedBox(height: 28.h),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                          color: Colors.black87, fontSize: 15.sp),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Add to Bowl',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onSubmit() {
    final marketPrice = double.tryParse(marketPriceCtrl.text) ?? 0.0;
    final userPrice = double.tryParse(userPriceCtrl.text) ?? 0.0;
    final usedWeight = double.tryParse(usedWeightCtrl.text) ?? 0.0;

    if (usedWeight <= 0) {
      Get.snackbar(
        'Error',
        'Please enter the weight used',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Check against available weight
    final available =
        double.tryParse(widget.product.currentWeightGrams) ?? 0.0;
    if (usedWeight > available && available > 0) {
      Get.snackbar(
        'Insufficient Stock',
        'Only ${available.toStringAsFixed(1)}g available',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (userPrice <= 0 && marketPrice <= 0) {
      Get.snackbar(
        'Error',
        'Please enter at least one price',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final controller = Get.find<NewMixController>();
    controller.addProductToCurrentBowl(
      product: widget.product,
      usedWeight: usedWeight,
      userPrice: userPrice > 0 ? userPrice : marketPrice,
      marketPriceValue: marketPrice > 0 ? marketPrice : userPrice,
    );

    Get.back(); // Close sheet, stay on product list
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildPriceField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      style: TextStyle(fontSize: 15.sp, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: Colors.grey[400], size: 20.sp),
        prefixText: '\$ ',
        prefixStyle: TextStyle(
            fontSize: 15.sp,
            color: Colors.grey[600],
            fontWeight: FontWeight.w600),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide:
              BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
      ),
    );
  }
}
