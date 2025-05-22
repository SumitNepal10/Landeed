import 'package:flutter/material.dart';
import 'package:landeed/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:landeed/constant/api_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final _authState = ValueNotifier<bool>(false);

  ValueNotifier<bool> get authState => _authState;

  bool _isAuthenticated = false;
  bool _isAdmin = false;
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _tempUserData;

  bool get isAuthenticated => _isAuthenticated;
  bool get isAdmin => _isAdmin;
  Map<String, dynamic>? get userData => _userData;

  AuthService() {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      final token = await getToken();
      final adminToken = await getAdminToken();
      final userData = await getUser();
      final adminData = await getAdmin();
      
      if (adminToken != null && adminData != null) {
        _isAuthenticated = true;
        _isAdmin = true;
        _userData = adminData;
        notifyListeners();
      } else if (token != null && userData != null) {
        _isAuthenticated = true;
        _isAdmin = false;
        _userData = userData;
        notifyListeners();
      }
    } catch (e) {
      _isAuthenticated = false;
      _isAdmin = false;
      _userData = null;
      notifyListeners();
    }
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: 'token');
    } catch (e) {
      return null;
    }
  }

  Future<String?> getAdminToken() async {
    try {
      return await _storage.read(key: 'admin_token');
    } catch (e) {
      throw Exception('Error getting admin token');
    }
  }

  Future<Map<String, dynamic>?> getAdmin() async {
    try {
      final adminJson = await _storage.read(key: 'admin');
      return adminJson != null ? jsonDecode(adminJson) : null;
    } catch (e) {
      throw Exception('Error getting admin data');
    }
  }

  Future<bool> checkAuthentication() async {
    try {
      final token = await getToken();
      final adminToken = await getAdminToken();
      return token != null || adminToken != null;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    bool isAdmin = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/${isAdmin ? 'admin' : 'auth'}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (isAdmin) {
          await _storage.write(key: 'admin_token', value: data['token']);
          await _storage.write(key: 'admin', value: jsonEncode(data['admin']));
          _isAuthenticated = true;
          _isAdmin = true;
          _userData = data['admin'];
        } else {
          await _storage.write(key: 'token', value: data['token']);
          await _storage.write(key: 'userData', value: jsonEncode(data['user']));
          _isAuthenticated = true;
          _isAdmin = false;
          _userData = data['user'];
        }
        
        _authState.value = true;
        notifyListeners();

        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      print('Login error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<void> logout() async {
    try {
      await _storage.deleteAll();
      _isAuthenticated = false;
      _isAdmin = false;
      _userData = null;
      _authState.value = false;
      notifyListeners();
    } catch (e) {
      print('Logout error: $e');
      rethrow;
    }
  }

  Future<bool> checkIsAdmin() async {
    try {
      final adminToken = await getAdminToken();
      final adminData = await getAdmin();
      return adminToken != null && adminData != null;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUser() async {
    try {
      final userJson = await _storage.read(key: 'userData');
      return userJson != null ? jsonDecode(userJson) : null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getUserId() async {
    try {
      final user = await getUser();
      return user?['_id'];
    } catch (e) {
      return null;
    }
  }

  Future<void> sendSignupOTP({
    required String email,
    required String password,
    required String phoneNumber,
    required String fullName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'phoneNumber': phoneNumber,
          'fullName': fullName,
        }),
      );

      if (response.statusCode == 200) {
        // Store temporary user data
        _tempUserData = {
          'email': email,
          'password': password,
          'phoneNumber': phoneNumber,
          'fullName': fullName,
        };
        return;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      throw Exception('Failed to send OTP: $e');
    }
  }

  Future<void> verifyOTPAndSignup(String otp) async {
    if (_tempUserData == null) {
      throw Exception('No pending signup data found');
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _tempUserData!['email'],
          'otp': otp,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Store user data and token
        await _storage.write(key: 'token', value: data['token']);
        await _storage.write(key: 'user', value: jsonEncode(data['user']));
        _isAuthenticated = true;
        _isAdmin = false;
        _userData = data['user'];
        _tempUserData = null; // Clear temporary data
        notifyListeners();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Invalid OTP');
      }
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }

  Future<void> verifyOTP({
    required String verificationId,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'verificationId': verificationId,
          'otp': otp,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'token', value: data['token']);
        await _storage.write(key: 'user', value: jsonEncode(data['user']));
        _isAuthenticated = true;
        _isAdmin = false;
        _userData = data['user'];
        notifyListeners();
      } else {
        throw Exception('Failed to verify OTP');
      }
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }

  Future<void> resendOTP(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/resend-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to resend OTP');
      }
    } catch (e) {
      throw Exception('Failed to resend OTP: $e');
    }
  }

  Future<void> signup({
    required String email,
    required String password,
    required String phoneNumber,
    required String fullName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'phoneNumber': phoneNumber,
          'fullName': fullName,
          'userData': {
            'email': email,
            'password': password,
            'phoneNumber': phoneNumber,
            'fullName': fullName,
          }
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      throw Exception('Failed to send OTP: $e');
    }
  }

  Future<String?> getUserToken() async {
    try {
      return await _storage.read(key: 'user_token');
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUserProfile({
    required String name,
    String? profileImageBase64,
  }) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Not authenticated');

      final userData = await getUser();
      if (userData == null || userData['email'] == null) {
        throw Exception('User email not found');
      }

      final body = {
        'email': userData['email'],
        'name': name,
        if (profileImageBase64 != null) 'profileImage': profileImageBase64,
      };

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/auth/update-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final updatedUser = jsonDecode(response.body)['user'];
        await _storage.write(key: 'userData', value: jsonEncode(updatedUser));
        _userData = updatedUser;
        notifyListeners();
      } else {
        throw Exception('Failed to update profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<void> verifyEmailOTP({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          // Store user data and token
          await _storage.write(key: 'token', value: data['token']);
          await _storage.write(key: 'userData', value: jsonEncode(data['user']));
          _isAuthenticated = true;
          _isAdmin = false;
          _userData = data['user'];
          notifyListeners();
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Email verification failed');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> resendEmailOTP(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/resend-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to resend OTP');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> verifyPasswordResetOTP({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'isPasswordReset': true,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Password reset verification failed');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/request-password-reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to send password reset OTP');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to reset password');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
} 