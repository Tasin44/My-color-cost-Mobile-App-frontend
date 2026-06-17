import 'package:color_os/app/controllers/auth_controller.dart';
import 'package:color_os/app/controllers/main_controller.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:color_os/app/views/screens/notifications/notification_screen.dart';
import 'package:get/get.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Row(
      children: [
        // Profile Picture + Greeting (tappable → Profile tab)
        GestureDetector(
          onTap: () {
            Get.find<MainController>().changeTab(4);
          },
          child: Row(
            children: [
              // Profile Picture
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.primaryColor, AppColors.secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Obx(
                  () => authController.userImage.value.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            authController.userImage.value,
                            fit: BoxFit.cover,
                            width: 48.w,
                            height: 48.w,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 24.sp,
                                ),
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                        ),
                ),
              ),
              SizedBox(width: 12.w),
              // Greeting Text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Obx(
                        () => Text(
                          authController.userName.value.isNotEmpty
                              ? 'Hi ${authController.userName.value.split(' ')[0]} '
                              : 'Hi Guest ',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Text('👋', style: TextStyle(fontSize: 20.sp)),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Here\'s what\'s happening today.',
                    style: TextStyle(fontSize: 14.sp, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Spacer(),
        // Notification Icon
        GestureDetector(
          onTap: () {
            Get.to(() => const NotificationScreen());
          },
          child: Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: Colors.black87,
              size: 22.sp,
            ),
          ),
        ),
      ],
    );
  }
}
