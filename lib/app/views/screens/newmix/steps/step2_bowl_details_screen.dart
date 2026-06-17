import 'package:color_os/app/controllers/new_mix_controller.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/views/screens/newmix/widgets/step_progress_header.dart';
import 'package:color_os/app/views/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class Step2BowlDetailsScreen extends StatefulWidget {
  const Step2BowlDetailsScreen({Key? key}) : super(key: key);

  @override
  State<Step2BowlDetailsScreen> createState() => _Step2BowlDetailsScreenState();
}

class _Step2BowlDetailsScreenState extends State<Step2BowlDetailsScreen> {
  late TextEditingController gramsController;
  double _previewCost = 0.0;

  NewMixController get controller => Get.find<NewMixController>();

  @override
  void initState() {
    super.initState();
    gramsController = TextEditingController();
    gramsController.addListener(_onGramsChanged);
  }

  void _onGramsChanged() {
    final grams = double.tryParse(gramsController.text) ?? 0.0;
    setState(() {
      _previewCost = controller.calculateUsageCost(grams);
    });
  }

  @override
  void dispose() {
    gramsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Bowl Details',
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
              currentStep: 2,
              totalSteps: 4,
              title: 'Add Amount',
            ),

            // Bowl Header
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Obx(() {
                final product = controller.selectedInventoryProduct.value;
                final bowl = controller.currentBowl.value;
                final pricePerGram = bowl?.pricePerGram ?? 0.0;
                final availableGrams =
                    double.tryParse(product?.currentWeightGrams ?? '0') ?? 0.0;
                return Column(
                  children: [
                    CircleAvatar(
                      radius: 30.r,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: product?.productImage != null
                          ? NetworkImage(product!.productImage!)
                          : null,
                      child: product?.productImage == null
                          ? const Icon(Icons.inventory_2)
                          : null,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      bowl?.name ?? 'Mix',
                      style: AppTextStyle.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      product?.productName ?? '',
                      style: AppTextStyle.bodyMedium.copyWith(
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    // Pricing info row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _infoChip(
                          Icons.straighten,
                          'Available',
                          '${availableGrams.toStringAsFixed(2)}g',
                          Colors.blue,
                        ),
                        _infoChip(
                          Icons.monetization_on_outlined,
                          'Per gram',
                          '\$${pricePerGram.toStringAsFixed(4)}',
                          Colors.green,
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ),

            SizedBox(height: 30.h),

            // Add Grams input
            Text(
              'Add Amount (Grams)',
              style: AppTextStyle.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: gramsController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                hintText: 'Enter grams',
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
                suffixText: 'g',
              ),
            ),

            SizedBox(height: 16.h),

            // Live cost preview
            if (_previewCost > 0)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.green.shade100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Estimated cost',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14.sp,
                      ),
                    ),
                    Text(
                      '\$${_previewCost.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 24.h),

            // Start Timer / Continue Button
            PrimaryButton(
              text: 'Continue',
              onPressed: () {
                final grams = double.tryParse(gramsController.text) ?? 0.0;
                if (grams > 0) {
                  // Perform validation against available stock if possible
                  final product = controller.selectedInventoryProduct.value;
                  if (product != null &&
                      product.currentWeightGrams.isNotEmpty) {
                    final available =
                        double.tryParse(product.currentWeightGrams) ?? 0.0;
                    if (grams > available) {
                      Get.snackbar(
                        'Insufficient Stock',
                        'You only have ${available.toStringAsFixed(2)}g available.',
                        backgroundColor: Colors.orange,
                        colorText: Colors.white,
                      );
                      return;
                    }
                  }

                  controller.addGramsToCurrentBowl(grams);
                } else {
                  Get.snackbar('Error', 'Please enter valid grams');
                }
              },
              height: 56.h,
              borderRadius: 12,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 4.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
