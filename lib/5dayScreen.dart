import 'package:flutter/material.dart';

class FiveDayScreen extends StatelessWidget {
  final String location;
  const FiveDayScreen({Key? key, required this.location}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('7-Day Forecast - $location'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days.map((day) => Text(day)).toList(),
          ),
          const SizedBox(height: 20),
          const Text('Forecast Predictions'),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
