import 'package:color_os/app/core/constant/api_endpoints.dart';
import 'package:color_os/app/core/services/api_services.dart';
import 'package:color_os/app/models/service_type_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ServiceController extends GetxController {
  var isLoading = false.obs;
  var servicesList = <ServiceTypeModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchServices();
  }

  Future<void> fetchServices() async {
    isLoading.value = true;
    try {
      final response = await ApiServices.getData(ApiEndpoints.services);
      if (response != null && response.success) {
        final data = response.data;
        if (data != null && data['services'] != null) {
          final List<dynamic> servicesJson = data['services'];
          servicesList.value = servicesJson
              .map((json) => ServiceTypeModel.fromJson(json))
              .toList();
        }
      } else {
        debugPrint(
            'Error fetching services: ${response?.message ?? "Unknown"}');
      }
    } catch (e) {
      debugPrint('Exception fetching services: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createService({
    required String name,
    required String description,
    required int serviceTimeMinutes,
    required String priceType,
    String? serviceFee,
  }) async {
    isLoading.value = true;
    try {
      final Map<String, dynamic> body = {
        'name': name,
        'description': description,
        'service_time_minutes': serviceTimeMinutes,
        'price_type': priceType,
      };

      // Only include service_fee if it's not null and price_type is not 'free'
      if (priceType != 'free' && serviceFee != null && serviceFee.isNotEmpty) {
        body['service_fee'] = serviceFee;
      }

      final response =
          await ApiServices.postData(ApiEndpoints.services, body);

      if (response != null && response.success) {
        await fetchServices(); // Refresh the list
        return true;
      } else {
        Get.snackbar(
          'Error',
          response?.message ?? 'Failed to create service',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      debugPrint('Exception creating service: $e');
      Get.snackbar(
        'Error',
        'An error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateService({
    required int id,
    required String name,
    required String description,
    required int serviceTimeMinutes,
    required String priceType,
    String? serviceFee,
  }) async {
    isLoading.value = true;
    try {
      final Map<String, dynamic> body = {
        'name': name,
        'description': description,
        'service_time_minutes': serviceTimeMinutes,
        'price_type': priceType,
      };

      if (priceType != 'free' && serviceFee != null && serviceFee.isNotEmpty) {
        body['service_fee'] = serviceFee;
      } else if (priceType == 'free') {
          // If it's free, we should probably clear the fee on the backend, 
          // but the backend might handle it. We can optionally send null.
          body['service_fee'] = null;
      }

      final response = await ApiServices.updateData(
          ApiEndpoints.serviceDetail(id), body);

      if (response != null && response.success) {
        await fetchServices();
        return true;
      } else {
        Get.snackbar(
          'Error',
          response?.message ?? 'Failed to update service',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      debugPrint('Exception updating service: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteService(int id) async {
    isLoading.value = true;
    try {
      final response =
          await ApiServices.deleteData(ApiEndpoints.serviceDetail(id));
      if (response != null && response.success) {
        await fetchServices();
        Get.snackbar(
          'Success',
          'Service deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade400,
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          response?.message ?? 'Failed to delete service',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      debugPrint('Exception deleting service: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
