import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MyBasicCalc());
  }
}

class MyBasicCalc extends StatefulWidget {
  const MyBasicCalc({super.key});

  @override
  State<MyBasicCalc> createState() => _MyBasicCalcState();
}

class _MyBasicCalcState extends State<MyBasicCalc> {
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  double result = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text('My Basic Calc'),
      ),
      body: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            TextField(controller: controller1),
            TextField(controller: controller2),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    double num1 = double.parse(controller1.text);
                    double num2 = double.parse(controller2.text);
                    result = num1 + num2;
                    setState(() {});
                    print(result);
                  },
                  child: Text('Calculate (+)'),
                ),
                ElevatedButton(
                  onPressed: () {
                    //opcode
                    double num1 = double.parse(controller1.text);
                    double num2 = double.parse(controller2.text);
                    result = num1 - num2;
                    setState(() {});
                    print(result);
                  },
                  child: Text('Calculate (-)'),
                ),
                ElevatedButton(
                  onPressed: multOperation,
                  child: Text('Calculate (*)'),
                ),
                ElevatedButton(
                  onPressed: divOperation,
                  child: Text('Calculate (/)'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Result: ${result.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }

  /// Divide the two numbers input by the user and save the result in `result`.
  /// Also, call `setState` to rebuild the UI with the new result.
  /// The result is also printed to the console for debugging purposes.
  void divOperation() {
    double num1 = double.parse(controller1.text);
    double num2 = double.parse(controller2.text);
    result = num1 / num2;
    setState(() {});
    print(result);
  }

  /// Multiply the two numbers input by the user and save the result in `result`.
  /// Also, call `setState` to rebuild the UI with the new result.
  /// The result is also printed to the console for debugging purposes.
  void multOperation() {
    double num1 = double.parse(controller1.text);
    double num2 = double.parse(controller2.text);
    result = num1 * num2;
    setState(() {});
    print(result);
  }
}
