import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mytodolist/mainscreen.dart';
import 'package:mytodolist/registerscreen.dart';
import 'package:http/http.dart' as http;
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadCredentials();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'), backgroundColor: Colors.blue),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 5),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text('Remember Me'),
                  SizedBox(width: 10),
                  Checkbox(
                    value: isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isChecked = value!;
                      });
                      // Handle checkbox state change
                      if (isChecked) {
                        storeCredentials();
                      } else {
                        removeCredentials();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle login logic here
                    loginUser();
                  },
                  child: const Text('Login'),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  // Navigate to register screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
                child: Text(
                  ""
                  'Don\'t have an account? Sign up',
                  style: TextStyle(
                    color: Colors.blue,
                    // decoration: TextDecoration.underline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void loginUser() {
    // TODO: implement loginUser
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    // Check if email and password are valid
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please fill all fields')));
      return;
    }
    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter a valid email')));
      return;
    }
    // TODO: implement loginUser
    // Send a POST request to the server with the email and password
    http
        .post(
          Uri.parse('http://192.168.0.145/mytodolist/php/login_user.php'),
          body: {'email': email, 'password': password},
        )
        .then((response) {
          print(response.body);
          if (response.statusCode == 200) {
            // Login successful, navigate to home screen
            var jsonResponse = jsonDecode(response.body);
            if (jsonResponse['status'] == 'success') {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Login successful')));
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainScreen()),
              );
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Login failed')));
            }
          } else {
            // Login failed, show error message
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Login failed')));
          }
        });
  }

  void storeCredentials() {
    // TODO: implement storeCredentials
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    // Store email and password in shared preferences
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please fill all fields')));
      isChecked = false;
      setState(() {});
      return;
    } else {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('email', email);
        prefs.setString('password', password);
        prefs.setBool('ischecked', isChecked);
      });
      print("ISCHECK");
      print(isChecked);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Credentials stored')));
    }
  }

  void removeCredentials() {
    // TODO: implement removeCredentials
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('email');
      prefs.remove('password');
      prefs.remove('ischecked');
    });
    emailController.clear();
    passwordController.clear();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Credentials removed')));
  }

  loadCredentials() async {
    // TODO: implement loadCredentials
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      emailController.text = prefs.getString('email') ?? '';
      passwordController.text = prefs.getString('password') ?? '';
      isChecked = prefs.getBool('ischecked') ?? false;
    });
  }
}
