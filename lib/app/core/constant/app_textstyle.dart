import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextStyle {
  // Display styles - Large text for main headings
  static TextStyle displayLarge = TextStyle(
    fontSize: 57.sp,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
    color: Colors.white,
  );

  static TextStyle displayMedium = TextStyle(
    fontSize: 45.sp,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle displaySmall = TextStyle(
    fontSize: 36.sp,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // Headline styles - Section headings
  static TextStyle headlineLarge = TextStyle(
    fontSize: 32.sp,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle headlineMedium = TextStyle(
    fontSize: 28.sp,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle headlineSmall = TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Title styles - Smaller headings and important text
  static TextStyle titleLarge = TextStyle(
    fontSize: 22.sp,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static TextStyle titleMedium = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    color: Colors.white,
  );

  static TextStyle titleSmall = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: Colors.white,
  );

  // Body styles - Regular text content
  static TextStyle bodyLarge = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
    color: Colors.white,
  );

  static TextStyle bodyMedium = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
    color: Colors.white,
  );

  static TextStyle bodySmall = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    color: Colors.white,
  );

  // Label styles - Button text and labels
  static TextStyle labelLarge = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: Colors.white,
  );

  static TextStyle labelMedium = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: Colors.white,
  );

  static TextStyle labelSmall = TextStyle(
    fontSize: 11.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: Colors.white,
  );

  // Custom styles for specific use cases
  static TextStyle button = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.25,
    color: Colors.white,
  );

  static TextStyle caption = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    color: Colors.white,
  );

  static TextStyle overline = TextStyle(
    fontSize: 10.sp,
    fontWeight: FontWeight.normal,
    letterSpacing: 1.5,
    color: Colors.white,
  );
}
