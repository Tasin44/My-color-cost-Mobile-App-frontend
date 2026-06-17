import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';

class TimePicker extends StatelessWidget {
  final int selectedHour;
  final int selectedMinute;
  final String selectedPeriod; // AM or PM
  final Function(int) onHourChanged;
  final Function(int) onMinuteChanged;
  final Function(String) onPeriodChanged;

  const TimePicker({
    Key? key,
    required this.selectedHour,
    required this.selectedMinute,
    required this.selectedPeriod,
    required this.onHourChanged,
    required this.onMinuteChanged,
    required this.onPeriodChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Appointment Time',
          style: AppTextStyle.titleSmall.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hour picker
              _buildNumberPicker(
                value: selectedHour,
                minValue: 1,
                maxValue: 12,
                onChanged: onHourChanged,
              ),

              SizedBox(width: 8.w),

              // Colon separator
              Text(
                ':',
                style: AppTextStyle.headlineSmall.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(width: 8.w),

              // Minute picker
              _buildNumberPicker(
                value: selectedMinute,
                minValue: 0,
                maxValue: 59,
                onChanged: onMinuteChanged,
                twoDigits: true,
              ),

              SizedBox(width: 20.w),

              // AM/PM picker
              _buildPeriodPicker(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNumberPicker({
    required int value,
    required int minValue,
    required int maxValue,
    required Function(int) onChanged,
    bool twoDigits = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            int newValue = value + 1;
            if (newValue > maxValue) newValue = minValue;
            onChanged(newValue);
          },
          child: Icon(
            Icons.keyboard_arrow_up,
            size: 24.sp,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: 50.w,
          alignment: Alignment.center,
          child: Text(
            twoDigits ? value.toString().padLeft(2, '0') : value.toString(),
            style: AppTextStyle.headlineSmall.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () {
            int newValue = value - 1;
            if (newValue < minValue) newValue = maxValue;
            onChanged(newValue);
          },
          child: Icon(
            Icons.keyboard_arrow_down,
            size: 24.sp,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodPicker() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            onPeriodChanged(selectedPeriod == 'AM' ? 'PM' : 'AM');
          },
          child: Icon(
            Icons.keyboard_arrow_up,
            size: 24.sp,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: 60.w,
          alignment: Alignment.center,
          child: Text(
            selectedPeriod,
            style: AppTextStyle.titleLarge.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () {
            onPeriodChanged(selectedPeriod == 'AM' ? 'PM' : 'AM');
          },
          child: Icon(
            Icons.keyboard_arrow_down,
            size: 24.sp,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
