// lib/main.dart
import 'package:flutter/material.dart';
import 'package:video_calling_app/pages/homepage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Calling App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Homepage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
