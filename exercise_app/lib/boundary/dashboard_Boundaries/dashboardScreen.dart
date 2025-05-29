import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:exercise_app/boundary/dashboard_Boundaries/profileEditScreen.dart';
import 'package:exercise_app/boundary/dashboard_Boundaries/summaryDashboardSection.dart';
import 'package:exercise_app/boundary/exercise_Boundaries/workoutHistoryScreen.dart';
import 'package:exercise_app/boundary/exercise_Boundaries/workoutScreen.dart';
import 'package:exercise_app/boundary/leaderboardSection.dart';
import 'package:exercise_app/controller/pointsServices/pointsController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:exercise_app/controller/userServices/userGetService.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int selectedIndex = 0; // 0 = Summary, 1 = Leaderboard
  int userPoints = 0;
  int userLevel = 1;
  int xpRemaining = 0;
  int xpForThisLevel = 100;
  double xpProgressValue = 0.0;
  int previousLevel = 1;
  
  final confettiController = ConfettiController(duration: const Duration(seconds: 2));

  String firstName = "User";
  String activeSection = 'Summary';
  final List<String> tabs = ["Summary", "Leaderboard"];

@override
void initState() {
  super.initState();
  fetchFirstName();
  loadUserPoints();
  activeSection = 'summary'; // 👈 Set default
}

  @override
  void dispose() {
    confettiController.dispose();
    super.dispose();
  }
  

  int calculateLevelFromPoints(int points) {
    int level = 1;
    int xp = points;
    while (true) {
      int requiredXp = 100 + (level - 1) * 50;
      if (xp < requiredXp) break;
      xp -= requiredXp;
      level++;
    }
    return level;
  }

  Future<void> loadUserPoints() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    final data = doc.data();
    final points = (data?['points'] ?? 0).toInt();
    final calculatedLevel = calculateLevelFromPoints(points);
    final existingLevel = (data?['level'] ?? 1).toInt();
// Only show confetti if the level increased
  final leveledUp = calculatedLevel > existingLevel;

    int usedXp = 0;
    for (int i = 1; i < calculatedLevel; i++) {
      usedXp += 100 + (i - 1) * 50;
    }

    int xpNeeded = 100 + (calculatedLevel - 1) * 50;
    int xpSoFar = points - usedXp;
    double progress = xpSoFar / xpNeeded;

    if (leveledUp) {
  confettiController.play();
  Fluttertoast.showToast(
    msg: "🎉 Level Up! You're now Level $calculatedLevel!",
    backgroundColor: Colors.green,
    textColor: Colors.white,
    fontSize: 16,
  );
}

    await PointsController().updateUserLevel(calculatedLevel);

  setState(() {
  userPoints = points;
  userLevel = calculatedLevel;
  xpForThisLevel = xpNeeded;
  xpRemaining = xpNeeded - xpSoFar;
  xpProgressValue = progress;
  previousLevel = existingLevel;
});

  }

  Future<void> fetchFirstName() async {
    var data = await UserGetService().getUserData();
    if (data != null && data.containsKey('first_name')) {
      setState(() {
        firstName = data['first_name'];
      });
    }
  }

  void onSectionSelected(String section) {
    setState(() {
      activeSection = section == activeSection ? 'none' : section;
    });
  }
  

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFF2A0D45),
          
        
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      
                      children: [
                        Text(
                          "Hi, $firstName! ",
                          style: GoogleFonts.raleway(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text("👋", style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.lightBlue.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Lvl $userLevel",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.lightGreenAccent,
                              fontSize: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      " Total XP : $userPoints                        Current Level : ${xpForThisLevel - xpRemaining} / $xpForThisLevel",
                      style: const TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 3),
                    Stack(
                      children: [
                        Container(
                          height: 12,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white10,
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: 0,
                              end: xpProgressValue,
                            ),
                            duration: const Duration(milliseconds: 700),
                            builder: (context, value, _) => Container(
                              height: 10,
                              width: MediaQuery.of(context).size.width * 0.85 * value,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFEC6EAD), Color(0xFF3494E6)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.purpleAccent.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ],
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 20),
                  itemCount: tabs.length,
                  itemBuilder: (context, index) {
                    final isSelected = activeSection == tabs[index].toLowerCase();
                    return GestureDetector(
                      onTap: () => onSectionSelected(tabs[index].toLowerCase()),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.purple : Color.fromARGB(8, 255, 255, 255),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? Colors.purple : Colors.white30,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          tabs[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _renderActiveSection(),
                ),
              ),
                  Divider(
      color: Colors.white24,
      thickness: 2,
      height: 2,
    ),
    const SizedBox(height: 4),
            ],
          ),
          
          
          bottomNavigationBar: BottomNavigationBar(
            selectedItemColor: Colors.purpleAccent,
            unselectedItemColor: Colors.white70,
            backgroundColor: const Color(0xFF2A0D45),
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: "Workout"),
              BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
              BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: "Profile"),
            ],
            onTap: (index) {
              if (index == 1 ) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WorkoutScreen()),
                ).then((_) => loadUserPoints());
              }
              else if (index == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WorkoutHistoryScreen()),
                ).then((_) => ());
              }
              else if ( index ==3 )
              {
                Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
                    ).then((_) => loadUserPoints());
              }
            },
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.purpleAccent,
              Colors.lightBlueAccent,
              Colors.greenAccent,
              Colors.orangeAccent,
            ],
            emissionFrequency: 0.2,
            numberOfParticles: 20,
            gravity: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _renderActiveSection() {
    if (activeSection == 'summary') {
      return const SummaryDashboardSection();
     } else if (activeSection == 'leaderboard') {
  return const LeaderboardSection();

    } else {
      return const SummaryDashboardSection();
  }}
}