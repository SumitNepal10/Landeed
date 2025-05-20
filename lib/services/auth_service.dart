import 'package:flutter/material.dart';
import 'package:partice_project/services/api_service.dart';
import 'package:partice_project/services/storage_service.dart';
import 'package:partice_project/utils/route_name.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:partice_project/constant/api_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final _authState = ValueNotifier<bool>(false);

  ValueNotifier<bool> get authState => _authState;

  bool _isAuthenticated = false;
  Map<String, dynamic>? _userData;

  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get userData => _userData;

  AuthService() {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final token = await getToken();
    final userData = await getUser();
    
    if (token != null && userData != null) {
      _isAuthenticated = true;
      _userData = userData;
      notifyListeners();
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<bool> checkAuthentication() async {
    final token = await getToken();
    return token != null;
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'token', value: data['token']);
        await _storage.write(key: 'user', value: jsonEncode(data['user']));
        _authState.value = true;
        _isAuthenticated = true;
        _userData = data['user'];
        notifyListeners();
      } else {
        throw Exception('Login failed');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<void> signup({
    required String email,
    required String password,
    required String phoneNumber,
    required String fullName,
  }) async {
    try {
      final response = await ApiService.signup(
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        fullName: fullName,
      );
      _isAuthenticated = true;
      _userData = response['user'];
      await _storage.write(key: 'token', value: response['token']);
      await _storage.write(key: 'user', value: jsonEncode(response['user']));
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        await http.post(
          Uri.parse('${ApiConstants.baseUrl}/auth/logout'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
      }
    } catch (e) {
      print('Logout error: $e');
    } finally {
      await _storage.delete(key: 'token');
      await _storage.delete(key: 'user');
      _isAuthenticated = false;
      _userData = null;
      _authState.value = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> getUser() async {
    final userJson = await _storage.read(key: 'user');
    if (userJson != null) {
      return jsonDecode(userJson);
    }
    return null;
  }

  Future<String?> getUserId() async {
    final user = await getUser();
    return user?['_id'];
  }
} 