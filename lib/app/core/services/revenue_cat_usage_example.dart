import 'package:color_os/app/core/services/revenue_cat_service.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Example usage of RevenueCat Service
/// This file demonstrates how to integrate RevenueCat in your app
class RevenueCatUsageExamples {
  final RevenueCatService _revenueCat = RevenueCatService();

  /// Example 1: Check if user has premium access
  Future<bool> checkPremiumAccess() async {
    // Method 1: Check for specific entitlement
    bool hasPremium = _revenueCat.hasActiveEntitlement('premium');

    // Method 2: Check if user is premium
    bool isPremium = _revenueCat.isPremiumUser;

    return hasPremium || isPremium;
  }

  /// Example 2: Display paywall/subscription screen
  Future<void> showPaywallExample(BuildContext context) async {
    // Get available packages
    final packages = _revenueCat.availablePackages;

    if (packages.isEmpty) {
      // No packages available, maybe show error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No subscriptions available')),
      );
      return;
    }

    // Show packages to user
    showModalBottomSheet(
      context: context,
      builder: (context) => SubscriptionSheet(packages: packages),
    );
  }

  /// Example 3: Purchase a specific package
  Future<bool> purchaseMonthlySubscription() async {
    try {
      // Get monthly package
      final monthlyPackage = _revenueCat.monthlyPackage;

      if (monthlyPackage == null) {
        print('Monthly package not available');
        return false;
      }

      // Purchase the package
      final customerInfo = await _revenueCat.purchasePackage(monthlyPackage);

      if (customerInfo != null) {
        // Purchase successful
        print('Purchase successful!');
        return true;
      } else {
        // User cancelled
        print('User cancelled purchase');
        return false;
      }
    } catch (e) {
      print('Purchase error: $e');
      return false;
    }
  }

  /// Example 4: Restore purchases
  Future<void> restorePurchasesExample(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Restore purchases
      final customerInfo = await _revenueCat.restorePurchases();

      // Hide loading
      Navigator.of(context).pop();

      if (customerInfo != null && customerInfo.entitlements.active.isNotEmpty) {
        // Purchases restored successfully
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchases restored successfully!')),
        );
      } else {
        // No purchases found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No purchases found to restore')),
        );
      }
    } catch (e) {
      // Hide loading
      Navigator.of(context).pop();

      // Show error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error restoring purchases: $e')));
    }
  }

  /// Example 5: Listen to customer info updates
  void setupCustomerInfoListener() {
    _revenueCat.customerInfoStream.listen((customerInfo) {
      // Customer info updated (e.g., after purchase or restore)
      print('Customer info updated');

      // Check if user has premium
      if (customerInfo.entitlements.active.isNotEmpty) {
        print('User has premium access');
        // Update UI to show premium features
      } else {
        print('User does not have premium');
        // Update UI to show paywall
      }
    });
  }

  /// Example 6: Set user attributes for analytics
  Future<void> setUserAttributesExample(String userId, String email) async {
    // Login user with custom ID (links purchases across devices)
    await _revenueCat.login(userId);

    // Set user email
    await _revenueCat.setEmail(email);

    // Set custom attributes
    await _revenueCat.setUserAttributes({
      'user_type': 'premium',
      'signup_date': DateTime.now().toIso8601String(),
      'platform': 'mobile',
    });
  }

  /// Example 7: Check subscription details
  void checkSubscriptionDetails() {
    if (_revenueCat.hasActiveSubscription) {
      print('User has active subscription');

      final expirationDate = _revenueCat.subscriptionExpirationDate;
      print('Expires: $expirationDate');

      final willRenew = _revenueCat.willRenew;
      print('Will renew: $willRenew');
    }
  }

  /// Example 8: Get specific offering package
  Future<Package?> getSpecificPackage(String identifier) async {
    // Refresh offerings to get latest
    await _revenueCat.refreshOfferings();

    // Get package by identifier
    return _revenueCat.getPackage(identifier);
  }
}

/// Example Subscription Sheet Widget
class SubscriptionSheet extends StatelessWidget {
  final List<Package> packages;

  const SubscriptionSheet({Key? key, required this.packages}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Choose Your Plan',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ...packages.map((package) => PackageCard(package: package)),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () async {
              await RevenueCatService().restorePurchases();
              Navigator.pop(context);
            },
            child: const Text('Restore Purchases'),
          ),
        ],
      ),
    );
  }
}

/// Example Package Card Widget
class PackageCard extends StatelessWidget {
  final Package package;

  const PackageCard({Key? key, required this.package}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final product = package.storeProduct;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(product.title),
        subtitle: Text(product.description),
        trailing: Text(
          product.priceString,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        onTap: () async {
          try {
            final result = await RevenueCatService().purchasePackage(package);
            if (result != null) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Purchase successful!')),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: $e')));
          }
        },
      ),
    );
  }
}

/// Example: Premium Feature Gate Widget
class PremiumFeatureGate extends StatelessWidget {
  final Widget child;
  final Widget? lockedWidget;

  const PremiumFeatureGate({Key? key, required this.child, this.lockedWidget})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPremium = RevenueCatService().isPremiumUser;

    if (isPremium) {
      return child;
    }

    return lockedWidget ??
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Premium Feature',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Upgrade to access this feature'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Navigate to paywall
                  RevenueCatUsageExamples().showPaywallExample(context);
                },
                child: const Text('Upgrade Now'),
              ),
            ],
          ),
        );
  }
}
