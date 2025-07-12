import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mytodolist2/loginscreen.dart';
import 'package:mytodolist2/myconfig.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController reenterPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Colors.blue,
      ),
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
              SizedBox(height: 5),
              TextField(
                controller: reenterPasswordController,
                decoration: InputDecoration(
                  labelText: 'Reenter Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle login logic here
                    registerDialog(context);
                  },
                  child: const Text('Register'),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text(
                  ""
                  'Already have an account? Login',
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

  void registerDialog(BuildContext context) {
    String email = emailController.text;
    String password = passwordController.text;
    String reenterPassword = reenterPasswordController.text;
    if (email.isEmpty || password.isEmpty || reenterPassword.isEmpty) {
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
    if (password != reenterPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Passwords do not match')));
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure?'),
          content: Text('Register new account with  $email'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                registerAccount(email, password);
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  /// Register a new user account to the server
  ///
  /// This function will send a POST request to the server with the
  /// provided [email] and [password]. If the response status code
  /// is 200, it will then decode the JSON response and check if
  /// the registration was successful. If it was, it will show a
  /// success message. Otherwise, it will show an error message with
  /// the status message from the server.
  void registerAccount(String email, String password) {
    // TODO: implement registerAccount
    http
        .post(
          Uri.parse('${MyConfig.apiUrl}register_user.php'),
          body: {'email': email, 'password': password},
        )
        .then((response) {
          print(response.body);
          if (response.statusCode == 200) {
            var jsonResponse = jsonDecode(response.body);
            if (jsonResponse['status'] == 'success') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Registration successful')),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Registration ${jsonResponse['status']}'),
                ),
              );
            }
          }
        });
  }
}
