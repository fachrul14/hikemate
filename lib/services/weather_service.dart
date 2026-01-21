import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class WeatherService {
  final String apiKey = "b90d953c26626c8384f67acf1efc7b4a";

  Future<Map<String, dynamic>> getCurrentWeather() async {
    // LOCATION
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final url = "https://api.openweathermap.org/data/2.5/weather"
        "?lat=${position.latitude}"
        "&lon=${position.longitude}"
        "&units=metric"
        "&lang=id"
        "&appid=$apiKey";

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    return {
      "temp": data['main']['temp'],
      "condition": data['weather'][0]['description'],
      "main": data['weather'][0]['main'],
      "icon": data['weather'][0]['icon'],
    };
  }
}
