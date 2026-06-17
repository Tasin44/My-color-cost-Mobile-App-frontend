import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OverviewHeader extends StatefulWidget {
  const OverviewHeader({super.key});

  @override
  State<OverviewHeader> createState() => _OverviewHeaderState();
}

class _OverviewHeaderState extends State<OverviewHeader> {
  String selectedFilter = 'This Month';

  final List<String> filterOptions = [
    'Today',
    'This Week',
    'This Month',
    'This Year',
    'Last 7 Days',
    'Last 30 Days',
    'Last 90 Days',
    'Custom Range',
  ];

  void _showFilterMenu() {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      items: filterOptions.map((String option) {
        return PopupMenuItem<String>(
          value: option,
          child: Row(
            children: [
              if (selectedFilter == option)
                Icon(Icons.check, size: 18.sp, color: Colors.blue)
              else
                SizedBox(width: 18.sp),
              SizedBox(width: 8.w),
              Text(
                option,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: selectedFilter == option
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: selectedFilter == option
                      ? Colors.blue
                      : Colors.black87,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ).then((String? value) {
      if (value != null && value != selectedFilter) {
        setState(() {
          selectedFilter = value;
        });
        // TODO: Implement filter logic here
        // You can call a controller method to filter data based on selection
        print('Filter changed to: $value');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Overview',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        GestureDetector(
          onTap: _showFilterMenu,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Text(
                  'Show: ',
                  style: TextStyle(fontSize: 13.sp, color: Colors.black54),
                ),
                Text(
                  selectedFilter,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 18.sp,
                  color: Colors.black87,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
