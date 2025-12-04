class WeatherInfo {
  final double temperature;
  final double windspeed;
  final String weatherCode;

  WeatherInfo({
    required this.temperature,
    required this.windspeed,
    required this.weatherCode,
  });

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    final current = json["current_weather"];
    return WeatherInfo(
      temperature: current["temperature"]?.toDouble(),
      windspeed: current["windspeed"]?.toDouble(),
      weatherCode: current["weathercode"].toString(),
    );
  }
}
