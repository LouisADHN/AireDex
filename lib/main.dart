import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const AireApp());
}

class AireApp extends StatelessWidget {
  const AireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}
