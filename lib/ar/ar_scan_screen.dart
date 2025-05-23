// import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
// import 'package:ar_flutter_plugin/datatypes/node_types.dart' show NodeType;
// import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
// import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
// import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
// import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
// import 'package:flutter/material.dart';
// import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
// import 'package:ar_flutter_plugin/models/ar_node.dart';
// import 'package:vector_math/vector_math_64.dart' as vector;

// class ARScanScreen extends StatefulWidget {
//   const ARScanScreen({super.key});

//   @override
//   State<ARScanScreen> createState() => _ARScanScreenState();
// }

// class _ARScanScreenState extends State<ARScanScreen> {
//   late ARSessionManager _arSessionManager;
//   late ARObjectManager _arObjectManager;

//   bool _isReady = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("AR Item Scanner")),
//       body: Stack(
//         children: [
//           ARView(
//             onARViewCreated: _onARViewCreated,
//             planeDetectionConfig: PlaneDetectionConfig.horizontal,
//           ),
//           if (_isReady)
//             Positioned(
//               bottom: 20,
//               left: 20,
//               right: 20,
//               child: ElevatedButton.icon(
//                 icon: const Icon(Icons.ads_click),
//                 label: const Text("Scan and Show Item"),
//                 onPressed: _placeARObject,
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   void _onARViewCreated(
//     ARSessionManager arSessionManager,
//     ARObjectManager arObjectManager,
//     ARAnchorManager arAnchorManager,
//     ARLocationManager arLocationManager,
//   ) {
//     _arSessionManager = arSessionManager;
//     _arObjectManager = arObjectManager;

//     _arSessionManager.onInitialize(
//       showFeaturePoints: false,
//       showPlanes: true,
//       showWorldOrigin: false,
//     );

//     _arObjectManager.onInitialize();

//     setState(() {
//       _isReady = true;
//     });
//   }

//   Future<void> _placeARObject() async {
//     try {
//       final node = ARNode(
//         type: NodeType.localGLTF2,
//         uri: "assets/models/box_model/scene.gltf", // Path must match your asset
//         scale: vector.Vector3(0.2, 0.2, 0.2),
//         position: vector.Vector3(0.0, 0.0, -1.0), // 1 meter in front
//         rotation: vector.Vector4(0.0, 1.0, 0.0, 0.0),
//       );

//       final success = await _arObjectManager.addNode(node);
//       if (!success!) {
//         _showSnackbar("❌ Failed to place item in AR space.");
//       }
//     } catch (e) {
//       _showSnackbar("Error: ${e.toString()}");
//     }
//   }

//   void _showSnackbar(String message) {
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text(message)));
//   }

//   @override
//   void dispose() {
//     _arSessionManager.dispose();
//     super.dispose();
//   }
// }
