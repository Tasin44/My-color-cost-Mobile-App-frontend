import 'package:color_os/app/controllers/new_mix_controller.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/models/inventory_product_model.dart';
import 'package:color_os/app/views/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AddToBowlSheet extends StatefulWidget {
  final InventoryProduct product;
  final NewMixController controller;

  const AddToBowlSheet({
    Key? key,
    required this.product,
    required this.controller,
  }) : super(key: key);

  @override
  State<AddToBowlSheet> createState() => _AddToBowlSheetState();
}

class _AddToBowlSheetState extends State<AddToBowlSheet> {
  late TextEditingController priceController;
  late TextEditingController nameController;
  late TextEditingController weightController;

  // True once the async cache-check has completed.
  // The "Continue Bowl" button is disabled until this is true so that the
  // user can never accidentally submit before the correct original weight is
  // resolved — which would corrupt the cache and break future calculations.
  bool _weightReady = false;
  bool _weightFromCache = false;

  @override
  void initState() {
    super.initState();
    priceController = TextEditingController(
      text: widget.product.userPrice ?? widget.product.marketPrice ?? '',
    );
    nameController = TextEditingController(text: widget.product.productName);

    // Start EMPTY — we intentionally do NOT seed from the API value here.
    // The API's original_weight_grams field may equal current_weight_grams
    // (i.e. already-reduced stock), which would corrupt the price-per-gram.
    // The canonical value comes from the SharedPreferences cache loaded below.
    weightController = TextEditingController();

    _loadCachedOriginalWeight();
  }

  /// Loads the confirmed original weight from SharedPreferences.
  ///
  /// * If a cached value exists → use it (user-confirmed truth).
  /// * If no cache → fall back to the API's [originalWeightGrams] if provided,
  ///   otherwise leave the field empty for the user to fill manually.
  /// * Sets [_weightReady] = true only AFTER this check so the submit button
  ///   cannot be tapped before the correct value is in the field.
  Future<void> _loadCachedOriginalWeight() async {
    final cached =
        await NewMixController.loadOriginalWeight(widget.product.id);
    if (!mounted) return;

    setState(() {
      if (cached != null) {
        weightController.text = cached.toStringAsFixed(2);
        _weightFromCache = true;
      } else {
        // No cache yet — use whatever the API provided (may be null/empty).
        // The user will confirm the correct value on first use, after which
        // it gets cached and this branch is never taken again.
        weightController.text = widget.product.originalWeightGrams ?? '';
        _weightFromCache = false;
      }
      _weightReady = true;
    });
  }

  @override
  void dispose() {
    priceController.dispose();
    nameController.dispose();
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // hasCachedWeight is only true after the async check confirms it.
    final bool hasCachedWeight = _weightReady && _weightFromCache;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
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
            Text(
              'Add to Bowl',
              style: AppTextStyle.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),

          // Mix Name
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Mix Name',
              labelStyle: TextStyle(color: Colors.grey[600]),
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
                borderSide: BorderSide(color: AppColors.primaryColor),
              ),
              prefixIcon: Icon(Icons.edit, color: AppColors.primaryColor),
            ),
          ),

          SizedBox(height: 16.h),

          // Price
          TextField(
            controller: priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              labelText: 'Price (full bottle cost)',
              labelStyle: TextStyle(color: Colors.grey[600]),
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
                borderSide: BorderSide(color: AppColors.primaryColor),
              ),
              prefixIcon: Icon(
                Icons.attach_money,
                color: AppColors.primaryColor,
              ),
              suffixText: widget.product.userPrice == null &&
                      widget.product.marketPrice == null
                  ? 'Set Manually'
                  : 'Edit if needed',
            ),
          ),

          SizedBox(height: 16.h),

          // ── Original Full-Bottle Weight ──────────────────────────────────
          // price_per_gram = user_price / original_weight  (constant forever)
          // each_item_cost = price_per_gram × used_grams
          //
          // We block submission until _weightReady = true so that a stale API
          // value can NEVER be submitted before the cache overrides it.
          // ─────────────────────────────────────────────────────────────────
          if (!_weightReady)
            Container(
              height: 64.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Loading original weight…',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            )
          else
            TextField(
              controller: weightController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'Original Full Bottle Weight (when FULL)',
                helperText: hasCachedWeight
                    ? '✓ Saved — Available now: ${widget.product.currentWeightGrams}g'
                    : 'Enter the weight of a NEW, unopened bottle — Available: ${widget.product.currentWeightGrams}g',
                helperStyle: TextStyle(
                  color: hasCachedWeight
                      ? Colors.green.shade700
                      : Colors.orange.shade800,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                ),
                labelStyle: TextStyle(color: Colors.grey[600]),
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
                  borderSide: BorderSide(color: AppColors.primaryColor),
                ),
                prefixIcon: Icon(
                  hasCachedWeight ? Icons.lock_outline : Icons.scale,
                  color: hasCachedWeight
                      ? Colors.green.shade600
                      : AppColors.primaryColor,
                ),
                suffixText: 'g',
              ),
            ),

          SizedBox(height: 24.h),

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
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: PrimaryButton(
                  text: _weightReady ? 'Continue Bowl' : 'Loading…',
                  onPressed: !_weightReady
                      ? null // disabled while cache is loading
                      : () {
                          final price =
                              double.tryParse(priceController.text) ?? 0.0;
                          final weight =
                              double.tryParse(weightController.text) ?? 0.0;
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            Get.snackbar(
                              'Error',
                              'Name cannot be empty',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            return;
                          }
                          if (weight <= 0) {
                            Get.snackbar(
                              'Error',
                              'Please enter the original full bottle weight',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            return;
                          }
                          widget.controller.confirmAddToBowl(
                            widget.product,
                            name,
                            price,
                            weight,
                          );
                        },
                  height: 56.h,
                  borderRadius: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  }
}
