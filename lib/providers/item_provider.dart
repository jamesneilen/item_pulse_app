// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:uuid/uuid.dart';
// import '../models/item_model.dart';
// import '../services/item_service.dart';

// class ItemProvider with ChangeNotifier {
//   String name = '';
//   String category = '';
//   String description = '';
//   File? image;

//   void setName(String value) {
//     name = value;
//     notifyListeners();
//   }

//   void setCategory(String value) {
//     category = value;
//     notifyListeners();
//   }

//   void setDescription(String value) {
//     description = value;
//     notifyListeners();
//   }

//   void setImage(File value) {
//     image = value;
//     notifyListeners();
//   }

//   Future<void> registerItem() async {
//     if (image == null || name.isEmpty) {
//       throw Exception("Missing required fields");
//     }

//     final id = const Uuid().v4();
//     final item = Item(
//       id: id,
//       title: name,
//       category: category,
//       description: description,
//       imageUrl: '', // to be replaced after upload
//       timestamp: DateTime.now().toUtc(
//     );

//     await uploadItem(item, image!);

//     // Clear form
//     name = '';
//     category = '';
//     description = '';
//     image = null;
//     notifyListeners();
//   }
// }
