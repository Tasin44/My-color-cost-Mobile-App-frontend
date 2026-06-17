import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/core/services/revenue_cat_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Example Paywall Screen for Premium Subscriptions
/// This is a ready-to-use paywall screen that you can customize
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({Key? key}) : super(key: key);

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final RevenueCatService _revenueCat = RevenueCatService();
  bool _isLoading = true;
  bool _isPurchasing = false;
  List<Package> _packages = [];
  int _selectedPackageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    setState(() => _isLoading = true);

    try {
      await _revenueCat.refreshOfferings();
      final packages = _revenueCat.availablePackages;

      setState(() {
        _packages = packages;
        _isLoading = false;

        // Select annual package by default if available
        final annualIndex = packages.indexWhere(
          (p) => p.packageType == PackageType.annual,
        );
        if (annualIndex != -1) {
          _selectedPackageIndex = annualIndex;
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar(
        'Error',
        'Failed to load subscription plans',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _purchasePackage(Package package) async {
    setState(() => _isPurchasing = true);

    try {
      final customerInfo = await _revenueCat.purchasePackage(package);

      if (customerInfo != null) {
        // Purchase successful
        Get.back(result: true);
        Get.snackbar(
          'Success',
          'Welcome to Premium!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isPurchasing = false);
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _isPurchasing = true);

    try {
      final customerInfo = await _revenueCat.restorePurchases();

      if (customerInfo != null && customerInfo.entitlements.active.isNotEmpty) {
        Get.back(result: true);
        Get.snackbar(
          'Success',
          'Purchases restored successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Info',
          'No purchases found to restore',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to restore purchases',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isPurchasing = false);
    }
  }

  String _getPackageTitle(Package package) {
    switch (package.packageType) {
      case PackageType.monthly:
        return 'Monthly';
      case PackageType.annual:
        return 'Annual';
      case PackageType.lifetime:
        return 'Lifetime';
      default:
        return 'Premium';
    }
  }

  String _getPackageDescription(Package package) {
    switch (package.packageType) {
      case PackageType.monthly:
        return 'Billed monthly';
      case PackageType.annual:
        return 'Best value - Save 50%';
      case PackageType.lifetime:
        return 'One-time payment';
      default:
        return 'Premium access';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        children: [
                          // Header
                          Icon(
                            Icons.workspace_premium,
                            size: 80.sp,
                            color: AppColors.primaryColor,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Go Premium',
                            style: TextStyle(
                              fontSize: 32.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Unlock all features and get the best experience',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 32.h),

                          // Features List
                          _buildFeature('Unlimited color mixing'),
                          _buildFeature('Advanced analytics'),
                          _buildFeature('Premium support'),
                          _buildFeature('Ad-free experience'),
                          _buildFeature('Cloud backup'),
                          _buildFeature('Export all data'),

                          SizedBox(height: 32.h),

                          // Package Selection
                          if (_packages.isNotEmpty) ...[
                            ..._packages.asMap().entries.map((entry) {
                              final index = entry.key;
                              final package = entry.value;
                              return _buildPackageCard(
                                package,
                                isSelected: _selectedPackageIndex == index,
                                onTap: () {
                                  setState(() => _selectedPackageIndex = index);
                                },
                              );
                            }),
                          ] else
                            const Text('No subscription plans available'),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Actions
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 50.h,
                          child: ElevatedButton(
                            onPressed: _isPurchasing || _packages.isEmpty
                                ? null
                                : () => _purchasePackage(
                                    _packages[_selectedPackageIndex],
                                  ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: _isPurchasing
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Continue',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        TextButton(
                          onPressed: _isPurchasing ? null : _restorePurchases,
                          child: Text(
                            'Restore Purchases',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFeature(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.primaryColor, size: 24.sp),
          SizedBox(width: 12.w),
          Text(
            text,
            style: TextStyle(fontSize: 16.sp, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(
    Package package, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final product = package.storeProduct;
    final isBestValue = package.packageType == PackageType.annual;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.1)
              : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                // Selection indicator
                Container(
                  width: 24.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryColor
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                    color: isSelected ? AppColors.primaryColor : Colors.white,
                  ),
                  child: isSelected
                      ? Icon(Icons.check, size: 16.sp, color: Colors.white)
                      : null,
                ),
                SizedBox(width: 12.w),

                // Package info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getPackageTitle(package),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _getPackageDescription(package),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Price
                Text(
                  product.priceString,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),

            // Best value badge
            if (isBestValue)
              Positioned(
                top: -8.h,
                right: -8.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    'BEST VALUE',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
