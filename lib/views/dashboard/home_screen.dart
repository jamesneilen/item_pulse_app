import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:item_pulse_app/items/add_items_screen.dart';
import 'package:item_pulse_app/views/dashboard/widgets/goog_maps.dart';
import 'package:provider/provider.dart';

import '../../ar/ar_scan_screen.dart';
import '../../items/item_list_screen.dart';
import '../../providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final isAuthenticated = context.watch<UserProvider>().isAuthenticated;
    final authProvider = context.read<UserProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'ItemPulse Menu',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {},
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('Hello, ${user?.name ?? "Guest"}'),
        // leading: IconButton(
        //   icon: const Icon(Icons.menu),
        //   onPressed: () => _scaffoldKey.currentState!.openDrawer(),
        // ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddItemScreen()),
              );
            },
            icon: Icon(Icons.add),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              // Navigate to notifications
            },
          ),
        ],
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Big Map Section
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: MyMap(),
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
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildQuickAction(
                      context,
                      Ionicons.alert_circle,
                      "Report Lost",
                      Colors.red,
                      () {},
                    ),
                    _buildQuickAction(
                      context,
                      Ionicons.checkmark_circle,
                      "Report Found",
                      Colors.green,
                      () {},
                    ),
                    _buildQuickAction(
                      context,
                      Ionicons.scan,
                      "AR Scan",
                      Colors.blue,
                      () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => ARScanScreen(),
                        //   ),
                        // );
                      },
                    ),
                    _buildQuickAction(
                      context,
                      Ionicons.map,
                      "View Map",
                      Colors.orange,
                      () {},
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildMyItemsCard(context),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (index) {
          // handle navigation
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Community"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 80,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyItemsCard(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(Icons.inventory_2),
        title: const Text("My Registered Items"),
        subtitle: const Text("Tap to view or manage"),
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
