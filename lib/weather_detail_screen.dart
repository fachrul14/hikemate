import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherDetailScreen extends StatefulWidget {
  const WeatherDetailScreen({super.key});

  @override
  State<WeatherDetailScreen> createState() => _WeatherDetailScreenState();
}

class _WeatherDetailScreenState extends State<WeatherDetailScreen> {
  // ================= CONFIG =================
  final String apiKey = "b90d953c26626c8384f67acf1efc7b4a";

  String normalizeConditionFromMain(String main) {
    switch (main.toLowerCase()) {
      case 'clear':
        return 'Cerah';
      case 'clouds':
        return 'Berawan';
      case 'rain':
      case 'drizzle':
        return 'Hujan';
      case 'thunderstorm':
        return 'Badai';
      case 'mist':
      case 'fog':
      case 'haze':
        return 'Berkabut';
      default:
        return 'Tidak diketahui';
    }
  }

  String windDirectionFromDegree(int degree) {
    if (degree < 0) return "-";

    const directions = [
      "Utara",
      "Timur Laut",
      "Timur",
      "Tenggara",
      "Selatan",
      "Barat Daya",
      "Barat",
      "Barat Laut"
    ];

    final index = ((degree + 22.5) ~/ 45) % 8;
    return directions[index];
  }

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
  double altitude = 0;

  Future<void> _onRefresh() async {
    await fetchWeather();
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
      desiredAccuracy: LocationAccuracy.lowest, // 🔥 PERUBAHAN (lebih cepat)
      timeLimit: const Duration(seconds: 5), // 🔥 PERUBAHAN
    );

    lat = position.latitude;
    lon = position.longitude;
    altitude = position.altitude;
  }

  // ================= ADDRESS =================
  Future<void> _getAddress() async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lon)
          .timeout(const Duration(seconds: 3));

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        fullAddress = [
          p.subLocality,
          p.locality,
          p.subAdministrativeArea,
          p.administrativeArea,
          p.country,
        ].where((e) => e != null && e!.isNotEmpty).join(", ");
      } else {
        fullAddress =
            "Lat: ${lat.toStringAsFixed(4)}, Lon: ${lon.toStringAsFixed(4)}";
      }
    } catch (e) {
      debugPrint("GEOCODING FAILED: $e");
      fullAddress =
          "Lat: ${lat.toStringAsFixed(4)}, Lon: ${lon.toStringAsFixed(4)}";
    }

    if (mounted) {
      setState(() {});
    }
  }

  // ================= CACHE =================
  Future<void> saveCache() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('temperature', temperature);
    prefs.setDouble('feelsLike', feelsLike);
    prefs.setInt('humidity', humidity);
    prefs.setInt('pressure', pressure);
    prefs.setDouble('windSpeed', windSpeed);
    prefs.setInt('windDegree', windDegree);
    prefs.setInt('visibility', visibility);
    prefs.setInt('cloudiness', cloudiness);
    prefs.setString('condition', condition);
    prefs.setString('weatherMain', weatherMain);
    prefs.setString('weatherIcon', weatherIcon);
    prefs.setString('address', fullAddress);
    prefs.setDouble('altitude', altitude);
  }

  Future<bool> loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('temperature')) return false;
    if (!mounted) return false;

    setState(() {
      temperature = prefs.getDouble('temperature') ?? 0;
      feelsLike = prefs.getDouble('feelsLike') ?? 0;
      humidity = prefs.getInt('humidity') ?? 0;
      pressure = prefs.getInt('pressure') ?? 0;
      windSpeed = prefs.getDouble('windSpeed') ?? 0;
      windDegree = prefs.getInt('windDegree') ?? 0;
      visibility = prefs.getInt('visibility') ?? 0;
      cloudiness = prefs.getInt('cloudiness') ?? 0;
      condition = prefs.getString('condition') ?? "-";
      weatherMain = prefs.getString('weatherMain') ?? "";
      weatherIcon = prefs.getString('weatherIcon') ?? "01d";
      fullAddress = prefs.getString('address') ?? "-";
      altitude = prefs.getDouble('altitude') ?? 0;
      isLoading = false; // 🔥 PERUBAHAN
    });

    return true;
  }

  // ================= FETCH WEATHER =================
  Future<void> fetchWeather() async {
    try {
      await _getLocation();

      final url = "https://api.openweathermap.org/data/2.5/weather"
          "?lat=$lat&lon=$lon"
          "&units=metric"
          "&lang=id"
          "&appid=$apiKey";

      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));

      final data = json.decode(response.body);
      if (!mounted) return;

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
        fullAddress =
            "Lat: ${lat.toStringAsFixed(4)}, Lon: ${lon.toStringAsFixed(4)}";
      });

      saveCache();

      _getAddress().then((_) {
        if (mounted) setState(() {});
      });
    } catch (e) {
      debugPrint("OFFLINE MODE: $e");
      await loadCache();
    }
  }

  @override
  void initState() {
    super.initState();
    loadCache();
    fetchWeather();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: isLoading
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(
                    height: 300,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(
                          top: 40, bottom: 25, left: 15, right: 15),
                      decoration: BoxDecoration(
                        color: _getHeaderColor(),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(25),
                        ),
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
                                width: 40,
                                height: 40,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.terrain,
                                  color: Colors.white,
                                  size: 36,
                                ),
                              ),
                              const Spacer(),
                              const Text(
                                "Detail Cuaca",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Image.network(
                            "https://openweathermap.org/img/wn/$weatherIcon@4x.png",
                            width: 60,
                            height: 60,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "${temperature.toStringAsFixed(1)} ℃",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                normalizeConditionFromMain(weatherMain),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                condition,
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            fullAddress == "-"
                                ? "Mengambil lokasi..."
                                : fullAddress,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    _weatherCard([
                      _buildWeatherRow(
                          Icons.thermostat, "Terasa", "$feelsLike ℃"),
                      _buildWeatherRow(Icons.air, "Angin", "$windSpeed m/s"),
                      _buildWeatherRow(
                          Icons.water_drop, "Kelembapan", "$humidity %"),
                      _buildWeatherRow(Icons.speed, "Tekanan", "$pressure hPa"),
                      _buildWeatherRow(
                        Icons.remove_red_eye,
                        "Visibility",
                        "${(visibility / 1000).toStringAsFixed(1)} km",
                      ),
                      _buildWeatherRow(
                          Icons.cloud, "Cloudiness", "$cloudiness %"),
                      _buildWeatherRow(
                        Icons.navigation,
                        "Arah Angin",
                        "${windDirectionFromDegree(windDegree)} ($windDegree°)",
                      ),
                    ]),
                  ],
                ),
              ),
      ),
    );
  }

  Color _getHeaderColor() {
    switch (weatherMain.toLowerCase()) {
      case 'clear':
        return const Color(0xFF0097B2);
      case 'clouds':
        return const Color(0xFF607D8B);
      case 'rain':
      case 'drizzle':
      case 'thunderstorm':
        return const Color(0xFF455A64);
      default:
        return const Color(0xFF0097B2);
    }
  }

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
