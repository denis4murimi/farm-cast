import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:farmcast/constants.dart';
import 'package:farmcast/models/weather_model.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  static final String city = 'Nairobi';
  static Future<List<WeatherForecast>> fetch5DayForecast() async {
    try {
      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$city&units=metric&appid=$OPENWEATHER_API_KEY',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        //log('Weather data: $data');
        final List forecasts = data['list'];
        final dailyForecasts =
            forecasts
                .where((item) => item['dt_txt'].contains('12:00:00'))
                .map<WeatherForecast>((item) => WeatherForecast.fromJson(item))
                .toList();

        return dailyForecasts;
      } else {
        throw Exception('Failed to fetch weather data');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      throw Exception('Unexpected error occurred: \$e');
    }
  }
}
