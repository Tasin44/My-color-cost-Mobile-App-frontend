import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';

class ReminderInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isChecked;
  final Function(bool?) onCheckChanged;
  final String label;
  final String suffix;
  final String hintText;
  final String checkboxText;

  const ReminderInput({
    Key? key,
    required this.controller,
    required this.isChecked,
    required this.onCheckChanged,
    this.label = 'Reminder',
    this.suffix = '/Days',
    this.hintText = 'enter reminder days',
    this.checkboxText = 'Remind me about this appointment,',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.titleSmall.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: AppTextStyle.bodyLarge.copyWith(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: AppTextStyle.bodyLarge.copyWith(
                      color: Colors.grey.shade400,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFB2F5EA),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12.r),
                    bottomRight: Radius.circular(12.r),
                  ),
                ),
                child: Text(
                  suffix,
                  style: AppTextStyle.bodyLarge.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            GestureDetector(
              onTap: () => onCheckChanged(!isChecked),
              child: Container(
                width: 20.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: isChecked ? const Color(0xFFFF6B9D) : Colors.white,
                  border: Border.all(
                    color: isChecked
                        ? const Color(0xFFFF6B9D)
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: isChecked
                    ? Icon(Icons.check, size: 14.sp, color: Colors.white)
                    : null,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                checkboxText,
                style: AppTextStyle.bodyMedium.copyWith(color: Colors.black87),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
