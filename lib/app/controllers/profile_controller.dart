import 'dart:io';
import 'package:color_os/app/core/helper/sharedpref_helper.dart';
import 'package:http/http.dart' as http;
import 'package:color_os/app/core/constant/api_endpoints.dart';
import 'package:color_os/app/core/services/api_services.dart';
import 'package:color_os/app/models/api_response.dart';
import 'package:color_os/app/controllers/affiliate_controller.dart';
import 'package:color_os/app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;
  final RxString appointmentLink = ''.obs;
  final RxBool isGeneratingLink = false.obs;

  // Trial Management
  final RxString trialDaysRemaining = ''.obs;
  final RxBool isTrialActive = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
    checkTrialStatus();
  }



  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final response = await ApiServices.getData(ApiEndpoints.fetchProfile);

      if (response != null &&
          ApiResponse.isSuccessfulHttpStatus(response.statusCode) &&
          response.data != null) {
        user.value = UserModel.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateUserProfile({
    required String name,
    required String contactNumber,
    File? image,
  }) async {
    try {
      isUpdating.value = true;
      final Map<String, String> fields = {
        'name': name,
        'contact_number': contactNumber,
      };

      dynamic response;

      if (image != null) {
        // Multipart request for image update
        List<http.MultipartFile> files = [];
        files.add(await http.MultipartFile.fromPath('image', image.path));

        response = await ApiServices.patchMultipartData(
          ApiEndpoints.updateProfile,
          fields,
          files,
        );
      } else {
        // Simple JSON patch if no image
        response = await ApiServices.updateData(
          ApiEndpoints.updateProfile,
          fields,
        );
      }

      if (response != null && response.success) {
        // Refresh profile data
        await fetchProfile();
        return true;
      } else {
        String message = response?.message ?? 'Failed to update profile';
        debugPrint(
          'ProfileController: Update failed. Status: ${response?.statusCode}, Message: $message',
        );
        Get.snackbar(
          'Hold on',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.amber.shade700,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  Future<bool> checkAndGenerateAppointmentLink() async {
    try {
      isGeneratingLink.value = true;

      final response = await ApiServices.getData(ApiEndpoints.services);

      if (response != null &&
          ApiResponse.isSuccessfulHttpStatus(response.statusCode) &&
          response.data != null) {

        final data = response.data;
        if (data is Map && data.containsKey('services')) {
          final servicesList = data['services'] as List;

          if (servicesList.isEmpty) {
            Get.snackbar(
              'No Services Found',
              'Please create at least one service before generating a booking link.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.amber.shade700,
              colorText: Colors.white,
              duration: const Duration(seconds: 3),
            );
            return false;
          }

          final bookingUrl = data['booking_url'];
          if (bookingUrl != null && (bookingUrl as String).isNotEmpty) {
            appointmentLink.value = bookingUrl;
            return true;
          } else {
            Get.snackbar(
              'Error',
              'Could not retrieve booking URL from response',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.shade400,
              colorText: Colors.white,
            );
            return false;
          }
        }
      } else {
        Get.snackbar(
          'Error',
          response?.message ?? 'Failed to check services',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error generating link: $e');
      Get.snackbar(
        'Error',
        'An error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    } finally {
      isGeneratingLink.value = false;
    }
    return false;
  }

  void toggleNotifications(bool value) {
    // Update local user state for visual feedback only (no API call as requested)
    if (user.value != null) {
      user.value = user.value!.copyWith(notificationEnabled: value);
    }
  }

  Future<void> checkTrialStatus() async {
    try {
      // 1. Try to get status from AffiliateController (Backend truth)
      if (Get.isRegistered<AffiliateController>()) {
        final affiliate = Get.find<AffiliateController>();
        await affiliate.fetchSubscriptionStatus();

        if (affiliate.subscriptionData.value != null &&
            affiliate.subscriptionData.value!.data != null) {
          final subData = affiliate.subscriptionData.value!.data!;
          isTrialActive.value = subData.isSubscribed;

          if (subData.isSubscribed) {
            trialDaysRemaining.value = subData.planType.capitalizeFirst ?? '';
            return;
          }
        }
      }

      // 2. Fallback to local trial management
      final status = await SharedprefHelper.getString(
        SharedprefHelper.subscriptionStatus,
      );
      final startDateStr = await SharedprefHelper.getString(
        SharedprefHelper.trialStartDate,
      );

      if (status == 'trial' && startDateStr.isNotEmpty) {
        final startDate = DateTime.parse(startDateStr);
        final now = DateTime.now();
        final difference = now.difference(startDate).inDays;
        final remaining = 7 - difference;

        if (remaining > 0) {
          isTrialActive.value = true;
          trialDaysRemaining.value = '$remaining Days Left';
        } else {
          isTrialActive.value = false;
          trialDaysRemaining.value = 'Trial Expired';
        }
      } else {
        isTrialActive.value = false;
      }
    } catch (e) {
      debugPrint('Error checking trial status: $e');
      isTrialActive.value = false;
    }
  }

  Future<void> refreshData() async {
    await fetchProfile();
    await checkTrialStatus();
  }
}
