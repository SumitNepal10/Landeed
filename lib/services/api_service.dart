import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';

  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Signup
  static Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String phoneNumber,
    required String fullName,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
        'fullName': fullName,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await StorageService.saveToken(data['token']);
      await StorageService.saveUserData(data['user']);
      return data;
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  // Login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await StorageService.saveToken(data['token']);
      await StorageService.saveUserData(data['user']);
      return data;
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  // Logout
  static Future<void> logout() async {
    await StorageService.clearStorage();
  }
} 