import 'package:color_os/app/controllers/new_mix_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class AddMixCard extends StatelessWidget {
  const AddMixCard({super.key});

  @override
  Widget build(BuildContext context) {
    // We use Get.put to ensure the controller exists, but tag or permanent might be needed if shared
    // For now, simple put is fine as it acts as a singleton by default in GetX unless scoped
    final controller = Get.put(NewMixController());

    return InkWell(
      onTap: () {
        // Clear any pre-selected product
        controller.selectedInventoryProduct.value = null;
        controller.mixTypeController.clear();
        controller.serviceTypeController.clear();

        // Reset mix and show bowl details sheet
        controller.resetMix();
        controller.showBowlDetailsSheet();
      },
      child: Card(
        color: Colors.white,
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Mix icon circle
              Center(
                child: Container(
                  width: 70.w,
                  height: 70.h,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFC8DD),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/svg/mix_icon.svg',
                      width: 40.w,
                      height: 40.h,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Title
              Text(
                'Start your service',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(height: 8.h),

              // Subtitle
              Text(
                'Scan or search for the product you want to\nadd to your mix',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
