import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'heightWeightScreen.dart';

class PhysicalActivityScreen extends StatefulWidget {
  const PhysicalActivityScreen({super.key});

  @override
  _PhysicalActivityScreenState createState() => _PhysicalActivityScreenState();
}

class _PhysicalActivityScreenState extends State<PhysicalActivityScreen> {
  final List<String> activityLevels = ["Beginner", "Intermediate", "Advanced"];
  String? selectedActivityLevel;

  Future<void> _saveActivityLevel() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && selectedActivityLevel != null) {
      await FirebaseFirestore.instance.collection("users").doc(user.uid).set(
        {"activity_level": selectedActivityLevel},
        SetOptions(merge: true), // Merge with existing data
      );

      // Navigate to Dashboard after saving activity level
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HeightWeightScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E1A47),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Physical Activity Level",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ...activityLevels.map((level) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedActivityLevel = level;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(vertical: 25),
                    decoration: BoxDecoration(
                      color:
                          selectedActivityLevel == level
                              ? Colors.purpleAccent
                              : Colors.black26,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Center(
                      child: Text(
                        level,
                        style: TextStyle(
                          color:
                              selectedActivityLevel == level
                                  ? Colors.white
                                  : Colors.white70,
                          fontSize: 23,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context); // Back to goal selection screen
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
                    onPressed:
                        selectedActivityLevel == null
                            ? null
                            : _saveActivityLevel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
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
    );
  }
}
