import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _apiKey = 'e1f9fa009adb34c884f6cdeccbfb8a0c';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/forecast';

  static Future<List<Map<String, String>>> fetchFiveDayForecast(String location) async {
    final url = Uri.parse('$_baseUrl?q=$location&units=metric&appid=$_apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['list'];

      final Map<String, Map<String, String>> dailyForecast = {};

      for (var item in list) {
        final dateTime = DateTime.parse(item['dt_txt']);
        final day = dateTime.weekday;
        final dateKey = "${dateTime.year}-${dateTime.month}-${dateTime.day}";

        // Use only one forecast per day (e.g., the first)
        if (!dailyForecast.containsKey(dateKey)) {
          final description = item['weather'][0]['description'];
          final temp = item['main']['temp'].toStringAsFixed(1);
          dailyForecast[dateKey] = {
            'day': _weekdayName(day),
            'desc': description,
            'temp': '$temp°C',
          };
        }

        if (dailyForecast.length == 5) break;
      }

      return dailyForecast.values.toList();
    } else {
      throw Exception('Failed to load forecast');
    }
  }

  static String _weekdayName(int weekday) {
    const names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return names[weekday % 7];
  }
}
