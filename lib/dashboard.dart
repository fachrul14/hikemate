import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'weather_detail_screen.dart';
import 'services/weather_service.dart';
import 'package:hikemate/widgets/app_header.dart';
import 'package:shared_preferences/shared_preferences.dart';

final supabase = Supabase.instance.client;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final WeatherService weatherService = WeatherService();

  String username = '';
  bool isLoading = true;
  late RealtimeChannel? _profileChannel;

  bool isLoadingWeather = true;
  double temperature = 0;
  String condition = "-";
  String weatherMain = "";
  String weatherIcon = '';
  String weatherStatus = "Aman";
  Color weatherStatusColor = Colors.green;
  String todayQuote = "Memuat pesan hari ini...";
  bool isLoadingQuote = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
    _fetchProfile();
    _listenProfileChanges();
    _loadDailyQuoteFromSupabase();
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return "Selamat pagi ";
    if (hour < 15) return "Selamat siang ";
    if (hour < 18) return "Selamat sore ";
    return "Selamat malam ";
  }

  @override
  void dispose() {
    if (_profileChannel != null) {
      supabase.removeChannel(_profileChannel!);
    }
    super.dispose();
  }

  void _listenProfileChanges() {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      _profileChannel = supabase
          .channel('profile-changes')
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'profiles',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'id',
              value: user.id,
            ),
            callback: (payload) {
              final newUsername = payload.newRecord['username'];
              if (newUsername != null && mounted) {
                setState(() {
                  username = newUsername;
                });
              }
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint("REALTIME DISABLED (OFFLINE): $e");
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
      isLoadingWeather = true;
    });

    await Future.wait([
      _fetchProfile(),
      _loadWeather(),
    ]);
  }

  Future<void> _loadWeather() async {
    try {
      final data = await weatherService.getCurrentWeather();

      if (!mounted) return;

      setState(() {
        temperature = data['temp'].toDouble();
        condition = data['condition'];
        weatherMain = data['main'];
        weatherIcon = data['icon'];

        _determineWeatherStatus();
        isLoadingWeather = false;
      });
    } catch (e) {
      debugPrint("WEATHER OFFLINE: $e");

      if (!mounted) return;

      setState(() {
        condition = "Mode Offline";
        weatherIcon = "01d";
        _determineWeatherStatus();
        isLoadingWeather = false;
      });
    }
  }

  Future<void> _fetchProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await supabase
          .from('profiles')
          .select('username')
          .eq('id', user.id)
          .single();

      if (!mounted) return;

      setState(() {
        username = data['username'] ?? 'Pendaki';
        isLoading = false;
      });
    } catch (e) {
      debugPrint("PROFILE OFFLINE: $e");

      if (!mounted) return;

      setState(() {
        username = "Pendaki";
        isLoading = false;
      });
    }
  }

  Future<void> _loadDailyQuoteFromSupabase() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final savedDate = prefs.getString('quote_date');
    final savedQuote = prefs.getString('quote_text');

    //  Pakai cache kalau masih hari yang sama
    if (savedDate == today && savedQuote != null) {
      setState(() {
        todayQuote = savedQuote;
        isLoadingQuote = false;
      });
      return;
    }

    try {
      // 🔹 Ambil semua ID quote
      final List quoteList = await supabase.from('quotes').select('id');

      final int total = quoteList.length;
      if (total == 0) {
        throw Exception("Quote kosong");
      }

      // 🔹 Index harian
      final int index = DateTime.now().day % total;

      // 🔹 Ambil 1 quote berdasarkan index
      final quoteRes = await supabase
          .from('quotes')
          .select('text')
          .range(index, index)
          .single();

      final String quoteText = quoteRes['text'];

      // 🔹 Simpan cache
      await prefs.setString('quote_date', today);
      await prefs.setString('quote_text', quoteText);

      if (!mounted) return;

      setState(() {
        todayQuote = quoteText;
        isLoadingQuote = false;
      });
    } catch (e) {
      debugPrint("QUOTE OFFLINE: $e");

      if (!mounted) return;

      setState(() {
        todayQuote = "Jaga alam sebagaimana kamu menjaga rumahmu sendiri.";
        isLoadingQuote = false;
      });
    }
  }

  void _determineWeatherStatus() {
    final main = weatherMain.toLowerCase();

    if (main.contains('thunderstorm') ||
        main.contains('storm') ||
        main.contains('extreme')) {
      weatherStatus = "Bahaya";
      weatherStatusColor = Colors.red;
    } else if (main.contains('rain') ||
        main.contains('drizzle') ||
        main.contains('snow')) {
      weatherStatus = "Waspada";
      weatherStatusColor = Colors.orange;
    } else if (main.contains('clouds')) {
      weatherStatus = "Waspada";
      weatherStatusColor = Colors.orange;
    } else if (condition == "Mode Offline") {
      weatherStatus = "Waspada";
      weatherStatusColor = Colors.orange;
    } else {
      weatherStatus = "Aman";
      weatherStatusColor = Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ================= HEADER (REUSABLE) =================
          const AppHeader(
            title: "Selamat Datang di HikeMate!",
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              color: Colors.blue,
              backgroundColor: Colors.white,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLoading ? "Memuat..." : "${getGreeting()}, $username!",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    InkWell(
                      borderRadius: BorderRadius.circular(15),
                      splashColor: Colors.blue.withOpacity(0.15),
                      highlightColor: Colors.blue.withOpacity(0.05),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: weatherStatusColor
                                              .withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                              color: weatherStatusColor),
                                        ),
                                        child: Text(
                                          weatherStatus,
                                          style: TextStyle(
                                            color: weatherStatusColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
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
                                      if (condition == "Mode Offline")
                                        const Padding(
                                          padding: EdgeInsets.only(top: 2),
                                          child: Text(
                                            "Offline",
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.orange,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      _buildHikingIndicator(),
                                    ],
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Ketuk untuk melihat detail cuaca.",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      "Pesan untuk Pendaki",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildHeavyShadowCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.format_quote, size: 20),
                              SizedBox(width: 6),
                              Text(
                                "Quote Hari Ini",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "“$todayQuote”",
                            textAlign: TextAlign.justify,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildHikingIndicator() {
    IconData icon;
    String text;

    if (weatherStatus == "Aman") {
      icon = Icons.check_circle;
      text = "Layak mendaki hari ini";
    } else if (weatherStatus == "Waspada") {
      icon = Icons.warning;
      text = "Perlu kehati-hatian";
    } else {
      icon = Icons.cancel;
      text = "Tidak disarankan mendaki";
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Icon(
            icon,
            color: weatherStatusColor,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: weatherStatusColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
