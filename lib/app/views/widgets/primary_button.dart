import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrimaryButton extends StatelessWidget {
  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double? height;
  final double? borderRadius;
  final TextStyle? textStyle;

  const PrimaryButton({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.borderRadius,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null && !isLoading;

    return Container(
      width: width ?? double.infinity,
      height: height ?? 40.h,
      decoration: BoxDecoration(
        gradient: isDisabled ? null : AppColors.buttonGradient,
        color: isDisabled ? Colors.grey.shade300 : null,
        borderRadius: BorderRadius.circular(borderRadius ?? 16.r),
        boxShadow: isDisabled
            ? []
            : [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 16.r),
          ),
          padding: EdgeInsets.zero,
        ),
        child: isLoading
            ? SizedBox(
                width: 24.w,
                height: 24.h,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : child ??
                  Text(
                    text ?? '',
                    style:
                        textStyle ??
                        TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                  ),
      ),
    );
  }
}
