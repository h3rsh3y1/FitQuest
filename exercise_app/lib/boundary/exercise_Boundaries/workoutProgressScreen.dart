import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercise_app/boundary/exercise_Boundaries/workoutSummaryScreen.dart';
import 'package:exercise_app/controller/celebrationService.dart';
import 'package:exercise_app/controller/workoutService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:exercise_app/controller/pointsServices/pointsController.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class WorkoutProgressScreen extends StatefulWidget {
  final List<dynamic> exercises;
  final String workoutName;

  const WorkoutProgressScreen({
    super.key,
    required this.exercises,
    required this.workoutName,
  });

  @override
  State<WorkoutProgressScreen> createState() => _WorkoutProgressScreenState();
}

class _WorkoutProgressScreenState extends State<WorkoutProgressScreen> {
  Set<int> processedIndexes = {};
  bool isWorkoutEnded = false;
  bool finalExerciseProcessed = false;
  int totalEstimatedReps = 0;
  int currentIndex = 0;
  int totalCompleted = 0;
  double totalCalories = 0;
  bool isPaused = false;
  bool isResting = false;
  Timer? liveTimer;
  int elapsedSeconds = 0;
  int restSeconds = 20;
  double userWeight = 70;
  bool showCelebration = false;
  late DateTime exerciseStartTime;

  @override
  void initState() {
    super.initState();
    fetchUserWeight();
    exerciseStartTime = DateTime.now();
    startLiveTimer();
  }

  Future<void> fetchUserWeight() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (doc.exists) {
      setState(() {
        userWeight = double.tryParse(doc.data()?['weight'].toString() ?? '70') ?? 70;
      });
    }
  }

  void processCurrentExercise() {
    if (processedIndexes.contains(currentIndex)) return;

    final currentExercise = widget.exercises[currentIndex];
    final met = currentExercise['met'] ?? 4.0;
    final exerciseEndTime = DateTime.now();
    final actualDurationSeconds = exerciseEndTime.difference(exerciseStartTime).inSeconds;
    final secondsPerRep = _getRepDurationForExercise(currentExercise['name']);
    final isIsometric = secondsPerRep > 1000;

    double estimatedReps = isIsometric
        ? actualDurationSeconds / 30.0
        : actualDurationSeconds / secondsPerRep;

    totalEstimatedReps += estimatedReps.round();
    totalCalories += (met * 3.5 * userWeight * (actualDurationSeconds / 60.0)) / 200;

    totalCompleted++;
    processedIndexes.add(currentIndex);
  }

  void startLiveTimer() {
    liveTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isPaused) {
        setState(() {
          elapsedSeconds++;
          if (isResting) {
            restSeconds--;
            if (restSeconds <= 0) {
              nextExercise();
            }
          }
        });
      }
    });
  }

  void togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
  }

  double _getRepDurationForExercise(String exerciseName) {
    final name = exerciseName.toLowerCase();

    if (name.contains("advanced")) return 2.0;
    if (name.contains("intermediate")) return 2.5;
    if (name.contains("beginner")) return 3.0;
    if (name.contains("plank") || name.contains("hold")) return 9999;
    return 3.0;
  }

  void nextExercise() {
    processCurrentExercise();

    if (currentIndex >= widget.exercises.length - 1) {
      setState(() {
        isResting = false;
        restSeconds = 20;
        exerciseStartTime = DateTime.now();
      });
      return;
    }

    setState(() {
      currentIndex++;
      isResting = false;
      restSeconds = 20;
      exerciseStartTime = DateTime.now();
    });
  }

  Future<void> endWorkout() async {
  if (isWorkoutEnded) return;
  isWorkoutEnded = true;

  if (!finalExerciseProcessed) {
    processCurrentExercise();
    finalExerciseProcessed = true;
  }

  liveTimer?.cancel();
  storeWorkoutData();

  final pointsController = PointsController();
  int earnedPoints = pointsController.calculatePoints(
    durationInSeconds: elapsedSeconds,
    caloriesBurned: totalCalories,
    completedExercises: totalCompleted,
    totalExercises: widget.exercises.length,
  );
  await pointsController.addPointsToUser(earnedPoints);

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get();

  int totalPoints = doc.data()?['points'] ?? 0;
  int level = getLevelFromPoints(totalPoints);
  int xpRemaining = getRemainingXpToNextLevel(totalPoints);

  print("🎉 Level: $level, XP to next: $xpRemaining");

  setState(() => showCelebration = true);

  // Wait for 2.5 seconds before navigating
  await Future.delayed(const Duration(seconds: 3));

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => WorkoutSummaryScreen(
        total: widget.exercises.length,
        completed: totalCompleted,
        calories: totalCalories,
        duration: elapsedSeconds,
        reps: totalEstimatedReps,
      ),
    ),
  );
}


  void startRest() {
    if (currentIndex >= widget.exercises.length - 1) {
      if (!finalExerciseProcessed) {
        processCurrentExercise();
        finalExerciseProcessed = true;
      }
      endWorkout();
      return;
    }

    setState(() {
      isResting = true;
      restSeconds = 20;
    });
  }

  void skipRest() {
    processCurrentExercise();
    setState(() {
      isResting = false;
      restSeconds = 20;
    });
    exerciseStartTime = DateTime.now();
    nextExercise();
  }

  void storeWorkoutData() async {
    List<String> exerciseNames =
        widget.exercises.map((e) => e['name'].toString()).toList();

    await WorkoutSaveService().saveWorkoutData(
      workoutName: widget.workoutName,
      duration: elapsedSeconds,
      calories: totalCalories,
      completedExercises: totalCompleted,
      timestamp: DateTime.now(),
      exerciseNames: exerciseNames,
    );
  }

  String formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    liveTimer?.cancel();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  final currentExercise = widget.exercises[currentIndex];
  const double buttonWidth = 160;
  const double buttonHeight = 48;
  const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  return Stack(
    children: [
  Scaffold(
    backgroundColor: const Color(0xFF2A0D45),
    appBar: AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - kToolbarHeight - 48,
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Total Time: ${formatDuration(elapsedSeconds)}",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Exercise ${currentIndex + 1} of ${widget.exercises.length}",
                  style: const TextStyle(fontSize: 20, color: Colors.white70),
                ),
                const SizedBox(height: 20),
                if (isResting)
                  Column(
                    children: [
                      const Text(
                        "Rest Time",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "$restSeconds s",
                        style: const TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: buttonWidth,
                        height: buttonHeight,
                        child: ElevatedButton(
                          onPressed: skipRest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Text("Skip Rest", style: buttonTextStyle.copyWith(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Prepare for the next exercise",
                        style: TextStyle(fontSize: 18, color: Colors.white70),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      Text(
                        currentExercise['name'].toString().toUpperCase(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          currentExercise['gifUrl'],
                          height: 300,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Equipment: ${currentExercise['equipment']}",
                        style: const TextStyle(fontSize: 18, color: Colors.white70),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: buttonWidth,
                        height: buttonHeight,
                        child: ElevatedButton(
                          onPressed: startRest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Text("Next Exercise", style: buttonTextStyle.copyWith(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: buttonWidth,
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: togglePause,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: Text(
                          isPaused ? "Resume" : "Pause",
                          style: buttonTextStyle.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: buttonWidth,
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: endWorkout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: Text("End Workout", style: buttonTextStyle.copyWith(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
   if (showCelebration) const CelebrationOverlay(),
    ],
  );
    
}
}