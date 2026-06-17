import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';

class ClientSelector extends StatelessWidget {
  final String? selectedClient;
  final VoidCallback onTap;
  final String hintText;

  const ClientSelector({
    Key? key,
    this.selectedClient,
    required this.onTap,
    this.hintText = 'select client',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Client',
              style: AppTextStyle.titleSmall.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            GestureDetector(
              onTap: onTap,
              child: Text(
                'Select',
                style: AppTextStyle.titleSmall.copyWith(
                  color: const Color(0xFFFF6B9D),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300, width: 1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedClient ?? hintText,
                    style: AppTextStyle.bodyLarge.copyWith(
                      color: selectedClient == null
                          ? Colors.grey.shade400
                          : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey.shade600,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
