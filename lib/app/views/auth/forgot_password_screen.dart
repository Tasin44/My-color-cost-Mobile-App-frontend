import 'package:color_os/app/core/constant/app_textstyle.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/views/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              height: 220.h,
              decoration: BoxDecoration(gradient: AppColors.primaryGradient),
              padding: EdgeInsets.only(top: ScreenUtil().statusBarHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 16.w),
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
                              size: 16.sp,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'Forgot Password',
                    style: AppTextStyle.displaySmall.copyWith(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Text(
                      'Enter your email address and we\'ll send you a verification code to reset your password.',
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
            top: 220.h,
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
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 60.h),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        style: AppTextStyle.bodyMedium.copyWith(
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter your email address',
                          filled: true,
                          fillColor: const Color(0xFFF8F8F8),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 10.h,
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
                          hintStyle: AppTextStyle.bodyMedium.copyWith(
                            color: const Color(0xFFAAAAAA),
                            fontSize: 15.sp,
                          ),
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            size: 24.sp,
                            color: const Color(0xFFAAAAAA),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email address';
                          }
                          if (!GetUtils.isEmail(value.trim())) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        onFieldSubmitted: (value) => _handleForgotPassword(),
                      ),

                      SizedBox(height: 32.h),

                      Obx(
                        () => PrimaryButton(
                          text: 'Send Reset Code',
                          isLoading:
                              _authController.isForgotPasswordLoading.value,
                          onPressed: _handleForgotPassword,
                          height: 50.h,
                        ),
                      ),

                      SizedBox(height: 40.h),

                      // Back to Login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Remember your password? ',
                            style: AppTextStyle.bodyMedium.copyWith(
                              fontSize: 15.sp,
                              color: Colors.black87,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Get.back(),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Sign In',
                              style: AppTextStyle.bodyMedium.copyWith(
                                fontSize: 15.sp,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
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

  void _handleForgotPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      _authController.forgotPassword(email: _emailController.text.trim());
    }
  }
}
