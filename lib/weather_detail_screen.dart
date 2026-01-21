import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class WeatherDetailScreen extends StatefulWidget {
  const WeatherDetailScreen({super.key});

  @override
  State<WeatherDetailScreen> createState() => _WeatherDetailScreenState();
}

class _WeatherDetailScreenState extends State<WeatherDetailScreen> {
  // ================= CONFIG =================
  final String apiKey = "b90d953c26626c8384f67acf1efc7b4a";

  bool isLoading = true;

  String fullAddress = "-";
  int visibility = 0;
  int cloudiness = 0;
  int windDegree = 0;

  // ================= WEATHER DATA =================
  double temperature = 0;
  double feelsLike = 0;
  String condition = "-";
  String weatherMain = "";
  String weatherIcon = "01d";
  double windSpeed = 0;
  int humidity = 0;
  int pressure = 0;

  // ================= LOCATION =================
  double lat = 0;
  double lon = 0;

  // ================= ICON LOGIC =================
  IconData getWeatherIcon() {
    switch (weatherMain.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
      case 'drizzle':
        return Icons.grain;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'snow':
        return Icons.ac_unit;
      case 'mist':
      case 'fog':
      case 'haze':
        return Icons.blur_on;
      default:
        return Icons.cloud_queue;
    }
  }

  Color getHeaderColor() {
    switch (weatherMain.toLowerCase()) {
      case 'clear':
        return const Color(0xFF0097B2); // Biru cerah
      case 'clouds':
        return const Color(0xFF607D8B); // Biru keabu
      case 'rain':
      case 'drizzle':
      case 'thunderstorm':
        return const Color(0xFF455A64); // Abu gelap
      case 'snow':
        return const Color(0xFF81D4FA); // Biru muda
      case 'mist':
      case 'fog':
      case 'haze':
        return const Color(0xFF9E9E9E); // Abu muda
      default:
        return const Color(0xFF0097B2);
    }
  }

  // ================= GPS =================
  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception("GPS tidak aktif");

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Izin lokasi ditolak permanen");
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    lat = position.latitude;
    lon = position.longitude;
  }

  // ================= ADDRESS =================
  Future<void> _getAddress() async {
    final placemarks = await placemarkFromCoordinates(lat, lon);

    if (placemarks.isNotEmpty) {
      final p = placemarks.first;

      fullAddress = [
        p.subLocality,
        p.locality,
        p.subAdministrativeArea,
        p.administrativeArea,
        p.country,
      ].where((e) => e != null && e!.isNotEmpty).join(", ");
    }
  }

  // ================= FETCH WEATHER =================
  Future<void> fetchWeather() async {
    try {
      await _getLocation();
      await _getAddress();

      final url = "https://api.openweathermap.org/data/2.5/weather"
          "?lat=$lat&lon=$lon"
          "&units=metric"
          "&lang=id"
          "&appid=$apiKey";

      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return;

      final data = json.decode(response.body);

      setState(() {
        temperature = (data['main']['temp'] ?? 0).toDouble();
        feelsLike = (data['main']['feels_like'] ?? 0).toDouble();
        humidity = data['main']['humidity'] ?? 0;
        pressure = data['main']['pressure'] ?? 0;
        windSpeed = (data['wind']['speed'] ?? 0).toDouble();
        windDegree = data['wind']?['deg'] ?? 0;
        visibility = data['visibility'] ?? 0;
        cloudiness = data['clouds']?['all'] ?? 0;
        condition = data['weather'][0]['description'] ?? "-";
        weatherMain = data['weather'][0]['main'] ?? "";
        weatherIcon = data['weather'][0]['icon'] ?? "01d";

        isLoading = false;
      });
    } catch (e) {
      debugPrint("ERROR: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // ================= HEADER =================
                  Container(
                    padding: const EdgeInsets.only(
                        top: 40, bottom: 25, left: 15, right: 15),
                    decoration: BoxDecoration(
                      color: getHeaderColor(),
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(25)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Image.asset(
                              "assets/images/logo.png",
                              width: 45,
                              height: 45,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.terrain,
                                      color: Colors.white, size: 40),
                            ),
                            const Spacer(),
                            const Text(
                              "Detail Cuaca",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Image.network(
                          "https://openweathermap.org/img/wn/$weatherIcon@4x.png",
                          width: 60,
                          height: 60,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.cloud, size: 50),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "${temperature.toStringAsFixed(1)} ℃",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          condition,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          fullAddress,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ================= DETAIL CARD =================
                  _weatherCard([
                    _buildWeatherRow(
                        Icons.thermostat, "Terasa", "$feelsLike ℃"),
                    _buildWeatherRow(Icons.air, "Angin", "$windSpeed m/s"),
                    _buildWeatherRow(
                        Icons.water_drop, "Kelembapan", "$humidity %"),
                    _buildWeatherRow(Icons.speed, "Tekanan", "$pressure hPa"),
                    _buildWeatherRow(Icons.remove_red_eye, "Visibility",
                        "${(visibility / 1000).toStringAsFixed(1)} km"),
                    _buildWeatherRow(
                        Icons.cloud, "Cloudiness", "$cloudiness %"),
                    _buildWeatherRow(
                        Icons.navigation, "Arah Angin", "$windDegree°"),
                  ]),
                ],
              ),
            ),
    );
  }

  // ================= COMPONENT =================
  Widget _weatherCard(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black),
          boxShadow: const [
            BoxShadow(color: Colors.black26, offset: Offset(4, 4))
          ],
        ),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildWeatherRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0097B2)),
          const SizedBox(width: 15),
          Text(label,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
