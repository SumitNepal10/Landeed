import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:landeed/models/message.dart';
import 'package:landeed/constant/api_constants.dart';

class MessageService {
  final String baseUrl = ApiConstants.baseUrl;

  // Save a message to MongoDB
  Future<Message> saveMessage(Message message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(message.toJson()),
      );

      if (response.statusCode == 201) {
        return Message.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to save message: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error saving message: $e');
    }
  }

  // Get messages for a specific property
  Future<List<Message>> getMessagesForProperty(String propertyId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages/property/$propertyId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> messagesJson = json.decode(response.body);
        return messagesJson.map((json) => Message.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load messages: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading messages: $e');
    }
  }

  // Get messages between two users for a specific property
  Future<List<Message>> getMessagesBetweenUsers(
    String propertyId,
    String user1Id,
    String user2Id,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages/property/$propertyId/users/$user1Id/$user2Id'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> messagesJson = json.decode(response.body);
        return messagesJson.map((json) => Message.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load messages: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading messages: $e');
    }
  }
} 