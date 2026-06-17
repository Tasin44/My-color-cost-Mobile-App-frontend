import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// RevenueCat Service for managing in-app purchases and subscriptions
/// Supports both iOS and Android platforms
class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  // RevenueCat API Keys
  // TODO: Replace with your actual API keys from RevenueCat dashboard
  static const String _appleApiKey = 'appl_xaNqKNIRRxFUrAMxVmBROYqetlA';
  static const String _googleApiKey = 'goog_YOUR_GOOGLE_API_KEY';

  // Subscription/Product identifiers
  // TODO: Add your product IDs from App Store Connect and Google Play Console
  static const String monthlySubscriptionId = 'monthly_subscription';
  static const String yearlySubscriptionId = 'yearly_subscription';

  // Current customer info
  CustomerInfo? _customerInfo;
  CustomerInfo? get customerInfo => _customerInfo;

  // Offerings available for purchase
  Offerings? _offerings;
  Offerings? get offerings => _offerings;

  // Stream controller for customer info updates
  final StreamController<CustomerInfo> _customerInfoController =
      StreamController<CustomerInfo>.broadcast();
  Stream<CustomerInfo> get customerInfoStream => _customerInfoController.stream;

  /// Initialize RevenueCat SDK
  /// Should be called early in the app lifecycle (e.g., main.dart)
  ///
  /// [userId] - Optional user ID to identify the user in RevenueCat
  Future<void> initialize({String? userId}) async {
    try {
      // Configure SDK based on platform
      late PurchasesConfiguration configuration;

      if (Platform.isIOS) {
        configuration = PurchasesConfiguration(_appleApiKey);
      } else if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(_googleApiKey);
      } else {
        throw UnsupportedError('Platform not supported for RevenueCat');
      }

      // Initialize Purchases SDK
      await Purchases.configure(configuration);

      // Set user ID if provided
      if (userId != null) {
        await Purchases.logIn(userId);
      }

      // Set up listener for customer info updates
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        _customerInfo = customerInfo;
        _customerInfoController.add(customerInfo);
      });

      // Load initial customer info and offerings
      await Future.wait([_loadCustomerInfo(), _loadOfferings()]);

      print('RevenueCat initialized successfully');
    } on PlatformException catch (e) {
      print('RevenueCat initialization error: ${e.message}');
      rethrow;
    } catch (e) {
      print('RevenueCat initialization error: $e');
      rethrow;
    }
  }

  /// Load current customer information
  Future<void> _loadCustomerInfo() async {
    try {
      _customerInfo = await Purchases.getCustomerInfo();
    } on PlatformException catch (e) {
      print('Error loading customer info: ${e.message}');
    }
  }

  /// Load available offerings
  Future<void> _loadOfferings() async {
    try {
      _offerings = await Purchases.getOfferings();
    } on PlatformException catch (e) {
      print('Error loading offerings: ${e.message}');
    }
  }

  /// Refresh customer info manually
  Future<CustomerInfo?> refreshCustomerInfo() async {
    await _loadCustomerInfo();
    return _customerInfo;
  }

  /// Refresh offerings manually
  Future<Offerings?> refreshOfferings() async {
    await _loadOfferings();
    return _offerings;
  }

  /// Check if user has active subscription or entitlement
  ///
  /// [entitlementId] - The entitlement identifier from RevenueCat dashboard
  bool hasActiveEntitlement(String entitlementId) {
    if (_customerInfo == null) return false;

    final entitlement = _customerInfo!.entitlements.all[entitlementId];
    return entitlement?.isActive ?? false;
  }

  /// Check if user is subscribed to any premium plan
  bool get isPremiumUser {
    if (_customerInfo == null) return false;

    // Check if user has any active entitlement
    return _customerInfo!.entitlements.active.isNotEmpty;
  }

  /// Purchase a package
  ///
  /// [package] - The package to purchase
  /// Returns CustomerInfo on success, null on cancellation
  Future<CustomerInfo?> purchasePackage(Package package) async {
    try {
      final purchaseResult = await Purchases.purchasePackage(package);
      _customerInfo = purchaseResult;
      return _customerInfo;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);

      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        print('User cancelled the purchase');
        return null;
      } else if (errorCode == PurchasesErrorCode.purchaseNotAllowedError) {
        print('Purchase not allowed');
        throw Exception('Purchases are not allowed on this device');
      } else if (errorCode == PurchasesErrorCode.paymentPendingError) {
        print('Payment is pending');
        throw Exception('Payment is pending. Please check back later.');
      } else {
        print('Purchase error: ${e.message}');
        throw Exception('Purchase failed: ${e.message}');
      }
    } catch (e) {
      print('Purchase error: $e');
      throw Exception('An unexpected error occurred during purchase');
    }
  }

  /// Purchase a product (StoreProduct) directly
  ///
  /// [product] - The StoreProduct to purchase
  /// Returns CustomerInfo on success, null on cancellation
  Future<CustomerInfo?> purchaseStoreProduct(StoreProduct product) async {
    try {
      final purchaseResult = await Purchases.purchaseStoreProduct(product);
      _customerInfo = purchaseResult;
      return _customerInfo;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);

      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        print('User cancelled the purchase');
        return null;
      } else {
        print('Purchase error: ${e.message}');
        throw Exception('Purchase failed: ${e.message}');
      }
    } catch (e) {
      print('Purchase error: $e');
      throw Exception('An unexpected error occurred during purchase');
    }
  }

  /// Restore previous purchases
  /// Useful for users who reinstalled the app or switched devices
  Future<CustomerInfo?> restorePurchases() async {
    try {
      _customerInfo = await Purchases.restorePurchases();
      return _customerInfo;
    } on PlatformException catch (e) {
      print('Restore purchases error: ${e.message}');
      throw Exception('Failed to restore purchases: ${e.message}');
    } catch (e) {
      print('Restore purchases error: $e');
      throw Exception('An unexpected error occurred while restoring purchases');
    }
  }

  /// Login user with custom user ID
  /// This helps track users across devices
  Future<CustomerInfo?> login(String userId) async {
    try {
      final result = await Purchases.logIn(userId);
      _customerInfo = result.customerInfo;
      return _customerInfo;
    } on PlatformException catch (e) {
      print('Login error: ${e.message}');
      throw Exception('Failed to login: ${e.message}');
    }
  }

  /// Logout current user
  Future<CustomerInfo?> logout() async {
    try {
      _customerInfo = await Purchases.logOut();
      return _customerInfo;
    } on PlatformException catch (e) {
      print('Logout error: ${e.message}');
      throw Exception('Failed to logout: ${e.message}');
    }
  }

  /// Get the current offerings
  /// Returns the default offering if available
  Package? get defaultPackage {
    return _offerings?.current?.availablePackages.firstOrNull;
  }

  /// Get all available packages from current offering
  List<Package> get availablePackages {
    return _offerings?.current?.availablePackages ?? [];
  }

  /// Get monthly subscription package
  Package? get monthlyPackage {
    return _offerings?.current?.monthly;
  }

  /// Get annual subscription package
  Package? get annualPackage {
    return _offerings?.current?.annual;
  }

  /// Get lifetime package
  Package? get lifetimePackage {
    return _offerings?.current?.lifetime;
  }

  /// Get specific package by identifier
  Package? getPackage(String identifier) {
    return _offerings?.current?.availablePackages
        .where((package) => package.identifier == identifier)
        .firstOrNull;
  }

  /// Check if user can make payments (useful for parental controls check)
  Future<bool> canMakePayments() async {
    try {
      return await Purchases.canMakePayments();
    } catch (e) {
      print('Error checking payment capability: $e');
      return false;
    }
  }

  /// Set user attributes for analytics and targeting
  Future<void> setUserAttributes(Map<String, String> attributes) async {
    try {
      await Purchases.setAttributes(attributes);
    } on PlatformException catch (e) {
      print('Error setting attributes: ${e.message}');
    }
  }

  /// Set user email
  Future<void> setEmail(String email) async {
    try {
      await Purchases.setEmail(email);
    } on PlatformException catch (e) {
      print('Error setting email: ${e.message}');
    }
  }

  /// Set user phone number
  Future<void> setPhoneNumber(String phoneNumber) async {
    try {
      await Purchases.setPhoneNumber(phoneNumber);
    } on PlatformException catch (e) {
      print('Error setting phone number: ${e.message}');
    }
  }

  /// Set user display name
  Future<void> setDisplayName(String displayName) async {
    try {
      await Purchases.setDisplayName(displayName);
    } on PlatformException catch (e) {
      print('Error setting display name: ${e.message}');
    }
  }

  /// Check for any active subscription
  bool get hasActiveSubscription {
    if (_customerInfo == null) return false;

    return _customerInfo!.entitlements.active.values.any(
      (entitlement) => entitlement.productIdentifier.contains('subscription'),
    );
  }

  /// Get active subscription expiration date
  String? get subscriptionExpirationDate {
    if (_customerInfo == null) return null;

    final activeEntitlements = _customerInfo!.entitlements.active.values;
    if (activeEntitlements.isEmpty) return null;

    return activeEntitlements.first.expirationDate;
  }

  /// Check if subscription will renew
  bool get willRenew {
    if (_customerInfo == null) return false;

    final activeEntitlements = _customerInfo!.entitlements.active.values;
    if (activeEntitlements.isEmpty) return false;

    return activeEntitlements.first.willRenew;
  }

  /// Dispose resources
  void dispose() {
    _customerInfoController.close();
  }
}
