import 'package:flutter/material.dart';
import 'package:partice_project/services/api_service.dart';
import 'package:partice_project/services/storage_service.dart';
import 'package:partice_project/utils/route_name.dart';

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  Map<String, dynamic>? _userData;

  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get userData => _userData;

  AuthService() {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final token = await StorageService.getToken();
    final userData = await StorageService.getUserData();
    
    if (token != null && userData != null) {
      _isAuthenticated = true;
      _userData = userData;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await ApiService.login(email: email, password: password);
      _isAuthenticated = true;
      _userData = response['user'];
      notifyListeners();
    } catch (e) {
      rethrow;
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
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await ApiService.logout();
    _isAuthenticated = false;
    _userData = null;
    notifyListeners();
  }
} 