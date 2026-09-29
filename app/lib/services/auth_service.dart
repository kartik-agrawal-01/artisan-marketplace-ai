import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;



  Future<bool> checkIfEmailExists(String email) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Artisans')
          .where('email', isEqualTo: email)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print("Error checking if email exists: $e");
      return false;
    }
  }
  // Email/Password Sign-In
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Error during email/password sign-in: $e");
      throw FirebaseAuthException(message: 'Email/Password sign-in failed: $e', code: '');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();

  }

  //register with email and password
  Future<User?> registerWithEmailPassword(String email, String password, String name) async {
    try {
      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      String uid = cred.user!.uid;

      await FirebaseFirestore.instance.collection('Artisans').doc(uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return cred.user; // ✅ success
    } catch (e) {
      print("Register Error: $e");
      return null; // ❌ failure
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;
}