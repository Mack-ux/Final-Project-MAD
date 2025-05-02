import 'package:flutter/material.dart';
import 'weather_service.dart';

class FiveDayScreen extends StatefulWidget {
  final String location;
  const FiveDayScreen({Key? key, required this.location}) : super(key: key);

  @override
  State<FiveDayScreen> createState() => _FiveDayScreenState();
}

class _FiveDayScreenState extends State<FiveDayScreen> {
  late Future<List<Map<String, String>>> _forecastFuture;

  @override
  void initState() {
    super.initState();
    _forecastFuture = WeatherService.fetchFiveDayForecast(widget.location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('5-Day Forecast - ${widget.location}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _forecastFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No forecast data found.'));
          }

          final forecast = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: forecast.length,
            itemBuilder: (context, index) {
              final dayForecast = forecast[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(dayForecast['day']!),
                  subtitle: Text(dayForecast['desc']!),
                  trailing: Text(dayForecast['temp']!),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

