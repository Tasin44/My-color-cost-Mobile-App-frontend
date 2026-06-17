import 'dart:ui' as dart_ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:color_os/app/controllers/new_mix_controller.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';
import 'package:color_os/app/views/screens/newmix/widgets/step_progress_indicator.dart';
import 'package:color_os/app/views/screens/newmix/widgets/scan_barcode_button.dart';
import 'package:color_os/app/views/screens/newmix/widgets/recent_products_list.dart';
import 'package:color_os/app/views/screens/newmix/widgets/quick_tips_card.dart';
import 'package:color_os/app/views/widgets/add_mix_card.dart';

class NewMixScreen extends StatelessWidget {
  const NewMixScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NewMixController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: Colors.black87, size: 24.sp),
        ),
        centerTitle: true,
        title: Text(
          'New Mix',
          style: AppTextStyle.titleLarge.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       // Handle more options
        //     },
        //     icon: Icon(Icons.more_vert, color: Colors.black87, size: 24.sp),
        //   ),
        // ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Step progress indicator
                Obx(
                  () => StepProgressIndicator(
                    currentStep: controller.currentStep.value,
                    totalSteps: controller.totalSteps.value,
                    progress:
                        controller.currentStep.value /
                        controller.totalSteps.value,
                  ),
                ),

                SizedBox(height: 28.h),

                // Add Mix Card
                AddMixCard(),

                SizedBox(height: 8.h),

                // Scan barcode button
                ScanBarcodeButton(onPressed: controller.scanBarcode),

                SizedBox(height: 12.h),

                // Search field
                // ProductSearchField(
                //   controller: controller.searchController,
                //   onChanged: controller.searchProducts,
                // ),
                SizedBox(height: 24.h),

                // Recent products list
                Obx(() {
                  final products = controller.inventoryProducts.toList();
                  return RecentProductsList(
                    products: products,
                    onProductTap: (product) {
                      controller.selectedInventoryProduct.value = product;
                      controller.mixTypeController.clear();
                      controller.serviceTypeController.clear();

                      // Directly show bowl details sheet
                      controller.showBowlDetailsSheet();
                    },
                  );
                }),
                SizedBox(height: 20.h),

                // Quick tips card
                QuickTipsCard(),

                SizedBox(height: 20.h),
              ],
            ),
          ),

          // Loading Overlay
          Obx(() {
            if (controller.isCheckingStatus.value) {
              return Stack(
                children: [
                  // Blur effect
                  Positioned.fill(
                    child: ColoredBox(color: Colors.black.withOpacity(0.3)),
                  ),
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: dart_ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        color: Colors.transparent,
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
