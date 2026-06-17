import 'package:color_os/app/controllers/auth_controller.dart';
import 'package:color_os/app/controllers/account_type_controller.dart';
import 'package:color_os/app/core/constant/app_content.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/views/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class VerifyAccountScreen extends StatefulWidget {
  final String? email;

  const VerifyAccountScreen({super.key, this.email});

  @override
  State<VerifyAccountScreen> createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  // Variables to handle different verification types
  late String email;
  late String verificationType; // 'signup' or 'forgot_password'
  AccountType? accountType;

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments as Map<String, dynamic>? ?? {};
    email = arguments['email'] ?? widget.email ?? '';
    verificationType = arguments['type'] ?? 'signup';
    accountType = arguments['accountType'];
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String _digitsOnly(String s) => s.replaceAll(RegExp(r'\D'), '');

  /// Fills OTP boxes from pasted or multi-key input starting at [startIndex].
  void _applyOtpDigits(String raw, int startIndex) {
    var d = _digitsOnly(raw);
    if (d.length > 6) d = d.substring(0, 6);
    var di = 0;
    for (var i = startIndex; i < 6 && di < d.length; i++, di++) {
      _controllers[i].text = d[di];
    }
    setState(() {});
    if (d.length >= 6 - startIndex) {
      _focusNodes[5].requestFocus();
    } else {
      final next = startIndex + d.length;
      _focusNodes[next.clamp(0, 5)].requestFocus();
    }
  }

  void _onOtpFieldChanged(int index, String value) {
    final digits = _digitsOnly(value);
    if (digits.isEmpty) {
      _controllers[index].clear();
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
      return;
    }
    if (digits.length > 1) {
      _applyOtpDigits(digits, index);
      return;
    }
    _controllers[index].text = digits;
    _controllers[index].selection = TextSelection.collapsed(offset: 1);
    if (index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  String _getVerificationCode() {
    return _controllers.map((controller) => controller.text).join();
  }

  void _verifyCode() {
    String code = _getVerificationCode();
    if (code.length == 6) {
      if (email.isNotEmpty) {
        final authController = Get.find<AuthController>();

        if (verificationType == 'forgot_password') {
          // For forgot password, we must also verify OTP to get the access token
          authController.verifyOtp(
            email: email,
            otpCode: code,
            verificationType: 'forgot_password',
          );
        } else {
          // For signup verification, use existing OTP verification
          authController.verifyOtp(
            email: email,
            otpCode: code,
            accountType: accountType,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Email address not found. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      Get.snackbar(
        'Error',
        'Please enter all 6 digits',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _resendCode() {
    if (email.isNotEmpty) {
      // Use AuthController to handle resend OTP
      final authController = Get.find<AuthController>();
      authController.resendOtp(email: email);
    } else {
      Get.snackbar(
        'Error',
        'Email address not found. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

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
                  // Logo
                  Image.asset(
                    AppContent.appLogo,
                    width: 200.w,
                    height: 66.h,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 10.h),
                  // Title
                  Text(
                    verificationType == 'forgot_password'
                        ? 'Verify Reset Code'
                        : 'Verify Your Account',
                    style: AppTextStyle.displaySmall.copyWith(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Subtitle (two short lines)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Text(
                      'Your OTP was sent to your email.\nPlease check your junk.',
                      style: AppTextStyle.bodyMedium.copyWith(
                        fontSize: 14.sp,
                        height: 1.35,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 60.h),
                    // OTP Input Fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        6,
                        (index) => _buildOTPField(index),
                      ),
                    ),
                    SizedBox(height: 40.h),
                    // Verify Button
                    SizedBox(
                      width: double.infinity,
                      child: Obx(() {
                        return PrimaryButton(
                          text: verificationType == 'forgot_password'
                              ? 'Verify Code'
                              : 'Verify',
                          isLoading: authController.isOtpLoading.value,
                          onPressed: _verifyCode,
                          height: 50.h,
                        );
                      }),
                    ),
                    SizedBox(height: 24.h),
                    // Resend Code Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't received code? ",
                          style: AppTextStyle.bodyMedium.copyWith(
                            color: Colors.black87,
                            fontSize: 15.sp,
                          ),
                        ),
                        TextButton(
                          onPressed: authController.isResendOtpLoading.value
                              ? null
                              : _resendCode,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Obx(() {
                            return authController.isResendOtpLoading.value
                                ? SizedBox(
                                    width: 16.w,
                                    height: 16.h,
                                    child: CircularProgressIndicator(
                                      color: AppColors.primaryColor,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Resend now',
                                    style: AppTextStyle.bodyMedium.copyWith(
                                      color: AppColors.primaryColor,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  );
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOTPField(int index) {
    return Container(
      width: 50.w,
      height: 50.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 1.5),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 6,
        style: AppTextStyle.bodyLarge.copyWith(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) => _onOtpFieldChanged(index, value),
        onSubmitted: (value) {
          if (index == 5 && _getVerificationCode().length == 6) {
            _verifyCode();
          }
        },
      ),
    );
  }
}
