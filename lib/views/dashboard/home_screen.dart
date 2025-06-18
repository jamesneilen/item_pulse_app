import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

// Your app's imports
import 'package:item_pulse_app/items/add_items_screen.dart';
import 'package:item_pulse_app/items/item_list_screen.dart'; // Make sure this is the correct path for RegisteredItemsScreen
import 'package:item_pulse_app/providers/auth_provider.dart';
import 'package:item_pulse_app/views/dashboard/widgets/goog_maps.dart';

import '../../ar/ar_scan_screen.dart';
import '../../models/item_model.dart';
import '../../profile/profile_screen.dart';
import '../../providers/user_provider.dart';

// Dummy screens for the bottom nav bar
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("Search Screen")));
}

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("Community Screen")));
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Improvement 2: Manage the state of the BottomNavigationBar
  int _selectedIndex = 0;

  // List of pages to be displayed by the BottomNavigationBar
  static const List<Widget> _pages = <Widget>[
    _DashboardView(), // The main content of your original screen
    SearchScreen(),
    CommunityScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Reading the provider once is enough if we pass it down
    final authProvider = context.watch<UserProvider>();
    final user = authProvider.user;

    return Scaffold(
      key: _scaffoldKey,
      // Improvement 3: Wire up the drawer functionality
      drawer: _buildAppDrawer(context, authProvider),
      appBar: AppBar(
        // The title now changes based on the selected tab
        title: Text(_getAppBarTitle(_selectedIndex, user?.name)),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
        ),
        actions: [
          IconButton(
            tooltip: 'Add New Item',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddItemScreen()),
              );
            },
            icon: const Icon(Icons.add_circle_outline),
          ),
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              /* Navigate to notifications */
            },
          ),
        ],
      ),
      // The body of the scaffold is now the currently selected page
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Good for 4+ items
        // Improvement 1: Use theme colors
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(
          context,
        ).colorScheme.onSurface.withOpacity(0.7),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Ionicons.home_outline),
            activeIcon: Icon(Ionicons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.search_outline),
            activeIcon: Icon(Ionicons.search),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.people_outline),
            activeIcon: Icon(Ionicons.people),
            label: "Community",
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.person_outline),
            activeIcon: Icon(Ionicons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle(int index, String? userName) {
    switch (index) {
      case 0:
        return 'Hello, ${userName ?? "Guest"}';
      case 1:
        return 'Search Items';
      case 2:
        return 'Community';
      case 3:
        return 'My Profile';
      default:
        return 'ItemPulse';
    }
  }

  Drawer _buildAppDrawer(BuildContext context, UserProvider authProvider) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            // Improvement 1: Use theme colors
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Text(
              'ItemPulse Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Ionicons.person_circle_outline),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              _onItemTapped(3); // Navigate to profile tab
            },
          ),
          ListTile(
            leading: const Icon(Ionicons.settings_outline),
            title: const Text('Settings'),
            onTap: () {
              /* Navigate to settings screen */
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Ionicons.log_out_outline),
            title: const Text('Logout'),
            onTap: () {
              // Improvement 3: Implement logout
              Navigator.pop(context); // Close the drawer first
              // authProvider.signOut();
              // The main app wrapper should listen to auth state and navigate to login screen
            },
          ),
        ],
      ),
    );
  }
}

/// This is the original body content, now in its own widget
class _DashboardView extends StatelessWidget {
  const _DashboardView();

  Widget build(BuildContext context) {
    final uid = Provider.of<UserProvider>(context, listen: false).user?.uid;

    return Column(
      children: [
        // Big Map Section
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              // Use a StreamBuilder to get live updates of item locations
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('items')
                        .where('userId', isEqualTo: uid)
                        .where(
                          'status',
                          whereIn: ['lost', 'found'],
                        ) // Only show lost or found items
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final items =
                      snapshot.data!.docs
                          .map(
                            (doc) => Item.fromFirestore(
                              doc as DocumentSnapshot<Map<String, dynamic>>,
                            ),
                          )
                          .toList();

                  // Pass the fetched items to our new dynamic map!
                  return MyMap(
                    items: items,
                    onMarkerTapped: (item) {
                      // When a marker is tapped, you could show a bottom sheet with details
                      print('Tapped on map marker for: ${item.title}');
                    },
                  );
                },
              ),
            ),
          ),
        ),
        // Action Section
        Expanded(
          flex: 3,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                "Quick Actions",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _buildQuickAction(
                    context,
                    Ionicons.alert_circle_outline,
                    "Report Lost",
                    Colors.red,
                    () {},
                  ),
                  _buildQuickAction(
                    context,
                    Ionicons.checkmark_done_circle_outline,
                    "Report Found",
                    Colors.green,
                    () {},
                  ),
                  _buildQuickAction(
                    context,
                    Ionicons.scan_outline,
                    "AR Scan",
                    Colors.blue,
                    () {},
                  ),
                  _buildQuickAction(
                    context,
                    Ionicons.map_outline,
                    "View Map",
                    Colors.orange,
                    () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildMyItemsCard(context),
            ],
          ),
        ),
      ],
    );
  }

  // Improvement 4: Use InkWell and make it more responsive
  Widget _buildQuickAction(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return SizedBox(
      width:
          (MediaQuery.of(context).size.width / 2) -
          24, // Take up half screen width minus padding
      child: Material(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
            child: Row(
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMyItemsCard(BuildContext context) {
    return Card(
      // The CardTheme from your main theme will style this automatically!
      child: ListTile(
        leading: const Icon(Ionicons.cube_outline),
        title: const Text(
          "My Registered Items",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text("Tap to view or manage your items"),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RegisteredItemsScreen(),
            ),
          );
        },
      ),
    );
  }
}
