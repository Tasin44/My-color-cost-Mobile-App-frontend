import 'package:color_os/app/views/screens/account_type/account_type_screen.dart';
import 'package:color_os/app/views/screens/auth/signin/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:get/get.dart';

class DressingScreen extends StatefulWidget {
  const DressingScreen({super.key});

  @override
  State<DressingScreen> createState() => _DressingScreenState();
}

class _DressingScreenState extends State<DressingScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subtitleFade;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _buttonFade;
  late Animation<Offset> _buttonSlide;
  late Animation<double> _loginFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _titleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
          ),
        );

    _subtitleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
    );
    _subtitleSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
          ),
        );

    _buttonFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
    );
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
          ),
        );

    _loginFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset('assets/images/dressing_image.jpg', fit: BoxFit.cover),
          // Gradient overlay - stronger at the bottom for better text readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.5, 1.0],
                colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.5),
                  Colors.black.withOpacity(0.85),
                ],
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  FadeTransition(
                    opacity: _titleFade,
                    child: SlideTransition(
                      position: _titleSlide,
                      child: Text(
                        'Profits simplified, margins amplified.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.15,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  // Subtitle
                  FadeTransition(
                    opacity: _subtitleFade,
                    child: SlideTransition(
                      position: _subtitleSlide,
                      child: Text(
                        'Track costs, manage appointments, and discover\ninsights that grow your business.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 25.h),
                  // Get Start Button
                  FadeTransition(
                    opacity: _buttonFade,
                    child: SlideTransition(
                      position: _buttonSlide,
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to next screen
                          Get.to(AccountTypeScreen());
                        },
                        child: Container(
                          width: double.infinity,
                          height: 60.h,
                          padding: EdgeInsets.all(4.r),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40.r),
                            border: Border.all(
                              color: AppColors.primaryColor.withOpacity(0.5),
                              width: 1.5,
                            ),
                            color: Colors.black.withOpacity(0.4),
                          ),
                          child: Row(
                            children: [
                              // Inner Capsule
                              Container(
                                padding: EdgeInsets.fromLTRB(
                                  6.w,
                                  4.h,
                                  16.w,
                                  4.h,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30.r),
                                  color: const Color(0xFF262626),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8.r),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.primaryColor,
                                      ),
                                      child: Icon(
                                        Icons.brush,
                                        color: Colors.white,
                                        size: 18.sp,
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Text(
                                      'Get Start',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              // Arrows
                              Row(
                                children: [
                                  Icon(
                                    Icons.chevron_right,
                                    size: 14.sp,
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    size: 18.sp,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    size: 24.sp,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                              SizedBox(width: 12.w),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Log In Link
                  FadeTransition(
                    opacity: _loginFade,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 15.sp,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.to(() => const SignInScreen());
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Log In',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
