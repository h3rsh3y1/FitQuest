import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardSummaryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Map<String, dynamic>>> fetchCaloriesLast5Days() async {
    User? user = _auth.currentUser;
    if (user == null) return [];

    DateTime now = DateTime.now();
    DateTime fiveDaysAgo = now.subtract(const Duration(days: 7));

    final snapshot =
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('workouts')
            .where('timestamp', isGreaterThanOrEqualTo: fiveDaysAgo)
            .get();

    Map<String, Map<String, dynamic>> summary = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final date = (data['timestamp'] as Timestamp).toDate().toLocal();
      final day = DateTime(date.year, date.month, date.day);

      summary[day.toString()] ??= {'date': day, 'calories': 0.0, 'duration': 0};

      summary[day.toString()]!['calories'] +=
          (data['calories'] ?? 0).toDouble();
      summary[day.toString()]!['duration'] += (data['duration'] ?? 0);
    }

    return summary.values.toList()..sort(
      (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime),
    );
  }

  Future<List<Map<String, dynamic>>> fetchWorkoutsByDate(DateTime date) async {
    User? user = _auth.currentUser;
    if (user == null) return [];

    final snapshot =
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('workouts')
            .get();

    return snapshot.docs.map((doc) => doc.data()).where((data) {
      final workoutDate = (data['timestamp'] as Timestamp).toDate().toLocal();
      return _isSameDay(workoutDate, date);
    }).toList();
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    final localD1 = d1.toLocal();
    final localD2 = d2.toLocal();
    return localD1.year == localD2.year &&
        localD1.month == localD2.month &&
        localD1.day == localD2.day;
  }
}

class UserPointsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<int> getUserPoints() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return 0;

    final snapshot = await _firestore.collection('users').doc(uid).get();
    return snapshot.data()?['points'] ?? 0;
  }
}
