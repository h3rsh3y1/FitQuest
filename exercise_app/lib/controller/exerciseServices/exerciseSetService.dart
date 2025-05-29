

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExerciseSetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// **Save New Exercise to Firestore**
  Future<void> setExerciseData({
    required String exerciseId,
    required String name,
    required String bodyPart,
    required String equipment,
    required String target,
    required String gifUrl,
  }) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('exercises')
          .doc(exerciseId)
          .set({
        'name': name,
        'bodyPart': bodyPart,
        'equipment': equipment,
        'target': target,
        'gifUrl': gifUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }
}
