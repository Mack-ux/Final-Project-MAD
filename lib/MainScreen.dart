import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'MapScreen.dart';
import '5dayScreen.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainScreen extends StatefulWidget {
  final String location;
  const MainScreen({Key? key, required this.location}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late Future<Map<String, dynamic>> _weatherFuture;
  final String apiKey = 'e1f9fa009adb34c884f6cdeccbfb8a0c';
  final TextEditingController _reportController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _weatherFuture = fetchWeatherAndForecast(widget.location);
  }

  // geocoding function to fetch coordinates for any city
  Future<LatLng?> fetchCoordinates(String location) async {
    final url =
        'https://api.openweathermap.org/geo/1.0/direct?q=$location&limit=1&appid=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        return LatLng(data[0]['lat'], data[0]['lon']);
      }
    }
    return null;
  }

  // current weather and 5day/3hour forecast from OpenWeatherMap API
  Future<Map<String, dynamic>> fetchWeatherAndForecast(String location) async {
    final currentUrl =
        'https://api.openweathermap.org/data/2.5/weather?q=$location&units=imperial&appid=$apiKey';
    final currentResponse = await http.get(Uri.parse(currentUrl));
    if (currentResponse.statusCode != 200) {
      throw Exception('Failed to load current weather');
    }

    final currentData = json.decode(currentResponse.body);
    final lat = currentData['coord']['lat'];
    final lon = currentData['coord']['lon'];

    final forecastUrl =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&units=imperial&appid=$apiKey';
    final forecastResponse = await http.get(Uri.parse(forecastUrl));
    if (forecastResponse.statusCode != 200) {
      throw Exception('Failed to load forecast data');
    }

    final forecastData = json.decode(forecastResponse.body);
    return {'current': currentData, 'forecast': forecastData['list']};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Current Weather: ${widget.location}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _weatherFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            final current = data['current'];
            final forecast = data['forecast'] as List;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // current temperature, humidity, and description
                  CurrentWeatherInfo(
                    temperature: current['main']['temp'],
                    description: current['weather'][0]['description'],
                    humidity: current['main']['humidity'],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),

                  const Text(
                    'Next 24 Hours Forecast',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // hourly forecast cards
                  SizedBox(
                    height: 180,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(8, (index) {
                          return HourlyForecastCard(data: forecast[index]);
                        }),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // refresh button
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _weatherFuture = fetchWeatherAndForecast(
                          widget.location,
                        );
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                  const SizedBox(height: 10),

                  // navigation to map
                  ElevatedButton(
                    onPressed: () async {
                      final coords = await fetchCoordinates(widget.location);
                      if (coords != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => MapScreen(
                                  location: widget.location,
                                  coordinates: coords,
                                ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Location not found')),
                        );
                      }
                    },
                    child: const Text('Map'),
                  ),
                  const SizedBox(height: 10),

                  // navigation to 5-day forecast
                  ElevatedButton(
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => FiveDayScreen(location: widget.location),
                          ),
                        ),
                    child: const Text('5-Day Forecast'),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const Text(
                    'Community Reports',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueGrey),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white.withValues(),
                    ),
                    
                    height: 250,
                    child: Column(
                      children: [
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream:
                                FirebaseFirestore.instance
                                    .collection('reports')
                                    .where('city', isEqualTo: widget.location)
                                    .orderBy('timestamp', descending: true)
                                    .limit(20)
                                    .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Text('Loading messages...');
                              }
                              final docs = snapshot.data!.docs;

                              return ListView.builder(
                                reverse: true,
                                itemCount: docs.length,
                                itemBuilder: (context, index) {
                                  final data =
                                      docs[index].data()
                                          as Map<String, dynamic>;
                                  final time =
                                      (data['timestamp'] as Timestamp).toDate();
                                  final user =
                                      data['userDisplayName'] ?? 'User';
                                  final message = data['message'] ?? '';

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 2,
                                    ),
                                    child: Text(
                                      '$user: $message (${time.hour}:${time.minute.toString().padLeft(2, '0')})',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _reportController,
                                decoration: const InputDecoration(
                                  hintText: 'Hows the weather lookin here?',
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: () async {
                                final msg = _reportController.text.trim();
                                final user = FirebaseAuth.instance.currentUser;

                                if (msg.isEmpty || user == null) return;

                                final city = widget.location.toLowerCase();

                                // check if this user has submitted a report to this city recently
                                final query =
                                    await FirebaseFirestore.instance
                                        .collection('reports')
                                        .where('userId', isEqualTo: user.uid)
                                        .where('city', isEqualTo: city)
                                        .orderBy('timestamp', descending: true)
                                        .limit(1)
                                        .get();

                                if (query.docs.isNotEmpty) {
                                  final lastTime =
                                      (query.docs.first['timestamp']
                                              as Timestamp)
                                          .toDate();
                                  final now = DateTime.now();
                                  final diff = now.difference(lastTime);

                                  if (diff.inMinutes < 30) {
                                    final wait = 30 - diff.inMinutes;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Please wait $wait more minute(s) before posting again.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                }

                                // cooldown check
                                await FirebaseFirestore.instance
                                    .collection('reports')
                                    .add({
                                      'userId': user.uid,
                                      'userDisplayName':
                                          user.displayName ??
                                          user.email ??
                                          'User',
                                      'message': msg,
                                      'city': city,
                                      'timestamp': Timestamp.now(),
                                    });

                                _reportController.clear();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data'));
          }
        },
      ),
    );
  }
}

// widget displaying current info
class CurrentWeatherInfo extends StatelessWidget {
  final double temperature;
  final String description;
  final int humidity;

  const CurrentWeatherInfo({
    Key? key,
    required this.temperature,
    required this.description,
    required this.humidity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Temperature: ${temperature.toStringAsFixed(1)}°F',
          style: const TextStyle(fontSize: 24),
        ),
        Text('Description: $description', style: const TextStyle(fontSize: 20)),
        Text('Humidity: $humidity%', style: const TextStyle(fontSize: 20)),
      ],
    );
  }
}

// widget displaying each hourly forecast card
class HourlyForecastCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const HourlyForecastCard({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final time = DateTime.fromMillisecondsSinceEpoch(data['dt'] * 1000);
    final temp = data['main']['temp'];
    final desc = data['weather'][0]['description'];

    return Container(
      width: 120,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(),
        border: Border.all(color: Colors.blueGrey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat.jm().format(time),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('${temp.toStringAsFixed(1)}°F'),
          const SizedBox(height: 4),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
