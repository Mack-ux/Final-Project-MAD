import 'package:flutter/material.dart';
import 'HomeScreen.dart';

void main() {
  runApp(const WeatherlyApp());
}

class WeatherlyApp extends StatelessWidget {
  const WeatherlyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weatherly',
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
