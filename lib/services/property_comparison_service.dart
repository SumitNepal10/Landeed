import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constant/api_constants.dart';
import '../services/auth_service.dart';
import '../models/property.dart';

class PropertyComparisonService with ChangeNotifier {
  final AuthService _authService = AuthService();
  final List<Property> _comparisonList = [];
  bool _isLoading = false;
  String _error = '';

  List<Property> get comparisonList => _comparisonList;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> addToComparison(Property property) async {
    if (_comparisonList.length >= 4) {
      _error = 'Maximum 4 properties can be compared at once';
      notifyListeners();
      return;
    }

    if (!_comparisonList.any((p) => p.id == property.id)) {
      _comparisonList.add(property);
      notifyListeners();
    }
  }

  Future<void> removeFromComparison(String propertyId) async {
    _comparisonList.removeWhere((property) => property.id == propertyId);
    notifyListeners();
  }

  Future<void> clearComparison() async {
    _comparisonList.clear();
    notifyListeners();
  }

  Future<Map<String, dynamic>> getComparisonSummary() async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _authService.getUserToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final propertyIds = _comparisonList.map((p) => p.id).join(',');
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/properties/compare?ids=$propertyIds'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get comparison summary');
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getSimilarProperties(String propertyId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _authService.getUserToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/properties/$propertyId/similar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get similar properties');
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