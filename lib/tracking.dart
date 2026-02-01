import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'sos.dart';
import 'package:hikemate/widgets/app_header.dart';

class TrackingPage extends StatefulWidget {
  final List<List<LatLng>> gpxPolylines;

  const TrackingPage({
    super.key,
    required this.gpxPolylines,
  });

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  double smoothElevation(double newValue) {
    if (elevationData.isEmpty) return newValue;

    const double alpha = 0.25; // 0.2–0.3 ideal untuk GPS
    return (elevationData.last * (1 - alpha)) + (newValue * alpha);
  }

  // ================= KONSTANTA =================
  static const double MIN_MOVE_DISTANCE = 8;
  static const double MAX_ACCURACY = 20;
  static const double ELEVATION_THRESHOLD = 3;
  static const double STEP_LENGTH = 0.75;
  static const Duration SAVE_POINT_INTERVAL = Duration(seconds: 5);
  static const double MAP_MOVE_THRESHOLD = 20;

  // ================= MAP =================
  final MapController _mapController = MapController();
  Timer? _mapMoveTimer;

  // ================= SUPABASE =================
  final supabase = Supabase.instance.client;
  String? trackingSessionId;
  bool _sessionEnded = false;

  // ================= DATA =================
  final List<LatLng> trackedRoute = [];
  final List<double> elevationData = [];
  StreamSubscription<Position>? positionStream;
  DateTime? _lastSaveTime;

  double totalDistance = 0;
  double currentElevation = 0;
  LatLng? currentPosition;

  // ================= STAT =================
  late DateTime startTime;
  Duration trackingDuration = Duration.zero;
  double currentSpeedKmh = 0;
  double avgSpeedKmh = 0;
  double elevationGain = 0;
  int currentSteps = 0;

  Timer? _durationTimer;
  bool _isDisposed = false;

  double getMinElevation() => elevationData.reduce((a, b) => a < b ? a : b);

  double getMaxElevation() => elevationData.reduce((a, b) => a > b ? a : b);

  // ================= UTIL =================
  void _safeSetState(VoidCallback fn) {
    if (mounted && !_isDisposed) {
      setState(fn);
    }
  }

  double getStepFactor() {
    if (elevationGain > 500) return 0.85;
    if (elevationGain > 200) return 0.9;
    return 1.0;
  }

  // ================= INIT =================
  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    _init();

    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _safeSetState(() {
        trackingDuration = DateTime.now().difference(startTime);
      });
    });
  }

  Future<void> _init() async {
    await _createTrackingSession();
    await _initLocation();
  }

  @override
  void dispose() {
    _isDisposed = true;
    positionStream?.cancel();
    _durationTimer?.cancel();
    _mapMoveTimer?.cancel();
    _safeEndSession();
    super.dispose();
  }

  // ================= SESSION =================
  Future<void> _createTrackingSession() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final res = await supabase
          .from('tracking_sessions')
          .insert({
            'user_id': user.id,
            'start_time': DateTime.now().toIso8601String(),
            'total_distance': 0,
          })
          .select()
          .single();

      trackingSessionId = res['id'];
    } catch (e) {
      debugPrint("Create session error: $e");
    }
  }

  Future<void> _safeEndSession() async {
    if (_sessionEnded || trackingSessionId == null) return;
    _sessionEnded = true;

    try {
      await supabase.from('tracking_sessions').update({
        'end_time': DateTime.now().toIso8601String(),
        'total_distance': totalDistance,
        'steps': currentSteps,
        'elevation_gain': elevationGain,
      }).eq('id', trackingSessionId!);
    } catch (e) {
      debugPrint("End session error: $e");
    }
  }

  // ================= LOCATION =================
  Future<void> _initLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) return;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    currentPosition = LatLng(pos.latitude, pos.longitude);
    trackedRoute.add(currentPosition!);
    currentElevation = smoothElevation(pos.altitude);
    elevationData.add(currentElevation);

    _safeSetState(() {});

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) _mapController.move(currentPosition!, 16);
    });

    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen(_onLocationUpdate);
  }

  void _onLocationUpdate(Position pos) {
    if (_isDisposed || trackingSessionId == null) return;
    if (pos.accuracy > MAX_ACCURACY) return;

    final newPoint = LatLng(pos.latitude, pos.longitude);

    double distance = 0;
    if (trackedRoute.isNotEmpty) {
      distance = Geolocator.distanceBetween(
        trackedRoute.last.latitude,
        trackedRoute.last.longitude,
        pos.latitude,
        pos.longitude,
      );

      if (distance < MIN_MOVE_DISTANCE) return;
      totalDistance += distance;
    }

    final diffElev =
        elevationData.isNotEmpty ? pos.altitude - elevationData.last : 0;
    if (diffElev > ELEVATION_THRESHOLD) elevationGain += diffElev;

    currentSpeedKmh = pos.speed > 0 ? pos.speed * 3.6 : 0;
    avgSpeedKmh = trackingDuration.inSeconds > 0
        ? (totalDistance / 1000) / (trackingDuration.inSeconds / 3600)
        : 0;

    trackedRoute.add(newPoint);
    currentPosition = newPoint;
    currentElevation = pos.altitude;
    elevationData.add(currentElevation);
    currentSteps = ((totalDistance / STEP_LENGTH) * getStepFactor()).round();

    _safeSetState(() {});

    if (distance > MAP_MOVE_THRESHOLD) {
      _mapMoveTimer ??= Timer(const Duration(seconds: 2), () {
        if (!_isDisposed && currentPosition != null) {
          _mapController.move(
            currentPosition!,
            _mapController.camera.zoom,
          );
        }
        _mapMoveTimer = null;
      });
    }

    _saveTrackingPointThrottled(pos);
  }

  // ================= SAVE POINT =================
  void _saveTrackingPointThrottled(Position pos) {
    final now = DateTime.now();
    if (_lastSaveTime != null &&
        now.difference(_lastSaveTime!) < SAVE_POINT_INTERVAL) return;

    _lastSaveTime = now;
    _saveTrackingPoint(pos);
  }

  Future<void> _saveTrackingPoint(Position pos) async {
    try {
      await supabase.from('tracking_points').insert({
        'session_id': trackingSessionId,
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        'elevation': pos.altitude,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint("Save point error: $e");
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    if (currentPosition == null) {
      return Scaffold(
        body: Column(
          children: const [
            AppHeader(title: "Tracking Jalur dan Elevasi", showBack: true),
            Expanded(child: Center(child: CircularProgressIndicator())),
          ],
        ),
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color.fromARGB(255, 0, 133, 234),
        icon: const Icon(Icons.flag, color: Colors.white),
        label: const Text("Akhiri Pendakian",
            style: TextStyle(color: Colors.white)),
        onPressed: () async {
          await _safeEndSession();
          if (mounted) Navigator.pop(context);
        },
      ),
      body: Column(
        children: [
          const AppHeader(title: "Tracking Jalur dan Elevasi", showBack: true),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _mapSection(),
                  const SizedBox(height: 15),
                  _statsSection(),
                  const SizedBox(height: 25),
                  const Text(
                    "Grafik Elevasi",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  _elevationChart(),
                  const SizedBox(height: 10),
                  Text(
                    "Ketinggian saat ini : ${currentElevation.toStringAsFixed(0)} mdpl",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= MAP + SOS =================
  Widget _mapSection() {
    return Stack(
      children: [
        SizedBox(
          height: 420,
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: currentPosition!,
              initialZoom: 16,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              PolylineLayer(
                polylines: [
                  ...widget.gpxPolylines.map(
                    (s) => Polyline(
                      points: s,
                      color: Colors.blue,
                      strokeWidth: 4,
                    ),
                  ),
                  Polyline(
                    points: trackedRoute,
                    color: Colors.red,
                    strokeWidth: 5,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: currentPosition!,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.person_pin_circle,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SosScreen()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              "Mode SOS",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ================= STATS =================
  Widget _statsSection() {
    Widget card(String label, String value, IconData icon) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.teal),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 11)),
          ],
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        card("Durasi", "${trackingDuration.inMinutes} mnt", Icons.timer),
        card("Jarak", "${(totalDistance / 1000).toStringAsFixed(2)} km",
            Icons.route),
        card("Langkah", "$currentSteps", Icons.directions_walk),
        card(
            "Speed", "${currentSpeedKmh.toStringAsFixed(1)} km/h", Icons.speed),
        card("Avg Speed", "${avgSpeedKmh.toStringAsFixed(1)} km/h",
            Icons.trending_up),
        card("Elevation Gain", "${elevationGain.toStringAsFixed(0)} m",
            Icons.terrain),
      ],
    );
  }

  // ================= CHART =================
  Widget _elevationChart() {
    if (elevationData.length < 2) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text("Data elevasi belum cukup")),
      );
    }

    final minY = getMinElevation() - 5;
    final maxY = getMaxElevation() + 5;

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            horizontalInterval: 10,
          ),
          borderData: FlBorderData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (elevationData.length / 5).ceilToDouble(),
                getTitlesWidget: (v, _) => Text(v.toInt().toString(),
                    style: const TextStyle(fontSize: 10)),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                reservedSize: 42,
                getTitlesWidget: (v, _) => Text("${v.toInt()} m",
                    style: const TextStyle(fontSize: 10)),
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: elevationData
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                  .toList(),
              isCurved: true,
              barWidth: 3,
              color: Colors.green,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.green.withOpacity(0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
