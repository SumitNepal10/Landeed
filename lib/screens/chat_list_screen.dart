import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import 'chat_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constant/api_constants.dart';
import '../constant/colors.dart';

class ChatListScreen extends StatefulWidget {
  final String userId;
  final String baseUrl;

  const ChatListScreen({
    Key? key,
    required this.userId,
    required this.baseUrl,
  }) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late ChatService _chatService;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _conversations = [];

  @override
  void initState() {
    super.initState();
    _chatService = ChatService(
      baseUrl: widget.baseUrl,
      userId: widget.userId,
    );
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/chat/rooms').replace(
        queryParameters: {'userId': widget.userId},
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _conversations = List<Map<String, dynamic>>.from(data);
          _error = null;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _conversations = [];
          _error = null;
        });
      } else {
        print('Backend response body on chat list error: ${response.body}');
        throw Exception('Failed to load chat rooms: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading chat rooms: $e');
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red[300]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _error = null;
                _isLoading = true;
              });
              _loadConversations();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthenticationWidget(BuildContext context) {
    return SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat History'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget(_error!)
              : _conversations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No conversations yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start chatting with property owners\nor interested buyers',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = _conversations[index];
                        final otherUser = conversation['otherUser'];

                        final String otherUserId = otherUser?['_id']?.toString() ?? '';
                        final String otherUserEmail = otherUser?['email'] ?? '';
                        final String otherUserName = otherUser?['fullName'] ?? otherUserEmail;

                        if (otherUser == null || otherUserId.isEmpty || otherUserEmail.isEmpty) {
                          print('Skipping conversation item due to missing or invalid user data: $conversation');
                          return SizedBox.shrink();
                        }

                        final lastMessage = conversation['lastMessage'];
                        final lastMessageTime = conversation['lastMessageTime'] != null
                            ? DateTime.parse(conversation['lastMessageTime'])
                            : DateTime.now();

                        final int unreadCount = conversation['unreadCount'] is int ? conversation['unreadCount'] : 0;

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.primaryColor,
                              child: Text(
                                otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              otherUserName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                lastMessage?.toString() ?? 'No messages yet',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _formatTimestamp(lastMessageTime),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                if (unreadCount > 0) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      unreadCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    userId: widget.userId,
                                    receiverId: otherUserId,
                                    receiverName: otherUserName,
                                    receiverEmail: otherUserEmail,
                                    baseUrl: widget.baseUrl,
                                  ),
                                ),
                              ).then((_) => _loadConversations());
                            },
                          ),
                        );
                      },
                    ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  @override
  void dispose() {
    _chatService.dispose();
    super.dispose();
  }
} 