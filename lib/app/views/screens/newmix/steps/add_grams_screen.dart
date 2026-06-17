import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/controllers/new_mix_controller.dart';
import 'package:color_os/app/views/widgets/primary_button.dart';

class AddGramsScreen extends StatefulWidget {
  const AddGramsScreen({Key? key}) : super(key: key);

  @override
  State<AddGramsScreen> createState() => _AddGramsScreenState();
}

class _AddGramsScreenState extends State<AddGramsScreen> {
  final TextEditingController gramsController = TextEditingController();
  double selectedGrams = 0.0;

  @override
  void initState() {
    super.initState();
    gramsController.text = '0';
  }

  @override
  void dispose() {
    gramsController.dispose();
    super.dispose();
  }

  void setGrams(double grams) {
    setState(() {
      selectedGrams = grams;
      gramsController.text = grams.toString();
    });
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
          icon: Icon(Icons.arrow_back, color: Colors.black87, size: 24.sp),
        ),
        title: Text(
          'New Mix',
          style: AppTextStyle.headlineSmall.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        // actions: [
        //   IconButton(
        //     onPressed: () {},
        //     icon: Icon(Icons.more_vert, color: Colors.black87, size: 24.sp),
        //   ),
        // ],
      ),
      body: Obx(
        () => Column(
          children: [
            // Progress Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Step ${controller.currentStep.value} of ${controller.totalSteps.value}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Add Grams',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: LinearProgressIndicator(
                      value: controller.progressPercentage,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryColor,
                      ),
                      minHeight: 8.h,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    // Bowl Info Card
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFF0F6),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.currentBowl.value?.name ??
                                      'Bowl 1',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Developer 20 Vol',
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

                    // Market Price
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
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '£${controller.marketPrice.value.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: Colors.black87,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.lock_outline,
                            color: Colors.grey[400],
                            size: 20.sp,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 30.h),

                    // How many grams section
                    Text(
                      'How many grams?',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Enter the amount of bowl used.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Grams Input Display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          gramsController.text,
                          style: TextStyle(
                            fontSize: 48.sp,
                            fontWeight: FontWeight.w300,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Padding(
                          padding: EdgeInsets.only(top: 20.h),
                          child: Text(
                            'g',
                            style: TextStyle(
                              fontSize: 20.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // Quick select buttons
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildQuickSelectButton('20g', 20.0),
                          SizedBox(width: 12.w),
                          _buildQuickSelectButton('50g', 50.0),
                          SizedBox(width: 12.w),
                          _buildQuickSelectButton('100g', 100.0),
                          SizedBox(width: 12.w),
                          _buildQuickSelectButton('200g', 200.0),
                        ],
                      ),
                    ),

                    SizedBox(height: 30.h),

                    // Usage cost display
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      decoration: BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Usage cost for this product',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            '£${controller.calculateUsageCost(selectedGrams).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),

            // Continue Button
            Padding(
              padding: EdgeInsets.all(20.w),
              child: SizedBox(
                width: double.infinity,
                height: 50.h,
                child: PrimaryButton(
                  text: 'Continue',
                  onPressed: selectedGrams > 0
                      ? () {
                          controller.addGramsToCurrentBowl(selectedGrams);
                        }
                      : null,
                  height: 50.h,
                  borderRadius: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSelectButton(String label, double grams) {
    final isSelected = selectedGrams == grams;
    return GestureDetector(
      onTap: () => setGrams(grams),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.primaryColor : Colors.black87,
          ),
        ),
      ),
    );
  }
}
