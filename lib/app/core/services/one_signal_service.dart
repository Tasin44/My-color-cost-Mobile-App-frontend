import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/foundation.dart';

class OneSignalService {
  // TODO: Replace with your actual OneSignal App ID
  static const String _appId = "YOUR_ONESIGNAL_APP_ID_HERE";

  static Future<void> init() async {
    // Debugging (Enable only in debug mode)
    if (kDebugMode) {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    }

    // Initialize OneSignal
    // The appId can be updated here once provided by the user
    OneSignal.initialize(_appId);

    // Requesting permission is better handled in a specific UI flow (e.g., Home or Onboarding)
    // but we can trigger it here for simplicity or based on requirements.
    // OneSignal.Notifications.requestPermission(true);

    _setupListeners();
  }

  static void _setupListeners() {
    // Notification Click Listener
    OneSignal.Notifications.addClickListener((event) {
      debugPrint("--- OneSignal Notification Clicked ---");
      debugPrint("Title: ${event.notification.title}");
      debugPrint("Body: ${event.notification.body}");
      debugPrint("Additional Data: ${event.notification.additionalData}");
      
      // Example: Navigate based on data
      // if (event.notification.additionalData?["page"] == "inventory") {
      //   Get.toNamed("/inventory");
      // }
    });

    // Permission Change Listener
    OneSignal.Notifications.addPermissionObserver((state) {
      debugPrint("--- OneSignal Permission Changed: $state ---");
    });

    // Foreground Notification Listener (Optional - use if you want to show custom UI when app is open)
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      debugPrint("--- OneSignal Notification Will Display in Foreground ---");
      // event.preventDefault(); // Uncomment to stop OneSignal from showing the notification
    });
  }
}
