import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiErrorHandler {
  void logApiCall(
    String endpoint, {
    Map<String, dynamic>? requestBody,
    String? responseBody,
    int? statusCode,
  }) {
    developer.log(
      'API Call: $endpoint',
      name: 'ApiService',
      error: {
        'request': requestBody,
        'response': responseBody,
        'statusCode': statusCode,
      },
    );
  }

  String getErrorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      return body['message'] ?? 'An unexpected error occurred';
    } catch (e) {
      return 'Failed to process response: ${response.statusCode}';
    }
  }

  String handleException(dynamic error) {
    if (error is http.ClientException) {
      return 'Network error occurred. Please check your connection.';
    } else if (error is FormatException) {
      return 'Invalid response format from server.';
    } else if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return 'An unexpected error occurred';
  }

  void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
} 
 