import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _storage.write(key: 'userData', value: userData.toString());
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final userDataString = await _storage.read(key: 'userData');
    if (userDataString == null) return null;
    return Map<String, dynamic>.from(userDataString as Map);
  }

  static Future<void> clearStorage() async {
    await _storage.deleteAll();
  }
} 