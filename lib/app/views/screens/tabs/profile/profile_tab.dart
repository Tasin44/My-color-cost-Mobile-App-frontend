import 'package:color_os/app/controllers/auth_controller.dart';
import 'package:color_os/app/controllers/profile_controller.dart';
import 'package:color_os/app/controllers/appointment_controller.dart';
import 'package:color_os/app/views/screens/onboarding/working_hours_setup_sheet.dart';
import 'package:color_os/app/views/screens/subscription/subscription_screen.dart';
import 'package:color_os/app/views/screens/initial/initial_screen.dart';
import 'package:color_os/app/views/screens/tabs/profile/sub/accounts_department_screen.dart';
import 'package:color_os/app/views/screens/newmix/all_recent_bowls_screen.dart';
import 'package:color_os/app/views/screens/appointments/all_appointments_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:color_os/app/core/helper/sharedpref_helper.dart';

import 'package:color_os/app/core/constant/app_textstyle.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/views/screens/tabs/profile/sub/edit_profile_screen.dart';
import 'package:color_os/app/views/screens/tabs/profile/sub/monthly_expenses_screen.dart';
import 'package:color_os/app/views/screens/tabs/profile/sub/password_change_screen.dart';
import 'package:color_os/app/views/screens/tabs/profile/sub/generate_link_bottom_sheet.dart';
import 'package:color_os/app/views/screens/tabs/profile/sub/affiliate_screen.dart';
import 'package:color_os/app/views/screens/tabs/profile/sub/my_products_screen.dart';
import 'package:color_os/app/core/constant/app_static_text.dart';
import 'package:color_os/app/views/screens/profile/sub/static_content_screen.dart';
import 'package:color_os/app/views/screens/tabs/profile/sub/services/services_list_screen.dart';
import 'package:get/get.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Profile',
          style: AppTextStyle.headlineSmall.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: const SizedBox(),
      ),
      body: Obx(() {
        final image = authController.userImage.value;
        final name = authController.userName.value;
        final user = controller.user.value; // Keep for other fields if needed

        return RefreshIndicator(
          onRefresh: () async {
            await authController.fetchProfile();
            await controller
                .refreshData(); // Optionally refresh profile controller data too
          },
          color: AppColors.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: 20.h),

                // Profile Picture
                Container(
                  width: 100.w,
                  height: 100.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryColor, width: 3),
                  ),
                  child: ClipOval(
                    child: (image.isNotEmpty && !image.contains('example.com'))
                        ? Image.network(
                            image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.person,
                                  color: AppColors.primaryColor,
                                  size: 50.sp,
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Icon(
                              Icons.person,
                              color: AppColors.primaryColor,
                              size: 50.sp,
                            ),
                          ),
                  ),
                ),

                SizedBox(height: 16.h),

                // User Name
                Text(
                  name.isNotEmpty ? name : 'Guest User',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                if (user?.email != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    user!.email,
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                ],

                SizedBox(height: 12.h),

                // Subscription Status Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: Colors.orange.shade800,
                        size: 16.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        controller.isTrialActive.value
                            ? (controller.trialDaysRemaining.value.isNotEmpty
                                  ? controller.trialDaysRemaining.value
                                  : 'Subscribed')
                            : 'Standard Plan',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30.h),

                // Menu Options Container
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20.w),
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.person_outline,
                        title: 'Edit Profile Info',
                        onTap: () {
                          // Navigate to edit profile
                          Get.to(() => const EditProfileScreen());
                        },
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.person_outline,
                        title: 'Add Monthly Expense',
                        onTap: () {
                          // Navigate to monthly expenses list
                          Get.to(() => const MonthlyExpensesScreen());
                        },
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.history_rounded,
                        title: 'Saved Mix History',
                        onTap: () {
                          Get.to(() => const AllRecentBowlsScreen());
                        },
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.inventory_2_outlined,
                        title: 'My Products',
                        onTap: () {
                          Get.to(() => const MyProductsScreen());
                        },
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.lock_outline,
                        title: 'Password Change',
                        onTap: () {
                          // Navigate to password change
                          Get.to(() => const PasswordChangeScreen());
                        },
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.card_membership_outlined,
                        title: 'Subscription Plan',
                        onTap: () {
                          // Navigate to subscription plan
                          Get.to(() => const SubscriptionScreen());
                        },
                      ),
                      _buildDivider(),
                      if (user != null && !user.isStaff) ...[
                        _buildMenuItem(
                          icon: Icons.people_outline,
                          title: 'Affiliate Program',
                          onTap: () {
                            Get.to(() => const AffiliateScreen());
                          },
                        ),
                        _buildDivider(),
                      ],
                      // Notification Toggle (Simplified for now)
                      _buildMenuItem(
                        icon: Icons.notifications_none,
                        title: 'Notification',
                        onTap: () {},
                        trailing: Switch(
                          value: user?.notificationEnabled ?? false,
                          onChanged: (val) {
                            controller.toggleNotifications(val);
                          },
                          activeColor: AppColors.primaryColor,
                        ),
                      ),

                      _buildDivider(),
                      if (user != null && !user.isStaff) ...[
                        _buildMenuItem(
                          icon: Icons.account_balance,
                          title: 'Accounts Department',
                          onTap: () {
                            Get.to(() => const AccountsDepartmentScreen());
                          },
                        ),
                        _buildDivider(),
                      ],
                      if (user != null &&
                          (user.isSalonOwner || user.isSelfEmployed)) ...[
                        _buildMenuItem(
                          icon: Icons.access_time,
                          title: 'Working Hours',
                          onTap: () {
                            Get.to(() => const WorkingHoursSetupSheet());
                          },
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.design_services_outlined,
                          title: 'Services List',
                          onTap: () {
                            Get.to(() => const ServicesListScreen());
                          },
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          icon: Icons.event_note_outlined,
                          title: 'View All Appointments',
                          onTap: () {
                            // Ensure AppointmentController is available
                            if (!Get.isRegistered<AppointmentController>()) {
                              Get.put(AppointmentController());
                            }
                            Get.to(() => const AllAppointmentsScreen());
                          },
                        ),
                        _buildDivider(),
                      ],
                      _buildMenuItem(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        onTap: () {
                          Get.to(() => const StaticContentScreen(
                                title: AppStaticText.privacyPolicyTitle,
                                content: AppStaticText.privacyPolicyContent,
                              ));
                        },
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.description_outlined,
                        title: 'Terms & Conditions',
                        onTap: () {
                          Get.to(() => const StaticContentScreen(
                                title: AppStaticText.termsConditionsTitle,
                                content: AppStaticText.termsConditionsContent,
                              ));
                        },
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.logout,
                        title: 'Log Out',
                        onTap: () {
                          _showLogoutDialog(context);
                        },
                        isLogout: true,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30.h),

                // Appointment Link Section (always visible, fresh check on every tap)
                Obx(() {
                  final user = authController.user.value;
                  if (user != null && user.isStaff) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 16.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Appointment Link',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Share your booking URL with clients',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                          Obx(() => ElevatedButton(
                            onPressed: controller.isGeneratingLink.value
                                ? null
                                : () async {
                                    final success = await controller
                                        .checkAndGenerateAppointmentLink();
                                    if (success) {
                                      _showBookingUrlSheet(
                                        context,
                                        controller.appointmentLink.value,
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 10.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              elevation: 0,
                            ),
                            child: controller.isGeneratingLink.value
                                ? SizedBox(
                                    width: 16.w,
                                    height: 16.w,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Generate Link',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          )),
                        ],
                      ),
                    ),
                  );
                }),

                SizedBox(height: 40.h),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showBookingUrlSheet(BuildContext context, String url) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(
          24.w,
          20.h,
          24.w,
          24.h + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            // Icon
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9B26AF), Color(0xFFE0177A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.link_rounded, color: Colors.white, size: 28.sp),
            ),
            SizedBox(height: 14.h),
            Text(
              'Your Booking Link',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Share this link with your clients so they can book directly.',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade500,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            // URL box
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: SelectableText(
                url,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: url));
                  Get.back();
                  Get.snackbar(
                    'Copied!',
                    'Booking link copied to clipboard',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green.shade600,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2),
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                  );
                },
                icon: Icon(Icons.copy_rounded, size: 18.sp),
                label: Text(
                  'Copy Link',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22.sp,
              color: isLogout ? Colors.red : Colors.black87,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: isLogout ? Colors.red : Colors.black87,
                ),
              ),
            ),
            if (trailing != null)
              trailing
            else
              Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: isLogout ? Colors.red : Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[200],
      indent: 20.w,
      endIndent: 20.w,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 24.h),

              // Power/Logout Icon
              Container(
                width: 50.w,
                height: 50.h,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.power_settings_new,
                  color: Colors.red,
                  size: 28.sp,
                ),
              ),
              SizedBox(height: 20.h),

              // Title
              Text(
                'Are you sure want to Logout?',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),

              // Subtitle
              Text(
                'Thank you and see you again!',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),

              // Buttons Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        // Perform logout
                        await SharedprefHelper.remove(
                          SharedprefHelper().token,
                        ); // Assuming token key

                        // Clear navigation and go to initial route
                        Get.offAll(() => const InitialScreen());

                        Get.snackbar(
                          'Logged Out',
                          'You have been logged out successfully',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green.shade400,
                          colorText: Colors.white,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Yes, Logout',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }
}
