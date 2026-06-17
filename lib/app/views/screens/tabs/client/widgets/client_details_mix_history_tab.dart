import 'package:color_os/app/controllers/new_mix_controller.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/models/client_model.dart';
import 'package:color_os/app/models/mix_model.dart';
import 'package:color_os/app/views/screens/tabs/client/widgets/mix_details_bottom_sheet.dart';
import 'package:color_os/app/views/screens/tabs/client/sub-screen/all_mixes_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ClientDetailsMixHistoryTab extends StatefulWidget {
  final ClientModel client;

  const ClientDetailsMixHistoryTab({super.key, required this.client});

  @override
  State<ClientDetailsMixHistoryTab> createState() =>
      _ClientDetailsMixHistoryTabState();
}

class _ClientDetailsMixHistoryTabState
    extends State<ClientDetailsMixHistoryTab> {
  final Map<int, bool> _expandedMixes = {};
  final NewMixController _mixController = Get.isRegistered<NewMixController>()
      ? Get.find<NewMixController>()
      : Get.put(NewMixController());
  
  bool _isFetchingDetails = false;

  Future<void> _showMixDetails(MixModel basicMix) async {
    setState(() {
      _isFetchingDetails = true;
    });

    try {
      final detailedMix = await _mixController.fetchMixDetails(basicMix.id);
      
      if (detailedMix != null) {
        Get.bottomSheet(
          MixDetailsBottomSheet(mix: detailedMix),
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
        );
      } else {
        Get.snackbar(
          'Failed to retrieve details',
          'We couldn\'t load the full details for this mix. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.amber.shade700,
          colorText: Colors.white,
        );
      }
    } finally {
      setState(() {
        _isFetchingDetails = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Last Mixes',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.to(() => const AllMixesScreen()),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'See all',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (widget.client.mixHistory.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: Text(
                    'No mix history available',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
                  ),
                ),
              )
            else
              ...widget.client.mixHistory.map((mix) {
                final index = widget.client.mixHistory.indexOf(mix);
                final isExpanded = _expandedMixes[index] ?? false;
                return Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
                  child: _buildMixCard(mix, index, isExpanded),
                );
              }).toList(),
            SizedBox(height: 40.h),
          ],
        ),

        if (_isFetchingDetails)
          Container(
            color: Colors.black.withOpacity(0.1),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            ),
          ),
      ],
    );
  }

  Widget _buildMixCard(MixModel mix, int index, bool isExpanded) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
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
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
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
            SizedBox(height: 16.h),
            
            InkWell(
              onTap: () => _showMixDetails(mix),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Text(
                    'View Details',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
