import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:mytodolist2/mainscreen.dart';
import 'package:mytodolist2/myconfig.dart';
import 'package:mytodolist2/registerscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isChecked = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadCredentials();
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 600;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWideScreen ? 500 : double.infinity,
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
                          Icons.check_circle_outline,
                          size: 60,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Welcome Back",
                          style: GoogleFonts.poppins(
                            fontSize: 22 * textScale,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Log in to your MyTodoList account",
                          style: GoogleFonts.poppins(fontSize: 14 * textScale),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 25),
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
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Checkbox(
                              value: isChecked,
                              onChanged: (value) {
                                setState(() => isChecked = value!);
                                if (isChecked) {
                                  storeCredentials();
                                } else {
                                  removeCredentials();
                                }
                              },
                            ),
                            const Text("Remember Me"),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : loginUser,
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
                                : const Text('Login'),
                          ),
                        ),
                        const SizedBox(height: 15),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Don\'t have an account? Sign up',
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

  void loginUser() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showSnackBar("Please fill all fields");
      return;
    }
    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,4}$').hasMatch(email)) {
      showSnackBar("Please enter a valid email");
      return;
    }

    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${MyConfig.apiUrl}login_user.php'),
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'success') {
          final userData = jsonResponse['data'][0];
          showSnackBar("Login successful");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MainScreen(
                userEmail: userData['user_email'],
                userId: userData['user_id'],
              ),
            ),
          );
        } else {
          showSnackBar("Login failed: ${jsonResponse['message'] ?? ''}");
        }
      } else {
        showSnackBar("Server error. Please try again later.");
      }
    } catch (e) {
      showSnackBar("An error occurred: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void storeCredentials() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      showSnackBar("Please fill all fields");
      setState(() => isChecked = false);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
    await prefs.setBool('ischecked', isChecked);
    showSnackBar("Credentials saved");
  }

  void removeCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('password');
    await prefs.remove('ischecked');
    emailController.clear();
    passwordController.clear();
    showSnackBar("Credentials removed");
  }

  void loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      emailController.text = prefs.getString('email') ?? '';
      passwordController.text = prefs.getString('password') ?? '';
      isChecked = prefs.getBool('ischecked') ?? false;
    });
  }
}
