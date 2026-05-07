import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ClautterApp());
}

class ClautterApp extends StatelessWidget {
  const ClautterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clautter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
      ),
      home: const HomeScreen(),
    );
  }
}
