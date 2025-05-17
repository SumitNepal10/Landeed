class Property {
  final String id;
  final String imageUrl;
  final String type;
  final bool isSale;
  final double price;
  final String location;
  final bool isFavorite;

  const Property({
    required this.id,
    required this.imageUrl,
    required this.type,
    required this.isSale,
    required this.price,
    required this.location,
    this.isFavorite = false,
  });

  Property copyWith({
    String? id,
    String? imageUrl,
    String? type,
    bool? isSale,
    double? price,
    String? location,
    bool? isFavorite,
  }) {
    return Property(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      isSale: isSale ?? this.isSale,
      price: price ?? this.price,
      location: location ?? this.location,
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