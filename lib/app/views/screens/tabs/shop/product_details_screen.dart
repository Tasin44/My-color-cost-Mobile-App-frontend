import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:color_os/app/controllers/product_details_controller.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';
import 'package:color_os/app/views/screens/tabs/shop/widgets/rating_breakdown.dart';
import 'package:color_os/app/views/screens/tabs/shop/widgets/review_card.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductDetailsController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar with back button and menu
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            pinned: true,
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: Icon(Icons.arrow_back, color: Colors.black87, size: 20.sp),
            ),
            title: Text(
              'Product Details',
              style: AppTextStyle.titleLarge.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
              ),
            ),
            // actions: [
            //   IconButton(
            //     onPressed: () {},
            //     icon: Icon(Icons.more_vert, color: Colors.black87, size: 20.sp),
            //   ),
            // ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  height: 280.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    color: Colors.grey.shade200,
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: controller.product.imageUrl.isNotEmpty
                      ? Image.network(
                          controller.product.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.inventory_2_outlined,
                                size: 50.sp,
                                color: Colors.grey.shade400,
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Icon(
                            Icons.inventory_2_outlined,
                            size: 50.sp,
                            color: Colors.grey.shade400,
                          ),
                        ),
                ),

                SizedBox(height: 16.h),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name and Rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.product.name,
                                  style: AppTextStyle.titleLarge.copyWith(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18.sp,
                                  ),
                                ),
                                if (controller.product.retailer != 'Unknown')
                                  Text(
                                    'Sold by: ${controller.product.retailer}',
                                    style: AppTextStyle.bodySmall.copyWith(
                                      color: const Color(0xFFFF6B9D),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16.sp,
                              ),
                              SizedBox(width: 4.w),
                              Obx(
                                () => Text(
                                  controller.averageRating.value
                                      .toStringAsFixed(1),
                                  style: AppTextStyle.titleMedium.copyWith(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      // Price and Quantity
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (controller.product.discountedPrice < controller.product.price)
                                Text(
                                  '£${controller.product.price.toStringAsFixed(2)}',
                                  style: AppTextStyle.bodyMedium.copyWith(
                                    color: Colors.grey.shade500,
                                    fontSize: 16.sp,
                                    decoration: TextDecoration.lineThrough,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              Text(
                                '£${controller.product.discountedPrice.toStringAsFixed(2)}',
                                style: AppTextStyle.headlineMedium.copyWith(
                                  color: controller.product.discountedPrice < controller.product.price
                                      ? const Color(0xFFFE4C82)
                                      : Colors.black87,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 24.sp,
                                ),
                              ),
                              if (controller.product.vat > 0)
                                Text(
                                  '+ £${controller.product.vat.toStringAsFixed(2)} VAT',
                                  style: AppTextStyle.bodySmall.copyWith(
                                    color: Colors.grey.shade600,
                                    fontSize: 10.sp,
                                  ),
                                )
                              else
                                Text(
                                  'VAT Included',
                                  style: AppTextStyle.bodySmall.copyWith(
                                    color: Colors.green.shade600,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),

                          // Quantity Selector
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: controller.decrementQuantity,
                                  icon: Icon(
                                    Icons.remove,
                                    size: 16.sp,
                                    color: Colors.black87,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                  ),
                                  child: Obx(
                                    () => Text(
                                      controller.quantity.value.toString(),
                                      style: AppTextStyle.titleMedium.copyWith(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: controller.incrementQuantity,
                                  icon: Icon(
                                    Icons.add,
                                    size: 16.sp,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Promotion Info
                      if (controller.product.promoIsActive && controller.product.promoText != null) ...[
                        SizedBox(height: 12.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B9D).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: const Color(0xFFFF6B9D).withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.local_offer_outlined, color: const Color(0xFFFF6B9D), size: 18.sp),
                              SizedBox(width: 8.w),
                              Text(
                                controller.product.promoText!,
                                style: AppTextStyle.bodyMedium.copyWith(
                                  color: const Color(0xFFFF6B9D),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      SizedBox(height: 20.h),

                      // Delivery Info
                      if (controller.product.deliveryAreas.isNotEmpty) ...[
                        Text(
                          'Delivery Information',
                          style: AppTextStyle.titleMedium.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined,
                                      size: 16.sp, color: Colors.grey.shade600),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      'Available in: ${controller.product.deliveryAreas.join(", ")}',
                                      style: AppTextStyle.bodySmall.copyWith(
                                          color: Colors.grey.shade700),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  Icon(Icons.delivery_dining_outlined,
                                      size: 16.sp, color: Colors.grey.shade600),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Delivery Charge: £${controller.product.deliveryCharge.toStringAsFixed(2)}',
                                    style: AppTextStyle.bodySmall.copyWith(
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),
                      ],

                      // Description Preview
                      Text(
                        'Description Preview',
                        style: AppTextStyle.titleMedium.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      SizedBox(height: 10.h),

                      Obx(
                        () => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.product.description ??
                                  'A professional-grade amber pump bottle designed for everyday salon use. Ideal for storing liquid hair colour, peroxide, developers....',
                              style: AppTextStyle.bodyMedium.copyWith(
                                color: Colors.grey.shade700,
                                height: 1.5,
                              ),
                              maxLines: controller.isDescriptionExpanded.value
                                  ? null
                                  : 3,
                              overflow: controller.isDescriptionExpanded.value
                                  ? null
                                  : TextOverflow.ellipsis,
                            ),
                            GestureDetector(
                              onTap: controller.toggleDescription,
                              child: Text(
                                controller.isDescriptionExpanded.value
                                    ? 'see less'
                                    : 'see more',
                                style: AppTextStyle.bodyMedium.copyWith(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Rating Breakdown
                      Obx(
                        () => RatingBreakdown(
                          averageRating: controller.averageRating.value,
                          totalRatings: controller.totalRatings.value,
                          ratingBreakdown: controller.ratingBreakdown,
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Reviews Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(
                            () => Text(
                              '${controller.reviews.length} reviews',
                              style: AppTextStyle.titleMedium.copyWith(
                                color: Colors.black87,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12.h),

                      // Reviews List
                      Obx(() {
                        if (controller.isLoadingReviews.value) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(
                                color: Color(0xFFFF6B9D),
                              ),
                            ),
                          );
                        }

                        if (controller.reviews.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40.h),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.rate_review_outlined,
                                    size: 50.sp,
                                    color: Colors.grey.shade300,
                                  ),
                                  SizedBox(height: 12.h),
                                  Text(
                                    'No reviews yet',
                                    style: AppTextStyle.bodyMedium.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: controller.reviews
                              .map((review) => ReviewCard(review: review))
                              .toList(),
                        );
                      }),

                      SizedBox(height: 80.h), // Space for FAB
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Add to Cart / View Cart FAB
      floatingActionButton: Obx(
        () => FloatingActionButton.extended(
          onPressed: controller.isAddedToCart.value
              ? controller.viewCart
              : controller.addToCart,
          backgroundColor: const Color(0xFF4CAF50),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
          icon: Icon(
            controller.isAddedToCart.value
                ? Icons.shopping_cart
                : Icons.shopping_cart_outlined,
            color: Colors.white,
            size: 18.sp,
          ),
          label: Text(
            controller.isAddedToCart.value ? 'View Cart' : 'Add to Cart',
            style: AppTextStyle.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
