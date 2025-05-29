import 'package:exercise_app/boundary/login_Boundaries/physicalActivityLvlScreen.dart';
import 'package:flutter/material.dart';
import 'package:exercise_app/controller/userServices/userUpdateService.dart';

class GoalSelectionScreen extends StatefulWidget {
  const GoalSelectionScreen({super.key});

  @override
  _GoalSelectionScreenState createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends State<GoalSelectionScreen> {
  final List<String> goals = [
    "Get Fitter",
    "Gain Weight",
    "Lose Weight",
    "Reduce Stress",
    "Stay Healthy",
  ];

  String? selectedGoal;

  Future<void> _saveGoal() async {
    if (selectedGoal != null) {
      try {
        await UserUpdateService().updateUserData({
          "goal": selectedGoal,
        }); //  Now uses service!

        //  **Navigate only after successful update**
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const PhysicalActivityScreen(),
            ),
          );
        }
      } catch (e) {
        //  **Show error message if update fails**
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error saving goal: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Ensure user selects a goal before proceeding
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a goal before proceeding."),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: const Color(0xFF2E1A47),
  resizeToAvoidBottomInset: true, // ✅ allow layout to shift on keyboard open
  body: SafeArea(
    child: SingleChildScrollView( // ✅ enables scroll to prevent overflow
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
        child: ConstrainedBox( // ensures full screen usage
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 60,
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "What's Your Goal?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ...goals.map((goal) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedGoal = goal;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 30),
                      padding: const EdgeInsets.symmetric(vertical: 25),
                      decoration: BoxDecoration(
                        color: selectedGoal == goal
                            ? Colors.purpleAccent
                            : Colors.black26,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          goal,
                          style: TextStyle(
                            color: selectedGoal == goal
                                ? Colors.white
                                : Colors.white70,
                            fontSize: 23,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                      ),
                      child: const Text(
                        "Back",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: selectedGoal == null ? null : _saveGoal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 0,
                        ),
                      ),
                      child: const Text(
                        "Next",
                        style: TextStyle(
                          color: Colors.purple,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
);
  }
}
