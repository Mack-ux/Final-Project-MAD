import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'MapScreen.dart';
import '5dayScreen.dart';
import 'package:intl/intl.dart';

class MainScreen extends StatefulWidget {
  final String location;
  const MainScreen({Key? key, required this.location}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late Future<Map<String, dynamic>> _weatherFuture;
  final String apiKey = 'apikeyhere';

  @override
  void initState() {
    super.initState();
    _weatherFuture = fetchWeatherAndForecast(widget.location);
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
                        _weatherFuture = fetchWeatherAndForecast(widget.location);
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                  const SizedBox(height: 10),

                  // navigation to map
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MapScreen(location: widget.location),
                      ),
                    ),
                    child: const Text('Map'),
                  ),
                  const SizedBox(height: 10),

                  // navigation to 5-day forecast
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FiveDayScreen(location: widget.location),
                      ),
                    ),
                    child: const Text('5-Day Forecast'),
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

/// widget displaying current info
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

/// widget displaying each hourly forecast card
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
        color: Colors.white.withOpacity(0.05),
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
