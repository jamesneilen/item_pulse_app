import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyMap extends StatefulWidget {
  const MyMap({super.key});

  @override
  State<MyMap> createState() => _GoogleMapState();
}

class _GoogleMapState extends State<MyMap> {
  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(5.9631, 10.1591), // Bamenda coords
        zoom: 14.5,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      mapType: MapType.terrain,
      markers: {
        Marker(
          markerId: const MarkerId('location'),
          position: const LatLng(5.9631, 10.1591), // Bamenda coords
          infoWindow: const InfoWindow(
            title: 'Bamenda',
            snippet: 'This is Bamenda, Cameroon',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      },
    );
  }
}
