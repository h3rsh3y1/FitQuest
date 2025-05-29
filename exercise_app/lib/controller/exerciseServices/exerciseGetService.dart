import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseGetService {
  List<Map<String, dynamic>>? _cachedExercises;

  /// Fetch exercises from Firestore based on body parts and equipment type.
  ///
  /// - [bodyParts]: List of body parts to filter (e.g., ["waist", "chest"])
  /// - [equipment]: Equipment filter (e.g., "body weight")
  Future<List<Map<String, dynamic>>> getFilteredExercises({
    required List<String> bodyParts,
    required String equipment,
  }) async {
    List<Map<String, dynamic>> results = [];

    // Firestore whereIn supports only up to 10 items
    for (int i = 0; i < bodyParts.length; i += 10) {
      final slice = bodyParts.skip(i).take(10).toList();
      final snapshot = await FirebaseFirestore.instance
          .collection('exercises')
          .where('equipment', isEqualTo: equipment)
          .where('bodyPart', whereIn: slice)
          .get();

      results.addAll(snapshot.docs.map((doc) => doc.data()));
    }

    return results;
  }

  /// Fetch all exercises with in-memory caching to avoid repeated reads.
  Future<List<Map<String, dynamic>>> getAllExercisesCached() async {
    if (_cachedExercises != null) return _cachedExercises!;

    final snapshot = await FirebaseFirestore.instance
        .collection('exercises')
        .get();

    _cachedExercises = snapshot.docs.map((doc) => doc.data()).toList();
    return _cachedExercises!;
  }
}
