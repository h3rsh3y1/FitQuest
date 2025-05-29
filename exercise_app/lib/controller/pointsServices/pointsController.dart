import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PointsController {
  final _uid = FirebaseAuth.instance.currentUser!.uid;
  final _userRef = FirebaseFirestore.instance.collection('users');

  /// 🔢 Calculate points from workout performance
  int calculatePoints({
    required int durationInSeconds,
    required double caloriesBurned,
    required int completedExercises,
    required int totalExercises,
  }) {
    double efficiency = completedExercises / totalExercises;
    int durationPoints = (durationInSeconds / 60).round();
    int caloriePoints = caloriesBurned.round();
    int exercisePoints = (completedExercises * 2);

    return ((durationPoints + caloriePoints + exercisePoints) * efficiency).round();
  }

  /// 💾 Add points to the current user
  Future<void> addPointsToUser(int pointsToAdd) async {
    final doc = await _userRef.doc(_uid).get();
    final currentPoints = doc.data()?['points'] ?? 0;
    final newTotalPoints = currentPoints + pointsToAdd;

    int level = getLevelFromPoints(newTotalPoints);

    await _userRef.doc(_uid).update({
      'points': newTotalPoints,
      'level': level,
    });
  }

  /// 📤 Forcefully update the user's level in Firestore
  Future<void> updateUserLevel(int level) async {
    await _userRef.doc(_uid).update({
      'level': level,
    });
  }
}

/// 🧠 Calculate level based on total points
int getLevelFromPoints(int totalPoints) {
  int level = 1;
  int xpNeeded = 100;

  while (totalPoints >= xpNeeded) {
    totalPoints -= xpNeeded;
    level++;
    xpNeeded += 50;
  }

  return level;
}

/// 📈 Calculate XP needed to reach the next level
int getRemainingXpToNextLevel(int totalPoints) {
  int level = getLevelFromPoints(totalPoints);
  int xpForThisLevel = 100 + (level - 1) * 50;

  int usedXp = 0;
  for (int i = 1; i < level; i++) {
    usedXp += 100 + (i - 1) * 50;
  }

  return xpForThisLevel - (totalPoints - usedXp);
}