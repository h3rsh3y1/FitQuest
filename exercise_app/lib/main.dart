import 'package:exercise_app/controller/firebaseServices/firebase_options.dart';
import 'package:exercise_app/boundary/login_Boundaries/loginScreen.dart';
import 'package:exercise_app/controller/exerciseServices/exerciseInitService.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  ExerciseInitService exerciseInitService = ExerciseInitService();
  await exerciseInitService.updateGifUrlsOnly();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: Login());
  }
}
