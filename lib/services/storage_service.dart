// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';

// class StorageService {
//   static final StorageService _instance = StorageService._internal();
//   factory StorageService() => _instance;
//   StorageService._internal();

//   SharedPreferences? _prefs;

//   Future<void> initialize() async {
//     _prefs = await SharedPreferences.getInstance();
//   }

//   // Auth
//   Future<void> saveAuthToken(String token) async {
//     await _prefs?.setString('auth_token', token);
//   }

//   String? getAuthToken() {
//     return _prefs?.getString('auth_token');
//   }

//   Future<void> clearAuthToken() async {
//     await _prefs?.remove('auth_token');
//   }

//   // User
//   Future<void> saveUser(Map<String, dynamic> user) async {
//     await _prefs?.setString('user', jsonEncode(user));
//   }

//   Map<String, dynamic>? getUser() {
//     final userStr = _prefs?.getString('user');
//     if (userStr != null) {
//       return jsonDecode(userStr) as Map<String, dynamic>;
//     }
//     return null;
//   }

//   // Onboarding
//   Future<void> setOnboardingComplete() async {
//     await _prefs?.setBool('onboarding_complete', true);
//   }

//   bool isOnboardingComplete() {
//     return _prefs?.getBool('onboarding_complete') ?? false;
//   }

//   // Offline data
//   Future<void> saveOfflineData(String key, List<Map<String, dynamic>> data) async {
//     await _prefs?.setString(key, jsonEncode(data));
//   }

//   List<Map<String, dynamic>>? getOfflineData(String key) {
//     final dataStr = _prefs?.getString(key);
//     if (dataStr != null) {
//       return (jsonDecode(dataStr) as List).cast<Map<String, dynamic>>();
//     }
//     return null;
//   }
// }
