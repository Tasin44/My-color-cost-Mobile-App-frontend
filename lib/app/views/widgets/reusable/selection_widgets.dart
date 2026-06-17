import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';

/// Reusable selection card widget that can be used throughout the app
class SelectionCard extends StatelessWidget {
  final String title;
  final String description;
  final Widget icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showRecommended;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;

  const SelectionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.showRecommended = false,
    this.backgroundColor,
    this.borderColor,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: padding ?? EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? (borderColor ?? AppColors.primaryColor)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: (borderColor ?? AppColors.primaryColor).withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            icon,

            SizedBox(width: 16.w),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTextStyle.titleMedium.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (showRecommended) ...[
                        SizedBox(width: 8.w),
                        _buildRecommendedBadge(),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: AppTextStyle.bodySmall.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),

            // Selection Indicator
            _buildSelectionIndicator(),
          ],
        ),
      ),
    );
  }

  /// Build selection indicator (radio button)
  Widget _buildSelectionIndicator() {
    return Container(
      width: 24.w,
      height: 24.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? (borderColor ?? AppColors.primaryColor)
              : const Color(0xFFD1D5DB),
          width: 2,
        ),
        color: isSelected
            ? (borderColor ?? AppColors.primaryColor)
            : Colors.transparent,
      ),
      child: isSelected
          ? Icon(Icons.circle, size: 12.w, color: Colors.white)
          : null,
    );
  }

  /// Build recommended badge
  Widget _buildRecommendedBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        'Recommended',
        style: AppTextStyle.labelSmall.copyWith(
          color: AppColors.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Gradient button widget for consistent styling
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double? height;
  final List<Color>? gradientColors;
  final BorderRadiusGeometry? borderRadius;
  final TextStyle? textStyle;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.gradientColors,
    this.borderRadius,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? 56.h,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(16.r),
        gradient: onPressed != null
            ? (gradientColors != null
                  ? LinearGradient(
                      colors: gradientColors!,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : AppColors.primaryGradient)
            : null,
        color: onPressed == null ? Colors.grey[300] : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(16.r),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20.w,
                height: 20.h,
                child: CircularProgressIndicator(
                  color: onPressed != null ? Colors.white : Colors.grey[600],
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style:
                    textStyle ??
                    AppTextStyle.button.copyWith(
                      color: onPressed != null
                          ? Colors.white
                          : Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
              ),
      ),
    );
  }
}

/// Icon container widget for consistent icon styling
class IconContainer extends StatelessWidget {
  final Widget icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;
  final BorderRadiusGeometry? borderRadius;

  const IconContainer({
    super.key,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    this.size,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final containerSize = size ?? 48.w;

    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primaryColor.withOpacity(0.1),
        borderRadius: borderRadius ?? BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Theme(
          data: Theme.of(context).copyWith(
            iconTheme: IconThemeData(
              color: iconColor ?? AppColors.primaryColor,
              size: containerSize * 0.5,
            ),
          ),
          child: icon,
        ),
      ),
    );
  }
}
