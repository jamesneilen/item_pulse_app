import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/item_model.dart';

Future<void> uploadItem(Item item, File imageFile) async {
  final ref = FirebaseStorage.instance.ref().child('items/${item.id}.jpg');
  await ref.putFile(imageFile);
  final url = await ref.getDownloadURL();

  //   await FirebaseFirestore.instance
  //       .collection('items')
  //       .doc(item.id)
  //       .set(item.copyWith(imageUrl: url).toMap());
}
