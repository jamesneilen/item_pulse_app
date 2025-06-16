import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:item_pulse_app/items/add_items_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/item_model.dart';
import 'item_detail_screen.dart';

class RegisteredItemsScreen extends StatefulWidget {
  const RegisteredItemsScreen({super.key});

  @override
  State<RegisteredItemsScreen> createState() => _RegisteredItemsScreenState();
}

class _RegisteredItemsScreenState extends State<RegisteredItemsScreen> {
  late final Stream<QuerySnapshot> _itemsStream;
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (_user != null) {
      _itemsStream =
          FirebaseFirestore.instance
              .collection('items')
              .where('userId', isEqualTo: _user!.uid)
              .orderBy('timestamp', descending: true)
              .snapshots();
    }
  }

  void _showUndoSnackbar(Item item) {
    // Hide any existing SnackBars to prevent them from stacking.
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${item.title}" deleted.'),
        behavior: SnackBarBehavior.floating, // A nicer, modern look
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            // --- IMPLEMENTATION ---
            // Use the item's ID to specify the document location,
            // and use our new toMap() method to provide the data.
            // This will re-create the document that was just deleted.
            FirebaseFirestore.instance
                .collection('items')
                .doc(item.id)
                .set(item.toMap());
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Registered Items')),
        body: const Center(child: Text('Please log in to see your items.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Registered Items')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _itemsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // UX Improvement 1: Shimmer Loading State
            return _buildLoadingShimmer();
          }

          if (snapshot.hasError) {
            // UX Improvement 3: User-Friendly Error State
            return _buildErrorState();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // UX Improvement 2: Engaging Empty State with CTA
            return _buildEmptyState();
          }

          final items =
              snapshot.data!.docs
                  .map(
                    (doc) => Item.fromFirestore(
                      doc as DocumentSnapshot<Map<String, dynamic>>,
                    ),
                  )
                  .toList();

          // UX Improvement 5: Pull to Refresh
          return RefreshIndicator(
            onRefresh: () async {
              // The stream automatically refreshes, so we just need a delay
              // for the indicator to be visible to the user.
              await Future.delayed(const Duration(seconds: 1));
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: items.length,
              itemBuilder: (ctx, i) {
                final item = items[i];
                return _buildItemCard(item);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddItemScreen()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Register a new item',
      ),
    );
  }

  /// Builds the shimmer effect widget for the loading state.
  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder:
            (context, index) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const CircleAvatar(radius: 30),
                title: Container(height: 16, width: 100, color: Colors.white),
                subtitle: Container(
                  height: 12,
                  width: 200,
                  color: Colors.white,
                ),
              ),
            ),
      ),
    );
  }

  /// Builds the widget for the empty state.
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_box_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            const Text(
              'No Items Yet',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Tap the "+" button to register your first item.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the widget for the error state.
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            const Text(
              'Oops! Something went wrong.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed:
                  () => setState(() {
                    // This re-subscribes to the stream, effectively retrying.
                    _itemsStream =
                        FirebaseFirestore.instance
                            .collection('items')
                            .where('userId', isEqualTo: _user!.uid)
                            .orderBy('timestamp', descending: true)
                            .snapshots();
                  }),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the interactive card for a single item.
  Widget _buildItemCard(Item item) {
    // UX Improvement 4: Interactive Card
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        FirebaseFirestore.instance.collection('items').doc(item.id).delete();
        _showUndoSnackbar(item);
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: InkWell(
          onTap: () {
            // Placeholder: Navigate to a detailed view of the item
            print('Tapped on item: ${item.title}');
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ItemDetailScreen(item: item),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      item.imageUrl != null
                          ? Image.network(
                            item.imageUrl!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (ctx, err, stack) =>
                                    const Icon(Icons.broken_image, size: 80),
                          )
                          : const Icon(
                            Icons.image_not_supported,
                            size: 80,
                            color: Colors.grey,
                          ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      // UX Improvement 6: Relative Timestamp
                      Text(
                        timeago.format(item.timestamp.toDate()),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.grey),
                  onPressed: () {
                    // Placeholder: Navigate to the edit screen
                    print('Edit item: ${item.title}');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
