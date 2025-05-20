import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'storage_service.dart';
import 'package:landeed/constant/api_constants.dart';
import 'package:landeed/utils/api_error_handler.dart';

class ApiService {
  static final ApiErrorHandler _errorHandler = ApiErrorHandler();

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
    required BuildContext context,
  }) async {
    try {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
        'fullName': fullName,
      }),
    );

      _errorHandler.logApiCall(
        'POST /auth/signup',
        requestBody: {'email': email, 'phoneNumber': phoneNumber, 'fullName': fullName},
        responseBody: response.body,
        statusCode: response.statusCode,
      );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await StorageService.saveToken(data['token']);
      await StorageService.saveUserData(data['user']);
      return data;
    } else {
        final errorMessage = _errorHandler.getErrorMessage(response);
        _errorHandler.showError(context, errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      final errorMessage = _errorHandler.handleException(e);
      _errorHandler.showError(context, errorMessage);
      throw Exception(errorMessage);
    }
  }

  // Login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

      _errorHandler.logApiCall(
        'POST /auth/login',
        requestBody: {'email': email},
        responseBody: response.body,
        statusCode: response.statusCode,
      );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await StorageService.saveToken(data['token']);
      await StorageService.saveUserData(data['user']);
      return data;
    } else {
        final errorMessage = _errorHandler.getErrorMessage(response);
        _errorHandler.showError(context, errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      final errorMessage = _errorHandler.handleException(e);
      _errorHandler.showError(context, errorMessage);
      throw Exception(errorMessage);
    }
  }

  // Admin Login
  static Future<Map<String, dynamic>> adminLogin({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/admin/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

      _errorHandler.logApiCall(
        'POST /admin/login',
        requestBody: {'email': email},
        responseBody: response.body,
        statusCode: response.statusCode,
      );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await StorageService.saveAdminToken(data['token']);
      await StorageService.saveAdminData(data['admin']);
      return data;
    } else {
        final errorMessage = _errorHandler.getErrorMessage(response);
        _errorHandler.showError(context, errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      final errorMessage = _errorHandler.handleException(e);
      _errorHandler.showError(context, errorMessage);
      throw Exception(errorMessage);
    }
  }

  // Logout
  static Future<void> logout() async {
    try {
    await StorageService.clearStorage();
      _errorHandler.logApiCall('Logout', responseBody: 'Storage cleared successfully');
    } catch (e) {
      _errorHandler.handleException(e);
      rethrow;
    }
  }
} 