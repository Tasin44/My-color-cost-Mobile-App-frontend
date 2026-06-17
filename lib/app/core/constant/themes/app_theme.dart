import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';
import '../app_textstyle.dart';

class AppTheme {
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryColor,
      secondary: AppColors.secondaryColor,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black,
    ),

    // Input Decoration Theme - Based on the attached image
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF5F5F5), // Light grey background
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),

      // Border when not focused
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),

      // Border when focused
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
      ),

      // Border when there's an error
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),

      // Border when focused with error
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),

      // Border when disabled
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),

      // Hint text style
      hintStyle: AppTextStyle.bodyMedium.copyWith(
        color: const Color(0xFF9E9E9E),
        fontWeight: FontWeight.normal,
      ),

      // Label style
      labelStyle: AppTextStyle.bodyMedium.copyWith(
        color: const Color(0xFF757575),
      ),

      // Floating label style
      floatingLabelStyle: AppTextStyle.bodyMedium.copyWith(
        color: AppColors.primaryColor,
      ),

      // Error style
      errorStyle: AppTextStyle.bodySmall.copyWith(color: Colors.red),
    ),

    // Text Theme
    textTheme: TextTheme(
      displayLarge: AppTextStyle.displayLarge.copyWith(color: Colors.black),
      displayMedium: AppTextStyle.displayMedium.copyWith(color: Colors.black),
      displaySmall: AppTextStyle.displaySmall.copyWith(color: Colors.black),
      headlineLarge: AppTextStyle.headlineLarge.copyWith(color: Colors.black),
      headlineMedium: AppTextStyle.headlineMedium.copyWith(color: Colors.black),
      headlineSmall: AppTextStyle.headlineSmall.copyWith(color: Colors.black),
      titleLarge: AppTextStyle.titleLarge.copyWith(color: Colors.black),
      titleMedium: AppTextStyle.titleMedium.copyWith(color: Colors.black),
      titleSmall: AppTextStyle.titleSmall.copyWith(color: Colors.black),
      bodyLarge: AppTextStyle.bodyLarge.copyWith(color: Colors.black87),
      bodyMedium: AppTextStyle.bodyMedium.copyWith(color: Colors.black87),
      bodySmall: AppTextStyle.bodySmall.copyWith(color: Colors.black54),
      labelLarge: AppTextStyle.labelLarge.copyWith(color: Colors.black),
      labelMedium: AppTextStyle.labelMedium.copyWith(color: Colors.black),
      labelSmall: AppTextStyle.labelSmall.copyWith(color: Colors.black),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        textStyle: AppTextStyle.button,
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryColor,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        textStyle: AppTextStyle.labelLarge,
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryColor,
        side: BorderSide(color: AppColors.primaryColor, width: 1.5),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        textStyle: AppTextStyle.button,
      ),
    ),

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.black),
      titleTextStyle: AppTextStyle.titleLarge.copyWith(color: Colors.black),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryColor,
      secondary: AppColors.secondaryColor,
      surface: const Color(0xFF1E1E1E),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
    ),

    // Input Decoration Theme - Dark version
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2C2C2C), // Dark grey background
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),

      // Border when not focused
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFF3C3C3C), width: 1),
      ),

      // Border when focused
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
      ),

      // Border when there's an error
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),

      // Border when focused with error
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),

      // Border when disabled
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFF3C3C3C), width: 1),
      ),

      // Hint text style
      hintStyle: AppTextStyle.bodyMedium.copyWith(
        color: const Color(0xFF757575),
        fontWeight: FontWeight.normal,
      ),

      // Label style
      labelStyle: AppTextStyle.bodyMedium.copyWith(
        color: const Color(0xFF9E9E9E),
      ),

      // Floating label style
      floatingLabelStyle: AppTextStyle.bodyMedium.copyWith(
        color: AppColors.primaryColor,
      ),

      // Error style
      errorStyle: AppTextStyle.bodySmall.copyWith(color: Colors.red),
    ),

    // Text Theme
    textTheme: TextTheme(
      displayLarge: AppTextStyle.displayLarge,
      displayMedium: AppTextStyle.displayMedium,
      displaySmall: AppTextStyle.displaySmall,
      headlineLarge: AppTextStyle.headlineLarge,
      headlineMedium: AppTextStyle.headlineMedium,
      headlineSmall: AppTextStyle.headlineSmall,
      titleLarge: AppTextStyle.titleLarge,
      titleMedium: AppTextStyle.titleMedium,
      titleSmall: AppTextStyle.titleSmall,
      bodyLarge: AppTextStyle.bodyLarge,
      bodyMedium: AppTextStyle.bodyMedium,
      bodySmall: AppTextStyle.bodySmall,
      labelLarge: AppTextStyle.labelLarge,
      labelMedium: AppTextStyle.labelMedium,
      labelSmall: AppTextStyle.labelSmall,
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        textStyle: AppTextStyle.button,
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryColor,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        textStyle: AppTextStyle.labelLarge,
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryColor,
        side: BorderSide(color: AppColors.primaryColor, width: 1.5),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        textStyle: AppTextStyle.button,
      ),
    ),

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1E1E1E),
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: AppTextStyle.titleLarge,
    ),
  );
}
