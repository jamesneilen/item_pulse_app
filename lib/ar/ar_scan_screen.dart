// lib/screens/find_item_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Import your AR and ML screens/widgets here later
// import 'ar_scanner_view.dart';

import '../models/item_model.dart';

class FindItemScreen extends StatefulWidget {
  final Item itemToFind;
  const FindItemScreen({super.key, required this.itemToFind});

  @override
  State<FindItemScreen> createState() => _FindItemScreenState();
}

class _FindItemScreenState extends State<FindItemScreen> {
  // Phase 1: Map State
  final LatLng _lastSeenLocation = const LatLng(
    37.422,
    -122.084,
  ); // Placeholder

  // Phase 2: Bluetooth State
  BluetoothDevice? _targetDevice;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  int _rssi = -100; // Signal strength, from weak (-100) to strong (0)

  // Phase 3: AR State
  bool _isCloseEnoughForAR = false;

  @override
  void initState() {
    super.initState();
    if (widget.itemToFind.bluetoothDeviceId != null) {
      _startBluetoothScan();
    }
  }

  void _startBluetoothScan() {
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        // Find our target device by its ID
        if (r.device.remoteId.toString() ==
            widget.itemToFind.bluetoothDeviceId) {
          if (mounted) {
            setState(() {
              _targetDevice = r.device;
              _rssi = r.rssi;
              // If signal is strong enough, enable AR mode
              if (r.rssi > -50) {
                // Threshold for being "very close"
                _isCloseEnoughForAR = true;
              } else {
                _isCloseEnoughForAR = false;
              }
            });
          }
        }
      }
    });

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 30));
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    _scanSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Finding: ${widget.itemToFind.title}")),
      body: Stack(
        children: [
          // --- Phase 1: The Map View (always in the background) ---
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _lastSeenLocation,
              zoom: 18,
            ),
            markers: {
              Marker(
                markerId: MarkerId(widget.itemToFind.id),
                position: _lastSeenLocation,
                infoWindow: InfoWindow(title: 'Last Seen Here'),
              ),
            },
          ),

          // --- Phase 2: The Bluetooth "Hot/Cold" Finder UI ---
          // This UI overlays the map
          if (!_isCloseEnoughForAR) _buildBluetoothFinderUI(),

          // --- Phase 3: The AR View ---
          // This view will replace the Bluetooth UI when close enough
          if (_isCloseEnoughForAR)
            _buildARScannerView(), // This would be your AR/ML widget
        ],
      ),
    );
  }

  // --- UI Widget for Phase 2 ---
  Widget _buildBluetoothFinderUI() {
    // Convert RSSI to a 0.0 to 1.0 scale
    double signalStrength = ((_rssi + 100).clamp(0, 100) / 100.0);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _targetDevice == null ? "Searching..." : "Getting Closer...",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: signalStrength,
                minHeight: 20,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color.lerp(Colors.red, Colors.green, signalStrength)!,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Signal Strength: $_rssi dBm',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (_targetDevice == null)
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Text(
                    "Make sure the item's tag is powered on and you're within range.",
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Widget for Phase 3 (Placeholder) ---
  Widget _buildARScannerView() {
    // In a real app, this would return your AR widget.
    // return ARScannerView(itemToFind: widget.itemToFind);
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        color: Colors.black.withOpacity(0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.camera, color: Colors.white, size: 60),
            const SizedBox(height: 20),
            Text(
              "You're very close! \nPoint your camera around to find the '${widget.itemToFind.title}'.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
