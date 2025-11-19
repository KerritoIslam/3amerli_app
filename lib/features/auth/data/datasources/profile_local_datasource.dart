import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ProfileLocalDataSource {
  static const _userKey = 'cached_user_json';

  Future<void> saveUserJson(Map<String, dynamic> json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(json));
  }

  Future<Map<String, dynamic>?> readUserJson() async {
    print("User Model Reading from local datasource");
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_userKey);
    print("User Model Read from local datasource: $s");
    if (s == null) return null;
    print("User Model Read from local datasource: ${jsonDecode(s)}");
    return Map<String, dynamic>.from(jsonDecode(s) as Map);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
