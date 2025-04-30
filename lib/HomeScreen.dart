import 'package:flutter/material.dart';
import 'MainScreen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _locationController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Weather App')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Enter Location',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final location = _locationController.text.trim();
                  if (location.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainScreen(location: location),
                      ),
                    );
                  }
                },
                child: const Text('Check Weather'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
