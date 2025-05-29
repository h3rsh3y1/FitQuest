import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkoutSaveService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Save Workout Data to Firestore
  Future<void> saveWorkoutData({
    required String workoutName,
    required int duration,
    required double calories,
    required int completedExercises,
  
    required DateTime timestamp,
      required List<String> exerciseNames,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('workouts')
            .add({
              'workoutName': workoutName,
              'duration': duration,
              'calories': calories,
              'completedExercises': completedExercises,
              'timestamp': timestamp,
              'exerciseNames': exerciseNames,
            });
        print('✅ Workout data saved to Firestore');
      } else {
        print('❌ No user found. Cannot save workout data.');
      }
    } catch (e) {
      print('❌ Error saving workout data: $e');
    }
  }
}
