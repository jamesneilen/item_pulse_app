// lib/models/user_model.dart

import 'package:firebase_auth/firebase_auth.dart' as auth;

class UserData {
  final String uid;
  final String? name;
  final String? email;
  final String? photoUrl;

  UserData({required this.uid, this.name, this.email, this.photoUrl});

  // A factory constructor to create a UserData instance
  // from a Firebase Auth User object. This is a very common pattern.
  factory UserData.fromFirebaseAuth(auth.User firebaseUser) {
    return UserData(
      uid: firebaseUser.uid,
      name: firebaseUser.displayName,
      email: firebaseUser.email,
      photoUrl: firebaseUser.photoURL,
    );
  }
}
