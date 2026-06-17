import 'package:color_os/app/core/constant/api_endpoints.dart';
import 'package:color_os/app/core/services/api_services.dart';
import 'package:color_os/app/models/api_response.dart';
import 'package:color_os/app/models/subscription_status_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';

class AffiliateModel {
  final int id;
  final double amount;
  final String accountName;
  final String accountNumber;
  final String bankName;
  final String routingNumber;
  final String bankAddress;
  final String status;
  final String? adminNotes;
  final String createdAt;
  final String? processedAt;

  AffiliateModel({
    required this.id,
    required this.amount,
    required this.accountName,
    required this.accountNumber,
    required this.bankName,
    required this.routingNumber,
    required this.bankAddress,
    required this.status,
    this.adminNotes,
    required this.createdAt,
    this.processedAt,
  });

  factory AffiliateModel.fromJson(Map<String, dynamic> json) {
    return AffiliateModel(
      id: json['id'],
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      accountName: json['account_name'] ?? '',
      accountNumber: json['account_number'] ?? '',
      bankName: json['bank_name'] ?? '',
      routingNumber: json['routing_number'] ?? '',
      bankAddress: json['bank_address'] ?? '',
      status: json['status'] ?? '',
      adminNotes: json['admin_notes'],
      createdAt: json['created_at'] ?? '',
      processedAt: json['processed_at'],
    );
  }
}

class AffiliateController extends GetxController {
  // Dashboard stats
  final RxInt totalAffiliated = 0.obs;
  final RxInt activeReferrals = 0.obs;
  final RxDouble totalEarned = 0.0.obs;
  final RxDouble availableCommission = 0.0.obs;
  final RxInt pendingWithdrawals = 0.obs;

  final RxList<AffiliateModel> withdrawalHistory = <AffiliateModel>[].obs;
  final RxString referToken = ''.obs;
  final RxString shareMessage = ''.obs;
  final RxString referLink = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmittingWithdraw = false.obs;
  final RxBool isSearchingReferrer = false.obs;
  final Rxn<Map<String, dynamic>> referrerProfile = Rxn<Map<String, dynamic>>();

  // Subscription status
  final Rxn<SubscriptionStatusModel> subscriptionData =
      Rxn<SubscriptionStatusModel>();
  final RxString subscriptionStatus = 'none'.obs;
  final RxBool hasActiveSubscription = false.obs;
  final RxBool isSubscribing = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
    fetchReferralCode();
    fetchWithdrawalHistory();
    fetchSubscriptionStatus();
  }

  Future<void> fetchReferralCode() async {
    try {
      final response = await ApiServices.getData(ApiEndpoints.myReferralCode);
      if (response != null && response.success && response.data != null) {
        referToken.value = response.data['referral_code'] ?? '';
        shareMessage.value = response.data['share_message'] ?? '';
        referLink.value = response.data['referral_url'] ?? '';
      }
    } catch (e) {
      debugPrint('Error fetching referral code: $e');
    }
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      final response = await ApiServices.getData(
        ApiEndpoints.referralDashboard,
      );

      if (response != null && response.success && response.data != null) {
        final data = response.data;
        totalAffiliated.value = data['total_referrals'] ?? 0;
        activeReferrals.value = data['active_referrals'] ?? 0;
        totalEarned.value =
            double.tryParse(
              data['total_commission_earned']?.toString() ?? '0',
            ) ??
            0.0;
        availableCommission.value =
            double.tryParse(data['available_commission']?.toString() ?? '0') ??
            0.0;
        pendingWithdrawals.value = data['pending_withdrawals'] ?? 0;
      }
    } catch (e) {
      debugPrint('Error fetching dashboard data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchWithdrawalHistory() async {
    try {
      final response = await ApiServices.getData(ApiEndpoints.withdrawal);
      if (response != null && response.success && response.data != null) {
        final List<dynamic> historyData = response.data;
        withdrawalHistory.value = historyData
            .map((json) => AffiliateModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching withdrawal history: $e');
    }
  }

  Future<bool> submitWithdrawRequest({
    required String bankName,
    required String accountName,
    required String accountNumber,
    required String routingNumber,
    required String bankAddress,
    required double amount,
  }) async {
    if (amount <= 0) {
      Get.snackbar('Error', 'Amount must be greater than zero');
      return false;
    }

    try {
      isSubmittingWithdraw.value = true;
      final body = {
        "amount": amount,
        "account_name": accountName,
        "account_number": accountNumber,
        "bank_name": bankName,
        "routing_number": routingNumber,
        "bank_address": bankAddress,
      };

      final response = await ApiServices.postData(
        ApiEndpoints.withdrawal,
        body,
      );

      if (response != null && response.success) {
        Get.snackbar(
          'Success',
          'Withdrawal request submitted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade400,
          colorText: Colors.white,
        );
        fetchDashboardData();
        fetchWithdrawalHistory();
        return true;
      } else {
        Get.snackbar(
          'Error',
          response?.message ?? 'Failed to submit request',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error submitting withdraw request: $e');
      return false;
    } finally {
      isSubmittingWithdraw.value = false;
    }
  }

  Future<void> fetchSubscriptionStatus() async {
    try {
      isLoading.value = true;
      final response = await ApiServices.getData(
        ApiEndpoints.subscriptionStatus,
      );
      if (response != null && response.data != null) {
        debugPrint('Subscription Data: ${response.data}');
        final model = SubscriptionStatusModel.fromJson(response.data);
        subscriptionData.value = model;
        if (model.data != null) {
          final data = model.data!;
          subscriptionStatus.value = data.status;

          // Follow strictly the isSubscribed flag as requested
          hasActiveSubscription.value = data.isSubscribed;

          debugPrint(
            'Subscription Status: ${data.status}, IsSubscribed: ${data.isSubscribed} -> hasActiveSubscription: ${hasActiveSubscription.value}',
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching subscription status: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createSubscription({
    required String? referralCode,
    required String subscriptionPlan,
  }) async {
    try {
      isSubscribing.value = true;
      final authController = Get.find<AuthController>();
      final userId = authController.user.value?.id;

      if (userId == null) {
        Get.snackbar('Error', 'User ID not found');
        return false;
      }

      final body = {"user_id": userId, "subscription_plan": subscriptionPlan};
      if (referralCode != null && referralCode.trim().isNotEmpty) {
        body["referral_code"] = referralCode.trim();
      }

      debugPrint('--- CREATING SUBSCRIPTION ---');
      debugPrint('Requesting Body: $body');

      final response = await ApiServices.postData(
        ApiEndpoints.subscriptionCreate,
        body,
      );

      if (response != null &&
          ApiResponse.isSuccessfulHttpStatus(response.statusCode)) {
        debugPrint('Subscription Created Successfully');
        debugPrint('Response Data: ${response.data}');
        await fetchSubscriptionStatus();
        return true;
      } else {
        String errorMessage =
            response?.message ?? 'Failed to create subscription';

        // Handle detailed errors from the 'data' field
        if (response?.data != null && response!.data is Map) {
          final data = response.data as Map;
          List<String> details = [];

          data.forEach((key, value) {
            String field =
                key.toString().replaceAll('_', ' ').capitalizeFirst ??
                key.toString();
            if (value is List) {
              details.add("$field: ${value.join(', ')}");
            } else {
              details.add("$field: ${value.toString()}");
            }
          });

          if (details.isNotEmpty) {
            errorMessage = details.join('\n\n');
          }
        }

        Get.dialog(
          AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 8),
                Text('Subscription Error'),
              ],
            ),
            content: Text(errorMessage),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('OK')),
            ],
          ),
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error creating subscription: $e');
      return false;
    } finally {
      isSubscribing.value = false;
    }
  }

  Future<void> searchReferrer(String code) async {
    if (code.isEmpty) {
      referrerProfile.value = null;
      return;
    }

    try {
      isSearchingReferrer.value = true;
      final response = await ApiServices.getData(
        '${ApiEndpoints.searchReferrer}?code=$code',
      );

      if (response != null && response.success && response.data != null) {
        referrerProfile.value = response.data;
      } else {
        referrerProfile.value = null;
      }
    } catch (e) {
      debugPrint('Error searching referrer: $e');
      referrerProfile.value = null;
    } finally {
      isSearchingReferrer.value = false;
    }
  }
}
