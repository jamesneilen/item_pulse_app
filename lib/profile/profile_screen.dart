// lib/screens/profile/profile_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:item_pulse_app/items/item_list_screen.dart';
import 'package:item_pulse_app/models/item_model.dart'; // <-- Using your Item model
import 'package:item_pulse_app/providers/auth_provider.dart';
import 'package:item_pulse_app/providers/user_provider.dart'; // <-- Using your UserProvider
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch your UserProvider to get user data.
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    // A robust fallback if the user data isn't loaded yet.
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      // The body uses a ListView for scrollability on smaller devices.
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        children: [
          _buildProfileHeader(context, user),
          const SizedBox(height: 24),
          _buildStatsSection(context, user.uid),
          const SizedBox(height: 16),
          _buildMenuItems(context),
        ],
      ),
    );
  }

  /// Builds the top section with the user's avatar, name, and email.
  /// This now correctly uses your `AppUser` model.
  Widget _buildProfileHeader(BuildContext context, AppUser user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Ionicons.person,
            size: 50,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user.name,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  /// Builds the section showing key user statistics using a real-time stream.
  /// This has been updated to use your `Item` model and `ItemStatus` enum.
  Widget _buildStatsSection(BuildContext context, String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('items')
              .where('userId', isEqualTo: uid)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Text("Loading stats..."));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text("No item data found."));
        }

        // --- THE KEY IMPROVEMENT ---
        // Convert Firestore documents to a list of your type-safe `Item` objects.
        final items =
            snapshot.data!.docs
                .map(
                  (doc) => Item.fromFirestore(
                    doc as DocumentSnapshot<Map<String, dynamic>>,
                  ),
                )
                .toList();

        // Calculate stats using the clean `ItemStatus` enum.
        final totalItems = items.length;
        final lostItems =
            items.where((item) => item.status == ItemStatus.lost).length;
        final foundItems =
            items.where((item) => item.status == ItemStatus.found).length;
        // --- END IMPROVEMENT ---

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(context, totalItems.toString(), "Registered"),
            _buildStatItem(context, lostItems.toString(), "Lost"),
            _buildStatItem(context, foundItems.toString(), "Found"),
          ],
        );
      },
    );
  }

  /// A helper widget for a single statistic item. (No changes needed here)
  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  /// Builds the list of tappable menu options.
  Widget _buildMenuItems(BuildContext context) {
    return Column(
      children: [
        _buildMenuTile(
          context,
          icon: Ionicons.person_outline,
          title: 'Edit Profile',
          onTap: () {
            // TODO: Navigate to an EditProfileScreen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Edit Profile screen coming soon!")),
            );
          },
        ),
        _buildMenuTile(
          context,
          icon: Ionicons.cube_outline,
          title: 'My Registered Items',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegisteredItemsScreen()),
            );
          },
        ),
        _buildMenuTile(
          context,
          icon: Ionicons.settings_outline,
          title: 'Settings',
          onTap: () {
            // TODO: Navigate to a SettingsScreen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Settings screen coming soon!")),
            );
          },
        ),
        const Divider(height: 24),
        _buildMenuTile(
          context,
          icon: Ionicons.log_out_outline,
          title: 'Logout',
          isDestructive: true,
          onTap: () async {
            // Correctly signs out from Firebase and clears local provider state.
            await FirebaseAuth.instance.signOut();
            context.read<UserProvider>().clearUser();
          },
        ),
      ],
    );
  }

  /// A helper widget for a single menu ListTile. (No changes needed here)
  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color =
        isDestructive
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.onSurface;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      trailing:
          isDestructive
              ? null
              : const Icon(Ionicons.chevron_forward_outline, size: 16),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
