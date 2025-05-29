import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final String exerciseId;

  const ExerciseDetailScreen({super.key, required this.exerciseId});

  @override
  _ExerciseDetailScreenState createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  Map<String, dynamic>? exerciseData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchExerciseDetails();
  }

  Future<void> fetchExerciseDetails() async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection('exercises')
              .doc(widget.exerciseId)
              .get();

      if (doc.exists) {
        setState(() {
          exerciseData = doc.data() as Map<String, dynamic>;
          isLoading = false;
        });
      } else {
        throw Exception("Exercise not found");
      }
    } catch (e) {
      print("❌ Error fetching exercise details: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Exercise Details"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : exerciseData == null
              ? Center(child: Text("Exercise not found"))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      exerciseData!['gifUrl'],
                      width: double.infinity,
                      height: 350,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      exerciseData!['name'],
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "🎯 Target: ${exerciseData!['target']}",
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "🦾 Secondary Muscles: ${(exerciseData!['secondaryMuscles'] as List<dynamic>).join(', ')}",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "⚙️ Equipment: ${exerciseData!['equipment']}",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "🏋️‍♂️ Body Part: ${exerciseData!['bodyPart']}",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "📄 Instructions:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...(exerciseData!['instructions'] as List<dynamic>)
                        .asMap()
                        .entries
                        .map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              "${entry.key + 1}. ${entry.value}",
                              style: TextStyle(fontSize: 16),
                            ),
                          );
                        })
                        .toList(),
                  ],
                ),
              ),
    );
  }
}
