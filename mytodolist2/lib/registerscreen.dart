import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:mytodolist2/loginscreen.dart';
import 'package:mytodolist2/myconfig.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final reenterPasswordController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWide ? 500 : double.infinity,
                ),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 35,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_add_alt_1,
                          size: 60,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Create Account",
                          style: GoogleFonts.poppins(
                            fontSize: 22 * textScale,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Register a new MyTodoList account",
                          style: GoogleFonts.poppins(fontSize: 14 * textScale),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: reenterPasswordController,
                          decoration: const InputDecoration(
                            labelText: 'Re-enter Password',
                            prefixIcon: Icon(Icons.lock_outline),
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () => registerDialog(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  )
                                : const Text('Register'),
                          ),
                        ),
                        const SizedBox(height: 15),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Already have an account? Login',
                            style: GoogleFonts.poppins(
                              fontSize: 14 * textScale,
                              color: Colors.blue[700],
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void registerDialog(BuildContext context) {
    String email = emailController.text.trim();
    String password = passwordController.text;
    String reenterPassword = reenterPasswordController.text;

    if (email.isEmpty || password.isEmpty || reenterPassword.isEmpty) {
      showSnackBar('Please fill all fields');
      return;
    }

    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,4}$').hasMatch(email)) {
      showSnackBar('Please enter a valid email');
      return;
    }

    if (password.length < 6) {
      showSnackBar('Password must be at least 6 characters');
      return;
    }

    if (password != reenterPassword) {
      showSnackBar('Passwords do not match');
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Registration'),
        content: Text('Register new account with email:\n$email'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              registerAccount(email, password);
            },
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
        ],
      ),
    );
  }

  void registerAccount(String email, String password) async {
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${MyConfig.apiUrl}register_user.php'),
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'success') {
          showSnackBar('Registration successful');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        } else {
          showSnackBar('Registration failed: ${jsonResponse['status']}');
        }
      } else {
        showSnackBar('Server error');
      }
    } catch (e) {
      showSnackBar('Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
