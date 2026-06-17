import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';

class WeekCalendar extends StatelessWidget {
  final List<DateTime> weekDays;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final String Function(int) getDayName;

  const WeekCalendar({
    Key? key,
    required this.weekDays,
    required this.selectedDate,
    required this.onDateSelected,
    required this.getDayName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekDays.map((date) {
          final isSelected =
              date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: _buildDayItem(
              dayName: getDayName(date.weekday),
              day: date.day.toString().padLeft(2, '0'),
              isSelected: isSelected,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDayItem({
    required String dayName,
    required String day,
    required bool isSelected,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          dayName,
          style: AppTextStyle.bodySmall.copyWith(
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFF6B9D) : Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Center(
            child: Text(
              day,
              style: AppTextStyle.bodyMedium.copyWith(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
