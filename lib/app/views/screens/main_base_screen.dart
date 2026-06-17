import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/controllers/main_controller.dart';
import 'package:color_os/app/views/screens/appointments/appointments_screen.dart';
import 'package:color_os/app/views/screens/tabs/client/client_tab.dart';
import 'package:color_os/app/views/screens/tabs/home/home_tab.dart';
import 'package:color_os/app/views/screens/tabs/profile/profile_tab.dart';
import 'package:color_os/app/views/screens/tabs/shop/shop_tab.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class MainBaseScreen extends StatelessWidget {
  MainBaseScreen({super.key});

  // Initialize controller
  final MainController controller = Get.put(MainController());

  // List of tab widgets
  final List<Widget> _tabs = const [
    HomeTab(),
    ClientTab(),
    AppointmentsScreen(),
    ShopTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => _tabs[controller.currentIndex.value]),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primaryColor,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: [
            BottomNavigationBarItem(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedHome03,
                color: Colors.grey,
              ),
              activeIcon: HugeIcon(
                icon: HugeIcons.strokeRoundedHome03,
                color: AppColors.primaryColor,
              ),
              label: 'Home',
            ),

            BottomNavigationBarItem(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedUserMultiple,
                color: Colors.grey,
              ),
              activeIcon: HugeIcon(
                icon: HugeIcons.strokeRoundedUserMultiple,
                color: AppColors.primaryColor,
              ),
              label: 'Client',
            ),
            BottomNavigationBarItem(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedCalendar03,
                color: Colors.grey,
              ),
              activeIcon: HugeIcon(
                icon: HugeIcons.strokeRoundedCalendar03,
                color: AppColors.primaryColor,
              ),
              label: 'Appointments',
            ),
            BottomNavigationBarItem(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedShoppingBag01,
                color: Colors.grey,
              ),
              activeIcon: HugeIcon(
                icon: HugeIcons.strokeRoundedShoppingBag01,
                color: AppColors.primaryColor,
              ),
              label: 'Shop',
            ),
            BottomNavigationBarItem(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedUser,
                color: Colors.grey,
              ),
              activeIcon: HugeIcon(
                icon: HugeIcons.strokeRoundedUser,
                color: AppColors.primaryColor,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
