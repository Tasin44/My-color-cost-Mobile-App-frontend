import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductIconCircle extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double size;

  const ProductIconCircle({
    Key? key,
    required this.icon,
    this.backgroundColor = const Color(0xFFFFC8DD),
    this.iconColor = const Color(0xFFFF6B9D),
    this.size = 120,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.h,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Center(
        child: Icon(icon, size: (size * 0.5).sp, color: iconColor),
      ),
    );
  }
}
