import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../models/chat_message.dart';
import 'auth_service.dart';
import 'package:http/http.dart' as http;
import '../constant/api_constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';
import '../models/message.dart';
import 'dart:async'; // Import for StreamController
import 'package:flutter/foundation.dart';

class ChatService extends ChangeNotifier {
  final AuthService _authService = AuthService();
  String? _currentUserEmail;
  // Stream controller for incoming messages
  final _messageController = StreamController<Message>.broadcast();
  
  // Public stream for incoming messages
  Stream<Message> get messagesStream => _messageController.stream;
  
  // Stream controller for typing status
  final _typingStatusController = StreamController<Map<String, dynamic>>.broadcast();
  
  // Public stream for typing status
  Stream<Map<String, dynamic>> get typingStatusStream => _typingStatusController.stream;

  late IO.Socket socket;
  final String baseUrl;
  final String userId;

  ChatService({required this.baseUrl, required this.userId}) {
    _initializeEmail();
    _initializeSocket();
  }

  Future<void> _initializeEmail() async {
    final userData = await _authService.getUser();
    if (userData != null) {
      _currentUserEmail = userData['email'];
    }
  }

  String? get currentUserEmail => _currentUserEmail;

  void _initializeSocket() {
    socket = IO.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'auth': {'userEmail': _currentUserEmail},
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 1000,
      'timeout': 10000,
    });

    socket.connect();
    
    socket.onConnect((_) {
      print('Connected to WebSocket');
      if (_currentUserEmail != null) {
        socket.emit('join', _currentUserEmail);
      }
    });

    socket.onDisconnect((_) {
      print('Disconnected from WebSocket');
      // Attempt to reconnect
      // socket.connect(); // Removed automatic reconnect on disconnect to avoid potential loops
    });

    socket.onError((error) {
      print('Socket error: $error');
      // Attempt to reconnect on error
      // socket.connect(); // Removed automatic reconnect on error to avoid potential loops
    });

    socket.onConnectError((error) {
      print('Socket connection error: $error');
      // Attempt to reconnect on connection error
      // socket.connect(); // Removed automatic reconnect on connect error to avoid potential loops
    });
    
    // Listen for incoming messages and add to stream
    socket.on('receive_message', (data) {
      print('Received message from socket: $data');
      try {
        final message = Message.fromJson(data);
        _messageController.add(message);
        // Notify listeners that a new message was received (optional, if UI listens directly to ChatService)
        // notifyListeners(); 
      } catch (e) {
        print('Error parsing received socket message: $e for data: $data');
      }
    });
    
    // Listen for message delivered confirmations
    socket.on('message_delivered', (data) {
       print('Message delivered confirmation from socket: $data');
       try {
         final message = Message.fromJson(data);
         // You could potentially update message status in a local list here
         // and then call notifyListeners();
       } catch (e) {
         print('Error parsing delivered socket message: $e for data: $data');
       }
    });
    
    // Listen for message read confirmations
    socket.on('message_read', (data) {
       print('Message read confirmation from socket: $data');
       try {
         final message = Message.fromJson(data);
         // You could potentially update message status in a local list here
         // and then call notifyListeners();
       } catch (e) {
         print('Error parsing read socket message: $e for data: $data');
       }
    });
    
    // Listen for typing status updates and add to stream
    socket.on('typing', (data) {
       print('Typing status from socket: $data');
       _typingStatusController.add(Map<String, dynamic>.from(data));
       // Notify listeners about typing status changes (optional)
       // notifyListeners();
    });
  }

  void sendMessage({
    required String receiverEmail,
    required String message,
  }) {
    if (_currentUserEmail == null) {
      print('Error: Sender email not available for sending message');
      return;
    }

    socket.emit('sendMessage', {
      'senderEmail': _currentUserEmail,
      'receiverEmail': receiverEmail,
      'message': message,
    });
  }

  Future<List<ChatMessage>> getChatHistory(String receiverEmail) async {
    try {
      if (_currentUserEmail == null) {
        await _initializeEmail();
      }

      if (_currentUserEmail == null) {
        throw Exception('Logged-in user email not available for fetching chat history');
      }

      print('Fetching chat history with:');
      print('Current user email: $_currentUserEmail');
      print('Receiver email: $receiverEmail');

      final url = Uri.parse('${ApiConstants.baseUrl}/chat/history/$receiverEmail').replace(
        queryParameters: {'userId': _currentUserEmail!},
      );

      print('Request URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ChatMessage.fromMap(json)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        print('Backend response body on chat history error: ${response.body}');
        throw Exception('Failed to load chat history: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting chat history: $e');
      rethrow;
    }
  }

  void sendTypingStatus(String receiverEmail, bool isTyping) {
    if (_currentUserEmail == null) return;

    socket.emit('typing', {
      'senderEmail': _currentUserEmail,
      'receiverEmail': receiverEmail,
      'isTyping': isTyping,
    });
  }

  void markMessagesAsRead({required String senderEmail, required String receiverEmail}) {
    if (_currentUserEmail == null) return;
    if (receiverEmail != _currentUserEmail) {
      print('Warning: Attempted to mark messages as read for a conversation where current user is not the receiver.');
      return;
    }

    print('Attempting to mark messages from ${senderEmail} as read for user ${receiverEmail}.');
    socket.emit('mark_read', { 'senderEmail': senderEmail, 'receiverEmail': receiverEmail });
  }

  Future<void> markAsDelivered(String messageId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/chat/mark-delivered'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'messageId': messageId,
        }),
      );

      if (response.statusCode != 200) {
        print('Failed to mark message as delivered: ${response.statusCode}');
      }
    } catch (e) {
      print('Error marking message as delivered: $e');
    }
  }

  void dispose() {
    socket.disconnect();
    socket.dispose();
    _messageController.close();
    _typingStatusController.close();
  }

  Future<void> sendMessageToSocket({
    required String receiverEmail,
    required String propertyId,
    required String message,
  }) async {
    try {
      if (_currentUserEmail == null) {
        final userData = await _authService.getUser();
        if (userData != null) {
          _currentUserEmail = userData['email'];
        }
      }

      if (_currentUserEmail == null) {
        throw Exception('Sender email not available for sending message (via sendMessageToSocket)');
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/chat/send'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'senderEmail': _currentUserEmail,
          'receiverEmail': receiverEmail,
          'message': message,
          'propertyId': propertyId,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        socket.emit('message_sent', {
          ...data,
          'status': 'sent',
        });
      } else {
        print('Failed to save message via HTTP: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to save message via HTTP with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending message via HTTP: $e');
      rethrow;
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/chat/rooms/$conversationId');
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Add any necessary authentication headers here
          // 'Authorization': 'Bearer ${your_token}',
        },
      );

      if (response.statusCode != 200) {
        print('Failed to delete conversation: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to delete conversation with status: ${response.statusCode}');
      }
      print('Conversation $conversationId deleted successfully on backend');
    } catch (e) {
      print('Error deleting conversation: $e');
      rethrow;
    }
  }
} 