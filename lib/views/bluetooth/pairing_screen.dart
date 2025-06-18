// lib/screens/pairing_screen.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:ionicons/ionicons.dart';
import '../../models/item_model.dart';
import 'package:permission_handler/permission_handler.dart';

class PairingScreen extends StatefulWidget {
  final Item itemToPair;
  const PairingScreen({super.key, required this.itemToPair});

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  // We use a map to easily handle device updates and prevent duplicates
  final Map<String, ScanResult> _foundDevices = {};
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  bool _isScanning = false;
  bool _hasPermissions = false; // Assume permissions are granted for simplicity

  @override
  void initState() {
    super.initState();
    _startScan();
    _requestPermissions();
  }

  // NEW METHOD: Handles the entire permission request flow
  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses =
        await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.location,
        ].request();

    if (mounted) {
      // Check if all permissions are granted
      if (statuses[Permission.bluetoothScan]!.isGranted &&
          statuses[Permission.bluetoothConnect]!.isGranted &&
          statuses[Permission.location]!.isGranted) {
        setState(() {
          _hasPermissions = true;
        });
        // Permissions are granted, now we can start scanning
        _startScan();
      } else {
        // User denied one or more permissions
        setState(() {
          _hasPermissions = false;
        });
        _showPermissionDeniedDialog();
      }
    }
  }

  @override
  void dispose() {
    // Crucial: Stop scanning and cancel subscription to prevent memory leaks
    FlutterBluePlus.stopScan();
    _scanSubscription?.cancel();
    super.dispose();
  }

  void _startScan() {
    if (!_hasPermissions) {
      print("Cannot scan without permissions.");
      return; // Do nothing if we don't have permissions
    }
    setState(() {
      _isScanning = true;
      _foundDevices.clear(); // Clear previous results
    });

    // Listen to the stream of scan results
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        print(
          'Found device: ${r.device.remoteId} with name: "${r.device.platformName}" at RSSI: ${r.rssi}',
        );

        // We only care about devices with a name to make it user-friendly
        // if (r.device.platformName.isNotEmpty) {
        if (mounted) {
          setState(() {
            // Add or update the device in our map
            _foundDevices[r.device.remoteId.toString()] = r;
          });
          // }
        }
      }
    });

    // Start scanning for 10 seconds
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

    // After the scan timeout, set scanning to false
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    });
  }

  // NEW METHOD: A user-friendly dialog if permissions are denied
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Permissions Required'),
            content: const Text(
              'Bluetooth and Location permissions are required to find nearby tracking tags. Please enable them in your phone settings.',
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  // Optionally, pop the pairing screen since it can't function
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Open Settings'),
                onPressed: () {
                  // This will open the app's settings page for the user
                  openAppSettings();
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
    );
  }

  Future<void> _pairDevice(BluetoothDevice device) async {
    // Stop scanning before pairing
    await FlutterBluePlus.stopScan();
    setState(() => _isScanning = false);

    // Show a confirmation dialog
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Confirm Pairing'),
            content: Text(
              'Do you want to pair "${widget.itemToPair.title}" with this device?\n\nID: ${device.remoteId}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                child: const Text('PAIR'),
                onPressed: () async {
                  try {
                    // Update the document in Firestore
                    await FirebaseFirestore.instance
                        .collection('items')
                        .doc(widget.itemToPair.id)
                        .update({
                          'bluetoothDeviceId': device.remoteId.toString(),
                        });

                    // Pop the dialog and then the pairing screen
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Item paired successfully!'),
                      ),
                    );
                  } catch (e) {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error pairing item: $e')),
                    );
                  }
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pairing "${widget.itemToPair.title}"')),
      body:
          !_hasPermissions
              ? _buildPermissionRequestView()
              : Column(
                children: [
                  // --- Instructional Header ---
                  _buildHeader(),
                  const Divider(height: 1),

                  // --- List of Found Devices ---
                  Expanded(child: _buildDeviceList()),
                ],
              ),
      // --- Floating Action Button to Rescan ---
      floatingActionButton:
          _hasPermissions
              ? FloatingActionButton.extended(
                onPressed: _isScanning ? null : _startScan,
                label: Text(_isScanning ? 'Scanning...' : 'Scan Again'),
                icon:
                    _isScanning
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Ionicons.scan_outline),
              )
              : null,
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Icon(
            Ionicons.bluetooth_outline,
            size: 40,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Searching for Devices',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Make sure your tracking tag is powered on and nearby.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionRequestView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bluetooth_disabled, size: 60, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              'Permissions Needed',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'This feature requires Bluetooth and Location access to work.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _requestPermissions, // Let the user try again
              child: const Text('Grant Permissions'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceList() {
    if (_isScanning && _foundDevices.isEmpty) {
      return const Center(child: Text("Scanning for nearby tags..."));
    }

    if (!_isScanning && _foundDevices.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            "No devices found. Try moving closer to your tag and tap 'Scan Again'.",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Sort devices by signal strength (strongest first)
    final sortedDevices =
        _foundDevices.values.toList()..sort((a, b) => b.rssi.compareTo(a.rssi));

    return ListView.builder(
      itemCount: sortedDevices.length,
      itemBuilder: (context, index) {
        final result = sortedDevices[index];
        return ListTile(
          leading: Icon(
            result.rssi > -60
                ? Ionicons.wifi
                : (result.rssi > -80
                    ? Ionicons.wifi_outline
                    : Ionicons.cellular_outline),
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(result.device.platformName),
          subtitle: Text('Signal: ${result.rssi} dBm'),
          trailing: ElevatedButton(
            child: const Text('Pair'),
            onPressed: () => _pairDevice(result.device),
          ),
        );
      },
    );
  }
}
