import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constant/api_constants.dart';
import '../services/auth_service.dart';

class PropertyAnalyticsService with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String _error = '';

  bool get isLoading => _isLoading;
  String get error => _error;

  Future<Map<String, dynamic>> getPropertyAnalytics(String propertyId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _authService.getUserToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/properties/$propertyId/analytics'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load property analytics');
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> trackPropertyView(String propertyId) async {
    try {
      final token = await _authService.getUserToken();
      if (token == null) return;

      await http.post(
        Uri.parse('${ApiConstants.baseUrl}/properties/$propertyId/track-view'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      print('Error tracking property view: $e');
    }
  }

  Future<void> trackPropertyInquiry(String propertyId) async {
    try {
      final token = await _authService.getUserToken();
      if (token == null) return;

      await http.post(
        Uri.parse('${ApiConstants.baseUrl}/properties/$propertyId/track-inquiry'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      print('Error tracking property inquiry: $e');
    }
  }

  Future<Map<String, dynamic>> getMarketTrends(String location) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _authService.getUserToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/market-trends?location=$location'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load market trends');
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 