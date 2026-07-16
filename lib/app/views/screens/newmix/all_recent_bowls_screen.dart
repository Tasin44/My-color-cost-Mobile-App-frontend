import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/controllers/new_mix_controller.dart';
import 'package:color_os/app/models/mix_model.dart';
import 'package:intl/intl.dart';
import 'package:color_os/app/views/screens/newmix/steps/select_client_screen.dart';

class AllRecentBowlsScreen extends StatefulWidget {
  const AllRecentBowlsScreen({Key? key}) : super(key: key);

  @override
  State<AllRecentBowlsScreen> createState() => _AllRecentBowlsScreenState();
}

class _AllRecentBowlsScreenState extends State<AllRecentBowlsScreen> {
  late NewMixController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<NewMixController>();
    // Always refresh when opening from profile
    controller.fetchRecentMixes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: Colors.black87, size: 24.sp),
        ),
        title: Text(
          'Mix History',
          style: AppTextStyle.headlineSmall.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingMixes.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.recentMixes.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchRecentMixes(),
          color: AppColors.primaryColor,
          child: CustomScrollView(
            slivers: [
              // Summary Banner
              SliverToBoxAdapter(child: _buildSummaryBanner()),

              // List
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final mix = controller.recentMixes[index];
                    return _buildMixCard(mix);
                  }, childCount: controller.recentMixes.length),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 24.h)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSummaryBanner() {
    final mixes = controller.recentMixes;
    final totalProfit = mixes.fold<double>(0, (sum, m) => sum + m.profit);
    final totalCharged = mixes.fold<double>(
      0,
      (sum, m) => sum + m.chargedAmount,
    );

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              label: 'Total Mixes',
              value: '${mixes.length}',
              icon: Icons.science_outlined,
            ),
          ),
          Container(width: 1, height: 40.h, color: Colors.white30),
          Expanded(
            child: _buildSummaryItem(
              label: 'Total Charged',
              value: '£${totalCharged.toStringAsFixed(2)}',
              icon: Icons.payments_outlined,
            ),
          ),
          Container(width: 1, height: 40.h, color: Colors.white30),
          Expanded(
            child: _buildSummaryItem(
              label: 'Total Profit',
              value: '£${totalProfit.toStringAsFixed(2)}',
              icon: Icons.trending_up_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 18.sp),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildMixCard(MixModel mix) {
    final formattedDate = DateFormat('d MMM yyyy').format(mix.date);
    final bool hasCharge = mix.chargedAmount > 0;
    final bool isProfit = mix.profit > 0;
    final bool isLoss = mix.profit < 0;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row — icon + name + date
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44.w,
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.science_outlined,
                    color: AppColors.primaryColor,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mix.mixName,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      if (mix.serviceType.isNotEmpty)
                        Text(
                          mix.serviceType,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[500],
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[400],
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (mix.bowlCount > 0 ? Colors.blue : Colors.grey)
                                .withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        '${mix.bowlCount} bowl${mix.bowlCount == 1 ? '' : 's'}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: mix.bowlCount > 0
                              ? Colors.blue[700]
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 12.h),
            Divider(color: Colors.grey[100], height: 1),
            SizedBox(height: 10.h),

            // Financial Row
            Row(
              children: [
                _buildFinancialChip(
                  label: 'Cost',
                  value: '£${mix.totalCost.toStringAsFixed(2)}',
                  color: Colors.orange,
                ),
                SizedBox(width: 8.w),
                _buildFinancialChip(
                  label: 'Charged',
                  value: hasCharge
                      ? '£${mix.chargedAmount.toStringAsFixed(2)}'
                      : '—',
                  color: Colors.blue,
                ),
                SizedBox(width: 8.w),
                _buildFinancialChip(
                  label: 'Profit',
                  value: isLoss
                      ? '-£${mix.profit.abs().toStringAsFixed(2)}'
                      : isProfit
                      ? '£${mix.profit.toStringAsFixed(2)}'
                      : '£0.00',
                  color: isProfit
                      ? Colors.green
                      : isLoss
                      ? Colors.red
                      : Colors.grey,
                ),
              ],
            ),

            // Client & Created By row
            if (mix.clientName != null || mix.createdBy != null) ...[
              SizedBox(height: 10.h),
              Row(
                children: [
                  // Client name chip
                  if (mix.clientName != null) ...[
                    Icon(
                      Icons.person_pin_outlined,
                      size: 13.sp,
                      color: AppColors.primaryColor,
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        '${mix.clientName!}${mix.clientId != null ? ' (ID: ${mix.clientId})' : ''}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 10.w),
                  ] else if (mix.clientId == null) ...[
                    TextButton(
                      onPressed: () {
                        Get.to(() => SelectClientScreen(
                              mixId: int.tryParse(mix.id),
                            ));
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            size: 13.sp,
                            color: AppColors.primaryColor,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Add Client',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10.w),
                  ],
                  // Created by
                  if (mix.createdBy != null) ...[
                    Flexible(
                      child: Text(
                        mix.createdBy!.name,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey[500],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        mix.createdBy!.type,
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: Colors.purple[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: color.withOpacity(0.9),
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 9.sp, color: color.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: () => controller.fetchRecentMixes(),
      color: AppColors.primaryColor,
      child: ListView(
        children: [
          SizedBox(height: 120.h),
          Center(
            child: Column(
              children: [
                Container(
                  width: 100.w,
                  height: 100.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.history_rounded,
                    size: 48.sp,
                    color: Colors.grey[350],
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'No Mix History',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Your saved mixes will appear here',
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
