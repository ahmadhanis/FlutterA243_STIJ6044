import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: const Text("Hello APP"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Hello World!',
                style: TextStyle(
                    fontSize: 40,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    backgroundColor: Colors.black),
              ),
              const Text("Welcome to Flutter"),
              const Text("Flutter is FUN"),
              const Text("Flutter is EASY"),
              ElevatedButton(onPressed: () {}, child: const Text("Click Me")),
              const SizedBox(
                height: 20,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("Hello World!"),
                  Text("Welcome to Flutter"),
                  Text("Flutter is FUN"),
                  Text("Flutter is EASY"),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
