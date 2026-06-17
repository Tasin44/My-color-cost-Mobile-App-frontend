import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/controllers/new_mix_controller.dart';
import 'package:color_os/app/views/screens/newmix/steps/select_client_screen.dart';
import 'package:color_os/app/views/widgets/primary_button.dart';

class FinalStepScreen extends StatefulWidget {
  const FinalStepScreen({Key? key}) : super(key: key);

  @override
  State<FinalStepScreen> createState() => _FinalStepScreenState();
}

class _FinalStepScreenState extends State<FinalStepScreen> {
  final TextEditingController chargeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final controller = Get.find<NewMixController>();
    chargeController.text = controller.clientCharge.value.toStringAsFixed(2);
  }

  @override
  void dispose() {
    chargeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NewMixController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20.sp),
        ),
        title: Text(
          'Final Step',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: Column(
        children: [
          // Progress Indicator
          Obx(() => _buildProgressIndicator(controller.currentStep.value)),

          SizedBox(height: 20.h),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(
                        () => Text(
                          'Step ${controller.currentStep.value} of ${controller.totalSteps.value}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Cost Summary Card
                  Obx(
                    () => Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFF0F6),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        children: [
                          _buildSummaryRow(
                            'Total Cost',
                            '£${controller.totalMixCost.value.toStringAsFixed(2)}',
                            false,
                          ),
                          SizedBox(height: 12.h),
                          Divider(
                            color: AppColors.primaryColor.withOpacity(0.3),
                          ),
                          SizedBox(height: 12.h),
                          _buildSummaryRow(
                            'Total Bowls',
                            controller.mixItems.length.toString(),
                            false,
                          ),
                          SizedBox(height: 8.h),
                          _buildSummaryRow(
                            'Total Grams',
                            '${controller.mixItems.fold(0.0, (sum, item) => sum + item.grams).toStringAsFixed(1)}g',
                            false,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Client Charge Section
                  Text(
                    'Client Charge',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Quick Charge Buttons
                  Row(
                    children: [
                      _buildQuickChargeButton('£10', 10.0, controller),
                      SizedBox(width: 10.w),
                      _buildQuickChargeButton('£15', 15.0, controller),
                      SizedBox(width: 10.w),
                      _buildQuickChargeButton('£20', 20.0, controller),
                      SizedBox(width: 10.w),
                      _buildQuickChargeButton('£25', 25.0, controller),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Custom Charge Input
                  TextField(
                    controller: chargeController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: 16.sp, color: Colors.black87),
                    onChanged: (value) {
                      final charge = double.tryParse(value) ?? 20.0;
                      controller.updateClientCharge(charge);
                    },
                    decoration: InputDecoration(
                      labelText: 'Custom Charge',
                      labelStyle: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                      prefixText: '£',
                      prefixStyle: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.black87,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
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

                  SizedBox(height: 24.h),

                  // Profit Card
                  Obx(
                    () => Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryColor,
                            AppColors.primaryColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Profit',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                '£${controller.profit.value.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            controller.profit.value >= 0
                                ? Icons.trending_up
                                : Icons.trending_down,
                            color: Colors.white,
                            size: 32.sp,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Assign to Client Section (Optional)
                  Text(
                    'Assign to Client (Optional)',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Assign Client Button
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: OutlinedButton(
                      onPressed: () {
                        Get.to(() => const SelectClientScreen());
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.primaryColor,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_add_outlined,
                            color: AppColors.primaryColor,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Obx(
                            () => Text(
                              controller.selectedClientId.value.isEmpty
                                  ? 'Select Client'
                                  : 'Client Selected',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),

          // Save Mix Button
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: Offset(0, -2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: PrimaryButton(
              text: 'Save Mix',
              onPressed: () {
                controller.saveMix();
              },
              height: 50.h,
              borderRadius: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(int currentStep) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: List.generate(4, (index) {
          final stepNumber = index + 1;
          final isActive = stepNumber <= currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primaryColor
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                if (index < 3) SizedBox(width: 4.w),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isHighlight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: isHighlight ? AppColors.primaryColor : Colors.grey[700],
            fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isHighlight ? AppColors.primaryColor : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickChargeButton(
    String label,
    double amount,
    NewMixController controller,
  ) {
    return Expanded(
      child: Obx(
        () => OutlinedButton(
          onPressed: () {
            controller.setQuickCharge(amount);
            chargeController.text = amount.toStringAsFixed(2);
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: controller.clientCharge.value == amount
                  ? AppColors.primaryColor
                  : Colors.grey[300]!,
              width: controller.clientCharge.value == amount ? 2 : 1,
            ),
            backgroundColor: controller.clientCharge.value == amount
                ? AppColors.primaryColor.withOpacity(0.1)
                : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            padding: EdgeInsets.symmetric(vertical: 10.h),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: controller.clientCharge.value == amount
                  ? AppColors.primaryColor
                  : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }
}
