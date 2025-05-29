import 'package:exercise_app/boundary/login_Boundaries/goalSelectionScreen.dart';
import 'package:exercise_app/controller/firebaseServices/auth_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:exercise_app/controller/userServices/userSetService.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkFields);
    _confirmPasswordController.addListener(_checkFields);
  }

  void _checkFields() {
    setState(() {
      isButtonEnabled =
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff2E1A47),
      resizeToAvoidBottomInset: true, // Prevent overflow issues with keyboard
      bottomNavigationBar: _signin(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Create\nYour Account",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),

              const Text(
                " First Name                   Last Name",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _nameFields(),
              const SizedBox(height: 15),

              const Text(
                " Email Address",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _emailAddress(),
              const SizedBox(height: 10),
              const Text(
                "   Email Address will be used as the username login",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),

              const SizedBox(height: 15),

              const Text(
                " Password",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _passwordFields(),
              const SizedBox(height: 10),

              const Text(
                "   Password must contain at least one uppercase letter, one\n   lowercase letter, one number, and one special character. It \n   should be at least 8 characters long.",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),

              const SizedBox(height: 50),
              _signup(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nameFields() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: TextField(
              controller: _firstNameController,
              decoration: InputDecoration(
                hintText: 'First Name',
                floatingLabelBehavior: FloatingLabelBehavior.never,
                labelStyle: TextStyle(
                  color: Colors.black.withOpacity(0.6),
                  fontSize: 16,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: TextField(
              controller: _lastNameController,
              decoration: InputDecoration(
                hintText: 'Last Name',
                floatingLabelBehavior: FloatingLabelBehavior.never,
                labelStyle: TextStyle(
                  color: Colors.black.withOpacity(0.6),
                  fontSize: 16,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _emailAddress() {
    return TextField(
      controller: _emailController,
      decoration: InputDecoration(
        hintText: 'Email Address',
        floatingLabelBehavior: FloatingLabelBehavior.never,
        labelStyle: TextStyle(
          color: Colors.black.withOpacity(0.6),
          fontSize: 16,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide.none,
        ),
      ),
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _passwordFields() {
    return Column(
      children: [
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Password',
            floatingLabelBehavior: FloatingLabelBehavior.never,
            labelStyle: TextStyle(
              color: Colors.black.withOpacity(0.6),
              fontSize: 16,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Confirm Password',
            floatingLabelBehavior: FloatingLabelBehavior.never,
            labelStyle: TextStyle(
              color: Colors.black.withOpacity(0.6),
              fontSize: 16,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  bool isValidPassword(String password) {
    // At least one uppercase, one lowercase, one number, one special character, min 8 chars
    final passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~^]).{8,}$',
    );
    return passwordRegex.hasMatch(password);
  }

  Widget _signup(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed:
            isButtonEnabled
                ? () async {
                  if (_passwordController.text !=
                      _confirmPasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Passwords do not match!"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (!isValidPassword(_passwordController.text)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Password must contain upper, lower, number, special char, and be 8+ chars.",
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  await AuthService().signup(
                    email: _emailController.text,
                    password: _passwordController.text,
                    context: context,
                  );

                  await UserSetService().setUserData(
                    firstName: _firstNameController.text,
                    lastName: _lastNameController.text,
                    email: _emailController.text,
                  );
                }
                : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isButtonEnabled ? Colors.white : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side:
                isButtonEnabled
                    ? BorderSide.none
                    : const BorderSide(color: Colors.white),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        ),
        child: Text(
          "Create account",
          style: TextStyle(
            color:
                isButtonEnabled
                    ? const Color.fromARGB(190, 104, 2, 147)
                    : Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _signin(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            const TextSpan(
              text: "Already Have an Account? ",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            TextSpan(
              text: "Log In",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              recognizer:
                  TapGestureRecognizer()
                    ..onTap =
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GoalSelectionScreen(),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
