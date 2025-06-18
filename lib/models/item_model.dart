import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum to represent the current state of an item.
/// This provides better type safety and code clarity than using raw strings.
enum ItemStatus {
  registered, // Default state when a user adds an item
  lost, // The owner has reported it as lost
  found, // A finder has reported this item (for the community feature)
  returned, // The item has been successfully returned
}

class Item {
  // --- Core Properties ---
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String category;
  final Timestamp timestamp; // The date the item was originally registered
  final String userId; // The ID of the user who owns this item

  // --- Tracking & Status Properties ---

  /// The current status of the item (e.g., registered, lost).
  final ItemStatus status;

  /// The unique identifier of the associated Bluetooth tracking tag.
  /// This is null if no tag has been paired.
  final String? bluetoothDeviceId;

  /// The geographical location where the item was reported as lost or found.
  /// This uses Firestore's GeoPoint type.
  final GeoPoint? lostOrFoundLocation;

  /// The timestamp for when the status was changed to 'lost' or 'found'.
  final Timestamp? lostOrFoundDate;

  /// The ID of a different user who might have found this item (for community features).
  final String? foundByUserId;

  Item({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.category,
    required this.timestamp,
    required this.userId,
    // Tracking fields
    required this.status,
    this.bluetoothDeviceId,
    this.lostOrFoundLocation,
    this.lostOrFoundDate,
    this.foundByUserId,
  });

  /// Factory constructor to create an `Item` instance from a Firestore document.
  /// This safely handles data parsing and provides default values for missing fields.
  factory Item.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw StateError("Missing data for item ID: ${doc.id}");
    }

    return Item(
      id: doc.id,
      title: data['title'] ?? 'No Title',
      description: data['description'] ?? 'No Description',
      imageUrl: data['imageUrl'],
      category: data['category'] ?? 'Uncategorized',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      userId: data['userId'] ?? '',

      // Safely parse the status enum from a string.
      // Defaults to 'registered' if the field is missing or invalid.
      status: ItemStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ItemStatus.registered,
      ),

      bluetoothDeviceId: data['bluetoothDeviceId'],
      lostOrFoundLocation: data['lostOrFoundLocation'] as GeoPoint?,
      lostOrFoundDate: data['lostOrFoundDate'] as Timestamp?,
      foundByUserId: data['foundByUserId'],
    );
  }

  /// Converts the `Item` object into a `Map<String, dynamic>`
  /// suitable for writing to a Firestore document.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'timestamp': timestamp,
      'userId': userId,
      // Convert the enum to its string name for storage.
      'status': status.name,
      'bluetoothDeviceId': bluetoothDeviceId,
      'lostOrFoundLocation': lostOrFoundLocation,
      'lostOrFoundDate': lostOrFoundDate,
      'foundByUserId': foundByUserId,
    };
  }
}
