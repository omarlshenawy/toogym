import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  AppStorage._();

  static SharedPreferences? _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static SharedPreferences get _instance {
    if (_preferences == null) {
      throw StateError(
        'AppStorage has not been initialized. '
            'Call AppStorage.init() before using storage.',
      );
    }

    return _preferences!;
  }

  // ------------------------------------------------------------
  // String
  // ------------------------------------------------------------

  static Future<bool> setString(
      String key,
      String value,
      ) async {
    return _instance.setString(key, value);
  }

  static String? getString(String key) {
    return _instance.getString(key);
  }

  static Future<bool> remove(String key) async {
    return _instance.remove(key);
  }

  // ------------------------------------------------------------
  // JSON
  // ------------------------------------------------------------

  static Future<bool> setJson(
      String key,
      Map<String, dynamic> value,
      ) async {
    return setString(key, jsonEncode(value));
  }

  static Map<String, dynamic>? getJson(String key) {
    final value = getString(key);

    if (value == null || value.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(value);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  // ------------------------------------------------------------
  // Clear
  // ------------------------------------------------------------

  static Future<bool> clear() async {
    return _instance.clear();
  }
}