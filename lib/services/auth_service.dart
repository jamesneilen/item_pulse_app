import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // --- OPTIMIZATION 1: Dependency Injection ---
  // We provide the instances via the constructor, which allows for easy mocking in tests.
  // We also provide default values for easy use in the main app.
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

  // --- Stream for auth state --- (No changes needed here)
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // --- OPTIMIZATION 2: Encapsulated Business Logic for Sign-Up ---
  /// Signs up a user with email/password, updates their name, and creates a user document.
  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception("Sign up failed: User object is null.");
      }

      // Update the user's name in Firebase Auth profile
      await user.updateDisplayName(name);

      // Create the corresponding user document in Firestore
      await _createUserDocument(uid: user.uid, email: email, name: name);
    } on FirebaseAuthException {
      // Re-throw the specific Firebase exception to be handled by the UI.
      rethrow;
    } catch (e) {
      // Throw a generic exception for other errors.
      throw Exception("An unexpected error occurred during sign up.");
    }
  }

  // --- OPTIMIZATION 3: Robust Google Sign-In with User Creation ---
  /// Signs in with Google and creates a user document if it's their first time.
  Future<void> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User aborted the sign-in flow
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      if (user != null) {
        // Check if the user document already exists
        final docRef = _firestore.collection('users').doc(user.uid);
        final docSnapshot = await docRef.get();

        // If it's a new user, create their document
        if (!docSnapshot.exists) {
          await _createUserDocument(
            uid: user.uid,
            email: user.email!,
            name: user.displayName!,
          );
        }
      }
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception("An unexpected error occurred during Google sign in.");
    }
  }

  // --- Standard Email Sign-In ---
  Future<void> signInWithEmail(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // --- OPTIMIZATION 4: Complete Sign Out ---
  /// Signs out from both Firebase and Google.
  Future<void> signOut() async {
    // Signing out of Google is important to allow users to pick a different account next time.
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  // --- Private helper method to create the user document ---
  Future<void> _createUserDocument({
    required String uid,
    required String email,
    required String name,
  }) {
    return _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
