import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/property.dart';
import '../models/property_notification.dart';
import '../services/auth_service.dart';
import '../constant/api_constants.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';

class PropertyProvider with ChangeNotifier {
  final List<Property> _myProperties = [];
  bool _isLoading = false;
  String _error = '';
  final AuthService _authService = AuthService();

  List<Property> get myProperties => _myProperties;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> getMyProperties() async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _authService.getUserToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/properties/my-properties'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _myProperties.clear();
        _myProperties.addAll(
          data.map((json) => Property.fromJson(json)).toList(),
        );
      } else {
        throw Exception('Failed to load properties');
      }
    } catch (e) {
      print('Error getting my properties: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProperty(Property property) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final token = await AuthService().getUserToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/properties'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(property.toJson()),
      );

      if (response.statusCode == 201) {
        final newProperty = Property.fromJson(json.decode(response.body));
        _myProperties.add(newProperty);
      } else {
        throw Exception('Failed to add property');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProperty(Property property) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final token = await AuthService().getUserToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/properties/${property.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(property.toJson()),
      );

      if (response.statusCode == 200) {
        final updatedProperty = Property.fromJson(json.decode(response.body));
        final index = _myProperties.indexWhere((p) => p.id == property.id);
        if (index != -1) {
          _myProperties[index] = updatedProperty;
        }
      } else {
        throw Exception('Failed to update property');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProperty(String propertyId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final token = await AuthService().getUserToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/properties/$propertyId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _myProperties.removeWhere((property) => property.id == propertyId);
      } else {
        throw Exception('Failed to delete property');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> handlePropertyRejection(String propertyId, String reason, BuildContext context) async {
    try {
      final token = await AuthService().getUserToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/properties/$propertyId/reject'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'reason': reason}),
      );

      if (response.statusCode == 200) {
        // Create and add notification
        final notification = PropertyNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Property Rejected',
          message: 'Your property has been rejected. Reason: $reason',
          propertyId: propertyId,
          type: 'rejection',
          createdAt: DateTime.now(),
        );

        // Add notification to the provider
        Provider.of<NotificationProvider>(context, listen: false)
            .addNotification(notification);

        // Remove the property from the list
        _myProperties.removeWhere((property) => property.id == propertyId);
        notifyListeners();
      } else {
        throw Exception('Failed to reject property');
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
} 