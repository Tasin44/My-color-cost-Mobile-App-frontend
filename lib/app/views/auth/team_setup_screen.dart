import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import '../../controllers/team_setup_controller.dart';
import '../widgets/reusable/selection_widgets.dart';

class TeamSetupScreen extends StatelessWidget {
  const TeamSetupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final TeamSetupController controller = Get.put(TeamSetupController());

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Stack(
        children: [
          // Background Gradient Layer
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 250.h,
              decoration: BoxDecoration(gradient: AppColors.primaryGradient),
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Back Button
                      Positioned(
                        left: 20.w,
                        child: GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 18.sp,
                            ),
                          ),
                        ),
                      ),
                      // Logo
                      Image.asset(
                        'assets/images/app_logo.png',
                        width: 200.w,
                        height: 60.h,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),

                  // Header Text
                  Text(
                    'Team Setup',
                    style: AppTextStyle.displaySmall.copyWith(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Text(
                      'Enter how many staff members work under your salon account.',
                      style: AppTextStyle.bodyMedium.copyWith(
                        fontSize: 14.sp,
                        height: 1.4,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Form Section
          Positioned(
            top: 250.h,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              width: Get.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.r),
                  topRight: Radius.circular(30.r),
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 30.h),

                      // Team Size Field
                      Text(
                        'Team Size',
                        style: AppTextStyle.titleMedium.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: controller.teamSizeController,
                        keyboardType: TextInputType.number,
                        style: AppTextStyle.bodyMedium.copyWith(
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'add your total number of staff',
                          hintStyle: AppTextStyle.bodySmall.copyWith(
                            fontSize: 14.sp,
                            color: const Color(0xFF9CA3AF),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: const BorderSide(
                              color: Color(0xFFE8E8E8),
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: const BorderSide(
                              color: Color(0xFFE8E8E8),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: BorderSide(
                              color: AppColors.primaryColor,
                              width: 1.5,
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8F8F8),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                        ),
                        validator: controller.validateTeamSize,
                        onChanged: controller.updateTeamSize,
                      ),

                      SizedBox(height: 24.h),

                      // Staff Email Description
                      Text(
                        'Staff Member Details',
                        style: AppTextStyle.titleMedium.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Enter staff member emails to invite them.',
                        style: AppTextStyle.bodySmall.copyWith(
                          fontSize: 13.sp,
                          color: Colors.grey[600],
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Staff Email Fields
                      Obx(
                        () => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...List.generate(
                              controller.staffEmailControllers.length,
                              (index) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '${controller.getOrdinalNumber(index + 1)} Staff Email',
                                          style: AppTextStyle.bodyMedium
                                              .copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                        ),
                                        const Spacer(),
                                        if (controller
                                                    .staffEmailControllers
                                                    .length >
                                                1 &&
                                            index > 0)
                                          TextButton(
                                            onPressed: () => controller
                                                .removeStaffEmailField(index),
                                            child: Text(
                                              'Remove',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: const Color(0xFFF87171),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 8.h),
                                    TextFormField(
                                      controller: controller
                                          .staffEmailControllers[index],
                                      keyboardType: TextInputType.emailAddress,
                                      style: AppTextStyle.bodyMedium.copyWith(
                                        color: Colors.black87,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'staff@example.com',
                                        hintStyle: AppTextStyle.bodySmall
                                            .copyWith(
                                              fontSize: 14.sp,
                                              color: const Color(0xFF9CA3AF),
                                            ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16.r,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE8E8E8),
                                            width: 1,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16.r,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE8E8E8),
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16.r,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.primaryColor,
                                            width: 1.5,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: const Color(0xFFF8F8F8),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16.w,
                                          vertical: 16.h,
                                        ),
                                      ),
                                      validator: (value) => controller
                                          .validateStaffEmail(value, index),
                                    ),
                                    SizedBox(height: 16.h),
                                  ],
                                );
                              },
                            ),

                            // Add More Staff Button
                            controller.staffEmailControllers.length <
                                    controller.staffLimit.value
                                ? Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: controller.addStaffEmailField,
                                      child: Text(
                                        'Add More +',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          color: AppColors.primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ],
                        ),
                      ),

                      SizedBox(height: 32.h),

                      // Setup Team Button
                      Obx(
                        () => GradientButton(
                          text: 'Setup Team',
                          isLoading: controller.isLoading.value,
                          onPressed: controller.handleTeamSetup,
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // // Skip for Now Option
                      // Center(
                      //   child: TextButton(
                      //     onPressed: controller.skipTeamSetup,
                      //     child: Text(
                      //       'Skip for now',
                      //       style: AppTextStyle.bodyMedium.copyWith(
                      //         fontSize: 14.sp,
                      //         color: Colors.grey[600],
                      //         fontWeight: FontWeight.w500,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
