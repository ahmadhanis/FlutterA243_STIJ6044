import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController controller1 = TextEditingController();
  String mytext = "";
  TextEditingController controller2 = TextEditingController();
  String mytext2 = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Input Output"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            const Text(
              'Welcome to Input Output App',
              style: TextStyle(fontSize: 30, color: Colors.blue),
            ),
            const Text("This is test for Input and Output"),
            //first set
            TextField(
              controller: controller1,
            ),
            ElevatedButton(
                onPressed: () {
                  mytext = controller1.text;
                  setState(() {});
                },
                child: const Text("Click Me")),
            Text(mytext),
            //second set
            TextField(
              controller: controller2,
            ),
            ElevatedButton(
                onPressed: () {
                  mytext2 = controller2.text;
                  setState(() {});
                },
                child: const Text("Click Me 2")),
            Text(mytext2)
          ],
        ),
      ),
    );
  }
}
