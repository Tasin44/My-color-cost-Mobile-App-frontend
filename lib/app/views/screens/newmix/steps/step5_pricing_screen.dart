import 'package:color_os/app/controllers/new_mix_controller.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/views/screens/newmix/widgets/step_progress_header.dart';
import 'package:color_os/app/views/screens/newmix/steps/select_client_screen.dart';
import 'package:color_os/app/views/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class Step5PricingScreen extends StatefulWidget {
  const Step5PricingScreen({Key? key}) : super(key: key);

  @override
  State<Step5PricingScreen> createState() => _Step5PricingScreenState();
}

class _Step5PricingScreenState extends State<Step5PricingScreen> {
  late final NewMixController controller;
  late final TextEditingController _chargeCtrl;

  // The quick-charge amount currently active (null = custom)
  double? _activeQuickCharge;

  static const List<int> _quickAmounts = [20, 25, 50, 100];

  @override
  void initState() {
    super.initState();
    controller = Get.find<NewMixController>();
    final initial = controller.clientCharge.value;
    _chargeCtrl = TextEditingController(text: initial.toStringAsFixed(2));
    // Mark active quick charge if the initial value matches one
    if (_quickAmounts.contains(initial.toInt()) && initial % 1 == 0) {
      _activeQuickCharge = initial;
    }
  }

  @override
  void dispose() {
    _chargeCtrl.dispose();
    super.dispose();
  }

  // Called by both the text field (user typing) and the quick-charge buttons.
  void _applyCharge(double amount, {bool fromQuickButton = false}) {
    controller.updateClientCharge(amount);
    setState(() {
      _activeQuickCharge = fromQuickButton ? amount : null;
    });
    // Only update the text field when coming from a quick-charge button press.
    // When the user is typing we must NOT overwrite their in-progress input.
    if (fromQuickButton) {
      _chargeCtrl.text = amount.toStringAsFixed(2);
      _chargeCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: _chargeCtrl.text.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'New Mix',
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
              currentStep: 4,
              totalSteps: 4,
              title: 'Pricing & Profit',
            ),

            // Total Mix Cost Box
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                children: [
                  Text(
                    'Total Mix Cost',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Obx(
                    () => Text(
                      '\$${controller.totalMixCost.value.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Set Client Charge Section
            Text(
              'Set Client Charge',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),

            // Charge Input — uses a single, properly managed TextEditingController
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Text(
                    '\$',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: TextField(
                      controller: _chargeCtrl,
                      style: TextStyle(
                        fontSize: 32.sp,
                        color: Colors.grey.shade800,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (val) {
                        final charge = double.tryParse(val) ?? 0.0;
                        _applyCharge(charge);
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '0.00',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            // Quick Charge Buttons — tapping one fills the text field immediately
            Row(
              children: _quickAmounts.map((amount) {
                final isActive = _activeQuickCharge == amount.toDouble();
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: OutlinedButton(
                      onPressed: () =>
                          _applyCharge(amount.toDouble(), fromQuickButton: true),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: BorderSide(
                          color: isActive
                              ? AppColors.primaryColor
                              : Colors.grey.shade300,
                          width: isActive ? 2 : 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        backgroundColor:
                            isActive ? AppColors.primaryColor.withOpacity(0.07) : Colors.white,
                      ),
                      child: Text(
                        '\$$amount',
                        style: TextStyle(
                          color: isActive
                              ? AppColors.primaryColor
                              : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 24.h),

            // Profit Box
            Obx(() {
              final profit = controller.profit.value;
              final margin = controller.clientCharge.value > 0
                  ? (profit / controller.clientCharge.value * 100)
                  : 0.0;

              return Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.green.shade100),
                ),
                child: Column(
                  children: [
                    Text(
                      'Your Profit',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '\$${profit.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${margin.toStringAsFixed(1)}% Margin',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              );
            }),

            SizedBox(height: 16.h),

            // Reminder banner
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: const Color(0xFFFFE082),
                  width: 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        color: const Color(0xFFF9A825),
                        size: 18.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Good to know',
                        style: TextStyle(
                          color: const Color(0xFFF57F17),
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  _buildReminderPoint(
                    'These margins are based on the data you have inputted, such as your colour usage, product information and service charge.',
                  ),
                  SizedBox(height: 8.h),
                  _buildReminderPoint(
                    'Don\'t forget to input your monthly expenses into your accounts department for a more in-depth view of your finances.',
                  ),
                ],
              ),
            ),

            SizedBox(height: 40.h),

            // Assign to Client Section
            Obx(() {
              final client = controller.selectedClient.value;

              if (client != null) {
                return Column(
                  children: [
                    // Selected Client Card
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20.r,
                            backgroundImage: client.profileImage != null
                                ? NetworkImage(client.profileImage!)
                                : null,
                            backgroundColor: Colors.grey.shade200,
                            // Guard against empty name to prevent RangeError
                            child: client.profileImage == null
                                ? Text(
                                    client.name.isNotEmpty
                                        ? client.name[0].toUpperCase()
                                        : '?',
                                  )
                                : null,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  client.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                Text(
                                  'Client',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () {
                              controller.selectedClientId.value = '';
                              controller.selectedClient.value = null;
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Assign Mix to Client Button
                    PrimaryButton(
                      onPressed: () => controller.saveMix(),
                      height: 56.h,
                      borderRadius: 12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check, color: Colors.white),
                          SizedBox(width: 8.w),
                          Text(
                            'Assign Mix to ${client.name}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return PrimaryButton(
                  text: 'Select Client to Assign',
                  onPressed: () => Get.to(() => const SelectClientScreen()),
                  height: 56.h,
                  borderRadius: 12,
                );
              }
            }),

            SizedBox(height: 12.h),

            Obx(() {
              if (controller.selectedClientId.value.isNotEmpty) {
                return const SizedBox.shrink();
              }
              return PrimaryButton(
                text: 'Save to History (No Client)',
                onPressed: () => controller.saveMix(),
                height: 56.h,
                borderRadius: 12,
              );
            }),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 5.h, right: 8.w),
          child: Container(
            width: 5.w,
            height: 5.w,
            decoration: const BoxDecoration(
              color: Color(0xFFF9A825),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: const Color(0xFF5D4037),
              fontSize: 12.sp,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
