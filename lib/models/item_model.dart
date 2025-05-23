class ItemModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final String imageUrl;
  final double? latitude;
  final double? longitude;

  ItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.imageUrl,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
}
