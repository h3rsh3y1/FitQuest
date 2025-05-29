import 'package:flutter/material.dart';
import 'exerciseDetailScreen.dart';
import 'workoutProgressScreen.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final String title;
  final List<dynamic> exercises;

  const WorkoutDetailScreen({
    super.key,
    required this.title,
    required this.exercises,
  });

  String getLevel() {
    if (title.toLowerCase().contains("beginner")) return "Beginner";
    if (title.toLowerCase().contains("intermediate")) return "Intermediate";
    if (title.toLowerCase().contains("advanced")) return "Advanced";
    return "Custom";
  }

  String getTime() {
    switch (getLevel()) {
      case "Beginner":
        return "16 mins";
      case "Intermediate":
        return "22 mins";
      case "Advanced":
        return "28 mins";
      default:
        return "20 mins";
    }
  }

  String getFocusArea() {
    return title.split(" •").first.trim();
  }

  @override
  Widget build(BuildContext context) {
    final level = getLevel();
    final time = getTime();
    final focus = getFocusArea();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            exercises.first['gifUrl'],
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _infoBox("Level", level),
                    _infoBox("Time", time),
                    _infoBox("Focus Area", focus),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "Exercises (${exercises.length})",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final ex = exercises[index];
                final name = ex['name'].toString().toLowerCase();
                final reps =
                    {
                      "Beginner": 10,
                      "Intermediate": 15,
                      "Advanced": 20,
                    }[level] ??
                    12;

                final repsOrTime =
                    name.contains("plank") || name.contains("hold")
                        ? "00:30"
                        : "x $reps";

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: InkWell(
                    onTap: () {
                      // ✅ Navigate to ExerciseDetailScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  ExerciseDetailScreen(exerciseId: ex['id']),
                        ),
                      );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            ex['gifUrl'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ex['name'].toString().toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(repsOrTime),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // ✅ Navigate to WorkoutProgressScreen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => WorkoutProgressScreen(
                      exercises: exercises,
                      workoutName: title,
                    ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Start Workout",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _infoBox(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
