import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  final String location;
  const MapScreen({Key? key, required this.location}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map - $location'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: const Center(child: Text('Radar Map Display Here')),
    );
  }
}
