import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:color_os/app/controllers/shop_controller.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/views/screens/tabs/shop/retailer_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AllRetailersScreen extends StatefulWidget {
  const AllRetailersScreen({super.key});

  @override
  State<AllRetailersScreen> createState() => _AllRetailersScreenState();
}

class _AllRetailersScreenState extends State<AllRetailersScreen> {
  final TextEditingController searchController = TextEditingController();
  final controller = Get.find<ShopController>();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'All Retailers',
          style: AppTextStyle.titleLarge.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 20.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(20.w),
            child: TextField(
              controller: searchController,
              onChanged: (value) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search retailers...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ),

          // Retailers List
          Expanded(
            child: Obx(() {
              if (controller.isLoadingRetailers.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                );
              }

              final retailers = controller.retailers.where((retailer) {
                final query = searchController.text.toLowerCase();
                return retailer.businessName.toLowerCase().contains(query) ||
                    retailer.retailerEmail.toLowerCase().contains(query);
              }).toList();

              if (retailers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.store_outlined,
                        size: 80.sp,
                        color: Colors.grey.shade300,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No retailers found',
                        style: AppTextStyle.titleMedium.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: retailers.length,
                itemBuilder: (context, index) {
                  final retailer = retailers[index];
                  return InkWell(
                    onTap: () => Get.to(
                      () => RetailerDetailsScreen(retailerId: retailer.id),
                    ),
                    child: Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Retailer Logo
                          Container(
                            width: 60.w,
                            height: 60.w,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1.w,
                              ),
                            ),
                            child: retailer.businessLogoUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: CachedNetworkImage(
                                      imageUrl: retailer.businessLogoUrl!,

                                      placeholder: (context, url) =>
                                          const Center(
                                            child: CircularProgressIndicator(
                                              color: AppColors.primaryColor,
                                            ),
                                          ),
                                      errorWidget: (context, url, error) =>
                                          Icon(
                                            Icons.store,
                                            size: 30.sp,
                                            color: Colors.grey,
                                          ),
                                    ),
                                  )
                                : Icon(
                                    Icons.store,
                                    size: 30.sp,
                                    color: Colors.grey,
                                  ),
                          ),
                          SizedBox(width: 12.w),

                          // Retailer Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  retailer.businessName,
                                  style: AppTextStyle.titleMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15.sp,
                                    color: Colors.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4.h),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.email_outlined,
                                      size: 13.sp,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 4.w),
                                    Expanded(
                                      child: Text(
                                        retailer.retailerEmail,
                                        style: AppTextStyle.bodySmall.copyWith(
                                          color: Colors.grey.shade600,
                                          fontSize: 11.sp,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.h),
                                // Delivery info wrapped in Flexible
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.local_shipping_outlined,
                                      size: 13.sp,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 4.w),
                                    Flexible(
                                      child: Wrap(
                                        spacing: 6.w,
                                        runSpacing: 2.h,
                                        children: [
                                          Text(
                                            'Delivery: \$${retailer.deliveryCharge}',
                                            style: AppTextStyle.bodySmall
                                                .copyWith(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 11.sp,
                                                ),
                                          ),
                                          Text(
                                            'Free Threshold \$${retailer.freeDeliveryThreshold}',
                                            style: AppTextStyle.bodySmall
                                                .copyWith(
                                                  color: AppColors.primaryColor,
                                                  fontSize: 11.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Arrow Icon
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16.sp,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
