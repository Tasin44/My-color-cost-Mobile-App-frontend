import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:color_os/app/controllers/shop_controller.dart';
import 'package:color_os/app/models/retailer_model.dart';
import 'package:color_os/app/models/product_model.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/views/screens/tabs/shop/product_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RetailerDetailsScreen extends StatefulWidget {
  final int retailerId;

  const RetailerDetailsScreen({super.key, required this.retailerId});

  @override
  State<RetailerDetailsScreen> createState() => _RetailerDetailsScreenState();
}

class _RetailerDetailsScreenState extends State<RetailerDetailsScreen> {
  final controller = Get.find<ShopController>();
  final Rx<RetailerDetails?> retailerDetails = Rx<RetailerDetails?>(null);
  final searchController = TextEditingController();
  final RxBool isLoading = true.obs;
  final RxBool isSearchVisible = false.obs;
  final RxString searchQuery = ''.obs;

  @override
  void initState() {
    super.initState();
    _loadRetailerDetails();
  }

  Future<void> _loadRetailerDetails() async {
    isLoading.value = true;
    try {
      final details = await controller.getRetailerDetails(widget.retailerId);
      retailerDetails.value = details;
    } finally {
      isLoading.value = false;
    }
  }

  List<RetailerProduct> _getFilteredProducts() {
    final details = retailerDetails.value;
    if (details == null) return [];
    
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) return details.products;

    return details.products.where((product) {
      return product.name.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query);
    }).toList();
  }

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
          'Retailer Details',
          style: AppTextStyle.titleLarge.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 20.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        final details = retailerDetails.value;
        if (details == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80.sp,
                  color: Colors.grey.shade300,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Failed to load retailer details',
                  style: AppTextStyle.titleMedium.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: _loadRetailerDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Retailer Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade100, width: 1.w),
                  ),
                ),
                child: Column(
                  children: [
                    // Top Info Row (Logo + Business Info)
                    Row(
                      children: [
                        // Logo
                        Container(
                          width: 54.w,
                          height: 54.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: Colors.grey.shade100,
                              width: 1.w,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: details.retailer.businessLogoUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: CachedNetworkImage(
                                    imageUrl: details.retailer.businessLogoUrl!,
                                    fit: BoxFit.contain,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.primaryColor,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.store,
                                      size: 24.sp,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : Icon(Icons.store, size: 24.sp, color: Colors.grey),
                        ),
                        SizedBox(width: 16.w),

                        // Business Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                details.retailer.businessName,
                                style: AppTextStyle.titleLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18.sp,
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
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(width: 4.w),
                                  Expanded(
                                    child: Text(
                                      details.retailer.retailerEmail,
                                      style: AppTextStyle.bodySmall.copyWith(
                                        color: Colors.grey[500],
                                        fontSize: 12.sp,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    // Delivery Info Row (Compact)
                    Row(
                      children: [
                        Expanded(
                          child: _buildCompactInfoChip(
                            icon: Icons.local_shipping_outlined,
                            label: 'Delivery',
                            value: '£${details.retailer.deliveryCharge}',
                            iconColor: AppColors.primaryColor,
                            bgColor: AppColors.primaryColor.withOpacity(0.05),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildCompactInfoChip(
                            icon: Icons.auto_awesome,
                            label: 'Free Threshold',
                            value: '£${details.retailer.freeDeliveryThreshold}',
                            iconColor: Colors.amber[700]!,
                            bgColor: Colors.amber.withOpacity(0.08),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Delivery Areas (More compact)
                    if (details.retailer.deliveryAreas.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14.sp,
                            color: Colors.grey[400],
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Delivery Service Areas:',
                            style: AppTextStyle.bodySmall.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: details.retailer.deliveryAreas.map((area) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                  width: 1.w,
                                ),
                              ),
                              child: Text(
                                area,
                                style: AppTextStyle.bodySmall.copyWith(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11.sp,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Products Section
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() => isSearchVisible.value
                            ? Expanded(
                                child: Container(
                                  height: 40.h,
                                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.search, size: 18.sp, color: Colors.grey),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: TextField(
                                          controller: searchController,
                                          onChanged: (val) => searchQuery.value = val,
                                          autofocus: true,
                                          style: AppTextStyle.bodySmall.copyWith(fontSize: 13.sp),
                                          decoration: InputDecoration(
                                            hintText: 'Search products...',
                                            hintStyle: AppTextStyle.bodySmall.copyWith(
                                              color: Colors.grey.shade400,
                                              fontSize: 12.sp,
                                            ),
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          searchController.clear();
                                          searchQuery.value = '';
                                          isSearchVisible.value = false;
                                        },
                                        child: Icon(Icons.close, size: 18.sp, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Row(
                                children: [
                                  Text(
                                    'Products',
                                    style: AppTextStyle.titleLarge.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18.sp,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    '(${details.totalProducts})',
                                    style: AppTextStyle.bodyMedium.copyWith(
                                      color: Colors.grey.shade600,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              )),
                        if (!isSearchVisible.value)
                          IconButton(
                            onPressed: () => isSearchVisible.value = true,
                            icon: Icon(Icons.search, size: 22.sp, color: Colors.black87),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Products Grid
                    Obx(() {
                      final products = _getFilteredProducts();
                      if (products.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.h),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 60.sp,
                                  color: Colors.grey.shade300,
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  searchQuery.value.isEmpty
                                      ? 'No products available'
                                      : 'No products match your search',
                                  style: AppTextStyle.bodyMedium.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12.w,
                          mainAxisSpacing: 12.h,
                          childAspectRatio: 0.80,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return _ProductCard(
                            product: product,
                            retailer: details.retailer,
                          );
                        },
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCompactInfoChip({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 16.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyle.bodySmall.copyWith(
                    color: Colors.grey[600],
                    fontSize: 10.sp,
                  ),
                ),
                Text(
                  value,
                  style: AppTextStyle.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final RetailerProduct product;
  final Retailer? retailer;

  const _ProductCard({required this.product, this.retailer});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Convert RetailerProduct to Product and navigate
        final productMap = product.toProduct();
        if (retailer != null) {
          productMap['delivery_areas'] = retailer!.deliveryAreas;
          productMap['delivery_charge'] = retailer!.deliveryCharge;
        }
        final productData = Product.fromJson(productMap);
        Get.to(() => const ProductDetailsScreen(), arguments: productData);
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade300, width: 1.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                  ),
                  child: product.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: product.imageUrl!,
                          height: 100.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 100.h,
                            color: Colors.grey.shade100,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryColor,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 100.h,
                            color: Colors.grey.shade100,
                            child: Icon(
                              Icons.image_not_supported,
                              size: 35.sp,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Container(
                          height: 100.h,
                          color: Colors.grey.shade100,
                          child: Icon(
                            Icons.image_not_supported,
                            size: 35.sp,
                            color: Colors.grey,
                          ),
                        ),
                ),
                // Promo Badge
                if (product.promoText != null)
                  Positioned(
                    bottom: 6.h,
                    left: 6.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(4.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        product.promoText!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                // Stock Status Badge
                Positioned(
                  top: 6.h,
                  right: 6.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: product.isInStock ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      product.isInStock ? 'In Stock' : 'Out',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Product Info
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(6.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product name and rating
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            product.name,
                            style: AppTextStyle.titleSmall.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 11.sp,
                              height: 1.2,
                              color: Colors.black,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 11.sp,
                                color: Colors.amber,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                product.averageRating,
                                style: AppTextStyle.bodySmall.copyWith(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                ' (${product.totalReviews})',
                                style: AppTextStyle.bodySmall.copyWith(
                                  color: Colors.grey.shade600,
                                  fontSize: 9.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 0.h),
                    // Price and quantity
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (double.parse(product.discountedMarketPrice) <
                            double.parse(product.marketPrice))
                          Text(
                            '£${product.marketPrice}',
                            style: AppTextStyle.bodySmall.copyWith(
                              color: Colors.grey.shade500,
                              fontSize: 9.sp,
                              decoration: TextDecoration.lineThrough,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '£${product.discountedMarketPrice}',
                              style: AppTextStyle.titleMedium.copyWith(
                                color: double.parse(product.discountedMarketPrice) <
                                        double.parse(product.marketPrice)
                                    ? AppColors.primaryColor
                                    : Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 13.sp,
                              ),
                            ),
                            Text(
                              'Qty: ${product.quantity}',
                              style: AppTextStyle.bodySmall.copyWith(
                                color: Colors.grey.shade600,
                                fontSize: 9.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
