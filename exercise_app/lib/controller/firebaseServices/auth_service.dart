import 'package:exercise_app/boundary/dashboard_Boundaries/dashboardScreen.dart';
import 'package:exercise_app/boundary/login_Boundaries/goalSelectionScreen.dart';
import 'package:exercise_app/boundary/login_Boundaries/loginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


class AuthService {
Future<void> signup({
  required String email,
  required String password,
  required BuildContext context,
}) async {
  try {
    final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      _showVerificationDialog(context, user);
    }
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with that email.';
      }
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }

  Future<void> signin({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Dashboard()),
      );
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'invalid-email') {
        message = 'No user found for that email.';
      } else if (e.code == 'invalid-credential') {
        message = 'Wrong password provided for that user.';
      }
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Login()),
        (route) => false,
      );
      Fluttertoast.showToast(
        msg: "Logged out successfully",
        toastLength: Toast.LENGTH_SHORT,
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Logout failed: ${e.toString()}");
    }
  }
  void _showVerificationDialog(BuildContext context, User user) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text("Verify Your Email"),
      content: const Text(
          "A verification email has been sent. Please verify before continuing."),
      actions: [
        TextButton(
          onPressed: () async {
  await user.reload(); // 🔄 Refresh user info from Firebase
  final refreshedUser = FirebaseAuth.instance.currentUser;

  if (refreshedUser != null && refreshedUser.emailVerified) {
    Navigator.pop(context); // Close dialog
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const GoalSelectionScreen()),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Email not verified yet."),
        backgroundColor: Colors.orange,
      ),
    );
  }
},

          child: const Text("I've Verified"),
        ),
      ],
    ),
  );
}
}
