import 'package:color_os/app/views/auth/forgot_password_screen.dart';
import 'package:color_os/app/controllers/account_type_controller.dart';
import 'package:color_os/app/views/widgets/primary_button.dart';
import 'package:color_os/app/controllers/auth_controller.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/views/screens/auth/signup/sign_up_screen.dart';
import 'package:color_os/app/views/screens/account_type/account_type_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SignInScreen extends StatefulWidget {
  final AccountType? accountType;
  const SignInScreen({super.key, this.accountType});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController _authController = Get.put(AuthController());
  bool _rememberMe = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                  // Logo
                  Image.asset(
                    'assets/images/app_logo.png',
                    width: 200.w,
                    height: 66.h,
                  ),

                  // Welcome Text
                  Text(
                    'Welcome Back!',
                    style: AppTextStyle.displaySmall.copyWith(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Text(
                      'Log in to continue mastering your mixes and managing your salon with precision.',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
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
                          hintText: 'Enter your password',
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
                              // Navigate to forgot password screen
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
                      // Sign In Button
                      SizedBox(
                        width: double.infinity,
                        child: Obx(() {
                          return PrimaryButton(
                            text: 'Sign In',
                            isLoading: _authController.isLoginLoading.value,
                            height: 48.h,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // Handle sign in with AuthController
                                _authController.signinUser(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text,
                                  rememberMe: _rememberMe,
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
                      // Sign Up Link
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: AppTextStyle.bodyMedium.copyWith(
                                color: Colors.black87,
                                fontSize: 15.sp,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Navigate to Sign Up
                                if (widget.accountType != null) {
                                  Get.to(
                                    SignUpScreen(
                                      accountType: widget.accountType!,
                                    ),
                                  );
                                } else {
                                  Get.to(() => const AccountTypeScreen());
                                }
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Sign Up',
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
