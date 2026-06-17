import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedprefHelper {
  final token = "token";
  final userId = 'userID';
  final role = 'role';
  final userName = 'userName';
  final userImage = 'userImage';
  final accountType = 'accountType';
  static const String appointmentUrl = 'appointment_url';
  static const String trialStartDate = 'trial_start_date';
  static const String subscriptionStatus = 'subscription_status';

  static Future<String> getString(String key) async {
    try {
      final _pref = await SharedPreferences.getInstance();
      return _pref.getString(key) ?? '';
    } catch (e) {
      debugPrint(e.toString());
      return '';
    }
  }

  static Future<bool> setString(String key, String value) async {
    try {
      final _pref = await SharedPreferences.getInstance();
      return _pref.setString(key, value);
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  static Future<bool> remove(String key) async {
    try {
      final _pref = await SharedPreferences.getInstance();
      return _pref.remove(key);
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}
