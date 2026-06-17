import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:flutter/cupertino.dart';

class GradiuntWidget extends StatelessWidget {
  final Widget child;
  const GradiuntWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: AppColors.primaryGradient),
      child: child,
    );
  }
}
