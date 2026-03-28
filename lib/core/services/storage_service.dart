import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  late final SharedPreferences _prefs;

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';
  static const String _onboardingKey = 'is_first_time';

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // ── Token ──────────────────────────────────────────────────────────────────
  void saveTokens(String accessToken, String refreshToken) {
    _prefs.setString(_tokenKey, accessToken);
    _prefs.setString(_refreshTokenKey, refreshToken);
  }

  void saveToken(String token) => _prefs.setString(_tokenKey, token);
  String? getToken() => _prefs.getString(_tokenKey);
  String? getRefreshToken() => _prefs.getString(_refreshTokenKey);
  
  void removeTokens() {
    _prefs.remove(_tokenKey);
    _prefs.remove(_refreshTokenKey);
  }

  // ── User data ──────────────────────────────────────────────────────────────
  void saveUser(Map<String, dynamic> user) =>
      _prefs.setString(_userKey, jsonEncode(user));
  Map<String, dynamic>? getUser() {
    final raw = _prefs.getString(_userKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  void removeUser() => _prefs.remove(_userKey);

  // ── Onboarding ─────────────────────────────────────────────────────────────
  bool get isFirstTime => _prefs.getBool(_onboardingKey) ?? true;
  void setOnboardingCompleted() => _prefs.setBool(_onboardingKey, false);

  // ── Clear all ──────────────────────────────────────────────────────────────
  void clearAll() => _prefs.clear();
}
