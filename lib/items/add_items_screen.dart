import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:item_pulse_app/core/themes.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:item_pulse_app/widgets/compress_image.dart';
import 'package:uuid/uuid.dart';
import '../widgets/custom_button.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  String _title = '';
  String _category = 'Wallet';
  String _description = '';
  String _status = 'lost';
  LatLng? _location;
  File? _imageFile;
  String? _bluetoothTagId;
  bool _visibleToCommunity = true;

  final List<String> _categories = ['Wallet', 'Bag', 'Phone', 'Key', 'Others'];

  Future<void> _pickImage() async {
    showModalBottomSheet(
      backgroundColor: myTheme.primaryColor,
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text("Take a Photo"),
                onTap: () async {
                  final picked = await _picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (picked != null) {
                    setState(() => _imageFile = File(picked.path));
                  }
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose from Gallery"),
                onTap: () async {
                  final picked = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (picked != null) {
                    setState(() => _imageFile = File(picked.path));
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
    setState(() {
      _location = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _imageFile == null ||
        _location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields.')),
      );
      return;
    }

    _formKey.currentState!.save();

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final user = FirebaseAuth.instance.currentUser;

      final userId = user?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated.')),
        );
        return;
      }

      // Compress the image
      final compressedXFile = await compressImage(XFile(_imageFile!.path));
      final compressedFile = File(compressedXFile.path);
      print('Compressed file path: ${compressedFile.path}');
      print('File exists: ${await compressedFile.path}');

      // Upload the image to Firebase Storage
      final uuid = const Uuid().v4();
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('item_images')
          .child('item_${timestamp}_$uuid.jpg');

      await storageRef.putFile(compressedFile);
      final imageUrl = await storageRef.getDownloadURL();
      print('Image uploaded: $imageUrl');
      // Save item data to Firestore
      await FirebaseFirestore.instance.collection('items').add({
        'title': _title,
        'category': _category,
        'description': _description,
        'status': _status,
        'latitude': _location!.latitude,
        'longitude': _location!.longitude,
        'imageUrl': imageUrl,
        'bluetoothTagId': _bluetoothTagId,
        'visibleToCommunity': _visibleToCommunity,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item registered successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Register Item')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Image picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child:
                      _imageFile == null
                          ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 40,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Tap to upload image",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          )
                          : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _imageFile!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                ),
              ),

              const SizedBox(height: 24),

              // Title
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Item Name *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) => val!.isEmpty ? 'Enter item name' : null,
                onSaved: (val) => _title = val!,
              ),

              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                value: _category,
                decoration: InputDecoration(
                  labelText: 'Category *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (val) => setState(() => _category = val!),
                items:
                    _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
              ),

              const SizedBox(height: 16),

              // Description
              TextFormField(
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Color, special marks, brand...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSaved: (val) => _description = val ?? '',
              ),

              const SizedBox(height: 16),

              // Lost or Found
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    "Item Status:",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text("Lost"),
                    selected: _status == 'lost',
                    onSelected: (val) => setState(() => _status = 'lost'),
                    selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text("Found"),
                    selected: _status == 'found',
                    onSelected: (val) => setState(() => _status = 'found'),
                    selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Location Button
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _getCurrentLocation,
                      icon: const Icon(Icons.location_on_outlined),
                      label: const Text("Use Current Location"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (_location != null)
                    Icon(Icons.check_circle, color: myTheme.primaryColor),
                ],
              ),

              const SizedBox(height: 16),

              // Optional BLE ID
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Bluetooth Tag ID (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSaved: (val) => _bluetoothTagId = val,
              ),

              const SizedBox(height: 12),

              // Visibility toggle
              SwitchListTile.adaptive(
                value: _visibleToCommunity,
                onChanged: (val) => setState(() => _visibleToCommunity = val),
                title: const Text("Visible to Community"),
                subtitle: const Text(
                  "Let others see this item in the public feed",
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: MyButton(
                  text: "Register Item",
                  onPressed: _submit,
                  height: 60,
                  width: 300,
                  fontSize: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
