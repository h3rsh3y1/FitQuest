import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExerciseUpdateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// **Update Saved Exercise Data**
  Future<void> updateExerciseData(
      String exerciseId, Map<String, dynamic> data) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('exercises')
            .doc(exerciseId)
            .set(
              data,
              SetOptions(merge: true),
            );
      } catch (e) {
        throw Exception("Error updating exercise data: $e");
      }
    } else {
      throw Exception("No logged-in user found.");
    }
  }
}
