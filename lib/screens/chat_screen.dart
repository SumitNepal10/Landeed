import 'package:flutter/material.dart';
import '../models/message.dart';
import '../models/property.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String receiverId;
  final String receiverName;
  final String receiverEmail;
  final String baseUrl;
  final Property? property;

  const ChatScreen({
    Key? key,
    required this.userId,
    required this.receiverId,
    required this.receiverName,
    required this.receiverEmail,
    required this.baseUrl,
    this.property,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatService _chatService;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];

  // Stream subscription for incoming messages
  StreamSubscription<Message>? _messagesSubscription;

  @override
  void initState() {
    super.initState();
    // Get the ChatService instance from the Provider
    _chatService = Provider.of<ChatService>(context, listen: false);
    
    // Although ChatService is now provided, ensure the socket is connected and joined
    // This might be redundant if handled globally, but good for ensuring in this screen context
    if (!_chatService.socket.connected) {
      _chatService.socket.connect();
      // Potentially re-emit 'join' if needed after a manual connect call
      // if (_chatService.currentUserEmail != null) {
      //    _chatService.socket.emit('join', _chatService.currentUserEmail);
      // }
    }

    _listenToMessagesStream();
    _loadChatHistory();
  }

  void _listenToMessagesStream() {
    // Listen for incoming messages
    _messagesSubscription = _chatService.messagesStream.listen((message) {
      print('Received message from stream in ChatScreen: ${message.toJson()}');
      // Only add the message if it's for the current conversation
      if (message.senderId == widget.receiverEmail || message.receiverId == widget.receiverEmail) {
        setState(() {
          // Prevent duplicates and ensure messages are in correct order if history loads later
          final existingIndex = _messages.indexWhere((m) => m.id == message.id);
          if (existingIndex == -1) {
            _messages.add(message);
            _scrollToBottom();
          } else {
             // Update existing message (e.g., status changes)
             _messages[existingIndex] = message;
          }
        });
        // Mark the received message as delivered
        if (message.receiverId == _chatService.currentUserEmail) {
           _chatService.markAsDelivered(message.id);
        }
      }
    });
  }

  Future<void> _loadChatHistory() async {
    try {
      final chatMessages = await _chatService.getChatHistory(widget.receiverEmail);
      if (mounted) {
        setState(() {
          _messages.clear();
          if (chatMessages.isNotEmpty) {
            _messages.addAll(chatMessages.map((chatMessage) => Message(
              id: chatMessage.id,
              senderId: chatMessage.senderEmail,
              receiverId: chatMessage.receiverEmail,
              propertyId: widget.property?.id ?? '',
              content: chatMessage.message,
              timestamp: chatMessage.timestamp,
              status: chatMessage.isRead ? 'read' : 'sent',
            )));
          }
        });
      }
    } catch (e) {
      print('Error loading chat history: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load chat history: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    try {
      // Create a temporary message object
      final tempMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
        senderId: _chatService.currentUserEmail ?? '',
        receiverId: widget.receiverEmail,
        propertyId: widget.property?.id ?? '',
        content: message,
        timestamp: DateTime.now(),
        status: 'sending',
      );

      // Add message to UI immediately
      setState(() {
        _messages.add(tempMessage);
      });
      _scrollToBottom();
      _messageController.clear();

      // Send message to server
      await _chatService.sendMessageToSocket(
        receiverEmail: widget.receiverEmail,
        propertyId: widget.property?.id ?? '',
        message: message,
      );

      // Update message status to sent
      setState(() {
        final index = _messages.indexWhere((m) => m.id == tempMessage.id);
        if (index != -1) {
          _messages[index] = _messages[index].copyWith(status: 'sent');
        }
      });
    } catch (e) {
      print('Error sending message: $e');
      // Update message status to failed
      setState(() {
        final index = _messages.indexWhere((m) => m.content == message);
        if (index != -1) {
          _messages[index] = _messages[index].copyWith(status: 'failed');
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _sendMessage,
            ),
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message.senderId == _chatService.currentUserEmail;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isMe
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message.content,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (message.status == 'sending')
                              const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                                ),
                              ),
                            if (message.status == 'failed')
                              Icon(Icons.error_outline, 
                                size: 12, 
                                color: isMe ? Colors.white70 : Colors.red,
                              ),
                            const SizedBox(width: 4),
                            Text(
                              _formatTimestamp(message.timestamp),
                              style: TextStyle(
                                fontSize: 12,
                                color: isMe
                                    ? Colors.white.withOpacity(0.7)
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inHours > 0) {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inMinutes > 0) {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return 'now';
    }
  }

  @override
  void dispose() {
    // No need to dispose _chatService here as it's provided
    _messageController.dispose();
    _scrollController.dispose();
    _messagesSubscription?.cancel(); // Cancel the stream subscription
    super.dispose();
  }
} 