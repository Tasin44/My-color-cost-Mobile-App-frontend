import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/core/services/api_services.dart';
import 'package:color_os/app/models/api_response.dart';
import 'package:color_os/app/core/constant/api_endpoints.dart';

class PasswordChangeScreen extends StatefulWidget {
  const PasswordChangeScreen({Key? key}) : super(key: key);

  @override
  State<PasswordChangeScreen> createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
  //   final TextEditingController currentPasswordController =
  //       TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  //   bool obscureCurrentPassword = true;
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    //     currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: Colors.black87, size: 24.sp),
        ),
        title: Text(
          'Password Change',
          style: AppTextStyle.headlineSmall.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SizedBox(height: 30.h),
              // // Current Password Field
              // Text(
              //   'Current Password',
              //   style: TextStyle(
              //     fontSize: 14.sp,
              //     fontWeight: FontWeight.w600,
              //     color: Colors.black87,
              //   ),
              // ),
              // SizedBox(height: 8.h),
              // TextField(
              //   controller: currentPasswordController,
              //   obscureText: obscureCurrentPassword,
              //   style: TextStyle(fontSize: 15.sp, color: Colors.black87),
              //   decoration: InputDecoration(
              //     filled: true,
              //     fillColor: Colors.white,
              //     hintText: 'Enter current password',
              //     hintStyle: TextStyle(
              //       color: Colors.grey[400],
              //       fontSize: 15.sp,
              //     ),
              //     contentPadding: EdgeInsets.symmetric(
              //       horizontal: 16.w,
              //       vertical: 14.h,
              //     ),
              //     suffixIcon: IconButton(
              //       icon: Icon(
              //         obscureCurrentPassword
              //             ? Icons.visibility_off
              //             : Icons.visibility,
              //         color: Colors.grey[600],
              //         size: 20.sp,
              //       ),
              //       onPressed: () {
              //         setState(() {
              //           obscureCurrentPassword = !obscureCurrentPassword;
              //         });
              //       },
              //     ),
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12.r),
              //       borderSide: BorderSide.none,
              //     ),
              //     enabledBorder: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12.r),
              //       borderSide: BorderSide.none,
              //     ),
              //     focusedBorder: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12.r),
              //       borderSide: BorderSide(
              //         color: AppColors.primaryColor,
              //         width: 1.5,
              //       ),
              //     ),
              //   ),
              // ),
              SizedBox(height: 30.h),

              SizedBox(height: 18.h),

              // New Password Field
              Text(
                'New Password',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: newPasswordController,
                obscureText: obscureNewPassword,
                style: TextStyle(fontSize: 15.sp, color: Colors.black87),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Enter new password',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 15.sp,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureNewPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey[600],
                      size: 20.sp,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureNewPassword = !obscureNewPassword;
                      });
                    },
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

              SizedBox(height: 18.h),

              // Confirm New Password Field
              Text(
                'Confirm New Password',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: confirmPasswordController,
                obscureText: obscureConfirmPassword,
                style: TextStyle(fontSize: 15.sp, color: Colors.black87),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Confirm new password',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 15.sp,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey[600],
                      size: 20.sp,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword = !obscureConfirmPassword;
                      });
                    },
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

              SizedBox(height: 12.h),

              // Password Requirements
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Password Requirements:',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    _buildRequirement('At least 8 characters'),
                    _buildRequirement(
                      'Contains uppercase and lowercase letters',
                    ),
                    _buildRequirement('Contains at least one number'),
                  ],
                ),
              ),

              SizedBox(height: 30.h),

              // Change Password Button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Change Password',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // Cancel Button
              Center(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 4.h),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16.sp,
            color: Colors.blue.shade700,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12.sp, color: Colors.blue.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword() async {
    final password = newPasswordController.text;

    // Empty check
    if (password.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a new password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }

    // Minimum length
    if (password.length < 8) {
      Get.snackbar(
        'Error',
        'Password must be at least 8 characters',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }

    // Must contain uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) {
      Get.snackbar(
        'Error',
        'Password must contain at least one uppercase letter',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }

    // Must contain lowercase letter
    if (!password.contains(RegExp(r'[a-z]'))) {
      Get.snackbar(
        'Error',
        'Password must contain at least one lowercase letter',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }

    // Must contain a number
    if (!password.contains(RegExp(r'[0-9]'))) {
      Get.snackbar(
        'Error',
        'Password must contain at least one number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }

    // Confirm password match
    if (confirmPasswordController.text != password) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final body = {"new_password": password};

      final response = await ApiServices.postData(
        ApiEndpoints.resetPassword,
        body,
      );

      Get.back(); // Close loading dialog

      if (response != null &&
          (response.success ||
              ApiResponse.isSuccessfulHttpStatus(response.statusCode))) {
        Get.back(); // Navigate back first
        Get.snackbar(
          'Success',
          'Password changed successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade400,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          response?.message ?? 'Failed to change password',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      debugPrint('Error changing password: $e');
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    }
  }
}
