import 'package:cloud_firestore/cloud_firestore.dart';
import 'exerciseApiService.dart';

class ExerciseInitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Updates only the gifUrl field for existing exercises if changed
  Future<void> updateGifUrlsOnly() async {
  try {
    final apiExercises = await ExerciseApiService.getExercises(limit: 0);
    final CollectionReference exercisesRef = FirebaseFirestore.instance.collection('exercises');

    // Fetch all existing Firestore docs once
    final existingDocs = await exercisesRef.get();
    final Map<String, Map<String, dynamic>> firestoreMap = {
      for (var doc in existingDocs.docs) doc.id: doc.data() as Map<String, dynamic>
    };

    int updated = 0, skipped = 0, missing = 0;
    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (var apiEx in apiExercises) {
      final id = apiEx['id'].toString();
      final newUrl = apiEx['gifUrl'];
      final existing = firestoreMap[id];

      if (existing != null) {
        if (existing['gifUrl'] != newUrl) {
          final docRef = exercisesRef.doc(id);
          batch.update(docRef, {'gifUrl': newUrl});
          updated++;
        } else {
          skipped++;
        }
      } else {
        missing++;
      }
    }

    await batch.commit();

    print("✅ Updated: $updated, ⏭️ Skipped: $skipped, ❌ Missing: $missing");
  } catch (e) {
    print("❌ Error: $e");
  }
}
}