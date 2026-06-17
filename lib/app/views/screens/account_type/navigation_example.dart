import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:color_os/app/views/screens/account_type/account_type_screen.dart';

/// Example of how to navigate to the Account Type Screen
class NavigationExample {
  /// Navigate to Account Type Screen using GetX navigation
  static void navigateToAccountTypeScreen() {
    Get.to(() => const AccountTypeScreen());
  }

  /// Navigate using named route (recommended)
  static void navigateToAccountTypeScreenNamed() {
    Get.toNamed('/account-type');
  }

  /// Navigate and replace current screen
  static void navigateAndReplaceToAccountTypeScreen() {
    Get.off(() => const AccountTypeScreen());
  }

  /// Navigate and clear all previous routes
  static void navigateAndClearToAccountTypeScreen() {
    Get.offAll(() => const AccountTypeScreen());
  }
}

/// Example button widget that can be used anywhere in the app
class AccountTypeNavigationButton extends StatelessWidget {
  const AccountTypeNavigationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => NavigationExample.navigateToAccountTypeScreenNamed(),
      child: const Text('Choose Account Type'),
    );
  }
}

/// Example usage in a widget tree
class ExampleUsage extends StatelessWidget {
  const ExampleUsage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Navigation Example'),
            SizedBox(height: 20),
            AccountTypeNavigationButton(),
          ],
        ),
      ),
    );
  }
}
