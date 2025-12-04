import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:perplexity_clone/models/weather_info.dart';

class WeatherService {
  // Koordinat default Jakarta
  static const double lat = -6.2000;
  static const double lon = 106.8166;

  Future<WeatherInfo?> fetchWeather() async {
    final url =
        "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true";

    try {
      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final map = json.decode(res.body);
        return WeatherInfo.fromJson(map);
      }
    } catch (e) {
      print("WEATHER ERROR: $e");
    }

    return null;
  }
}
