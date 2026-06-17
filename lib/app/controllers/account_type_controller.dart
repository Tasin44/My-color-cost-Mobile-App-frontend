import 'package:color_os/app/views/screens/auth/signup/sign_up_screen.dart';
import 'package:get/get.dart';

enum AccountType { salonOwner, selfEmployed, salonStaff, retailer }

class AccountTypeController extends GetxController {
  // Observable selected account type
  final Rx<AccountType?> selectedAccountType = Rx<AccountType?>(null);

  // Observable for button loading state
  final RxBool isLoading = false.obs;

  // Account type data with icons and descriptions
  final List<AccountTypeOption> accountTypeOptions = [
    AccountTypeOption(
      type: AccountType.salonOwner,
      title: 'Salon Owner With staff',
      description: 'Manage your salon and team',
      icon: '👨‍💼', // Using emoji for now, can be replaced with proper icons
      isRecommended: false,
    ),
    AccountTypeOption(
      type: AccountType.selfEmployed,
      title: 'Self-Employed',
      description: 'Freelance Hair Stylist',
      icon: '✂️',
      isRecommended: false,
    ),
    AccountTypeOption(
      type: AccountType.salonStaff,
      title: 'Salon Staff',
      description: 'Work under a salon account',
      icon: '👩‍💼',
      isRecommended: false,
    ),
    AccountTypeOption(
      type: AccountType.retailer,
      title: 'Retailer',
      description: 'Sell products to salons',
      icon: '🛒',
      isRecommended: false,
    ),
  ];

  /// Select an account type
  void selectAccountType(AccountType type) {
    selectedAccountType.value = type;
  }

  /// Check if an account type is selected
  bool isSelected(AccountType type) {
    return selectedAccountType.value == type;
  }

  /// Get the selected account type option
  AccountTypeOption? get selectedOption {
    if (selectedAccountType.value == null) return null;

    return accountTypeOptions.firstWhere(
      (option) => option.type == selectedAccountType.value,
    );
  }

  /// Continue to next step
  Future<void> continueToNextStep() async {
    if (selectedAccountType.value == null) {
      Get.snackbar(
        'Selection Required',
        'Please select an account type to continue',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      Get.to(SignUpScreen(accountType: selectedAccountType.value!));
      // // Simulate API call or processing
      // await Future.delayed(const Duration(milliseconds: 500));

      // // Save the selected account type to storage/preferences
      // await _saveAccountType();

      // // Navigate to next screen based on account type
      // _navigateToNextScreen();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to proceed. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    // Clean up any resources
    super.onClose();
  }
}

/// Account type option model
class AccountTypeOption {
  final AccountType type;
  final String title;
  final String description;
  final String icon;
  final bool isRecommended;

  AccountTypeOption({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    this.isRecommended = false,
  });
}
