import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class StorageService {
  static const _storage = FlutterSecureStorage();

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

  static Future<void> clearStorage() async {
    await _storage.deleteAll();
  }
} 