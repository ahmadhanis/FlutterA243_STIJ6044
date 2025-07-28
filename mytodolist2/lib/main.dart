import 'package:flutter/material.dart';
import 'package:mytodolist2/splashscreen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF0D47A1),
          primary: Color(0xFF0D47A1),
          secondary: Color(0xFF90CAF9),
        ),
        useMaterial3: true,
      ),
    );
  }
}
