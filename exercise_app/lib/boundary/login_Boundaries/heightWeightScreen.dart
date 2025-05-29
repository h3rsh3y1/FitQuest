import 'package:flutter/material.dart';
import 'package:exercise_app/controller/userServices/userUpdateService.dart';
import 'package:exercise_app/boundary/dashboard_Boundaries/dashboardScreen.dart';

class HeightWeightScreen extends StatefulWidget {
  const HeightWeightScreen({super.key});

  @override
  _HeightWeightScreenState createState() => _HeightWeightScreenState();
}

class _HeightWeightScreenState extends State<HeightWeightScreen> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  double _age = 18;
  String _selectedGender = "Male";

  Future<void> _saveData() async {
    if (_heightController.text.isEmpty || _weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter both height and weight."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    double? height = double.tryParse(_heightController.text);
    double? weight = double.tryParse(_weightController.text);

    if (height == null || weight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter valid numbers for height and weight."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (height < 50 || height > 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a realistic height between 50–200 cm."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (weight < 20 || weight > 125) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a realistic weight between 20–125 kg."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await UserUpdateService().updateUserData({
      "height": height,
      "weight": weight,
      "age": _age.round(),
      "gender": _selectedGender,
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Dashboard()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E1A47),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Personal Details",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Gender",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _genderButton("Male", Icons.male),
                  _genderButton("Female", Icons.female),
                ],
              ),
              const SizedBox(height: 30),
              _inputField("Height", "cm", _heightController),
              const SizedBox(height: 20),
              _inputField("Weight", "kg", _weightController),
              const SizedBox(height: 30),

              const Text(
                "Age",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _ageSlider(),
              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _outlinedButton("Back", () => Navigator.pop(context)),
                  _filledButton("Next", _saveData),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _genderButton(String gender, IconData icon) {
    bool isSelected = _selectedGender == gender;
    Color selectedColor =
        (gender == "Male") ? Colors.blueAccent : Colors.purpleAccent;

    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: MediaQuery.of(context).size.width * 0.42,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.black26,
          borderRadius: BorderRadius.circular(30),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: selectedColor.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ]
                  : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white70,
              size: 28,
            ),
            const SizedBox(width: 10),
            Text(
              gender,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(
    String label,
    String unit,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 18, color: Colors.white),
          decoration: InputDecoration(
            hintText: unit,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
            filled: true,
            fillColor: Colors.white24,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _ageSlider() {
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.purpleAccent,
            inactiveTrackColor: Colors.white24,
            thumbColor: Colors.purpleAccent,
            overlayColor: Colors.purpleAccent.withOpacity(0.2),
            trackHeight: 8,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Slider(
            value: _age,
            min: 10,
            max: 100,
            divisions: 90,
            label: "${_age.round()}",
            onChanged: (value) => setState(() => _age = value),
          ),
        ),
        Text(
          "${_age.round()} years",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _outlinedButton(String text, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  Widget _filledButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.purple,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
