import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class StorageService {
  static const _storage = FlutterSecureStorage();

  // User token methods
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _storage.write(key: 'userData', value: jsonEncode(userData));
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final userDataString = await _storage.read(key: 'userData');
    if (userDataString == null) return null;
    try {
      return jsonDecode(userDataString) as Map<String, dynamic>;
    } catch (e) {
      print('Error decoding user data: $e');
      return null;
    }
  }

  // Admin token methods
  static Future<void> saveAdminToken(String token) async {
    await _storage.write(key: 'admin_token', value: token);
  }

  static Future<String?> getAdminToken() async {
    return await _storage.read(key: 'admin_token');
  }

  static Future<void> saveAdminData(Map<String, dynamic> adminData) async {
    await _storage.write(key: 'adminData', value: jsonEncode(adminData));
  }

  static Future<Map<String, dynamic>?> getAdminData() async {
    final adminDataString = await _storage.read(key: 'adminData');
    if (adminDataString == null) return null;
    try {
      return jsonDecode(adminDataString) as Map<String, dynamic>;
    } catch (e) {
      print('Error decoding admin data: $e');
      return null;
    }
  }

  static Future<void> clearStorage() async {
    await _storage.deleteAll();
  }
} 