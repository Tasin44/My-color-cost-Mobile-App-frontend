import 'package:color_os/app/controllers/account_type_controller.dart';
import 'package:color_os/app/controllers/auth_controller.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart'
    show AppColors;
import 'package:color_os/app/views/screens/auth/signin/sign_in_screen.dart';
import 'package:color_os/app/views/widgets/primary_button.dart';
import 'package:color_os/app/views/auth/forgot_password_screen.dart';
import 'package:color_os/app/core/constant/app_static_text.dart';
import 'package:color_os/app/views/screens/profile/sub/static_content_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SignUpScreen extends StatefulWidget {
  final AccountType accountType;
  const SignUpScreen({super.key, required this.accountType});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _referCodeController = TextEditingController();
  final _ownerEmailController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referCodeController.dispose();
    _ownerEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.put(AuthController());

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
              width: Get.width,
              decoration: BoxDecoration(gradient: AppColors.primaryGradient),
              padding: EdgeInsets.only(top: ScreenUtil().statusBarHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/app_logo.png',
                    width: 200.w,
                    height: 66.h,
                  ),

                  // Welcome Text
                  Text(
                    'Create your Account',
                    style: AppTextStyle.displaySmall.copyWith(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Text(
                      'Join the colour revolution track, mix, and manage your salon like never before.',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
                      // Full Name Label
                      Text(
                        'Full Name',
                        style: AppTextStyle.titleMedium.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      // Full Name TextField
                      TextFormField(
                        controller: _fullNameController,
                        keyboardType: TextInputType.name,
                        style: AppTextStyle.bodyMedium.copyWith(
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'enter your full name',
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
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 5.h),
                      // Contact Number Label
                      Text(
                        'Contact Number',
                        style: AppTextStyle.titleMedium.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      // Contact Number TextField
                      TextFormField(
                        controller: _contactNumberController,
                        keyboardType: TextInputType.phone,
                        style: AppTextStyle.bodyMedium.copyWith(
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'enter your contact number',
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
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your contact number';
                          }
                          if (value.length < 10) {
                            return 'Please enter a valid contact number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 5.h),
                      // Email Address Label
                      Text(
                        'Email Address',
                        style: AppTextStyle.titleMedium.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      // Email TextField
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: AppTextStyle.bodyMedium.copyWith(
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'enter your email address',
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
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!GetUtils.isEmail(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 5.h),

                      // Owner Email Field - Only for Salon Staff
                      if (widget.accountType == AccountType.salonStaff) ...[
                        // Owner Email Address Label
                        Text(
                          'Owner Email Address',
                          style: AppTextStyle.titleMedium.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        // Owner Email TextField
                        TextFormField(
                          controller: _ownerEmailController,
                          keyboardType: TextInputType.emailAddress,
                          style: AppTextStyle.bodyMedium.copyWith(
                            color: Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: 'enter salon owner email address',
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
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter owner email address';
                            }
                            if (!GetUtils.isEmail(value)) {
                              return 'Please enter a valid owner email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 5.h),
                      ],

                      // Password Label
                      Text(
                        'Password',
                        style: AppTextStyle.titleMedium.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      // Password TextField
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: AppTextStyle.bodyMedium.copyWith(
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'enter your password',
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
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xFFAAAAAA),
                              size: 22.sp,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 5.h),
                      // Confirm Password Label
                      Text(
                        'Confirm Password',
                        style: AppTextStyle.titleMedium.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      // Confirm Password TextField
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        style: AppTextStyle.bodyMedium.copyWith(
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'confirm your password',
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
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xFFAAAAAA),
                              size: 22.sp,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 5.h),
                      // Refer Code Label
                      Text(
                        'Refer Code (Optional)',
                        style: AppTextStyle.titleMedium.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      // Refer Code TextField
                      TextFormField(
                        controller: _referCodeController,
                        keyboardType: TextInputType.text,
                        style: AppTextStyle.bodyMedium.copyWith(
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter refer code (optional)',
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
                            Icons.card_giftcard_outlined,
                            color: const Color(0xFFAAAAAA),
                            size: 22.sp,
                          ),
                        ),
                        validator: (value) {
                          // Since it's optional, we don't need to validate for emptiness
                          // But we can add format validation if needed
                          if (value != null && value.isNotEmpty) {
                            // Add any specific refer code format validation here
                            if (value.length < 3) {
                              return 'Refer code must be at least 3 characters';
                            }
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 8.h),
                      // Remember Me and Forgot Password Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Remember Me Checkbox
                          Row(
                            children: [
                              SizedBox(
                                height: 24.h,
                                width: 24.w,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                  activeColor: AppColors.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Remember me',
                                style: AppTextStyle.bodyMedium.copyWith(
                                  color: Colors.black87,
                                  fontSize: 15.sp,
                                ),
                              ),
                            ],
                          ),
                          // Forgot Password
                          TextButton(
                            onPressed: () {
                              // Handle forgot password
                              Get.to(() => const ForgotPasswordScreen());
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Forgot Password?',
                              style: AppTextStyle.bodyMedium.copyWith(
                                color: AppColors.primaryColor,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      // Terms & Privacy Policy
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: AppTextStyle.bodyMedium.copyWith(
                              color: Colors.black54,
                              fontSize: 12.sp,
                            ),
                            children: [
                              const TextSpan(
                                text: 'By signing up you\'re agreeing to our ',
                              ),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: GestureDetector(
                                  onTap: () {
                                    Get.to(() => const StaticContentScreen(
                                          title: AppStaticText.termsConditionsTitle,
                                          content: AppStaticText.termsConditionsContent,
                                        ));
                                  },
                                  child: Text(
                                    'Terms & Conditions',
                                    style: AppTextStyle.bodyMedium.copyWith(
                                      color: AppColors.primaryColor,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColors.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              const TextSpan(text: ' and '),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: GestureDetector(
                                  onTap: () {
                                    Get.to(() => const StaticContentScreen(
                                          title: AppStaticText.privacyPolicyTitle,
                                          content: AppStaticText.privacyPolicyContent,
                                        ));
                                  },
                                  child: Text(
                                    'Privacy Policy',
                                    style: AppTextStyle.bodyMedium.copyWith(
                                      color: AppColors.primaryColor,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColors.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        child: Obx(() {
                          return PrimaryButton(
                            text: 'Sign Up',
                            isLoading: authController.isSignupLoading.value,
                            height: 48.h,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // Use AuthController to handle sign up
                                authController.signupUser(
                                  fullName: _fullNameController.text,
                                  contactNumber: _contactNumberController.text,
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                  accountType: widget.accountType,
                                  referCode: hasReferCode ? referCode : null,
                                  ownerEmail:
                                      widget.accountType ==
                                          AccountType.salonStaff
                                      ? _ownerEmailController.text
                                      : null,
                                );
                              }
                            },
                          );
                        }),
                      ),
                      SizedBox(height: 18.h),
                      // OR Divider
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: const Color(0xFFE0E0E0),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Text(
                              'or',
                              style: AppTextStyle.bodyMedium.copyWith(
                                color: const Color(0xFF9E9E9E),
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: const Color(0xFFE0E0E0),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      // SizedBox(height: 24.h),
                      // // Google Sign In Button
                      // SizedBox(
                      //   width: double.infinity,
                      //   height: 40.h,
                      //   child: OutlinedButton(
                      //     onPressed: () {
                      //       // Handle Google sign in
                      //     },
                      //     style: OutlinedButton.styleFrom(
                      //       foregroundColor: Colors.black87,
                      //       side: const BorderSide(
                      //         color: Color(0xFFE0E0E0),
                      //         width: 1,
                      //       ),
                      //       backgroundColor: Colors.white,
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(16.r),
                      //       ),
                      //     ),
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: [
                      //         Image.asset(
                      //           'assets/images/google_icon.png',
                      //           height: 24.h,
                      //           width: 24.w,
                      //           errorBuilder: (context, error, stackTrace) {
                      //             return Icon(
                      //               Icons.g_mobiledata,
                      //               size: 28.sp,
                      //               color: Colors.red,
                      //             );
                      //           },
                      //         ),
                      //         SizedBox(width: 12.w),
                      //         Text(
                      //           'Google',
                      //           style: AppTextStyle.button.copyWith(
                      //             color: Colors.black87,
                      //             fontSize: 12.sp,
                      //             fontWeight: FontWeight.w500,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(height: 24.h),
                      // Sign In Link
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: AppTextStyle.bodyMedium.copyWith(
                                color: Colors.black87,
                                fontSize: 15.sp,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Navigate to Sign In
                                Get.to(
                                  SignInScreen(accountType: widget.accountType),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Sign In',
                                style: AppTextStyle.bodyMedium.copyWith(
                                  color: AppColors.primaryColor,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  /// Get the refer code value (returns empty string if not provided)
  String get referCode => _referCodeController.text.trim();

  /// Check if a refer code was provided
  bool get hasReferCode => referCode.isNotEmpty;
}
