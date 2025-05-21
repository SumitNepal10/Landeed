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
  final int yearBuilt;

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
    required this.yearBuilt,
  });

  // For backward compatibility
  String get imageUrl => images.isNotEmpty ? images.first : '';
  String get type => propertyType;

  factory Property.fromJson(Map<String, dynamic> json) {
    String parseId(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is int) return value.toString();
      // Log unexpected types for _id
      // print('Unexpected type for ID field: ${value.runtimeType} with value $value');
      return '';
    }

    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      // Log unexpected types for int fields
      // print('Unexpected type for integer field: ${value.runtimeType} with value $value');
      return 0;
    }

    double parseDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
       // Log unexpected types for double fields
      // print('Unexpected type for double field: ${value.runtimeType} with value $value');
      return 0.0;
    }

    // Log the raw values being parsed for id and userId
    // print('Parsing property JSON:');
    // print('  _id raw value: ${json['_id']?.runtimeType} - ${json['_id']}');
    // print('  id raw value: ${json['id']?.runtimeType} - ${json['id']}');
    // if (json.containsKey('user') && json['user'] != null) {
    //    print('  user type: ${json['user'].runtimeType}');
    //    if (json['user'] is Map) {
    //        print('  user._id raw value: ${json['user']?['_id']?.runtimeType} - ${json['user']?['_id']}');
    //    } else {
    //         print('  User field is not a map, value: ${json['user']}');
    //    }
    // }

    return Property(
      id: parseId(json['_id'] ?? json['id']),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: parseDouble(json['price']),
      location: json['location'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      propertyType: json['propertyType'] ?? json['type'] ?? '',
      status: json['status'] ?? 'available',
      bedrooms: json['bedrooms'] != null
          ? parseInt(json['bedrooms'])
          : json['roomDetails']?['bedrooms'] != null
              ? parseInt(json['roomDetails']?['bedrooms'])
              : 0,
      bathrooms: json['bathrooms'] != null
          ? parseInt(json['bathrooms'])
          : json['roomDetails']?['bathrooms'] != null
              ? parseInt(json['roomDetails']?['bathrooms'])
              : 0,
      area: json['area'] != null
          ? parseDouble(json['area'])
          : json['size'] != null
              ? parseDouble(json['size'])
              : 0.0,
      features: json['features'] is Map
          ? (json['features'] as Map).entries
              .where((e) => e.value == true)
              .map((e) => e.key.toString())
              .toList()
          : [],
      userId: parseId(json['userId'] ?? (json.containsKey('user') && json['user'] is Map ? json['user']['_id'] : null)),
      userEmail: json['userEmail'] ?? (json.containsKey('user') && json['user'] is Map ? json['user']['email'] : null),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      isSale: json['purpose'] == 'Sale' || (json['isSale'] ?? true),
      isFavorite: json['isFavorite'] ?? false,
      yearBuilt: json['yearBuilt'] != null
          ? parseInt(json['yearBuilt'])
          : DateTime.now().year,
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
      'yearBuilt': yearBuilt,
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
    int? yearBuilt,
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
      yearBuilt: yearBuilt ?? this.yearBuilt,
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