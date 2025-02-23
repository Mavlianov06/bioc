import 'dart:async';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int result = 0;
  Timer? decrementTimer;
  Timer? holdTimer;
  double rocketSpeed = 1.0;
  double rocketPosition = 0.0;

  void startIncrement() {
    holdTimer?.cancel();
    holdTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        result += 1;
        rocketSpeed = 1 + result / 100;
        rocketPosition -= 5;
      });
    });
  }

  void stopIncrement() {
    holdTimer?.cancel();
    startDecrement();
  }

  void startDecrement() {
    decrementTimer?.cancel();
    decrementTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        if (result > 1000) {
          result -= 1000;
        } else {
          result = 0;
        }
        rocketSpeed = 1 + result / 100;
        rocketPosition = 0;
      });
    });
  }

  @override
  void dispose() {
    holdTimer?.cancel();
    decrementTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: (100 / rocketSpeed).round()),
                    transform: Matrix4.translationValues(0, rocketPosition, 0),
                    child: const Icon(
                      Icons.rocket_launch,
                      size: 50,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text('$result', style: const TextStyle(fontSize: 30)),
              GestureDetector(
                onLongPress: startIncrement,
                onLongPressUp: stopIncrement,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: startIncrement,
                  child: const Text(
                    '+',
                    style: TextStyle(fontSize: 30, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
