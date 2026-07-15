import 'package:color_os/app/controllers/new_mix_controller.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AllBowlsReviewScreen extends GetView<NewMixController> {
  const AllBowlsReviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Service Summary',
          style: AppTextStyle.titleLarge.copyWith(color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Client & Service info
                    Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.primaryColor.withOpacity(0.15),
                        ),
                      ),
                      child: Column(
                        children: [
                          _infoRow(
                            Icons.person_outline,
                            'Client',
                            controller.selectedClient.value?.name ?? 'Unknown',
                          ),
                          SizedBox(height: 8.h),
                          _infoRow(
                            Icons.spa_outlined,
                            'Service',
                            controller.selectedServiceType.value?.name ??
                                'Unknown',
                          ),
                          SizedBox(height: 8.h),
                          _infoRow(
                            Icons.calendar_today_outlined,
                            'Date',
                            controller.serviceDate.value != null
                                ? '${controller.serviceDate.value!.day}/${controller.serviceDate.value!.month}/${controller.serviceDate.value!.year}'
                                : 'Not set',
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Bowls section title
                    Row(
                      children: [
                        Text(
                          'Bowls',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            '${controller.bowls.length} bowl${controller.bowls.length != 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12.h),

                    // Bowl cards
                    ...controller.bowls.asMap().entries.map((entry) {
                      final index = entry.key;
                      final bowl = entry.value;

                      return Container(
                        margin: EdgeInsets.only(bottom: 16.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: Colors.grey[200]!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Bowl header
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14.w, vertical: 12.h),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(14.r),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 34.w,
                                    height: 34.w,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor
                                          .withOpacity(0.12),
                                      borderRadius:
                                          BorderRadius.circular(8.r),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          bowl.mixName,
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          bowl.serviceName,
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Edit bowl
                                  IconButton(
                                    onPressed: () => controller.editBowl(index),
                                    icon: Icon(
                                      Icons.edit_outlined,
                                      color: Colors.blueGrey[600],
                                      size: 22.sp,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  SizedBox(width: 8.w),
                                  // Copy bowl
                                  IconButton(
                                    onPressed: () => controller.copyBowl(index),
                                    icon: Icon(
                                      Icons.copy_outlined,
                                      color: Colors.blueGrey[600],
                                      size: 20.sp,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  SizedBox(width: 8.w),
                                  // Delete bowl
                                  IconButton(
                                    onPressed: () {
                                      _showDeleteConfirmation(
                                          context, index, bowl.mixName);
                                    },
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Colors.red[400],
                                      size: 22.sp,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ),

                            // Products
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14.w, vertical: 8.h),
                              child: Column(
                                children: bowl.products.map((product) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 6.h),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          size: 6.sp,
                                          color: Colors.grey[400],
                                        ),
                                        SizedBox(width: 10.w),
                                        Expanded(
                                          child: Text(
                                            product.productName,
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 1,
                                            overflow:
                                                TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          '${product.usedWeight}g',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        SizedBox(width: 12.w),
                                        Text(
                                          'Cost: £${(product.userPrice > 0 ? (product.userPrice / 100) * product.usedWeight : 0.0).toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: AppColors.primaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),

                            // Per-bowl total cost
                            Builder(builder: (_) {
                              final bowlTotal = bowl.products.fold(
                                0.0,
                                (sum, p) => sum +
                                    (p.userPrice > 0
                                        ? (p.userPrice / 100) * p.usedWeight
                                        : 0.0),
                              );
                              return Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 14.w, vertical: 10.h),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor
                                      .withOpacity(0.06),
                                  borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(14.r),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Bowl Color Cost',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: AppColors.primaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '£${bowlTotal.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        color: AppColors.primaryColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),

                            // charged_amount is now root-level on the mix (not per-bowl).
                            // It is shown once in the summary card below.
                          ],
                        ),
                      );
                    }),

                    SizedBox(height: 8.h),

                    // Add More Bowls button
                    OutlinedButton.icon(
                      onPressed: () => controller.addMoreBowls(),
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: AppColors.primaryColor,
                        size: 22.sp,
                      ),
                      label: Text(
                        'Add More Bowls',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 15.sp,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        side: BorderSide(
                            color: AppColors.primaryColor, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Total summary
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Charged',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  color: Colors.white70,
                                ),
                              ),
                              SizedBox(width: 20.w),
                              Expanded(
                                child: Obx(
                                  () => TextField(
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d+\.?\d{0,2}')),
                                    ],
                                    onChanged: (val) {
                                      final amount =
                                          double.tryParse(val) ?? 0.0;
                                      controller.setChargedAmount(amount);
                                    },
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: controller
                                                  .chargedAmount.value >
                                              0
                                          ? controller.chargedAmount.value
                                              .toStringAsFixed(2)
                                          : '0.00',
                                      hintStyle: TextStyle(
                                          fontSize: 22.sp,
                                          color: Colors.white38),
                                      prefixText: '£ ',
                                      prefixStyle: TextStyle(
                                        fontSize: 22.sp,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                      isDense: true,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Submit button
            Container(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : () => controller.submitNewMix(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      disabledBackgroundColor:
                          Colors.green.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isSubmitting.value
                        ? SizedBox(
                            width: 24.w,
                            height: 24.h,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'Save & Finish Service',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: AppColors.primaryColor),
        SizedBox(width: 10.w),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey[500],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, int index, String bowlName) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Bowl'),
        content: Text('Remove "$bowlName"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteBowl(index);
              Get.back();
            },
            child: Text('Delete',
                style: TextStyle(color: Colors.red.shade600)),
          ),
        ],
      ),
    );
  }
}
