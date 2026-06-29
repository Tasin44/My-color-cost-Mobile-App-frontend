import 'package:color_os/app/controllers/auth_controller.dart';
import 'package:color_os/app/views/screens/tabs/shop/all_products_screen.dart';
import 'package:color_os/app/views/screens/tabs/shop/all_retailers_screen.dart';
import 'package:color_os/app/views/screens/tabs/shop/retailer_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:color_os/app/controllers/shop_controller.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';
import 'package:color_os/app/views/screens/tabs/shop/widgets/shop_search_bar.dart';
import 'package:color_os/app/views/screens/tabs/shop/widgets/product_card.dart';
import 'package:color_os/app/views/screens/tabs/shop/my_cart_view.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/views/screens/tabs/shop/widgets/request_product_sheet.dart';

class ShopTab extends StatelessWidget {
  const ShopTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ShopController());
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          final user = authController.user.value;
          
          if (user != null && user.isStaff) {
            return _buildRestrictedAccessView();
          }

          return Column(
            children: [
              // Header with title and cart icon
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Text(
                      'Shop',
                      style: AppTextStyle.titleLarge.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w700,
                        fontSize: 20.sp,
                      ),
                    ),

                    // Cart Icon
                    InkWell(
                      onTap: () {
                        Get.to(() => const MyCartView());
                      },
                      borderRadius: BorderRadius.circular(10.r),
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 24.sp,
                              color: Colors.black87,
                            ),
                            // Cart badge
                            Obx(() {
                              final itemCount = controller.cartItemsCount;
                              if (itemCount == 0) return const SizedBox();
                              return Positioned(
                                right: -6,
                                top: -6,
                                child: Container(
                                  padding: EdgeInsets.all(4.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 18.w,
                                    minHeight: 18.h,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$itemCount',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: ShopSearchBar(
                  controller: controller.searchController,
                  onFilterTap: controller.openFilters,
                ),
              ),

              SizedBox(height: 8.h),

              SizedBox(
                height: 160.h,
                width: Get.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Retailers',
                            style: AppTextStyle.titleLarge.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.w700,
                              fontSize: 18.sp,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.to(() => const AllRetailersScreen());
                            },
                            child: Text(
                              'View All',
                              style: AppTextStyle.bodyMedium.copyWith(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoadingRetailers.value) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryColor,
                            ),
                          );
                        }

                        if (controller.filteredRetailers.isEmpty) {
                          return Center(
                            child: Text(
                              'No retailers available',
                              style: AppTextStyle.bodySmall.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          itemCount: controller.filteredRetailers.length > 10
                              ? 10
                              : controller.filteredRetailers.length,
                          itemBuilder: (context, index) {
                            final retailer = controller.filteredRetailers[index];
                            return InkWell(
                              onTap: () => Get.to(
                                () => RetailerDetailsScreen(
                                  retailerId: retailer.id,
                                ),
                              ),
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 3.w),
                                width: 100.w,
                                padding: EdgeInsets.all(0.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    width: 1.w,
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 100.w,
                                      height: 75.h,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10.r),
                                          topRight: Radius.circular(10.r),
                                        ),
                                      ),
                                      child: retailer.businessLogoUrl != null
                                          ? Padding(
                                              padding: EdgeInsets.all(2.w),
                                              child: Image.network(
                                                retailer.businessLogoUrl!,
                                                fit: BoxFit.contain,
                                                errorBuilder:
                                                    (context, error, stackTrace) {
                                                      return Icon(
                                                        Icons.store,
                                                        size: 25.sp,
                                                        color: Colors.grey,
                                                      );
                                                    },
                                              ),
                                            )
                                          : Icon(
                                              Icons.store,
                                              size: 25.sp,
                                              color: Colors.grey,
                                            ),
                                    ),
                                    SizedBox(height: 6.h),
                                    Flexible(
                                      child: Text(
                                        retailer.businessName,
                                        style: AppTextStyle.bodySmall.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10.sp,
                                          color: Colors.black,
                                        ),
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
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
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => Text(
                        controller.totalProducts.value > 0
                            ? 'Products (${controller.totalProducts.value})'
                            : 'Products',
                        style: AppTextStyle.titleLarge.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w700,
                          fontSize: 18.sp,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.to(() => const AllProductsScreen());
                      },
                      child: Text(
                        'View All',
                        style: AppTextStyle.bodyMedium.copyWith(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Products Grid
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFFFF6B9D)),
                    );
                  }

                  if (controller.filteredProducts.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 28.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 72.sp,
                              color: Colors.grey.shade300,
                            ),
                            SizedBox(height: 20.h),
                            Text(
                              'No products found, but tell us what product you\'re after, the brand it belongs to, and we will go and get it.',
                              style: AppTextStyle.bodyMedium.copyWith(
                                color: Colors.grey.shade700,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 12.h),
                            ElevatedButton.icon(
                              onPressed: () {
                                Get.bottomSheet(
                                  RequestProductSheet(controller: controller),
                                  isScrollControlled: true,
                                );
                              },
                              icon: const Icon(
                                Icons.add_circle_outline,
                                color: Colors.white,
                              ),
                              label: const Text('Request Missing Product'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24.w,
                                  vertical: 12.h,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h),
                            Text(
                              'Thank you for your patience, we are still growing and developing our shop. By telling us what you need, we are able to grow quicker. 🌱',
                              style: AppTextStyle.bodySmall.copyWith(
                                color: Colors.grey.shade500,
                                height: 1.6,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 10.h,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 16.h,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: controller.filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = controller.filteredProducts[index];
                      return ProductCard(
                        product: product,
                        onTap: () => controller.viewProductDetails(product),
                        onAddToCart: () => controller.addToCart(product),
                      );
                    },
                  );
                }),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildRestrictedAccessView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 64.sp,
                color: AppColors.primaryColor,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Shopping Not Available',
              style: AppTextStyle.headlineSmall.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            Text(
              'This feature is only available for Salon Owners and Self-Employed professionals. Please contact your administrator if you believe this is an error.',
              style: AppTextStyle.bodyMedium.copyWith(
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
