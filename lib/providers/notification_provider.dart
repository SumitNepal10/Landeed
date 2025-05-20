import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/property_notification.dart';
import '../services/auth_service.dart';
import '../constant/api_constants.dart';

class NotificationProvider with ChangeNotifier {
  final List<PropertyNotification> _notifications = [];
  bool _isLoading = false;
  String _error = '';

  List<PropertyNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String get error => _error;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> getNotifications() async {
    _isLoading = true;
    _error = '';
    await Future.microtask(() => notifyListeners());

    try {
      final token = await AuthService().getUserToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _notifications.clear();
        _notifications.addAll(
          data.map((json) => PropertyNotification.fromJson(json)).toList(),
        );
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      await Future.microtask(() => notifyListeners());
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final token = await AuthService().getUserToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/notifications/$notificationId/read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
          notifyListeners();
        }
      } else {
        throw Exception('Failed to mark notification as read');
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final token = await AuthService().getUserToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/notifications/mark-all-read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _notifications.replaceRange(
          0,
          _notifications.length,
          _notifications.map((n) => n.copyWith(isRead: true)).toList(),
        );
        notifyListeners();
      } else {
        throw Exception('Failed to mark all notifications as read');
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void addNotification(PropertyNotification notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }
} 