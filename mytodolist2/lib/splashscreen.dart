import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mytodolist2/loginscreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    // Trigger fade-in
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    // Navigate after delay
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF90CAF9), Color(0xFF0D47A1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: AnimatedOpacity(
            duration: Duration(seconds: 1),
            opacity: _opacity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline, size: 80, color: Colors.white),
                SizedBox(height: 20),
                Text(
                  'MyTodoList',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Stay organized effortlessly',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 30),
                CircularProgressIndicator(color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
