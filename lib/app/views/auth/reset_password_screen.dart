import 'package:color_os/app/core/constant/app_textstyle.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/views/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                    'Reset Password',
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
                      'Create a new password for your account. Make sure it\'s at least 8 characters long.',
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
                      SizedBox(height: 40.h),
                      // New Password Label
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'New Password',
                          style: AppTextStyle.titleMedium.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: 5.h),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        textInputAction: TextInputAction.next,
                        style: AppTextStyle.bodyMedium.copyWith(
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter new password',
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
                            Icons.lock_outline,
                            size: 24.sp,
                            color: const Color(0xFFAAAAAA),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: const Color(0xFFAAAAAA),
                              size: 22.sp,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your new password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters long';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 20.h),

                      // Confirm Password Label
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Confirm Password',
                          style: AppTextStyle.titleMedium.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: 5.h),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: !_isConfirmPasswordVisible,
                        textInputAction: TextInputAction.done,
                        style: AppTextStyle.bodyMedium.copyWith(
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Confirm new password',
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
                            Icons.lock_outline,
                            size: 24.sp,
                            color: const Color(0xFFAAAAAA),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: const Color(0xFFAAAAAA),
                              size: 22.sp,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your new password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        onFieldSubmitted: (value) => _handleResetPassword(),
                      ),

                      SizedBox(height: 32.h),

                      // Reset Password Button
                      SizedBox(
                        width: double.infinity,
                        child: Obx(
                          () => PrimaryButton(
                            text: 'Reset Password',
                            isLoading:
                                _authController.isResetPasswordLoading.value,
                            onPressed: _handleResetPassword,
                            height: 50.h,
                          ),
                        ),
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

  void _handleResetPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      _authController.resetPassword(newPassword: _passwordController.text);
    }
  }
}
