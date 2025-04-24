class WeatherForecast {
  final DateTime dateTime;
  final double temperature;
  final double tempMax;
  final double tempMin;
  final double windSpeed;
  final String weatherDescription;
  final String icon;

  WeatherForecast({
    required this.dateTime,
    required this.temperature,
    required this.tempMax,
    required this.tempMin,
    required this.windSpeed,
    required this.weatherDescription,
    required this.icon,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      dateTime: DateTime.parse(json['dt_txt']),
      temperature: json['main']['temp'].toDouble(),
      tempMax: json['main']['temp_max'].toDouble(),
      tempMin: json['main']['temp_min'].toDouble(),
      windSpeed: json['wind']['speed'].toDouble(),
      weatherDescription: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
    );
  }
}
