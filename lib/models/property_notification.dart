class PropertyNotification {
  final String id;
  final String title;
  final String message;
  final String propertyId;
  final String type;
  final DateTime createdAt;
  bool isRead;

  PropertyNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.propertyId,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  factory PropertyNotification.fromJson(Map<String, dynamic> json) {
    return PropertyNotification(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      propertyId: json['propertyId'] ?? '',
      type: json['type'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'propertyId': propertyId,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  PropertyNotification copyWith({
    String? id,
    String? title,
    String? message,
    String? propertyId,
    String? type,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return PropertyNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      propertyId: propertyId ?? this.propertyId,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
} 