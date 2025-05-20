class Property {
  final String id;
  final String title;
  final String description;
  final double price;
  final String location;
  final List<String> images;
  final String propertyType;
  final String status;
  final int bedrooms;
  final int bathrooms;
  final double area;
  final List<String> features;
  final String? userId;
  final String? userEmail;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSale;
  final bool isFavorite;

  const Property({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.images,
    required this.propertyType,
    required this.status,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.features,
    this.userId,
    this.userEmail,
    required this.createdAt,
    required this.updatedAt,
    required this.isSale,
    this.isFavorite = false,
  });

  // For backward compatibility
  String get imageUrl => images.isNotEmpty ? images.first : '';
  String get type => propertyType;

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      location: json['location'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      propertyType: json['propertyType'] ?? json['type'] ?? '',
      status: json['status'] ?? 'available',
      bedrooms: json['bedrooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      area: double.tryParse(json['area']?.toString() ?? '0') ?? 0.0,
      features: json['features'] is Map
          ? (json['features'] as Map).entries
              .where((e) => e.value == true)
              .map((e) => e.key.toString())
              .toList()
          : [],
      userId: json['userId'] ?? json['user']?['_id'],
      userEmail: json['userEmail'] ?? json['user']?['email'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
      isSale: json['isSale'] ?? true,
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'location': location,
      'images': images,
      'propertyType': propertyType,
      'status': status,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'area': area,
      'features': features,
      'userId': userId,
      'userEmail': userEmail,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSale': isSale,
      'isFavorite': isFavorite,
    };
  }

  Property copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? location,
    List<String>? images,
    String? propertyType,
    String? status,
    int? bedrooms,
    int? bathrooms,
    double? area,
    List<String>? features,
    String? userId,
    String? userEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSale,
    bool? isFavorite,
  }) {
    return Property(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      location: location ?? this.location,
      images: images ?? this.images,
      propertyType: propertyType ?? this.propertyType,
      status: status ?? this.status,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      area: area ?? this.area,
      features: features ?? this.features,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSale: isSale ?? this.isSale,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Property && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}