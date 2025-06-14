class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String propertyId;
  final String content;
  final DateTime timestamp;
  final String status;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.propertyId,
    required this.content,
    required this.timestamp,
    required this.status,
  });

  Message copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? propertyId,
    String? content,
    DateTime? timestamp,
    String? status,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      propertyId: propertyId ?? this.propertyId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      propertyId: json['propertyId'] ?? '',
      content: json['content'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      status: json['status'] ?? 'sent',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'propertyId': propertyId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
    };
  }
} 