import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String category;
  final Timestamp timestamp;
  final String userId;

  Item({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.category,
    required this.timestamp,
    required this.userId,
  });

  factory Item.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Item(
      id: doc.id,
      title: data['title'] ?? 'No Title',
      description: data['description'] ?? 'No Description',
      imageUrl: data['imageUrl'],
      category: data['category'] ?? 'Uncategorized',
      timestamp: data['timestamp'] ?? Timestamp.now(), // Provide a default
      userId: data['userId'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'timestamp': timestamp,
    };
  }
}
