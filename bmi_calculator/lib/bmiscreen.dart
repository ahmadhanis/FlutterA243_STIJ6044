import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class BMIScreen extends StatefulWidget {
  const BMIScreen({super.key});

  @override
  State<BMIScreen> createState() => BMIScreenState();
}

class BMIScreenState extends State<BMIScreen> {
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  String desc = "NA";
  double bmi = 0.0;
  final player = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text("BMI Calculator"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                decoration: InputDecoration(labelText: "Height (meter)"),
                controller: heightController,
              ),
              TextField(
                decoration: InputDecoration(labelText: "Weight (kg)"),
                controller: weightController,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: calculateBMI,
                child: Text("Calculate BMI"),
              ),
              SizedBox(height: 16),
              Text(
                "BMI Result : ${bmi.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 24),
              ),
              Text(desc),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void calculateBMI() {
    // TODO: implement calculateBMI
    //input
    double height = double.parse(heightController.text);
    double weight = double.parse(weightController.text);
    //process
    bmi = weight / (height * height);
    if (bmi < 18.5) {
      desc = "Underweight";
      player.play(AssetSource('sounds/sad.mp3'));
    } else if (bmi >= 18.5 && bmi <= 24.9) {
      desc = "Normal Weight";
      player.play(AssetSource('sounds/win.mp3'));
    } else if (bmi >= 25 && bmi <= 29.9) {
      desc = "Overweight";
      player.play(AssetSource('sounds/sad.mp3'));
    } else {
      desc = "Obese";
      player.play(AssetSource('sounds/sad.mp3'));
    }
    //output
    setState(() {});
  }
}
