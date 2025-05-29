import 'package:exercise_app/boundary/exercise_Boundaries/workoutDetailScreen.dart';
import 'package:exercise_app/controller/exerciseServices/exerciseGetService.dart';
import 'package:flutter/material.dart';


class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final Map<String, List<String>> categoryMap = {
    "Abs": ["waist"],
    "Chest": ["chest"],
    "Arm": ["upper arms", "lower arms"],
    "Shoulder & Back": ["shoulders", "back"],
    "Legs": ["upper legs", "lower legs"],
  };

  final List<String> categories = [
    "Abs",
    "Chest",
    "Arm",
    "Shoulder & Back",
    "Legs",
  ];

  String selectedCategory = "Abs";
  Map<String, List<dynamic>> routines = {
    'Beginner': [],
    'Intermediate': [],
    'Advanced': [],
  };

  final ExerciseGetService _exerciseGetService = ExerciseGetService();

  @override
  void initState() {
    super.initState();
    fetchExercisesFromFirestore(selectedCategory);
  }

  Future<void> fetchExercisesFromFirestore(String category) async {
    try {
      final parts = categoryMap[category] ?? [];
      List<Map<String, dynamic>> allExercises =
    await _exerciseGetService.getAllExercisesCached();



      // Filter by body part and equipment
      final filtered =
          allExercises.where((e) {
            return parts.contains(e['bodyPart'].toLowerCase()) &&
                e['equipment'].toLowerCase() == 'body weight';
          }).toList();

      // Group by difficulty
      Map<String, List<dynamic>> grouped = {
        'Beginner': [],
        'Intermediate': [],
        'Advanced': [],
      };

      for (var exercise in filtered) {
        final name = exercise['name'].toLowerCase();

        if (_isAdvanced(name)) {
          grouped['Advanced']!.add(exercise);
        } else if (_isBeginner(name)) {
          grouped['Beginner']!.add(exercise);
        } else {
          grouped['Intermediate']!.add(exercise);
        }
      }

      // Fill to required length
      for (String level in grouped.keys) {
        final current = grouped[level]!;
        if (current.isNotEmpty && current.length < 10) {
          final List<dynamic> filler = [];
          while (filler.length + current.length < 10) {
            filler.addAll(current.take(10 - filler.length - current.length));
          }
          grouped[level] = current + filler;
        } else if (current.length > 15) {
          grouped[level] = current.take(15).toList();
        }
      }

      setState(() {
        selectedCategory = category;
        routines = grouped;
      });
    } catch (e) {
      print("❌ Error fetching exercises: $e");
    }
  }

  bool _isBeginner(String name) {
    return [
      'bridge',
      'raise',
      'touch',
      'plank',
      'bend',
      'static',
      'hold',
      'sit-up',
      'knee push-up',
      'incline push-up',
      'push-up',
    ].any((kw) => name.contains(kw));
  }

  bool _isAdvanced(String name) {
    return [
      'burpee',
      'pistol',
      'explosive',
      'tuck',
      'jump',
      'power',
      'sprint',
    ].any((kw) => name.contains(kw));
  }

  int _getDummyDuration(String level) {
    switch (level) {
      case 'Beginner':
        return 16;
      case 'Intermediate':
        return 22;
      case 'Advanced':
        return 28;
      default:
        return 20;
    }
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 227, 207, 247),
      appBar: AppBar(
        elevation: 2,
        title:Text(   
        "Classic Workouts",
        style: const TextStyle(
          fontSize: 35,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2A0D45),
          letterSpacing: 1,
        ),
      ),),




     body: Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16), // ← consistent left/right padding
  child: Column(
    children: [
      const SizedBox(height: 6),

      // Category Selector Scroll Row
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) {
            bool isSelected = category == selectedCategory;
            return GestureDetector(
              onTap: () => fetchExercisesFromFirestore(category),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : const LinearGradient(colors: [Colors.white, Colors.white]),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? Colors.deepPurple: Colors.white70,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),

    

      // Workout List
      Expanded(
        child: routines.values.every((list) => list.isEmpty)
            ? const Center(child: CircularProgressIndicator())
            : Expanded(
  child: routines.values.every((list) => list.isEmpty)
      ? const Center(child: CircularProgressIndicator())
      : ListView(
          children: ['Beginner', 'Intermediate', 'Advanced'].map((level) {
            final exercises = routines[level]!;
            if (exercises.isEmpty) return const SizedBox();

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WorkoutDetailScreen(
                      title: "$selectedCategory • $level",
                      exercises: exercises,
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 76, 40, 122),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        exercises.first['gifUrl'],
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$selectedCategory • $level",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${_getDummyDuration(level)} mins",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 20),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
),

      ),
    ],
  ),
),

    );
  }
}
