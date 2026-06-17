import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/models/client_model.dart';
import 'package:color_os/app/views/screens/tabs/client/sub-screen/all_mixes_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ClientDetailsOverviewTab extends StatelessWidget {
  final ClientModel client;

  const ClientDetailsOverviewTab({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Personal Information Section
          _buildSectionTitle('Personal Information'),
          SizedBox(height: 12.h),
          _buildInfoRow('Contact Number', client.contactNumber),
          SizedBox(height: 10.h),
          _buildInfoRow(
            'Skin Test Date',
            client.skinTestDate != null
                ? DateFormat('dd MMM yyyy').format(client.skinTestDate!)
                : 'Not set',
            isHighlighted: client.skinTestDate != null,
          ),
          SizedBox(height: 10.h),
          _buildInfoRow('Preferred Service', client.serviceType),

          SizedBox(height: 28.h),

          // Last Mixes Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle('Last Mixes'),
              TextButton(
                onPressed: () => Get.to(() => const AllMixesScreen()),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size(50.w, 30.h),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'See all',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Mix Cards
          if (client.mixHistory.isNotEmpty)
            ...client.mixHistory
                .take(3)
                .map(
                  (mix) => Column(
                    children: [
                      _buildMixCard(mix),
                      SizedBox(height: 10.h),
                    ],
                  ),
                )
          else
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32.h),
                child: Text(
                  'No mix history available',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
                ),
              ),
            ),

          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isHighlighted = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            color: isHighlighted ? Colors.orange : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMixCard(mix) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mix.serviceType,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  DateFormat('dd MMM yyyy').format(mix.date),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Cost: £${mix.totalCost.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Profit: £${mix.profit.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.green,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
