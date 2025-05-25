import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RegisteredItemsScreen extends StatelessWidget {
  const RegisteredItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('My Registered Items')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('items')
                .where('userId', isEqualTo: uid)
                .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No registered items yet.'));
          }

          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final item = docs[i].data() as Map<String, dynamic>;

              final String title = item['title'] ?? 'No title';
              final String description =
                  item['description'] ?? 'No description';
              final String? imageUrl = item['imageUrl'];
              final String category = item['category'] ?? 'Uncategorized';
              final Timestamp? timestamp = item['timestamp'];
              final String formattedDate =
                  timestamp != null
                      ? DateFormat.yMMMd().add_jm().format(timestamp.toDate())
                      : 'Unknown date';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading:
                      imageUrl != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                          : const Icon(Icons.image_not_supported, size: 60),
                  title: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        description.length > 80
                            ? '${description.substring(0, 80)}...'
                            : description,
                      ),
                      const SizedBox(height: 4),
                      Text('Category: $category'),
                      Text(
                        'Posted: $formattedDate',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
