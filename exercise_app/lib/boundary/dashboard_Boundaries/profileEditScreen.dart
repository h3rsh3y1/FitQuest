import 'package:exercise_app/boundary/dashboard_Boundaries/dashboardScreen.dart';
import 'package:exercise_app/controller/firebaseServices/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:exercise_app/controller/userServices/userGetService.dart';
import 'package:exercise_app/controller/userServices/userUpdateService.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> userData = {};
  bool isLoading = true;
  Future<void> _signOut() async {
    try {
      // Replace this with your actual sign-out method (e.g., Firebase sign-out)
      await AuthService().logout(context);

      print("Successfully signed out.");
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  final List<String> goals = [
    "Get Fitter",
    "Gain Weight",
    "Lose Weight",
    "Reduce Stress",
    "Stay Healthy",
  ];

  final List<String> genders = ["Male", "Female", "Other"];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      var data = await UserGetService().getUserData();
      if (data != null) {
        setState(() {
          userData = data;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateField(
    String key,
    String label,
    String currentValue,
  ) async {
    TextEditingController controller = TextEditingController(
      text: currentValue,
    );
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              "Edit $label",
              style: GoogleFonts.raleway(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: GoogleFonts.openSans(fontSize: 16, color: Colors.black),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.redAccent, fontSize: 16),
                ),
              ),
              TextButton(
                onPressed: () async {
                  double? value = double.tryParse(controller.text);
                  if (value == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter a valid number."),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Enforce limits
                  if ((key == "height" && (value < 50 || value > 200)) ||
                      (key == "weight" && (value < 20 || value > 125))) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          key == "height"
                              ? "Height must be between 50 and 200 cm."
                              : "Weight must be between 20 and 125 kg.",
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  await UserUpdateService().updateUserData({
                    key: controller.text,
                  });
                  setState(() {
                    userData[key] = controller.text;
                  });
                  Navigator.pop(context);
                },
                child: const Text(
                  "Save",
                  style: TextStyle(color: Colors.blueAccent, fontSize: 16),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _updateDropdownField(String key, String newValue) async {
    try {
      await UserUpdateService().updateUserData({key: newValue});
      setState(() {
        userData[key] = newValue;
      });
    } catch (e) {
      print("Error updating field: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E133D),

      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Profile",
          style: GoogleFonts.raleway(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              if (value == "signout") {
                await _signOut();
                Navigator.pushReplacementNamed(
                  context,
                  '/login',
                ); // Navigate to login screen after sign out
              }
              if(value=="Dashboard"){
                Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => Dashboard()),
  (route) => false);
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: "signout",
                    child: Text(
                      "Sign Out",
                      style: GoogleFonts.raleway(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    
                  ),
                ],
                
          ),
        ],
      ),

      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.blueAccent),
              )
              : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildProfileHeader(),
                      const SizedBox(height: 20),
                      _buildSection("Personal Information", [
                        _buildInfoCard(
                          "Full Name",
                          "${userData['first_name']} ${userData['last_name']}",
                          "first_name",
                        ),
                        _buildInfoCard("Email", userData['email'], null),
                        _buildInfoCard(
                          "Age",
                          userData['age'].toString(),
                          "age",
                        ),
                      ]),
                      _buildSection("Fitness Details", [
                        _buildHeightWeightCard(
                          "Height",
                          userData['height'].toString(),
                          "height",
                          "cm",
                        ),
                        _buildHeightWeightCard(
                          "Weight",
                          userData['weight'].toString(),
                          "weight",
                          "kg",
                        ),
                        _buildDropdownCard("Gender", "gender", genders),
                        _buildDropdownCard("Goal", "goal", goals),
                      ]),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.deepPurple[900],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.account_circle, size: 80, color: Colors.blueAccent),
          const SizedBox(height: 10),
          Text(
            "${userData['first_name']} ${userData['last_name']}",
            style: GoogleFonts.raleway(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            userData['email'],
            style: GoogleFonts.openSans(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          title,
          style: GoogleFonts.raleway(
            color: Colors.white70,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ...children,
      ],
    );
  }

  // 📌 Method: Builds an info card with editable text
  Widget _buildInfoCard(String title, String value, String? key) {
    return GestureDetector(
      onTap: key == null ? null : () => _updateField(key, title, value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          border: Border.all(color: Colors.deepPurple.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.openSans(color: Colors.black87, fontSize: 16),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: GoogleFonts.raleway(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (key != null)
                  const Icon(Icons.edit, color: Colors.blueAccent, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeightWeightCard(
    String title,
    String value,
    String key,
    String unit,
  ) {
    return GestureDetector(
      onTap: () => _updateField(key, title, value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          border: Border.all(color: Colors.deepPurple.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.openSans(color: Colors.black87, fontSize: 16),
            ),
            Text(
              "$value $unit",
              style: GoogleFonts.raleway(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownCard(String label, String key, List<String> options) {
    // Prevent duplicates and trim whitespace
    final distinctOptions = options.map((e) => e.trim()).toSet().toList();

    // Ensure current value is valid
    final currentValue =
        distinctOptions.contains(userData[key]) ? userData[key] : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        border: Border.all(color: Colors.deepPurple.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: GoogleFonts.openSans(color: Colors.black87, fontSize: 16),
          ),
          DropdownButton<String>(
            value: currentValue,
            hint: const Text("Select"),
            items:
                distinctOptions.map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(
                      option,
                      style: GoogleFonts.raleway(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  );
                }).toList(),
            onChanged: (newValue) => _updateDropdownField(key, newValue!),
          ),
        ],
      ),
    );
  }
}
