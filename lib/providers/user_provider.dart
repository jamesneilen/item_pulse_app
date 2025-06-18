import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:item_pulse_app/providers/auth_provider.dart';

class UserProvider with ChangeNotifier {
  AppUser? _user;
  AppUser? get user => _user;
  bool get isAuthenticated => _user != null;

  Future<void> loadUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .get();
      if (doc.exists) {
        _user = AppUser.fromMap(doc.data()!);
        notifyListeners();
      }
    }
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
