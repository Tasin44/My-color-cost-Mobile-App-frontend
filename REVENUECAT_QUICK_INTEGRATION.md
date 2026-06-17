# RevenueCat Quick Integration Guide for Color OS

This guide shows you exactly how to integrate RevenueCat into your Color OS mobile app and start monetizing immediately.

## Step 1: Complete the Initial Setup (5 minutes)

### 1.1 Update API Keys

Edit `lib/app/core/services/revenue_cat_service.dart` and replace the placeholder keys:

```dart
// Replace with your actual API keys from RevenueCat dashboard
static const String _appleApiKey = 'appl_YOUR_ACTUAL_APPLE_KEY';
static const String _googleApiKey = 'goog_YOUR_ACTUAL_GOOGLE_KEY';
```

**To get your keys:**

1. Go to [RevenueCat Dashboard](https://app.revenuecat.com/)
2. Create account and new project
3. Go to Project Settings → API Keys
4. Copy iOS and Android keys

### 1.2 Initialize in main.dart

Add this to your `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize RevenueCat early
  await RevenueCatService().initialize();
  
  runApp(const MyApp());
}
```

## Step 2: Create Your Products (10 minutes)

### 2.1 iOS App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Navigate to your app → Features → In-App Purchases
3. Create these products:
   - `monthly_subscription` (Auto-Renewable, $9.99/month)
   - `yearly_subscription` (Auto-Renewable, $99.99/year)  
   - `lifetime_purchase` (Non-Consumable, $299.99)

### 2.2 Android Google Play Console

1. Go to [Google Play Console](https://play.google.com/console/)
2. Navigate to your app → Monetize → Products → In-app products
3. Create the same products with same IDs

### 2.3 Configure RevenueCat Dashboard

1. Add iOS configuration (upload .p8 key from App Store Connect)
2. Add Android configuration (upload service account JSON)
3. Create entitlement called `premium`
4. Link all products to this entitlement

## Step 3: Add Paywall to Your App (2 minutes)

Your app already includes a ready-to-use paywall! Just navigate to it:

```dart
// Anywhere in your app
Get.to(() => const PaywallScreen());
```

## Step 4: Gate Premium Features (5 minutes per feature)

### Example 1: Premium Color Palettes

Add this to any screen that should be premium-only:

```dart
class MyPremiumScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Premium Features')),
      body: StreamBuilder<CustomerInfo>(
        stream: RevenueCatService().customerInfoStream,
        builder: (context, snapshot) {
          final isPremium = snapshot.data?.entitlements.active['premium'] != null;
          
          if (isPremium) {
            return MyPremiumContent(); // Your premium content
          }
          
          return PremiumUpgradePrompt(); // Show upgrade prompt
        },
      ),
    );
  }
}
```

### Example 2: Limited Free Usage

For features with usage limits (like exports):

```dart
class ExportButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final isPremium = RevenueCatService().customerInfo
            ?.entitlements.active['premium'] != null;
            
        if (isPremium) {
          // Unlimited exports for premium users
          performExport();
        } else {
          // Check free usage limit
          final prefs = await SharedPreferences.getInstance();
          final exports = prefs.getInt('export_count') ?? 0;
          
          if (exports < 3) {
            // Allow export and increment counter
            await prefs.setInt('export_count', exports + 1);
            performExport();
          } else {
            // Show paywall
            Get.to(() => const PaywallScreen());
          }
        }
      },
      child: Text('Export'),
    );
  }
  
  void performExport() {
    // Your export logic
    Get.snackbar('Success', 'Exported successfully!');
  }
}
```

## Step 5: Add Subscription Management (3 minutes)

Add this to your settings screen:

```dart
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Column(
        children: [
          // Your existing settings...
          
          // Add subscription status
          StreamBuilder<CustomerInfo>(
            stream: RevenueCatService().customerInfoStream,
            builder: (context, snapshot) {
              final isPremium = snapshot.data?.entitlements.active['premium'] != null;
              
              return ListTile(
                leading: Icon(
                  isPremium ? Icons.star : Icons.star_border,
                  color: isPremium ? Colors.orange : Colors.grey,
                ),
                title: Text(isPremium ? 'Premium Active' : 'Free Plan'),
                subtitle: Text(
                  isPremium 
                    ? 'All features unlocked' 
                    : 'Tap to upgrade',
                ),
                onTap: () => Get.to(() => const PaywallScreen()),
              );
            },
          ),
          
          // Restore purchases button
          ListTile(
            leading: Icon(Icons.restore),
            title: Text('Restore Purchases'),
            onTap: () async {
              try {
                await RevenueCatService().restorePurchases();
                Get.snackbar('Success', 'Purchases restored!');
              } catch (e) {
                Get.snackbar('Error', e.toString());
              }
            },
          ),
        ],
      ),
    );
  }
}
```

## Step 6: Test Everything (5 minutes)

### iOS Testing

1. Build app for TestFlight or simulator
2. Use sandbox Apple ID to test purchases
3. Verify purchases work and restore properly

### Android Testing  

1. Upload to Google Play Internal Testing
2. Test with test account
3. Verify purchases and subscriptions

## Common Integration Points for Color OS

### 1. Color Palette Screen

```dart
// In your color palette screen
if (!isPremium && paletteType == 'premium') {
  Get.to(() => const PaywallScreen());
  return;
}
```

### 2. Export Feature

```dart
// In your export functionality
if (!isPremium && exportCount >= freeLimit) {
  Get.to(() => const PaywallScreen());
  return;
}
```

### 3. Advanced Tools

```dart
// For advanced editing tools
if (!isPremium) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Premium Feature'),
      content: Text('Advanced tools require premium subscription'),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Get.back();
            Get.to(() => const PaywallScreen());
          },
          child: Text('Upgrade'),
        ),
      ],
    ),
  );
  return;
}
```

## Monitoring & Analytics

### Check Premium Status Anywhere

```dart
bool isPremium() {
  return RevenueCatService().customerInfo
      ?.entitlements.active['premium'] != null;
}
```

### Listen to Status Changes

```dart
RevenueCatService().customerInfoStream.listen((customerInfo) {
  final isPremium = customerInfo.entitlements.active['premium'] != null;
  // Update UI based on premium status
  setState(() {
    this.isPremium = isPremium;
  });
});
```

## Troubleshooting

### Common Issues

1. **Products not loading**
   - Check API keys are correct
   - Verify products exist in App Store/Play Store
   - Ensure entitlements are configured in RevenueCat

2. **Purchases failing**
   - Test with sandbox/internal testing accounts
   - Check device has payment method setup
   - Verify app bundle ID matches store configuration

3. **Restore not working**
   - User must use same Apple ID/Google account
   - Products must be properly linked in RevenueCat
   - Call `restorePurchases()` method

### Debug Mode

Add this for debugging during development:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable debug logging
  if (kDebugMode) {
    await Purchases.setLogLevel(LogLevel.debug);
  }
  
  await RevenueCatService().initialize();
  runApp(const MyApp());
}
```

## Next Steps

1. **Submit for Review**: Include in-app purchase descriptions when submitting to stores
2. **Monitor Analytics**: Check RevenueCat dashboard for subscription metrics
3. **A/B Test**: Try different paywall designs and pricing
4. **Add Webhooks**: Set up server-side validation if needed
5. **Optimize**: Track which features drive most conversions

## Support

- **RevenueCat Docs**: <https://docs.revenuecat.com/>
- **Flutter Guide**: <https://docs.revenuecat.com/docs/flutter>
- **Dashboard**: <https://app.revenuecat.com/>

---

**🎉 You're ready to monetize!** This integration should take about 30 minutes total, and your app will be ready to generate revenue through subscriptions and one-time purchases.
