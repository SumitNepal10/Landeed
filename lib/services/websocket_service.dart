import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

// Conditional import for different platforms
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/html.dart';
import 'package:landeed/models/message.dart';
import 'package:landeed/services/message_service.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  
  // Get the appropriate WebSocket URL based on platform
  String get _baseUrl {
    if (kIsWeb) {
      return 'ws://localhost:5000';
    } else if (!kIsWeb && Platform.isAndroid) {
      return 'ws://10.0.2.2:5000';
    } else {
      return 'ws://localhost:5000';
    }
  }
  
  final MessageService _messageService = MessageService();
  
  // Store message history
  final List<Message> _messageHistory = [];
  bool _isConnecting = false;
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 5;
  
  // Getter for message history
  List<Message> get messageHistory => List.unmodifiable(_messageHistory);
  
  // Getter for message stream
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  Future<void> connect(String userId) async {
    if (_isConnecting) return;
    
    try {
      _isConnecting = true;
      final wsUrl = Uri.parse('$_baseUrl/ws?userId=$userId');
      print('Connecting to WebSocket at: $wsUrl');

      // Use the appropriate WebSocket channel based on platform
      if (kIsWeb) {
        _channel = HtmlWebSocketChannel.connect(wsUrl);
      } else {
        _channel = IOWebSocketChannel.connect(wsUrl);
      }

      _channel?.stream.listen(
        (message) async {
          try {
            print('Received WebSocket message: $message');
            final data = json.decode(message);
            if (data['type'] == 'message') {
              _messageController.add(data);
            } else if (data['type'] == 'error') {
              print('Received error from server: ${data['message']}');
              _messageController.add(data);
            }
          } catch (e) {
            print('Error handling message: $e');
            _messageController.add({
              'type': 'error',
              'message': 'Error handling message: $e'
            });
          }
        },
        onError: (error) {
          print('WebSocket Error: $error');
          _messageController.add({
            'type': 'error',
            'message': 'WebSocket error: $error'
          });
        },
        onDone: () {
          print('WebSocket Connection Closed');
          _messageController.add({
            'type': 'error',
            'message': 'WebSocket connection closed'
          });
        },
      );
      
      _reconnectAttempts = 0;
      print('Successfully connected to WebSocket: $wsUrl');
    } catch (e) {
      print('WebSocket connection failed: $e');
      _messageController.add({
        'type': 'error',
        'message': 'Failed to connect to WebSocket: $e'
      });
    } finally {
      _isConnecting = false;
    }
  }

  void _handleConnectionError(String userId) {
    if (_reconnectAttempts < maxReconnectAttempts) {
      _reconnectAttempts++;
      print('Attempting to reconnect (${_reconnectAttempts}/$maxReconnectAttempts)...');
      Future.delayed(Duration(seconds: _reconnectAttempts * 2), () {
        connect(userId);
      });
    } else {
      print('Max reconnection attempts reached');
      _messageController.add({
        'type': 'error',
        'message': 'Failed to connect to chat server after $maxReconnectAttempts attempts'
      });
    }
  }

  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String propertyId,
    required String message,
  }) async {
    if (_channel == null || _channel!.sink == null) {
      throw Exception('WebSocket connection is not available');
    }

    final timestamp = DateTime.now();
    // Prepare data to send through WebSocket
    final data = {
      'type': 'message',
      'senderId': senderId,
      'receiverId': receiverId,
      'propertyId': propertyId,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };

    try {
      // Send through WebSocket
      _channel!.sink.add(json.encode(data));
      print('Sent message: ${json.encode(data)}');
      // The server will handle saving to the database and broadcasting the saved message back.
    } catch (e) {
      print('Error sending message: $e');
      throw Exception('Failed to send message: $e');
    }
  }

  // Get messages for a specific property
  Future<List<Message>> getMessagesForProperty(String propertyId) async {
    try {
      final messages = await _messageService.getMessagesForProperty(propertyId);
      _messageHistory.clear();
      _messageHistory.addAll(messages);
      return messages;
    } catch (e) {
      print('Error loading messages: $e');
      _messageController.add({
        'type': 'error',
        'message': 'Failed to load messages: $e'
      });
      return [];
    }
  }

  // Get messages between two users for a specific property
  Future<List<Message>> getMessagesBetweenUsers(
    String propertyId,
    String user1Id,
    String user2Id,
  ) async {
    try {
      return await _messageService.getMessagesBetweenUsers(
        propertyId,
        user1Id,
        user2Id,
      );
    } catch (e) {
      print('Error loading messages: $e');
      throw Exception('Failed to load messages: $e');
    }
  }

  void disconnect() {
    print('Disconnecting WebSocket...');
    _channel?.sink.close();
    _messageController.close();
  }
}
