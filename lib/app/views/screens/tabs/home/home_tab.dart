import 'package:color_os/app/controllers/auth_controller.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/controllers/home_controller.dart';
import 'package:color_os/app/views/screens/newmix/new_mix_screen.dart';
import 'package:color_os/app/views/screens/newmix/offline_mix_calculator_screen.dart';
import 'package:color_os/app/controllers/offline_mix_controller.dart';
import 'package:color_os/app/views/screens/tabs/client/add_new_client_screen.dart';
import 'package:color_os/app/views/screens/tabs/home/widgets/animated_stat_card.dart';
import 'package:color_os/app/views/screens/tabs/home/widgets/earnings_overview.dart';
import 'package:color_os/app/views/screens/tabs/home/widgets/home_header.dart';
import 'package:color_os/app/views/screens/tabs/home/widgets/overview_header.dart';
import 'package:color_os/app/views/screens/tabs/home/widgets/today_appointments.dart';
import 'package:color_os/app/views/widgets/add_mix_card.dart';
import 'package:color_os/app/controllers/new_mix_controller.dart';
import 'package:color_os/app/views/screens/newmix/widgets/scan_barcode_button.dart';
import 'package:color_os/app/controllers/working_hours_controller.dart';
import 'package:color_os/app/views/screens/tabs/home/widgets/setup_required_banner.dart';
import 'package:color_os/app/views/screens/appointments/appointments_screen.dart';
import 'package:color_os/app/views/screens/onboarding/working_hours_setup_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final RxBool _isSpeedDialOpen = false.obs;

  @override
  void initState() {
    super.initState();
    // Initialize HomeController
    Get.put(HomeController());

    // Refresh user profile
    try {
      Get.find<AuthController>().fetchProfile();
    } catch (e) {
      debugPrint('AuthController not found in HomeTab: $e');
    }

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSpeedDial() {
    _isSpeedDialOpen.value = !_isSpeedDialOpen.value;
    if (_isSpeedDialOpen.value) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final newMixController = Get.put(NewMixController());
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: controller.refreshData,
              color: AppColors.primaryColor,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                physics:
                    const AlwaysScrollableScrollPhysics(), // Ensure it's always scrollable for refresh
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    const HomeHeader(),
                    SizedBox(height: 12.h),

                    // Working Hours Setup Banner
                    _buildSetupBanner(),

                    // Add Mix Card
                    const AddMixCard(),
                    SizedBox(height: 12.h),

                    // Scan barcode button
                    ScanBarcodeButton(onPressed: newMixController.scanBarcode),
                    SizedBox(height: 24.h),

                    // Overview Section
                    const OverviewHeader(),
                    SizedBox(height: 16.h),

                    // Stats Cards
                    _buildStatsGrid(),
                    SizedBox(height: 24.h),

                    // Earnings Overview
                    const EarningsOverview(),
                    SizedBox(height: 24.h),

                    // Today Appointments
                    const TodayAppointments(),
                  ],
                ),
              ),
            ),
            // Backdrop overlay
            Obx(
              () => _isSpeedDialOpen.value
                  ? GestureDetector(
                      onTap: _toggleSpeedDial,
                      child: Container(color: Colors.black.withOpacity(0.3)),
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildSpeedDial(),
    );
  }

  Widget _buildSpeedDial() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Book Appointment
        _buildSpeedDialOption(
          label: 'Book Appointment',
          icon: Icons.calendar_month,
          color: AppColors.primaryColor,
          onTap: () {
            _toggleSpeedDial();
            _handleAppointmentNavigation();
          },
        ),
        SizedBox(height: 16.h),
        // Full mix creation flow (online)
        _buildSpeedDialOption(
          label: 'New Mix (Save to Records)',
          icon: Icons.science_outlined,
          color: AppColors.primaryColor,
          onTap: () {
            _toggleSpeedDial();
            final mixController = Get.isRegistered<NewMixController>()
                ? Get.find<NewMixController>()
                : Get.put(NewMixController());
            mixController.resetMix();
            Get.to(() => const NewMixScreen());
          },
        ),
        SizedBox(height: 16.h),
        // Offline colour cost calculator
        _buildSpeedDialOption(
          label: 'Mix Calculator (Offline)',
          icon: Icons.calculate_outlined,
          color: AppColors.primaryColor,
          onTap: () {
            _toggleSpeedDial();
            // Ensure a fresh controller instance for each session
            if (Get.isRegistered<OfflineMixController>()) {
              Get.delete<OfflineMixController>();
            }
            Get.to(() => const OfflineMixCalculatorScreen());
          },
        ),
        SizedBox(height: 16.h),
        // Add Client
        _buildSpeedDialOption(
          label: 'Add Client',
          icon: Icons.person_add,
          color: AppColors.primaryColor,
          onTap: () {
            _toggleSpeedDial();
            Get.to(() => const AddNewClientScreen());
          },
        ),
        SizedBox(height: 16.h),
        // Main FAB with Gradient
        GestureDetector(
          onTap: _toggleSpeedDial,
          child: Container(
            width: 56.w,
            height: 56.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.buttonGradient,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: RotationTransition(
                turns: Tween(begin: 0.0, end: 0.125).animate(_animation),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedAdd01,
                  color: Colors.white,
                  size: 32.sp,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeedDialOption({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ScaleTransition(
      scale: _animation,
      child: FadeTransition(
        opacity: _animation,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Label
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            // Icon button
            FloatingActionButton(
              heroTag: label,
              onPressed: onTap,
              backgroundColor: Colors.white,
              mini: true,
              elevation: 4,
              child: Icon(icon, color: color, size: 24.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final controller = Get.find<HomeController>();

    return Obx(() {
      if (controller.stats.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      final statsList = controller.stats;
      final icons = [
        Icons.palette_outlined, // Total Mixes
        Icons.attach_money, // Total Revenue
        Icons.trending_up, // Total Profit
        Icons.shopping_bag_outlined, // Total Cost
      ];
      final colors = [
        const Color(0xFF4CAF50), // Green for Total Mixes
        AppColors.primaryColor, // Primary for Total Revenue
        const Color(0xFFFFA726), // Orange for Total Profit
        AppColors.secondaryColor, // Secondary for Total Cost
      ];

      return Column(
        children: [
          Row(
            children: [
              if (statsList.length > 0)
                Expanded(
                  child: AnimatedStatCard(
                    icon: icons[0],
                    iconColor: colors[0],
                    title: statsList[0].title,
                    value: statsList[0].value,
                    change: statsList[0].change,
                    isPositive: statsList[0].isPositive,
                    animationDelay: 0,
                  ),
                ),
              SizedBox(width: 12.w),
              if (statsList.length > 1)
                Expanded(
                  child: AnimatedStatCard(
                    icon: icons[1],
                    iconColor: colors[1],
                    title: statsList[1].title,
                    value: statsList[1].value,
                    change: statsList[1].change,
                    isPositive: statsList[1].isPositive,
                    animationDelay: 100,
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              if (statsList.length > 2)
                Expanded(
                  child: AnimatedStatCard(
                    icon: icons[2],
                    iconColor: colors[2],
                    title: statsList[2].title,
                    value: statsList[2].value,
                    change: statsList[2].change,
                    isPositive: statsList[2].isPositive,
                    animationDelay: 200,
                  ),
                ),
              SizedBox(width: 12.w),
              if (statsList.length > 3)
                Expanded(
                  child: AnimatedStatCard(
                    icon: icons[3],
                    iconColor: colors[3],
                    title: statsList[3].title,
                    value: statsList[3].value,
                    change: statsList[3].change,
                    isPositive: statsList[3].isPositive,
                    animationDelay: 300,
                  ),
                ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildSetupBanner() {
    if (!Get.isRegistered<WorkingHoursController>()) {
      return const SizedBox.shrink();
    }

    final workingHoursController = Get.find<WorkingHoursController>();
    return Obx(() {
      if (workingHoursController.isLocked.value) {
        return const SizedBox.shrink();
      }
      return const SetupRequiredBanner();
    });
  }

  void _handleAppointmentNavigation() {
    final authController = Get.find<AuthController>();
    final isSalonOwner = authController.user.value?.isSalonOwner == true;

    if (isSalonOwner) {
      if (!Get.isRegistered<WorkingHoursController>()) {
        Get.to(() => const AppointmentsScreen());
        return;
      }

      final workingHoursController = Get.find<WorkingHoursController>();
      if (!workingHoursController.isLocked.value) {
        Get.snackbar(
          'Setup Required',
          'Please set up your working hours before booking appointments.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          mainButton: TextButton(
            onPressed: () {
              Get.back();
              Get.to(() => const WorkingHoursSetupSheet());
            },
            child: const Text('SETUP', style: TextStyle(color: Colors.white)),
          ),
        );
        return;
      }
    }

    Get.to(() => const AppointmentsScreen());
  }
}
