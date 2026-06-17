import 'package:color_os/app/core/constant/app_content.dart';
import 'package:color_os/app/views/screens/dressing/dressing_screen.dart';
import 'package:color_os/app/views/widgets/gradiunt_widget.dart';
import 'package:color_os/app/core/helper/sharedpref_helper.dart';
import 'package:color_os/app/views/screens/main_base_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Check for token
    final token = await SharedprefHelper.getString(SharedprefHelper().token);
    final hasToken = token.isNotEmpty;

    debugPrint('InitialScreen: Checking auth token...');
    debugPrint('InitialScreen: Token found: $hasToken');

    if (hasToken) {
      // If user is logged in, navigate immediately
      debugPrint('InitialScreen: Navigating to MainBaseScreen');
      Get.offAll(() => MainBaseScreen());
    } else {
      // If not logged in, wait for splash then go straight to Get Started
      debugPrint('InitialScreen: No token, navigating to DressingScreen');
      await Future.delayed(const Duration(milliseconds: 2500));
      if (mounted) {
        Get.offAll(() => const DressingScreen());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: GradiuntWidget(
        child: Center(
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 2000),
            curve: Curves.easeOutBack,
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              final op = value.clamp(0.0, 1.0).toDouble();
              final eased = Curves.easeOutBack.transform(op);
              return Opacity(
                opacity: op,
                child: Transform.scale(
                  scale: 0.8 + 0.2 * eased, // small > normal
                  child: child,
                ),
              );
            },
            child: Image.asset(AppContent.appLogo, width: 200, height: 66),
          ),
        ),
      ),
    );
  }
}
