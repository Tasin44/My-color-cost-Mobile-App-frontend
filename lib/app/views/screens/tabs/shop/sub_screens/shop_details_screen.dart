import 'package:cached_network_image/cached_network_image.dart';
import 'package:color_os/app/controllers/shop_controller.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/views/screens/tabs/shop/widgets/product_card.dart';
import 'package:color_os/app/views/screens/tabs/shop/widgets/request_product_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart'
    show ExtensionBottomSheet;
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class ShopDetailsScreen extends StatelessWidget {
  ShopDetailsScreen({super.key});
  final controller = Get.put(ShopController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Retailer Details')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CachedNetworkImage(
                            imageUrl:
                                'https://images-platform.99static.com//YJQkKp22e8n0PHJlYbCvpH1pElc=/130x64:936x870/fit-in/590x590/99designs-contests-attachments/93/93135/attachment_93135953',
                            height: 100.h,
                            width: 100.w,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Retailer Name',
                                  style: AppTextStyle.titleLarge.copyWith(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18.sp,
                                  ),
                                ),

                                Text(
                                  'Retailer Address',
                                  style: AppTextStyle.titleLarge.copyWith(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12.sp,
                                  ),
                                ),

                                Text(
                                  'A trusted local retailer offering quality products at fair prices for everyday needs.',
                                  style: AppTextStyle.titleLarge.copyWith(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w300,
                                    fontSize: 12.sp,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.star_rate_rounded,
                                      color: Colors.amber,
                                    ),
                                    Text(
                                      '4.5 (24+)',
                                      style: AppTextStyle.titleLarge.copyWith(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              ///---END OF PROFILE---///
              ///--- Start the body
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Products',
                    style: AppTextStyle.titleLarge.copyWith(
                      color: Colors.black87,

                      fontWeight: FontWeight.w700,
                      fontSize: 18.sp,
                    ),
                  ),
                ),
              ),
              // Products Grid
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF6B9D),
                      ),
                    );
                  }

                  if (controller.filteredProducts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 80.sp,
                            color: Colors.grey.shade300,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No products found.',
                            style: AppTextStyle.titleMedium.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 24.h),
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
                        ],
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
          ),
        ),
      ),
    );
  }
}
