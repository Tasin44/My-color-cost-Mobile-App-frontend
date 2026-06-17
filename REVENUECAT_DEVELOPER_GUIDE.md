# RevenueCat Developer Guide - Complete Workflow

## Table of Contents

1. [Initial Setup](#initial-setup)
2. [Creating Paywalls](#creating-paywalls)
3. [Managing Subscriptions](#managing-subscriptions)
4. [Premium Feature Gates](#premium-feature-gates)
5. [Customer Management](#customer-management)
6. [Testing & Debugging](#testing--debugging)
7. [Analytics & Reporting](#analytics--reporting)
8. [Best Practices](#best-practices)
9. [Common Patterns](#common-patterns)

## Initial Setup

### 1. RevenueCat Dashboard Configuration

#### Creating Your Project

1. **Sign up** at [RevenueCat Dashboard](https://app.revenuecat.com/)
2. **Create a new project** for your Color OS app
3. **Note your API keys** (you'll need them later)

#### Setting Up Entitlements

Entitlements represent what users get when they purchase. For Color OS, create:

```text
Entitlement ID: premium
Description: Access to all premium features
Products: monthly_subscription, yearly_subscription, lifetime_purchase
```

### 2. App Store / Play Store Setup

#### iOS (App Store Connect)

1. **Create In-App Products:**

   ```text
   Product ID: monthly_subscription
   Type: Auto-Renewable Subscription
   Price: $9.99/month
   
   Product ID: yearly_subscription
   Type: Auto-Renewable Subscription
   Price: $99.99/year
   
   Product ID: lifetime_purchase
   Type: Non-Consumable
   Price: $299.99
   ```

2. **Link to RevenueCat:**
   - Upload your `.p8` key file
   - Add Bundle ID
   - Configure webhooks

#### Android (Google Play Console)

1. **Create In-App Products:**

   ```text
   Product ID: monthly_subscription
   Type: Subscription
   Price: $9.99/month
   
   Product ID: yearly_subscription
   Type: Subscription
   Price: $99.99/year
   
   Product ID: lifetime_purchase
   Type: Managed product
   Price: $299.99
   ```

2. **Link to RevenueCat:**
   - Create service account
   - Upload JSON key
   - Configure permissions

### 3. Flutter App Configuration

Update your API keys in `revenue_cat_service.dart`:

```dart
// Replace with your actual keys from RevenueCat dashboard
static const String _appleApiKey = 'appl_xxxxxxxxxxxxxxxxxxxxxxxxxx';
static const String _googleApiKey = 'goog_xxxxxxxxxxxxxxxxxxxxxxxxxx';
```

Initialize in `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize RevenueCat early
  await RevenueCatService().initialize();
  
  runApp(MyApp());
}
```

## Creating Paywalls

### 1. Using the Built-in Paywall

Your app already includes a ready-to-use paywall at `lib/app/views/screens/paywall/paywall_screen.dart`.

**To show the paywall:**

```dart
import 'package:get/get.dart';
import 'package:color_os/app/views/screens/paywall/paywall_screen.dart';

// Navigate to paywall
void showPaywall() {
  Get.to(() => const PaywallScreen());
}
```

**Features included:**

- Package selection (Monthly, Annual, Lifetime)
- Loading states
- Error handling
- Restore purchases
- Visual feedback
- Customizable styling

### 2. Creating Custom Paywalls

#### Simple Feature Gate Paywall

```dart
class SimplePaywall extends StatelessWidget {
  const SimplePaywall({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Go Premium')),
      body: Column(
        children: [
          // Feature list
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(20),
              children: [
                _FeatureItem(
                  icon: Icons.palette,
                  title: 'Unlimited Color Schemes',
                  subtitle: 'Access to all premium color combinations',
                ),
                _FeatureItem(
                  icon: Icons.download,
                  title: 'Export Options',
                  subtitle: 'Save and export your designs',
                ),
                _FeatureItem(
                  icon: Icons.cloud_sync,
                  title: 'Cloud Sync',
                  subtitle: 'Sync across all your devices',
                ),
              ],
            ),
          ),
          
          // Purchase buttons
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                _PurchaseButton(
                  title: 'Monthly - \$9.99',
                  subtitle: 'Billed monthly',
                  onTap: () => _purchase('monthly_subscription'),
                ),
                SizedBox(height: 10),
                _PurchaseButton(
                  title: 'Annual - \$99.99',
                  subtitle: 'Save 17% - Billed yearly',
                  isRecommended: true,
                  onTap: () => _purchase('yearly_subscription'),
                ),
                SizedBox(height: 10),
                _PurchaseButton(
                  title: 'Lifetime - \$299.99',
                  subtitle: 'One-time payment',
                  onTap: () => _purchase('lifetime_purchase'),
                ),
                
                TextButton(
                  onPressed: _restorePurchases,
                  child: Text('Restore Purchases'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _purchase(String productId) async {
    try {
      final customerInfo = await RevenueCatService().purchaseProduct(productId);
      if (customerInfo.entitlements.active['premium'] != null) {
        Get.back(); // Close paywall
        Get.snackbar('Success', 'Premium activated!');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  void _restorePurchases() async {
    try {
      await RevenueCatService().restorePurchases();
      Get.snackbar('Success', 'Purchases restored!');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
```

#### Package-Based Paywall

```dart
class PackagePaywall extends StatefulWidget {
  @override
  _PackagePaywallState createState() => _PackagePaywallState();
}

class _PackagePaywallState extends State<PackagePaywall> {
  final RevenueCatService _revenueCat = RevenueCatService();
  List<Package> packages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  void _loadPackages() async {
    try {
      await _revenueCat.refreshOfferings();
      setState(() {
        packages = _revenueCat.availablePackages;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Choose Your Plan')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: packages.length,
              itemBuilder: (context, index) {
                final package = packages[index];
                return PackageCard(
                  package: package,
                  onTap: () => _purchasePackage(package),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _purchasePackage(Package package) async {
    try {
      final customerInfo = await _revenueCat.purchasePackage(package);
      if (customerInfo.entitlements.active['premium'] != null) {
        Get.back();
        Get.snackbar('Success', 'Premium activated!');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
```

## Managing Subscriptions

### 1. Checking Premium Status

```dart
class PremiumChecker {
  static bool isPremium() {
    final customerInfo = RevenueCatService().customerInfo;
    return customerInfo?.entitlements.active['premium'] != null;
  }

  static bool isSubscribed() {
    final customerInfo = RevenueCatService().customerInfo;
    final entitlement = customerInfo?.entitlements.active['premium'];
    return entitlement?.isActive == true;
  }

  static DateTime? getExpirationDate() {
    final customerInfo = RevenueCatService().customerInfo;
    final entitlement = customerInfo?.entitlements.active['premium'];
    return entitlement?.expirationDate;
  }

  static String getProductIdentifier() {
    final customerInfo = RevenueCatService().customerInfo;
    final entitlement = customerInfo?.entitlements.active['premium'];
    return entitlement?.productIdentifier ?? '';
  }
}
```

### 2. Subscription Status Widget

```dart
class SubscriptionStatusWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CustomerInfo>(
      stream: RevenueCatService().customerInfoStream,
      builder: (context, snapshot) {
        final customerInfo = snapshot.data;
        final isPremium = customerInfo?.entitlements.active['premium'] != null;

        if (!isPremium) {
          return Card(
            child: ListTile(
              leading: Icon(Icons.star_border, color: Colors.grey),
              title: Text('Free Plan'),
              subtitle: Text('Upgrade to unlock all features'),
              trailing: ElevatedButton(
                onPressed: () => Get.to(() => PaywallScreen()),
                child: Text('Upgrade'),
              ),
            ),
          );
        }

        final entitlement = customerInfo!.entitlements.active['premium']!;
        final expirationDate = entitlement.expirationDate;
        
        return Card(
          child: ListTile(
            leading: Icon(Icons.star, color: Colors.gold),
            title: Text('Premium Active'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Product: ${entitlement.productIdentifier}'),
                if (expirationDate != null)
                  Text('Expires: ${DateFormat.yMMMd().format(expirationDate)}'),
              ],
            ),
            trailing: TextButton(
              onPressed: _manageSubscription,
              child: Text('Manage'),
            ),
          ),
        );
      },
    );
  }

  void _manageSubscription() {
    // Open subscription management
    // iOS: App Store settings
    // Android: Google Play settings
  }
}
```

## Premium Feature Gates

### 1. Simple Feature Gate

```dart
class PremiumFeatureGate extends StatelessWidget {
  final Widget child;
  final VoidCallback? onUpgrade;
  
  const PremiumFeatureGate({
    Key? key,
    required this.child,
    this.onUpgrade,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CustomerInfo>(
      stream: RevenueCatService().customerInfoStream,
      builder: (context, snapshot) {
        final isPremium = snapshot.data?.entitlements.active['premium'] != null;
        
        if (isPremium) {
          return child;
        }
        
        return _PremiumRequired(onUpgrade: onUpgrade);
      },
    );
  }
}

class _PremiumRequired extends StatelessWidget {
  final VoidCallback? onUpgrade;
  
  const _PremiumRequired({this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Premium Feature',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'This feature requires a premium subscription',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: onUpgrade ?? () => Get.to(() => PaywallScreen()),
            child: Text('Upgrade to Premium'),
          ),
        ],
      ),
    );
  }
}
```

### 2. Usage-Based Feature Gate

```dart
class UsageFeatureGate extends StatelessWidget {
  final Widget child;
  final int maxFreeUsage;
  final String featureName;
  
  const UsageFeatureGate({
    Key? key,
    required this.child,
    required this.maxFreeUsage,
    required this.featureName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CustomerInfo>(
      stream: RevenueCatService().customerInfoStream,
      builder: (context, snapshot) {
        final isPremium = snapshot.data?.entitlements.active['premium'] != null;
        
        if (isPremium) {
          return child;
        }
        
        // Check usage count from local storage or API
        return FutureBuilder<int>(
          future: _getUsageCount(),
          builder: (context, usageSnapshot) {
            final currentUsage = usageSnapshot.data ?? 0;
            
            if (currentUsage < maxFreeUsage) {
              return Column(
                children: [
                  LinearProgressIndicator(
                    value: currentUsage / maxFreeUsage,
                    backgroundColor: Colors.grey[200],
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      '${maxFreeUsage - currentUsage} free $featureName remaining',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  Expanded(child: child),
                ],
              );
            }
            
            return _UsageExceeded(featureName: featureName);
          },
        );
      },
    );
  }

  Future<int> _getUsageCount() async {
    // Implement your usage tracking logic
    // This could be stored in SharedPreferences, local database, or remote API
    return 0;
  }
}
```

## Customer Management

### 1. User Login/Logout

```dart
class CustomerManager {
  static Future<void> loginUser(String userId) async {
    await RevenueCatService().logIn(userId);
  }
  
  static Future<void> logoutUser() async {
    await RevenueCatService().logOut();
  }
  
  static Future<void> setUserAttributes(Map<String, String> attributes) async {
    await RevenueCatService().setAttributes(attributes);
  }
}

// Usage example
await CustomerManager.loginUser('user_123');
await CustomerManager.setUserAttributes({
  'email': 'user@example.com',
  'display_name': 'John Doe',
  'preferred_language': 'en',
});
```

### 2. Customer Info Management

```dart
class CustomerInfoManager extends GetxController {
  final RevenueCatService _revenueCat = RevenueCatService();
  
  Rx<CustomerInfo?> customerInfo = Rx<CustomerInfo?>(null);
  RxBool isPremium = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _listenToCustomerInfo();
  }
  
  void _listenToCustomerInfo() {
    _revenueCat.customerInfoStream.listen((info) {
      customerInfo.value = info;
      isPremium.value = info.entitlements.active['premium'] != null;
    });
  }
  
  Future<void> refreshCustomerInfo() async {
    try {
      await _revenueCat.refreshCustomerInfo();
    } catch (e) {
      print('Error refreshing customer info: $e');
    }
  }
}
```

## Testing & Debugging

### 1. Sandbox Testing

#### iOS TestFlight

```dart
// Enable debug logs for testing
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable debug mode in development
  if (kDebugMode) {
    await Purchases.setLogLevel(LogLevel.debug);
  }
  
  await RevenueCatService().initialize();
  runApp(MyApp());
}
```

#### Android Internal Testing

```dart
// Test with Google Play Console Internal Testing
class TestingHelper {
  static Future<void> validatePurchase(String productId) async {
    try {
      final customerInfo = await RevenueCatService().purchaseProduct(productId);
      print('Purchase successful: ${customerInfo.entitlements.active}');
    } catch (e) {
      print('Purchase failed: $e');
    }
  }
}
```

### 2. Debug Information

```dart
class DebugPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CustomerInfo>(
      stream: RevenueCatService().customerInfoStream,
      builder: (context, snapshot) {
        final customerInfo = snapshot.data;
        
        return ExpansionTile(
          title: Text('RevenueCat Debug Info'),
          children: [
            ListTile(
              title: Text('User ID'),
              subtitle: Text(customerInfo?.originalAppUserId ?? 'Anonymous'),
            ),
            ListTile(
              title: Text('Active Entitlements'),
              subtitle: Text(customerInfo?.entitlements.active.keys.join(', ') ?? 'None'),
            ),
            ListTile(
              title: Text('Non-Subscription Purchases'),
              subtitle: Text(customerInfo?.nonSubscriptionTransactions.length.toString() ?? '0'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await RevenueCatService().refreshCustomerInfo();
                  Get.snackbar('Success', 'Customer info refreshed');
                } catch (e) {
                  Get.snackbar('Error', e.toString());
                }
              },
              child: Text('Refresh Customer Info'),
            ),
          ],
        );
      },
    );
  }
}
```

## Analytics & Reporting

### 1. Custom Analytics Integration

```dart
class PurchaseAnalytics {
  static void trackPaywallViewed(String source) {
    // Send to your analytics service
    FirebaseAnalytics.instance.logEvent(
      name: 'paywall_viewed',
      parameters: {'source': source},
    );
  }
  
  static void trackPurchaseAttempted(String productId) {
    FirebaseAnalytics.instance.logEvent(
      name: 'purchase_attempted',
      parameters: {'product_id': productId},
    );
  }
  
  static void trackPurchaseSuccessful(String productId, double price) {
    FirebaseAnalytics.instance.logEvent(
      name: 'purchase_successful',
      parameters: {
        'product_id': productId,
        'value': price,
        'currency': 'USD',
      },
    );
  }
  
  static void trackSubscriptionCancelled(String productId) {
    FirebaseAnalytics.instance.logEvent(
      name: 'subscription_cancelled',
      parameters: {'product_id': productId},
    );
  }
}
```

### 2. Revenue Tracking

```dart
class RevenueTracker extends GetxController {
  RxDouble totalRevenue = 0.0.obs;
  RxInt activeSubscriptions = 0.obs;
  RxInt lifetimePurchases = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    _trackRevenue();
  }
  
  void _trackRevenue() {
    RevenueCatService().customerInfoStream.listen((customerInfo) {
      _updateRevenueMetrics(customerInfo);
    });
  }
  
  void _updateRevenueMetrics(CustomerInfo customerInfo) {
    // Calculate metrics based on customer info
    // This would typically involve server-side calculations
    // RevenueCat provides detailed analytics in their dashboard
  }
}
```

## Best Practices

### 1. Error Handling

```dart
class PurchaseErrorHandler {
  static void handlePurchaseError(PurchasesError error) {
    switch (error.code) {
      case PurchasesErrorCode.userCancelledError:
        // User cancelled - no action needed
        break;
        
      case PurchasesErrorCode.paymentPendingError:
        Get.snackbar(
          'Payment Pending',
          'Your payment is being processed. Please wait.',
          duration: Duration(seconds: 5),
        );
        break;
        
      case PurchasesErrorCode.productNotAvailableForPurchaseError:
        Get.snackbar(
          'Product Unavailable',
          'This product is currently not available for purchase.',
        );
        break;
        
      case PurchasesErrorCode.networkError:
        Get.snackbar(
          'Network Error',
          'Please check your internet connection and try again.',
        );
        break;
        
      default:
        Get.snackbar(
          'Purchase Failed',
          'An error occurred: ${error.message}',
        );
    }
  }
}
```

### 2. Performance Optimization

```dart
class PurchaseCache extends GetxController {
  static const String _cacheKey = 'offerings_cache';
  static const Duration _cacheExpiry = Duration(hours: 1);
  
  DateTime? _lastCacheTime;
  Offerings? _cachedOfferings;
  
  Future<Offerings?> getCachedOfferings() async {
    if (_cachedOfferings != null && 
        _lastCacheTime != null && 
        DateTime.now().difference(_lastCacheTime!) < _cacheExpiry) {
      return _cachedOfferings;
    }
    
    try {
      final offerings = await RevenueCatService().refreshOfferings();
      _cachedOfferings = offerings;
      _lastCacheTime = DateTime.now();
      return offerings;
    } catch (e) {
      // Return cached data if available, even if expired
      return _cachedOfferings;
    }
  }
}
```

### 3. Offline Support

```dart
class OfflineManager {
  static const String _pendingPurchasesKey = 'pending_purchases';
  
  static Future<void> savePendingPurchase(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final pending = prefs.getStringList(_pendingPurchasesKey) ?? [];
    if (!pending.contains(productId)) {
      pending.add(productId);
      await prefs.setStringList(_pendingPurchasesKey, pending);
    }
  }
  
  static Future<void> processPendingPurchases() async {
    final prefs = await SharedPreferences.getInstance();
    final pending = prefs.getStringList(_pendingPurchasesKey) ?? [];
    
    for (final productId in pending) {
      try {
        await RevenueCatService().purchaseProduct(productId);
        pending.remove(productId);
      } catch (e) {
        // Keep in pending list to retry later
        print('Failed to process pending purchase: $productId');
      }
    }
    
    await prefs.setStringList(_pendingPurchasesKey, pending);
  }
}
```

## Common Patterns

### 1. Paywall Presentation Strategies

#### A. Feature-Gated Paywall

Show paywall when user tries to access premium features:

```dart
class ColorPaletteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PremiumFeatureGate(
      child: _PremiumColorPalette(),
      onUpgrade: () => _showPaywall('color_palette'),
    );
  }
  
  void _showPaywall(String source) {
    PurchaseAnalytics.trackPaywallViewed(source);
    Get.to(() => PaywallScreen());
  }
}
```

#### B. Usage Limit Paywall

Show paywall after user exceeds free usage:

```dart
class ExportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return UsageFeatureGate(
      child: _ExportInterface(),
      maxFreeUsage: 3,
      featureName: 'exports',
    );
  }
}
```

#### C. Time-Based Paywall

Show paywall after trial period:

```dart
class TrialManager extends GetxController {
  static const int trialDays = 7;
  
  bool get isTrialActive {
    final prefs = Get.find<SharedPreferences>();
    final installDate = prefs.getString('install_date');
    if (installDate == null) return true;
    
    final install = DateTime.parse(installDate);
    final daysSinceInstall = DateTime.now().difference(install).inDays;
    
    return daysSinceInstall < trialDays;
  }
  
  void checkTrialStatus() {
    if (!isTrialActive && !PremiumChecker.isPremium()) {
      Get.to(() => PaywallScreen());
    }
  }
}
```

### 2. Subscription Management

#### Cancel Subscription Flow

```dart
class SubscriptionManager {
  static Future<void> showCancelFlow() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Cancel Subscription'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to cancel your subscription?'),
            SizedBox(height: 16),
            Text('You will lose access to:'),
            Text('• Unlimited color schemes'),
            Text('• Export features'),
            Text('• Cloud sync'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Keep Subscription'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text('Cancel Subscription'),
          ),
        ],
      ),
    );
    
    if (result == true) {
      _openSubscriptionManagement();
    }
  }
  
  static void _openSubscriptionManagement() {
    if (Platform.isIOS) {
      // Open iOS subscription management
      launchUrl(Uri.parse('https://apps.apple.com/account/subscriptions'));
    } else {
      // Open Google Play subscription management
      launchUrl(Uri.parse('https://play.google.com/store/account/subscriptions'));
    }
  }
}
```

### 3. A/B Testing Paywalls

```dart
class PaywallABTest {
  static const String _testKey = 'paywall_variant';
  
  enum PaywallVariant { original, simplified, feature_focused }
  
  static PaywallVariant getCurrentVariant() {
    final prefs = Get.find<SharedPreferences>();
    final variantName = prefs.getString(_testKey);
    
    if (variantName == null) {
      // Assign random variant for new users
      final variant = PaywallVariant.values[
        Random().nextInt(PaywallVariant.values.length)
      ];
      prefs.setString(_testKey, variant.name);
      return variant;
    }
    
    return PaywallVariant.values.firstWhere(
      (v) => v.name == variantName,
      orElse: () => PaywallVariant.original,
    );
  }
  
  static Widget buildPaywall() {
    final variant = getCurrentVariant();
    
    switch (variant) {
      case PaywallVariant.original:
        return PaywallScreen();
      case PaywallVariant.simplified:
        return SimplifiedPaywallScreen();
      case PaywallVariant.feature_focused:
        return FeatureFocusedPaywallScreen();
    }
  }
}
```

## Quick Start Checklist

- [ ] **Set up RevenueCat dashboard** with your app configuration
- [ ] **Create products** in App Store Connect and Google Play Console
- [ ] **Update API keys** in `revenue_cat_service.dart`
- [ ] **Initialize RevenueCat** in your `main.dart`
- [ ] **Test purchases** using sandbox accounts
- [ ] **Implement feature gates** where needed
- [ ] **Add analytics tracking** for purchase events
- [ ] **Configure webhooks** for server-side validation (if needed)
- [ ] **Test restore purchases** functionality
- [ ] **Submit for review** with proper purchase descriptions

## Support & Resources

- **RevenueCat Documentation**: [https://docs.revenuecat.com/](https://docs.revenuecat.com/)
- **Flutter Plugin Docs**: [https://docs.revenuecat.com/docs/flutter](https://docs.revenuecat.com/docs/flutter)
- **Community Support**: [RevenueCat Community](https://community.revenuecat.com/)
- **Dashboard**: [https://app.revenuecat.com/](https://app.revenuecat.com/)

---

*This guide covers the most common RevenueCat implementation patterns for Flutter apps. Customize the examples based on your specific app requirements and business logic.*
