import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/models/mix_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class MixDetailsBottomSheet extends StatelessWidget {
  final MixModel mix;

  const MixDetailsBottomSheet({super.key, required this.mix});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        // bottom: false — home-indicator height is folded into the scroll
        // padding below so it doesn't create an empty gap inside the sheet.
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.symmetric(vertical: 16.h),
              width: 45.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  28.w,
                  8.h,
                  28.w,
                  40.h + MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mix.mixName,
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                mix.serviceType,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'PROFIT',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.green.shade800,
                                  letterSpacing: 1,
                                ),
                              ),
                              Text(
                                '£${mix.profit.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 28.h),

                    // Key Stats Row
                    Row(
                      children: [
                        _buildQuickStat(
                          Icons.calendar_today_rounded,
                          DateFormat('dd MMM yyyy').format(mix.date),
                          'Service Date',
                        ),
                        SizedBox(width: 16.w),
                        _buildQuickStat(
                          Icons.payments_outlined,
                          '£${mix.chargedAmount.toStringAsFixed(2)}',
                          'Amount Charged',
                        ),
                      ],
                    ),

                    SizedBox(height: 32.h),

                    // Products Section
                    Text(
                      'PRODUCT BREAKDOWN',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey[400],
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    ...mix.products.map((product) => _buildProductItem(product)),

                    if (mix.products.isEmpty)
                      Center(
                        child: Text(
                          'No detailed product info available',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),

                    SizedBox(height: 32.h),

                    // Financial Summary
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(color: Colors.grey[100]!),
                      ),
                      child: Column(
                        children: [
                          _buildSummaryRow('Service Material Cost', '£${mix.totalCost.toStringAsFixed(2)}'),
                          SizedBox(height: 12.h),
                          _buildSummaryRow('Service Price', '£${mix.chargedAmount.toStringAsFixed(2)}'),
                          Divider(height: 32.h, color: Colors.grey[200]),
                          _buildSummaryRow(
                            'Estimated Profit',
                            '£${mix.profit.toStringAsFixed(2)}',
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),

                    // PDF Download (Placeholder UI as per json having pdf_url)
                    if (mix.pdfUrl != null && mix.pdfUrl!.isNotEmpty) ...[
                      SizedBox(height: 24.h),
                      SizedBox(
                        width: double.infinity,
                        height: 56.h,
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          label: const Text('Download Service PDF'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.grey[100]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primaryColor, size: 20.sp),
            SizedBox(height: 12.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey[500],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(MixProduct product) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                '£${product.cost.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildProductTag(Icons.scale_rounded, '${product.usedWeight}g Used'),
              SizedBox(width: 12.w),
              if (product.isBleachTimerOn)
                _buildProductTag(
                  Icons.timer_outlined, 
                  product.bleachTimerDuration ?? 'Timer On', 
                  color: Colors.orange.shade800,
                  bgColor: Colors.orange.shade50
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductTag(IconData icon, String label, {Color? color, Color? bgColor}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.grey[50],
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color ?? Colors.grey[600]),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: color ?? Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: isTotal ? Colors.black : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20.sp : 14.sp,
            fontWeight: FontWeight.w800,
            color: isTotal ? Colors.green.shade800 : Colors.black87,
          ),
        ),
      ],
    );
  }
}
