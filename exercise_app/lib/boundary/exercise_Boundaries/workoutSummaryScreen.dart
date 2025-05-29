import 'package:flutter/material.dart';
import 'package:exercise_app/boundary/dashboard_Boundaries/dashboardScreen.dart';

class WorkoutSummaryScreen extends StatelessWidget {
  final int total;
  final int completed;
  final double calories;
  final int duration;
  final int reps;

  const WorkoutSummaryScreen({
    super.key,
    required this.total,
    required this.completed,
    required this.calories,
    required this.duration,
    required this.reps,
  });

  String formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A0D45),
      appBar: AppBar(
        
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              "Workout Complete! 🎉",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            GridView(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  padding: EdgeInsets.zero,
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 1.15,
    crossAxisSpacing: 20,
    mainAxisSpacing: 20,
  ),
                children: [
                  _buildStatCard(
                    icon: Icons.check_circle,
                    label: "Completed",
                    value: "$completed / $total",
                    gradient: const [Colors.tealAccent, Colors.greenAccent],
                  ),
                  _buildStatCard(
                    icon: Icons.local_fire_department,
                    label: "Calories",
                    value: "${calories.toStringAsFixed(1)} kcal",
                    gradient: const [Colors.orangeAccent, Colors.deepOrange],
                  ),
                  _buildStatCard(
                    icon: Icons.timer,
                    label: "Duration",
                    value: formatDuration(duration),
                    gradient: const [Colors.blueAccent, Colors.cyan],
                  ),
                  _buildStatCard(
                    icon: Icons.fitness_center,
                    label: "Reps Done",
                    value: "$reps",
                    gradient: const [Colors.purpleAccent, Colors.deepPurple],
                  ),
                ],
              
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: GestureDetector(
  onTap: () => Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => Dashboard()),
    (route) => false,
  ),
  child: Container(
    width: double.infinity,
    height: 50,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      gradient: const LinearGradient(
        colors: [Colors.amber, Color.fromARGB(255, 217, 255, 64)],
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.orange.withOpacity(0.4),
          offset: const Offset(0, 4),
          blurRadius: 8,
        ),
      ],
    ),
    child: const Center(
      child: Text(
        "Return to Dashboard",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Colors.black,
          letterSpacing: 0.5,
        ),
      ),
    ),
  ),
),

            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required List<Color> gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.last.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(2, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: Colors.black87),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
