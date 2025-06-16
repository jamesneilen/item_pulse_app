import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:item_pulse_app/core/themes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:item_pulse_app/widgets/compress_image.dart';
// import 'package:uuid/uuid.dart'; // REMOVED: Unused import
import '../widgets/custom_button.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  // State variables
  String _title = '';
  String _category = 'Wallet';
  String _description = '';
  String _status = 'lost';
  LatLng? _location;
  File? _imageFile;
  String? _bluetoothTagId;
  bool _visibleToCommunity = true;

  // ADDED: Loading state for submission process
  bool _isLoading = false;

  final List<String> _categories = ['Wallet', 'Bag', 'Phone', 'Key', 'Others'];

  Future<void> _pickImage() async {
    // No changes needed here, this function is well-implemented.
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
                  if (mounted) Navigator.of(context).pop();
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
                  if (mounted) Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getCurrentLocation() async {
    // No major changes needed, this function is well-implemented.
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permissions are permanently denied, we cannot request permissions.',
            ),
          ),
        );
      }
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
    setState(() {
      _location = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> _submit() async {
    print("--- Submit button pressed. Starting process... ---");

    // --- Step 1: Detailed Validation Check ---
    final isFormValid = _formKey.currentState?.validate() ?? false;
    final isImagePicked = _imageFile != null;
    final isLocationSet = _location != null;

    print(
      "Validation Status: isFormValid = $isFormValid, isImagePicked = $isImagePicked, isLocationSet = $isLocationSet",
    );

    if (!isFormValid || !isImagePicked || !isLocationSet) {
      print("Validation FAILED. Aborting submission.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Validation failed. Please check all fields.'),
        ),
      );
      return; // Exit function
    }

    print("Validation PASSED. Proceeding to save form state.");
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      print("Entered TRY block.");

      // --- Step 2: User Authentication Check ---
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("User is NULL. Throwing authentication exception.");
        throw Exception('User is not authenticated. Cannot submit item.');
      }
      print("User is authenticated. UID: ${user.uid}");

      // --- Step 3: Image Upload ---
      print("Attempting to upload image...");
      final imageUrl = await _uploadImageAndGetUrl(_imageFile!, user.uid);
      print("Image upload SUCCESS. URL: $imageUrl");

      // --- Step 4: Firestore Write ---
      final itemData = {
        'title': _title,
        'category': _category,
        'description': _description,
        'status': _status,
        'latitude': _location!.latitude,
        'longitude': _location!.longitude,
        'imageUrl': imageUrl,
        'bluetoothTagId': _bluetoothTagId,
        'visibleToCommunity': _visibleToCommunity,
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      };

      print("Attempting to write to Firestore with data: $itemData");
      await FirebaseFirestore.instance.collection('items').add(itemData);
      print("Firestore write SUCCESS.");

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item registered successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      print("--- CAUGHT AN ERROR ---");
      print("Error Type: ${e.runtimeType}");
      print("Error Message: $e");
      print("-----------------------");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
      }
    } finally {
      print("--- FINALLY block executed. Setting isLoading to false. ---");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ADDED: Extracted image upload logic into a helper function for clarity
  // In _uploadImageAndGetUrl()
  Future<String> _uploadImageAndGetUrl(File imageFile, String userId) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uniqueFileName =
        '$timestamp.jpg'; // We no longer need the userId in the filename itself

    // --- THIS IS THE CRITICAL CHANGE ---
    // The path now matches the new security rule: item_images/USER_ID/FILENAME.jpg
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('item_images')
        .child(userId) // The user's ID is now a folder in the path
        .child(uniqueFileName);
    // --- END OF CHANGE ---

    print('--- Storage Debug ---');
    print('Authenticated User ID for upload: $userId');
    print('Attempting to upload to new path: ${storageRef.fullPath}');
    print('-----------------------');

    final compressedXFile = await compressImage(XFile(imageFile.path));
    final compressedFile = File(compressedXFile.path);

    // We no longer need the custom metadata for security, but it's still good for tracking.
    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {'ownerId': userId},
    );

    final uploadTask = await storageRef.putFile(compressedFile, metadata);
    return await uploadTask.ref.getDownloadURL();
  }
  // REMOVED: Redundant and unused function
  // Future<String?> uploadItemImage(File file, String filename) async { ... }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Register Item')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          // REMOVED: incorrect `const` from children list
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image picker
              GestureDetector(
                onTap: _isLoading ? null : _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child:
                      _imageFile == null
                          ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              // const is correct here
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 40,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Tap to upload image*",
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
                validator:
                    (val) =>
                        val == null || val.isEmpty ? 'Enter item name' : null,
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 16),
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
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _getCurrentLocation,
                      icon: const Icon(Icons.location_on_outlined),
                      label: const Text("Use Current Location *"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (_location != null)
                    Icon(
                      Icons.check_circle,
                      color: Colors.green.shade600,
                      size: 28,
                    ),
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
              SwitchListTile(
                value: _visibleToCommunity,
                onChanged: (val) => setState(() => _visibleToCommunity = val),
                title: const Text("Visible to Community"),
                subtitle: const Text(
                  "Let others see this item in the public feed",
                ),
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 24),

              // Submit Button
              MyButton(text: "Register Item", onPressed: _submit, height: 55),
            ],
          ),
        ),
      ),
    );
  }
}
