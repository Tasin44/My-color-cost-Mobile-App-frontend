// Example: How to integrate RevenueCat paywall into Color OS app
// This shows practical implementation patterns for your specific app

import 'dart:io';
import 'package:color_os/app/core/services/revenue_cat_service.dart';
import 'package:color_os/app/views/screens/paywall/paywall_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// 1. PREMIUM FEATURE GATE EXAMPLE
/// Use this to gate premium features in your app

class PremiumColorPaletteScreen extends StatelessWidget {
  const PremiumColorPaletteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium Color Palettes')),
      body: StreamBuilder<CustomerInfo>(
        stream: RevenueCatService().customerInfoStream,
        builder: (context, snapshot) {
          final isPremium =
              snapshot.data?.entitlements.active['premium'] != null;

          if (isPremium) {
            return const PremiumColorPaletteGrid();
          }

          // Show paywall if not premium
          return const PremiumUpgradePrompt();
        },
      ),
    );
  }
}

class PremiumUpgradePrompt extends StatelessWidget {
  const PremiumUpgradePrompt({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.palette,
              size: 80,
              color: Colors.purple.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'Unlock Premium Color Palettes',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Get access to thousands of professional color combinations and advanced editing tools.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _showPaywall(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                backgroundColor: Colors.purple,
              ),
              child: const Text(
                'Upgrade to Premium',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _restorePurchases(),
              child: const Text('Already purchased? Restore'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaywall() {
    // Track analytics (if you have analytics setup)
    // FirebaseAnalytics.instance.logEvent(
    //   name: 'paywall_shown',
    //   parameters: {'source': 'color_palette_screen'},
    // );

    Get.to(() => const PaywallScreen());
  }

  void _restorePurchases() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await RevenueCatService().restorePurchases();
      Get.back(); // Close loading dialog

      Get.snackbar(
        'Success',
        'Purchases restored successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'Failed to restore purchases: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

class PremiumColorPaletteGrid extends StatelessWidget {
  const PremiumColorPaletteGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 20, // Your premium palettes count
      itemBuilder: (context, index) {
        return Card(
          elevation: 4,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [
                  Colors.purple.shade300,
                  Colors.blue.shade300,
                  Colors.pink.shade300,
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'Premium Palette ${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 2. USAGE-LIMITED FEATURE EXAMPLE
/// For features that have limited free usage

class ExportFeatureScreen extends StatefulWidget {
  const ExportFeatureScreen({Key? key}) : super(key: key);

  @override
  State<ExportFeatureScreen> createState() => _ExportFeatureScreenState();
}

class _ExportFeatureScreenState extends State<ExportFeatureScreen> {
  static const int maxFreeExports = 3;
  int currentExports = 0;

  @override
  void initState() {
    super.initState();
    _loadExportCount();
  }

  Future<void> _loadExportCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentExports = prefs.getInt('export_count') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export Colors')),
      body: StreamBuilder<CustomerInfo>(
        stream: RevenueCatService().customerInfoStream,
        builder: (context, snapshot) {
          final isPremium =
              snapshot.data?.entitlements.active['premium'] != null;

          return Column(
            children: [
              if (!isPremium) ...[
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Free Export Limit',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: currentExports / maxFreeExports,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          currentExports >= maxFreeExports
                              ? Colors.red
                              : Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${maxFreeExports - currentExports} free exports remaining',
                        style: TextStyle(color: Colors.blue.shade600),
                      ),
                      if (currentExports >= maxFreeExports) ...[
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => Get.to(() => const PaywallScreen()),
                          child: const Text('Upgrade for Unlimited Exports'),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              Expanded(
                child: _ExportInterface(
                  canExport: isPremium || currentExports < maxFreeExports,
                  onExport: _handleExport,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _handleExport() async {
    final customerInfo = RevenueCatService().customerInfo;
    final isPremium = customerInfo?.entitlements.active['premium'] != null;

    if (!isPremium && currentExports >= maxFreeExports) {
      Get.to(() => const PaywallScreen());
      return;
    }

    // Perform export
    await _performExport();

    if (!isPremium) {
      // Increment usage count
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        currentExports++;
      });
      await prefs.setInt('export_count', currentExports);
    }
  }

  Future<void> _performExport() async {
    // Your export logic here
    Get.snackbar(
      'Success',
      'Color palette exported!',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}

class _ExportInterface extends StatelessWidget {
  final bool canExport;
  final VoidCallback onExport;

  const _ExportInterface({required this.canExport, required this.onExport});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.file_download,
            size: 80,
            color: canExport ? Colors.blue : Colors.grey,
          ),
          const SizedBox(height: 24),
          const Text(
            'Export Your Color Palette',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: canExport ? onExport : null,
            child: const Text('Export as PNG'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: canExport ? onExport : null,
            child: const Text('Export as PDF'),
          ),
        ],
      ),
    );
  }
}

/// 3. SETTINGS SCREEN INTEGRATION
/// Show subscription status and management

class PremiumSettingsSection extends StatelessWidget {
  const PremiumSettingsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CustomerInfo>(
      stream: RevenueCatService().customerInfoStream,
      builder: (context, snapshot) {
        final customerInfo = snapshot.data;
        final isPremium = customerInfo?.entitlements.active['premium'] != null;

        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isPremium ? Icons.star : Icons.star_border,
                      color: isPremium ? Colors.orange : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Premium Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isPremium ? Colors.orange : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (isPremium) ...[
                  const Text(
                    '✅ Premium features unlocked',
                    style: TextStyle(color: Colors.green, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  if (customerInfo != null) ...[
                    Text(
                      'Product: ${_getProductName(customerInfo.entitlements.active['premium']!.productIdentifier)}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    if (customerInfo
                            .entitlements
                            .active['premium']!
                            .expirationDate !=
                        null) ...[
                      Text(
                        'Expires: ${DateFormat.yMMMd().format(DateTime.parse(customerInfo.entitlements.active['premium']!.expirationDate!))}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _manageSubscription,
                        child: const Text('Manage Subscription'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => Get.to(() => const PaywallScreen()),
                        child: const Text('View Plans'),
                      ),
                    ],
                  ),
                ] else ...[
                  const Text(
                    'Free plan - Limited features',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• 3 free exports per month\n• Basic color palettes\n• Standard support',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Get.to(() => const PaywallScreen()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text(
                      'Upgrade to Premium',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
                const Divider(height: 24),
                TextButton(
                  onPressed: () async {
                    try {
                      await RevenueCatService().restorePurchases();
                      Get.snackbar('Success', 'Purchases restored!');
                    } catch (e) {
                      Get.snackbar('Error', e.toString());
                    }
                  },
                  child: const Text('Restore Purchases'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getProductName(String productId) {
    switch (productId) {
      case 'monthly_subscription':
        return 'Monthly Premium';
      case 'yearly_subscription':
        return 'Annual Premium';
      case 'lifetime_purchase':
        return 'Lifetime Premium';
      default:
        return 'Premium';
    }
  }

  void _manageSubscription() {
    if (Platform.isIOS) {
      launchUrl(Uri.parse('https://apps.apple.com/account/subscriptions'));
    } else {
      launchUrl(
        Uri.parse('https://play.google.com/store/account/subscriptions'),
      );
    }
  }
}

/// 4. MAIN APP INTEGRATION EXAMPLE
/// How to initialize and check premium status in your main app

class ColorOSApp extends StatefulWidget {
  @override
  State<ColorOSApp> createState() => _ColorOSAppState();
}

class _ColorOSAppState extends State<ColorOSApp> {
  @override
  void initState() {
    super.initState();
    _initializeRevenueCat();
  }

  Future<void> _initializeRevenueCat() async {
    try {
      // Initialize RevenueCat
      await RevenueCatService().initialize();

      // Listen to customer info changes
      RevenueCatService().customerInfoStream.listen((customerInfo) {
        final isPremium = customerInfo.entitlements.active['premium'] != null;

        // Update app state based on premium status
        Get.find<AppController>().updatePremiumStatus(isPremium);

        // Track analytics (if you have analytics setup)
        // FirebaseAnalytics.instance.setUserProperty(
        //   name: 'premium_status',
        //   value: isPremium ? 'premium' : 'free',
        // );
      });

      // Refresh customer info
      await RevenueCatService().refreshCustomerInfo();
    } catch (e) {
      print('RevenueCat initialization error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Color OS',
      home: const Placeholder(), // Replace with your actual HomeScreen
      // Your app configuration
    );
  }
}

/// 5. CONTROLLER FOR MANAGING PREMIUM STATE

class AppController extends GetxController {
  RxBool isPremium = false.obs;

  void updatePremiumStatus(bool premium) {
    isPremium.value = premium;
  }

  bool canUseFeature(String feature) {
    // Define which features require premium
    const premiumFeatures = [
      'premium_palettes',
      'unlimited_exports',
      'cloud_sync',
      'advanced_editor',
    ];

    if (premiumFeatures.contains(feature)) {
      return isPremium.value;
    }

    return true; // Free feature
  }

  void showPaywallIfNeeded(String feature, {String? source}) {
    if (!canUseFeature(feature)) {
      Get.to(() => const PaywallScreen());

      // Track analytics (if you have analytics setup)
      // FirebaseAnalytics.instance.logEvent(
      //   name: 'paywall_triggered',
      //   parameters: {
      //     'feature': feature,
      //     'source': source ?? 'unknown',
      //   },
      // );
    }
  }
}
