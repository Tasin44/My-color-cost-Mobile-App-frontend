import 'package:color_os/app/core/constant/api_endpoints.dart';
import 'package:color_os/app/core/services/api_services.dart';
import 'package:color_os/app/models/api_response.dart';
import 'package:color_os/app/models/available_slot_model.dart';
import 'package:color_os/app/models/client_model.dart';
import 'package:color_os/app/models/service_type_model.dart';
import 'package:color_os/app/controllers/appointment_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookAppointmentController extends GetxController {
  // Observable variables
  final Rx<ClientModel?> selectedClient = Rx<ClientModel?>(null);
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<DateTime> currentMonth = DateTime.now().obs;
  final RxString selectedTimeSlot = ''.obs;

  final RxList<AvailableSlotModel> availableSlots = <AvailableSlotModel>[].obs;
  final RxBool isLoadingSlots = false.obs;

  final RxList<ClientModel> clients = <ClientModel>[].obs;
  final RxBool isLoadingClients = false.obs;

  final RxList<ServiceTypeModel> services = <ServiceTypeModel>[].obs;
  final RxBool isLoadingServices = false.obs;
  final RxList<int> selectedServiceIds = <int>[].obs;

  final RxBool isSubmitting = false.obs;

  // Text controllers
  final notesController = TextEditingController();
  final processingTimeController = TextEditingController();
  final blockedTimeController = TextEditingController();
  final extraServicingController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchClients();
    fetchServices();
    fetchAvailableSlots(selectedDate.value);
  }

  @override
  void onClose() {
    notesController.dispose();
    processingTimeController.dispose();
    blockedTimeController.dispose();
    extraServicingController.dispose();
    super.onClose();
  }

  // Select client
  void selectClient(ClientModel client) {
    selectedClient.value = client;
  }

  // Select date
  void selectDate(DateTime date) {
    selectedDate.value = date;
    selectedTimeSlot.value = ''; // Reset slot when date changes
    fetchAvailableSlots(date);
  }

  // Navigate month
  void previousMonth() {
    currentMonth.value = DateTime(
      currentMonth.value.year,
      currentMonth.value.month - 1,
    );
  }

  void nextMonth() {
    currentMonth.value = DateTime(
      currentMonth.value.year,
      currentMonth.value.month + 1,
    );
  }

  // Select time slot
  void selectTimeSlot(String slot) {
    selectedTimeSlot.value = slot;
  }

  // Toggle service selection
  void toggleService(int serviceId) {
    if (selectedServiceIds.contains(serviceId)) {
      selectedServiceIds.remove(serviceId);
    } else {
      selectedServiceIds.add(serviceId);
    }
  }

  bool isServiceSelected(int serviceId) {
    return selectedServiceIds.contains(serviceId);
  }

  // Get display label for selected services
  String get selectedServicesLabel {
    if (selectedServiceIds.isEmpty) return 'Select services';
    final names = services
        .where((s) => selectedServiceIds.contains(s.id))
        .map((s) => s.name)
        .toList();
    if (names.isEmpty) return '${selectedServiceIds.length} selected';
    if (names.length == 1) return names.first;
    return '${names.first} +${names.length - 1} more';
  }

  Future<void> fetchClients() async {
    try {
      isLoadingClients.value = true;
      final response = await ApiServices.getData(ApiEndpoints.clients);
      if (response != null &&
          ApiResponse.isSuccessfulHttpStatus(response.statusCode) &&
          response.data != null) {
        final data = response.data['clients'] as List;
        clients.value = data.map((e) => ClientModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching clients: $e');
    } finally {
      isLoadingClients.value = false;
    }
  }

  Future<void> fetchServices() async {
    try {
      isLoadingServices.value = true;
      final response = await ApiServices.getData(ApiEndpoints.services);
      if (response != null &&
          ApiResponse.isSuccessfulHttpStatus(response.statusCode) &&
          response.data != null) {
        final data = response.data['services'] as List;
        services.value =
            data.map((e) => ServiceTypeModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching services: $e');
    } finally {
      isLoadingServices.value = false;
    }
  }

  Future<void> fetchAvailableSlots(DateTime date) async {
    try {
      isLoadingSlots.value = true;
      availableSlots.clear();

      final dateStr =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      final response = await ApiServices.getData(
        '${ApiEndpoints.availableSlots}?date=$dateStr',
      );

      if (response != null &&
          ApiResponse.isSuccessfulHttpStatus(response.statusCode) &&
          response.data != null) {
        
        List dataList = [];
        if (response.data is List) {
          dataList = response.data as List;
        } else if (response.data is Map) {
          if (response.data.containsKey('available_slots')) {
            dataList = response.data['available_slots'] as List;
          } else if (response.data.containsKey('data') && response.data['data'] is List) {
            dataList = response.data['data'] as List;
          }
        }

        availableSlots.value = dataList
            .map((e) => AvailableSlotModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching slots: $e');
    } finally {
      isLoadingSlots.value = false;
    }
  }

  Future<void> submitAppointment() async {
    if (!_validateForm()) return;

    try {
      isSubmitting.value = true;

      final dateStr =
          "${selectedDate.value.year}-${selectedDate.value.month.toString().padLeft(2, '0')}-${selectedDate.value.day.toString().padLeft(2, '0')}";

      final body = <String, dynamic>{
        "client_id": int.parse(selectedClient.value!.id),
        "appointment_date": dateStr,
        "appointment_time": selectedTimeSlot.value.substring(0, 5), // HH:mm
        "service_type_ids": selectedServiceIds.toList(),
        if (notesController.text.trim().isNotEmpty)
          "notes": notesController.text.trim(),
        if (processingTimeController.text.trim().isNotEmpty)
          "processing_time": int.tryParse(processingTimeController.text.trim()) ?? 0,
        if (blockedTimeController.text.trim().isNotEmpty)
          "blocked_time": int.tryParse(blockedTimeController.text.trim()) ?? 0,
        if (extraServicingController.text.trim().isNotEmpty)
          "extra_servicing": int.tryParse(extraServicingController.text.trim()) ?? 0,
      };

      final response = await ApiServices.postData(
        ApiEndpoints.createAppointment,
        body,
      );

      if (response != null &&
          ApiResponse.isSuccessfulHttpStatus(response.statusCode)) {
        Get.back(); // Close screen
        Get.snackbar(
          'Success',
          response.message.isNotEmpty
              ? response.message
              : 'Appointment booked successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade400,
          colorText: Colors.white,
        );
        // Refresh the appointment list if controller is registered
        if (Get.isRegistered<AppointmentController>()) {
          Get.find<AppointmentController>().fetchAppointments(
            selectedDate.value,
          );
        }
      } else {
        // Show backend error message (e.g. "This time slot is fully booked")
        final errorMsg = response?.message ?? 'Failed to book appointment';
        Get.snackbar(
          'Booking Failed',
          errorMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      debugPrint('Error booking appointment: $e');
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  bool _validateForm() {
    if (selectedClient.value == null) {
      Get.snackbar(
        'Required',
        'Please select a client',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade400,
        colorText: Colors.white,
      );
      return false;
    }
    if (selectedTimeSlot.value.isEmpty) {
      Get.snackbar(
        'Required',
        'Please select a time slot',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade400,
        colorText: Colors.white,
      );
      return false;
    }
    if (selectedServiceIds.isEmpty) {
      Get.snackbar(
        'Required',
        'Please select at least one service',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade400,
        colorText: Colors.white,
      );
      return false;
    }
    return true;
  }
}
