import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';
import '../../../widgets/primary_button.dart';

class ScanBarcodeButton extends StatelessWidget {
  final Function() onPressed;
  final String text;

  const ScanBarcodeButton({
    Key? key,
    required this.onPressed,
    this.text = 'Scan Product Barcode',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      onPressed: onPressed,
      height: 56.h,
      borderRadius: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_scanner, color: Colors.white, size: 22.sp),
          SizedBox(width: 10.w),
          Text(
            text,
            style: AppTextStyle.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
