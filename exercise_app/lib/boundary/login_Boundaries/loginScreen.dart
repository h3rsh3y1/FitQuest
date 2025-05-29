import 'package:exercise_app/boundary/login_Boundaries/signupScreen.dart';
import 'package:exercise_app/controller/firebaseServices/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Login extends StatelessWidget {
  Login({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  void _showForgotPasswordDialog(BuildContext context) {
  final TextEditingController _resetEmailController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Reset Password"),
      content: TextField(
        controller: _resetEmailController,
        decoration: const InputDecoration(
          hintText: "Enter your email address",
        ),
        keyboardType: TextInputType.emailAddress,
      ),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: const Text("Send Reset Link"),
          onPressed: () async {
            final email = _resetEmailController.text.trim();
            if (email.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Please enter an email."),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            try {
              await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Password reset link sent! Check your email."),
                  backgroundColor: Colors.green,
                ),
              );
            } catch (e) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Error: ${e.toString()}"),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 166, 10, 140), Color(0xFF6A00F4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _backButton(context),
                const SizedBox(height: 20),
                _appTitle(),
                const SizedBox(height: 50),
                _emailField(),
                const SizedBox(height: 20),
                _passwordField(),
                _forgotPasswordText(context),
                const SizedBox(height: 25),
                _signinButton(context),
                const SizedBox(height: 20),
                _signupText(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _forgotPasswordText(BuildContext context) {
  return Align(
    alignment: Alignment.centerLeft,
    child: TextButton(
      onPressed: () => _showForgotPasswordDialog(context),
      child: const Text(
        "Forgot Password?",
        style: TextStyle(color: Colors.white70, fontSize: 14),
      ),
    ),
  );
}


  Widget _backButton(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _appTitle() {
    return Stack(
      children: [
        // Purple Outline
        Text(
          'Fit Quest',
          style: GoogleFonts.fredoka(
            textStyle: TextStyle(
              fontSize: 70,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              foreground:
                  Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 6
                    ..color = Color(0xFF9B5DE5), // Purple outline color
            ),
          ),
        ),
        // White Fill
        Text(
          'Fit Quest',
          style: GoogleFonts.fredoka(
            textStyle: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _emailField() {
    return _customTextField(
      controller: _emailController,
      label: "Email Address",
      hint: "Enter your email",
      icon: Icons.email_outlined,
    );
  }

  Widget _passwordField() {
    return _customTextField(
      controller: _passwordController,
      label: "Password",
      hint: "Enter your password",
      icon: Icons.lock_outline,
      obscureText: true,
    );
  }

  Widget _signinButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 3,
        ),
        onPressed: () async {
          await AuthService().signin(
            email: _emailController.text,
            password: _passwordController.text,
            context: context,
          );
        },
        child: Text(
          "Sign In",
          style: GoogleFonts.raleway(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _signupText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            const TextSpan(
              text: "New here? ",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            TextSpan(
              text: "Create Account",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
              recognizer:
                  TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Signup()),
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _customTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.raleway(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white70),
            prefixIcon: Icon(icon, color: Colors.white),
            filled: true,
            fillColor: Colors.white.withOpacity(0.2),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
