import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';

class AppointmentCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime currentMonth;
  final Function(DateTime) onDateSelected;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final bool Function(DateTime)? isDateEnabled;

  const AppointmentCalendar({
    Key? key,
    required this.selectedDate,
    required this.currentMonth,
    required this.onDateSelected,
    required this.onPreviousMonth,
    required this.onNextMonth,
    this.isDateEnabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Appointment Date',
          style: AppTextStyle.titleSmall.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              _buildHeader(),
              SizedBox(height: 12.h),
              _buildWeekDays(),
              SizedBox(height: 8.h),
              _buildDaysGrid(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: onPreviousMonth,
          child: Icon(Icons.chevron_left, color: Colors.black87, size: 24.sp),
        ),
        Row(
          children: [
            Text(
              '${months[currentMonth.month - 1]} ${currentMonth.year}',
              style: AppTextStyle.titleMedium.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(Icons.keyboard_arrow_down, color: Colors.black87, size: 20.sp),
          ],
        ),
        GestureDetector(
          onTap: onNextMonth,
          child: Icon(Icons.chevron_right, color: Colors.black87, size: 24.sp),
        ),
      ],
    );
  }

  Widget _buildWeekDays() {
    const weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekDays.map((day) {
        return SizedBox(
          width: 40.w,
          child: Center(
            child: Text(
              day,
              style: AppTextStyle.bodySmall.copyWith(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDaysGrid() {
    final daysInMonth = DateTime(
      currentMonth.year,
      currentMonth.month + 1,
      0,
    ).day;

    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);

    // Get weekday (1 = Monday, 7 = Sunday)
    // Adjust to start from Monday
    int startWeekday = firstDayOfMonth.weekday;

    final daysFromPreviousMonth = startWeekday - 1;

    final previousMonth = DateTime(currentMonth.year, currentMonth.month - 1);

    final daysInPreviousMonth = DateTime(
      previousMonth.year,
      previousMonth.month + 1,
      0,
    ).day;

    // Calculate total cells needed
    final totalCells = ((daysFromPreviousMonth + daysInMonth) / 7).ceil() * 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6.h,
        crossAxisSpacing: 6.w,
        childAspectRatio: 1.1,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        if (index < daysFromPreviousMonth) {
          // Previous month days
          final day = daysInPreviousMonth - daysFromPreviousMonth + index + 1;
          return _buildDayCell(
            day: day,
            isCurrentMonth: false,
            isSelected: false,
          );
        } else if (index < daysFromPreviousMonth + daysInMonth) {
          // Current month days
          final day = index - daysFromPreviousMonth + 1;
          final date = DateTime(currentMonth.year, currentMonth.month, day);
          final isSelected =
              date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;

          final isToday =
              DateTime.now().year == date.year &&
              DateTime.now().month == date.month &&
              DateTime.now().day == date.day;

          final isEnabled = isDateEnabled == null ? true : isDateEnabled!(date);

          return _buildDayCell(
            day: day,
            isCurrentMonth: true,
            isSelected: isSelected,
            isToday: isToday,
            isEnabled: isEnabled,
            onTap: isEnabled ? () => onDateSelected(date) : null,
          );
        } else {
          // Next month days
          final day = index - daysFromPreviousMonth - daysInMonth + 1;
          return _buildDayCell(
            day: day,
            isCurrentMonth: false,
            isSelected: false,
          );
        }
      },
    );
  }

  Widget _buildDayCell({
    required int day,
    required bool isCurrentMonth,
    required bool isSelected,
    bool isToday = false,
    bool isEnabled = true,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B9D) : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Text(
            day.toString(),
            style: AppTextStyle.bodyMedium.copyWith(
              color: isSelected
                  ? Colors.white
                  : !isEnabled
                  ? Colors.grey.shade300
                  : isCurrentMonth
                  ? (isToday ? const Color(0xFFFF6B9D) : Colors.black87)
                  : Colors.grey.shade400,
              decoration: !isEnabled ? TextDecoration.lineThrough : null,
              fontWeight: isSelected || isToday
                  ? FontWeight.w600
                  : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
