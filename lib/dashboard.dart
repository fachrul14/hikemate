import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'weather_detail_screen.dart';
import 'services/weather_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final WeatherService weatherService = WeatherService();

  String username = 'User';
  bool isLoadingProfile = true;

  bool isLoadingWeather = true;
  double temperature = 0;
  String condition = "-";
  String weatherMain = "";
  String weatherIcon = '';

  @override
  void initState() {
    super.initState();
    _loadWeather();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final data = await Supabase.instance.client
        .from('profiles')
        .select('username')
        .eq('id', user.id)
        .single();

    setState(() {
      username = data['username'] ?? 'User';
      isLoadingProfile = false;
    });
  }

  Future<void> _loadWeather() async {
    try {
      final data = await weatherService.getCurrentWeather();

      setState(() {
        temperature = data['temp'].toDouble();
        condition = data['condition'];
        weatherMain = data['main'];
        weatherIcon = data['icon'];
        isLoadingWeather = false;
      });
    } catch (e) {
      debugPrint("WEATHER ERROR: $e");
      isLoadingWeather = false;
    }
  }

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
      default:
        return Icons.cloud_queue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ================= HEADER =================
          Container(
            padding: const EdgeInsets.only(
              top: 30,
              left: 16,
              right: 16,
              bottom: 5,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF0097B2),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Image.asset(
                  "assets/images/logo.png",
                  width: 45,
                  height: 45,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.terrain, color: Colors.white, size: 40),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    "Selamat Datang di HikeMate!",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= SAPAAN =================
                  Text(
                    "Hallo, $username !",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ================= CARD CUACA =================
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WeatherDetailScreen(),
                        ),
                      );
                    },
                    child: _buildHeavyShadowCard(
                      child: isLoadingWeather
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Cuaca & Suhu Saat Ini",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "${temperature.toStringAsFixed(1)}°C",
                                      style: const TextStyle(
                                        fontSize: 45,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Image.network(
                                      "https://openweathermap.org/img/wn/$weatherIcon@2x.png",
                                      width: 60,
                                      height: 60,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.cloud, size: 50),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      condition,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ================= CARD QUOTE =================
                  _buildHeavyShadowCard(
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                      child: Text(
                        "“Alam semesta telah bekerja selama jutaan tahun untuk menciptakan keindahan yang kita nikmati hari ini; ia hanya meninggalkan kemurnian untuk kita syukuri. Maka, sudah sepatutnya kita bertamu dengan penuh hormat. Jangan biarkan kehadiranmu mengotori kesunyian hutan atau kejernihan sungai. Jangan tinggalkan apapun di sana selain jejak kaki yang akan tersapu waktu, dan jangan ambil apapun selain kenangan serta foto dalam bidikan lensa. Ingatlah bahwa plastik yang kamu bawa tidak akan pernah bisa menyatu dengan tanah. Bawa kembali sampahmu, sekecil apapun itu.”",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= CARD STYLE =================
  Widget _buildHeavyShadowCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 0,
            offset: Offset(4, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}
