import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';

class TeamSetupController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final formKey = GlobalKey<FormState>();

  // Arguments from navigation
  String userId = '';
  String email = '';

  // Form controllers
  final RxList<TextEditingController> staffEmailControllers =
      <TextEditingController>[].obs;
  final teamSizeController = TextEditingController();
  final RxInt staffLimit = 1.obs;

  // Loading state
  RxBool get isLoading => _authController.isTeamSetupLoading;

  @override
  void onInit() {
    super.onInit();
    _initializeArguments();
    _initializeTeamSize();
  }

  @override
  void onClose() {
    // Dispose all controllers
    for (var controller in staffEmailControllers) {
      controller.dispose();
    }
    teamSizeController.dispose();
    super.onClose();
  }

  void _initializeArguments() {
    final arguments = Get.arguments as Map<String, dynamic>? ?? {};
    userId = arguments['userId'] ?? '';
    email = arguments['email'] ?? '';

    // Debug logging
    debugPrint('TeamSetupController - Received arguments: $arguments');
    debugPrint('TeamSetupController - User ID: $userId');
    debugPrint('TeamSetupController - Email: $email');
  }

  void _initializeTeamSize() {
    // Initialize team size controller with default value
    teamSizeController.text = staffLimit.value.toString();

    // Initialize with one staff email field
    staffEmailControllers.add(TextEditingController());
  }

  void updateTeamSize(String value) {
    final newSize = int.tryParse(value);
    if (newSize != null && newSize > 0 && newSize <= 50) {
      staffLimit.value = newSize;

      // Sync the number of text controllers with the new size
      if (staffEmailControllers.length < newSize) {
        int toAdd = newSize - staffEmailControllers.length;
        for (int i = 0; i < toAdd; i++) {
          staffEmailControllers.add(TextEditingController());
        }
      } else if (staffEmailControllers.length > newSize) {
        int toRemove = staffEmailControllers.length - newSize;
        for (int i = 0; i < toRemove; i++) {
          final removed = staffEmailControllers.removeLast();
          removed.dispose();
        }
      }
    } else if (value.isEmpty) {
      // If the field is totally empty, we might want to clear or default to 1
      staffLimit.value = 1;
      while (staffEmailControllers.length > 1) {
        final removed = staffEmailControllers.removeLast();
        removed.dispose();
      }
    }
  }

  void addStaffEmailField() {
    // Also increase the overall team size if we manually add a field beyond limits
    staffLimit.value++;
    teamSizeController.text = staffLimit.value.toString();
    staffEmailControllers.add(TextEditingController());
  }

  void removeStaffEmailField(int index) {
    if (staffEmailControllers.length > 1 && index > 0) {
      staffEmailControllers[index].dispose();
      staffEmailControllers.removeAt(index);

      // Also sync back to team size
      staffLimit.value = staffEmailControllers.length;
      teamSizeController.text = staffLimit.value.toString();
    }
  }

  String getOrdinalNumber(int number) {
    if (number >= 11 && number <= 13) {
      return '${number}th';
    }
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }

  String? validateTeamSize(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter team size';
    }
    final teamSize = int.tryParse(value.trim());
    if (teamSize == null) {
      return 'Please enter a valid number';
    }
    if (teamSize < 1) {
      return 'Team size must be at least 1';
    }
    if (teamSize > 50) {
      return 'Team size cannot exceed 50';
    }
    return null;
  }

  String? validateStaffEmail(String? value, int index) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter staff email';
    }
    if (!GetUtils.isEmail(value.trim())) {
      return 'Please enter a valid email';
    }

    // Check for duplicate emails
    final currentEmail = value.trim().toLowerCase();
    final allEmails = staffEmailControllers
        .asMap()
        .entries
        .where(
          (entry) => entry.key != index && entry.value.text.trim().isNotEmpty,
        )
        .map((entry) => entry.value.text.trim().toLowerCase())
        .toList();

    if (allEmails.contains(currentEmail)) {
      return 'This email is already added';
    }

    return null;
  }

  void handleTeamSetup() {
    if (formKey.currentState?.validate() ?? false) {
      // Get all staff emails
      List<String> staffEmails = staffEmailControllers
          .map((controller) => controller.text.trim())
          .where((email) => email.isNotEmpty)
          .toList();

      if (staffEmails.length != staffLimit.value) {
        Get.snackbar(
          'Error',
          'Please provide all ${staffLimit.value} staff emails',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFF44336),
          colorText: Colors.white,
        );
        return;
      }

      // Check for duplicate emails
      final uniqueEmails = staffEmails.toSet();
      if (uniqueEmails.length != staffEmails.length) {
        Get.snackbar(
          'Error',
          'Please remove duplicate email addresses',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFF44336),
          colorText: Colors.white,
        );
        return;
      }

      // Debug logging before calling setupTeam
      debugPrint('TeamSetupController - Setting up team:');
      debugPrint('TeamSetupController - User ID: $userId');
      debugPrint('TeamSetupController - Staff Limit: ${staffLimit.value}');
      debugPrint('TeamSetupController - Staff Emails: $staffEmails');

      _authController.setupTeam(
        userId: userId,
        staffLimit: staffLimit.value,
        staffEmails: staffEmails,
      );
    }
  }

  void skipTeamSetup() {
    // Navigate directly to subscription without team setup
    Get.offAllNamed('/subscription');
  }
}
