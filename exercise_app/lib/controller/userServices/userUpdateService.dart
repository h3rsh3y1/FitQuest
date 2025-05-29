import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserUpdateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Updates user data by merging fields into the existing document
  Future<void> updateUserData(Map<String, dynamic> data) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).set(
          data,
          SetOptions(merge: true), // Merge to avoid overwriting
        );
      } catch (e) {
        throw Exception("Error updating user data: $e");
      }
    } else {
      throw Exception("No logged-in user found.");
    }
  }
}
