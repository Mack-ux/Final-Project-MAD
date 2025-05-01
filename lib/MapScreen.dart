import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  final String location;
  final LatLng coordinates;

  const MapScreen({
    Key? key,
    required this.location,
    required this.coordinates,
  }) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final String weatherApiKey = 'e1f9fa009adb34c884f6cdeccbfb8a0c';

  // all radar layers from OpenWeatherMap
  final Map<String, String> layers = {
    'Temperature': 'temp_new',
    'Precipitation': 'precipitation_new',
    'Clouds': 'clouds_new',
    'Wind': 'wind_new',
    'Pressure': 'pressure_new',
  };

  String selectedLayer = 'temp_new';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Map - ${widget.location}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // fixed height for box of map
            SizedBox(
              height: 300,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: widget.coordinates,
                  initialZoom: 6.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.weatherly',
                  ),

                  TileLayer(
                    urlTemplate:
                        'https://tile.openweathermap.org/map/$selectedLayer/{z}/{x}/{y}.png?appid=$weatherApiKey',
                    userAgentPackageName: 'com.example.weatherly',
                  ),

                  MarkerLayer(
                    markers: [
                      Marker(
                        point: widget.coordinates,
                        width: 80,
                        height: 80,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // change radar layer based on select
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Select Layer: ', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedLayer,
                  items: layers.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.value,
                      child: Text(entry.key),
                    );
                  }).toList(),
                  onChanged: (newLayer) {
                    if (newLayer != null) {
                      setState(() => selectedLayer = newLayer);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
