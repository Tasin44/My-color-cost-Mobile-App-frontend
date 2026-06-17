import 'dart:io';
import 'package:color_os/app/controllers/affiliate_controller.dart';
import 'package:color_os/app/controllers/profile_controller.dart';
import 'package:color_os/app/core/helper/sharedpref_helper.dart';
import 'package:color_os/app/views/screens/main_base_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../widgets/primary_button.dart';

class SubscriptionScreen extends StatefulWidget {
  final bool? isBack = false;
  const SubscriptionScreen({super.key});

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selectedPlan = 1; // Default to Annual for best value
  final TextEditingController _referCodeController = TextEditingController();
  final AffiliateController _affiliateController = Get.put(
    AffiliateController(),
  );

  @override
  void initState() {
    super.initState();
    _affiliateController.fetchSubscriptionStatus();

    // Auto-navigate away if already subscribed
    ever(_affiliateController.hasActiveSubscription, (bool subscribed) {
      if (subscribed && mounted) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted && _affiliateController.hasActiveSubscription.value) {
            Get.offAll(() => MainBaseScreen());
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _referCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: widget.isBack!
            ? const BackButton(color: Colors.black)
            : const SizedBox(),
        title: const Text(
          'Premium Access',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Skip option for testing purposes
          TextButton(
            onPressed: () => Get.offAll(() => MainBaseScreen()),
            child: Text(
              'Skip',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        if (_affiliateController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final isSubscribed = _affiliateController.hasActiveSubscription.value;

        if (isSubscribed) {
          final subDetails = _affiliateController
              .subscriptionData
              .value
              ?.data
              ?.subscriptionDetails;
          final planType =
              _affiliateController.subscriptionData.value?.data?.planType ??
              'Premium';
          final endDate =
              subDetails?.subscriptionEndDate ?? subDetails?.trialEndDate;

          return Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green.shade600,
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Already Subscribed!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You have an active $planType plan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  if (endDate != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Valid until: $endDate',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      text: 'Continue to App',
                      onPressed: () => Get.offAll(() => MainBaseScreen()),
                      borderRadius: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // 7-Day Free Trial Banner
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer_outlined, color: Colors.orange.shade800),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Start your 7-Day Free Trial today!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Main Title
              const Text(
                'Unlock Full Potential',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Get unlimited access to all features.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Feature List
              _buildFeatureItem(
                Icons.science_outlined,
                'Unlimited Mix Creation',
                'Create and save complex color formulas for every client.',
              ),
              _buildFeatureItem(
                Icons.qr_code_scanner,
                'Premium Barcode Scanner',
                'Identify products and manage inventory in seconds.',
              ),
              _buildFeatureItem(
                Icons.calendar_month_outlined,
                'Smart Booking System',
                'Manage salon appointments and client schedules effortlessly.',
              ),
              _buildFeatureItem(
                Icons.analytics_outlined,
                'Performance & Goal Tracking',
                'Track your salon profits and performance with real-time data.',
              ),
              _buildFeatureItem(
                Icons.person_outline,
                'Client History Card',
                'Detailed color history and digital notes for every client.',
              ),
              _buildFeatureItem(
                Icons.inventory_2_outlined,
                'Inventory Control',
                'Real-time tracking of stock levels and usage.',
              ),

              const SizedBox(height: 32),

              // View Only Mode Warning
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'After the trial ends:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'If you cancel or don\'t pay, your account will switch to "View-Only Mode". You can view data availability but features like scanning & booking will be locked.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Plans
              _buildPlanOption(
                index: 0,
                title: 'Monthly',
                price: '£19.99',
                period: '/month',
                trialText: '7 days free',
              ),
              const SizedBox(height: 12),
              _buildPlanOption(
                index: 1,
                title: 'Annual',
                price: '£235',
                period: '/year',
                trialText: '7 days free',
                badge: 'Best Value',
              ),

              const SizedBox(height: 24),

              // Referral Code Field
              TextFormField(
                controller: _referCodeController,
                decoration: InputDecoration(
                  labelText: 'Referral Code (Optional)',
                  hintText: 'Enter refer code',
                  prefixIcon: const Icon(Icons.redeem, color: Colors.pink),
                  suffixIcon: Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: Obx(() {
                      if (_affiliateController.isSearchingReferrer.value) {
                        return SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }
                      return TextButton(
                        onPressed: () {
                          if (_referCodeController.text.isNotEmpty) {
                            _affiliateController.searchReferrer(
                              _referCodeController.text,
                            );
                          }
                        },
                        child: Text(
                          'Apply',
                          style: TextStyle(
                            color: Colors.pink,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      );
                    }),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.pink, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),

              // Referrer Profile Info
              Obx(() {
                final referrer = _affiliateController.referrerProfile.value;
                if (referrer == null) return const SizedBox();

                return Container(
                  margin: EdgeInsets.only(top: 12.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.pink.shade100),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18.r,
                        backgroundColor: Colors.pink.shade100,
                        backgroundImage: referrer['profile_image'] != null
                            ? NetworkImage(referrer['profile_image'])
                            : null,
                        child: referrer['profile_image'] == null
                            ? Icon(
                                Icons.person,
                                size: 20.sp,
                                color: Colors.pink.shade400,
                              )
                            : null,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Referred by: ${referrer['name'] ?? 'Unknown'}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                                color: Colors.pink.shade800,
                              ),
                            ),
                            Text(
                              referrer['email'] ?? '',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.pink.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Colors.pink.shade400,
                          size: 20.sp,
                        ),
                        onPressed: () {
                          _affiliateController.referrerProfile.value = null;
                          _referCodeController.clear();
                        },
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 32),

              // Subscribe Button
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: 'Start 7-Day Free Trial',
                  onPressed: () {
                    _simulatePurchase(context);
                  },
                  height: 56, // Matching visual weight
                  borderRadius: 12,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No charge until trial ends. Cancel anytime.',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.pink, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanOption({
    required int index,
    required String title,
    required String price,
    required String period,
    String? trialText,
    String? badge,
  }) {
    bool isSelected = _selectedPlan == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? Colors.grey.shade50 : Colors.white,
        ),
        child: Row(
          children: [
            Radio<int>(
              value: index,
              groupValue: _selectedPlan,
              onChanged: (val) => setState(() => _selectedPlan = val!),
              activeColor: Colors.black,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (trialText != null)
                    Text(
                      trialText,
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  period,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _simulatePurchase(BuildContext context) {
    // Detect platform
    final isAndroid = Platform.isAndroid;
    final storeName = isAndroid ? "Google Play" : "App Store";
    final providerName = isAndroid ? "Google" : "Apple";

    // State for the simulation
    final RxString status = "Connecting to $storeName...".obs;
    final RxDouble progress = 0.0.obs;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      isAndroid
                          ? 'assets/icons/play_store.png'
                          : 'assets/icons/apple_store.png',
                      width: 24.w,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        isAndroid ? Icons.shop : Icons.apple,
                        color: isAndroid ? Colors.blue : Colors.black,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      storeName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              _selectedPlan == 0 ? "Color OS Monthly" : "Color OS Annual",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              _selectedPlan == 0
                  ? "7 days free, then £19.99/mo"
                  : "7 days free, then £235/yr",
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
            ),
            SizedBox(height: 24.h),
            Obx(
              () => Column(
                children: [
                  LinearProgressIndicator(
                    value: progress.value,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.green.shade600,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    status.value,
                    style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            const Divider(),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.info_outline, size: 16.sp, color: Colors.grey),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    "Your subscription will start automatically after the 7-day trial.",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
      isDismissible: false,
      enableDrag: false,
    );

    // Simulation sequence
    Future(() async {
      await Future.delayed(const Duration(seconds: 1));
      progress.value = 0.3;
      status.value = "Authenticating with $storeName...";

      await Future.delayed(const Duration(seconds: 1));
      progress.value = 0.6;
      status.value = "Verifying payment method...";

      await Future.delayed(const Duration(seconds: 1));
      progress.value = 0.9;
      status.value = "$providerName review in progress...";

      await Future.delayed(const Duration(seconds: 1));

      // Call the real subscription API
      final String plan = _selectedPlan == 0 ? "monthly" : "yearly";
      final bool success = await _affiliateController.createSubscription(
        referralCode: _referCodeController.text.trim(),
        subscriptionPlan: plan,
      );

      if (!success) {
        Get.back(); // Close bottom sheet
        return;
      }

      // Save trial data locally as well
      await SharedprefHelper.setString(
        SharedprefHelper.subscriptionStatus,
        'trial',
      );
      await SharedprefHelper.setString(
        SharedprefHelper.trialStartDate,
        DateTime.now().toIso8601String(),
      );

      // Refresh UI in controllers
      try {
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().checkTrialStatus();
        }
      } catch (e) {
        debugPrint('Error refreshing trial status: $e');
      }

      Get.back(); // Close bottom sheet processing

      // Show success notice
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Container(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: 48.sp,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  "Subscription Successful",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  "$providerName needs to review the app to active the subscription. Trial activated for testing purposes.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 32.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back(); // Close dialog
                      Get.offAll(() => MainBaseScreen());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      "Continue",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
    });
  }
}

class FeatureTile extends StatelessWidget {
  final String title;
  const FeatureTile({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.pink[300], size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
