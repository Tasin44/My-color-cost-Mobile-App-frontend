# RevenueCat Integration Guide

## Overview

This guide will help you set up RevenueCat for in-app purchases and subscriptions in your My Colour Cost Flutter app for both iOS and Android.

## Setup Steps

### 1. Create RevenueCat Account

1. Go to [RevenueCat Dashboard](https://app.revenuecat.com/)
2. Sign up or log in
3. Create a new project

### 2. iOS Setup (App Store Connect)

#### A. Create App in App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Create your app if not already created
3. Note your Bundle ID (e.g., `com.yourcompany.mycolourcost`)

#### B. Create In-App Products

1. In App Store Connect, go to your app
2. Navigate to "Features" > "In-App Purchases"
3. Create your products:
   - **Monthly Subscription**: `monthly_subscription`
   - **Yearly Subscription**: `yearly_subscription`
   - **Lifetime Purchase**: `lifetime_purchase` (Non-Consumable)

#### C. Configure RevenueCat for iOS

1. In RevenueCat Dashboard, go to Project Settings
2. Add Apple App Store configuration:
   - Enter your Bundle ID
   - Upload your In-App Purchase Key (.p8 file) from App Store Connect
   - Enter Key ID and Issuer ID

#### D. Update iOS Info.plist

The camera permission is already set. No additional changes needed.

### 3. Android Setup (Google Play Console)

#### A. Create App in Google Play Console

1. Go to [Google Play Console](https://play.google.com/console/)
2. Create your app if not already created
3. Note your Package Name (e.g., `com.yourcompany.mycolourcost`)

#### B. Create In-App Products

1. In Google Play Console, go to your app
2. Navigate to "Monetize" > "Products" > "In-app products"
3. Create your products:
   - **Monthly Subscription**: `monthly_subscription`
   - **Yearly Subscription**: `yearly_subscription`
   - **Lifetime Purchase**: `lifetime_purchase`

#### C. Link Google Play to RevenueCat

1. In RevenueCat Dashboard, go to Project Settings
2. Add Google Play Store configuration:
   - Enter your Package Name
   - Create a Service Account in Google Cloud Console
   - Grant necessary permissions
   - Download JSON key file and upload to RevenueCat

### 4. Update API Keys in Code

Edit `/lib/app/core/services/revenue_cat_service.dart`:

```dart
// Replace with your actual API keys from RevenueCat dashboard
static const String _appleApiKey = 'appl_YOUR_APPLE_API_KEY';
static const String _googleApiKey = 'goog_YOUR_GOOGLE_API_KEY';
```

To find your API keys:

1. Go to RevenueCat Dashboard
2. Navigate to Project Settings > API Keys
3. Copy the Apple App Store key and Google Play Store key

### 5. Update Product Identifiers (if different)

If your product IDs are different from the defaults, update them in `revenue_cat_service.dart`:

```dart
static const String monthlySubscriptionId = 'your_monthly_id';
static const String yearlySubscriptionId = 'your_yearly_id';
static const String lifetimeProductId = 'your_lifetime_id';
```

### 6. Create Entitlements in RevenueCat

1. Go to RevenueCat Dashboard > Entitlements
2. Create an entitlement (e.g., `premium`)
3. Attach your products to this entitlement

### 7. Install Dependencies

Run:

```bash
flutter pub get
```

### 8. Initialize RevenueCat in Your App

Edit `/lib/main.dart`:

```dart
import 'package:color_os/app/core/services/revenue_cat_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize RevenueCat
  try {
    await RevenueCatService().initialize();
  } catch (e) {
    print('RevenueCat initialization failed: $e');
  }
  
  runApp(const MyApp());
}
```

## Usage Examples

See `revenue_cat_usage_example.dart` for detailed usage examples.

## Testing

### iOS Testing

1. Use sandbox Apple ID for testing
2. Create test users in App Store Connect
3. Sign out of production Apple ID on device
4. Test purchases will be free

### Android Testing

1. Add test users in Google Play Console
2. Use internal testing track
3. Test purchases will be free for test users

## Important Notes

1. **Sandbox Testing**: Always test in sandbox environment first
2. **User IDs**: Link RevenueCat user IDs with your backend user IDs
3. **Restore Purchases**: Always provide a restore button for users
4. **Platform Differences**: Some features behave differently on iOS vs Android
5. **Entitlements**: Use entitlements instead of product IDs for cleaner code
6. **Customer Info**: Always check customer info to verify purchase status

## Troubleshooting

### "Product not found" error

- Ensure products are created in App Store Connect/Google Play Console
- Wait 1-2 hours for products to sync
- Check product IDs match exactly

### "User cancelled" on Android

- User tapped outside the payment sheet
- This is normal behavior, handle gracefully

### Purchases not restoring

- Ensure you're using the same Apple ID/Google account
- Call `restorePurchases()` explicitly
- Check RevenueCat dashboard for customer info

## Resources

- [RevenueCat Documentation](https://docs.revenuecat.com/)
- [Flutter Plugin Docs](https://docs.revenuecat.com/docs/flutter)
- [RevenueCat Dashboard](https://app.revenuecat.com/)
- [Support](https://community.revenuecat.com/)
