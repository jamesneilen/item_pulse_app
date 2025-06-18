// lib/views/dashboard/widgets/goog_maps.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../models/item_model.dart';

class MyMap extends StatefulWidget {
  // The map now accepts a list of items to display
  final List<Item> items;
  // An optional callback when a marker is tapped
  final Function(Item)? onMarkerTapped;

  const MyMap({super.key, required this.items, this.onMarkerTapped});

  @override
  State<MyMap> createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  // Controller to programmatically move the map camera
  GoogleMapController? _mapController;
  // A set to hold all the markers generated from the items
  final Set<Marker> _markers = {};

  // A default position in case no items have a location
  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(5.9631, 10.1591), // Bamenda, Cameroon
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    // Build the markers when the widget is first created
    _buildMarkersFromItems();
  }

  // This is called whenever the parent widget rebuilds with new items
  @override
  void didUpdateWidget(covariant MyMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the list of items has changed, rebuild the markers
    if (widget.items != oldWidget.items) {
      _buildMarkersFromItems();
      _moveCameraToFitMarkers();
    }
  }

  void _buildMarkersFromItems() {
    _markers.clear();
    for (final item in widget.items) {
      // We only create a marker if the item has a location
      if (item.lostOrFoundLocation != null) {
        final marker = Marker(
          markerId: MarkerId(item.id),
          position: LatLng(
            item.lostOrFoundLocation!.latitude,
            item.lostOrFoundLocation!.longitude,
          ),
          infoWindow: InfoWindow(
            title: item.title,
            snippet: 'Status: ${item.status.name}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            // Use different colors for different statuses
            item.status == ItemStatus.lost
                ? BitmapDescriptor.hueRed
                : BitmapDescriptor.hueGreen,
          ),
          onTap: () {
            // Trigger the callback if it exists
            widget.onMarkerTapped?.call(item);
          },
        );
        _markers.add(marker);
      }
    }
    // Refresh the UI to show the new markers
    if (mounted) setState(() {});
  }

  // A helper method to animate the camera to show all markers
  void _moveCameraToFitMarkers() {
    if (_markers.isEmpty || _mapController == null) return;

    if (_markers.length == 1) {
      // If there's only one marker, just go to it
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_markers.first.position, 15),
      );
    } else {
      // If there are multiple markers, calculate the bounds to fit them all
      LatLngBounds bounds = _getBoundsForMarkers(_markers);
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50.0), // 50.0 is for padding
      );
    }
  }

  LatLngBounds _getBoundsForMarkers(Set<Marker> markers) {
    double? minLat, maxLat, minLng, maxLng;

    for (final marker in markers) {
      final lat = marker.position.latitude;
      final lng = marker.position.longitude;
      if (minLat == null || lat < minLat) minLat = lat;
      if (maxLat == null || lat > maxLat) maxLat = lat;
      if (minLng == null || lng < minLng) minLng = lng;
      if (maxLng == null || lng > maxLng) maxLng = lng;
    }

    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: _defaultPosition,
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
        // When the map is ready, move the camera to fit the initial markers
        _moveCameraToFitMarkers();
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      mapType: MapType.normal,
      markers: _markers,
      // These gestures are important for use inside a ListView
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer()),
      },
    );
  }
}
