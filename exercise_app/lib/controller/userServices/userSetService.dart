import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserSetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ///  **Set User Data (Called at Sign-Up)**
  Future<void> setUserData({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
      });
    }
  }
}
