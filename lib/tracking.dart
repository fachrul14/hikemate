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
  // ================= KONSTANTA =================
  static const double MIN_MOVE_DISTANCE = 8;
  static const double MAX_ACCURACY = 20;
  static const double ELEVATION_THRESHOLD = 3;
  static const double STEP_LENGTH = 0.75;
  static const Duration SAVE_POINT_INTERVAL = Duration(seconds: 5);

  // ================= MAP =================
  final MapController _mapController = MapController();

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

  bool _isDisposed = false;

  // ================= INIT =================
  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    _init();
  }

  Future<void> _init() async {
    await _createTrackingSession();
    await _initLocation();
  }

  @override
  void dispose() {
    _isDisposed = true;
    positionStream?.cancel();
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

      if (!_isDisposed) trackingSessionId = res['id'];
    } catch (_) {}
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
    } catch (_) {}
  }

  // ================= LOCATION =================
  Future<void> _initLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (!mounted || _isDisposed) return;

    currentPosition = LatLng(pos.latitude, pos.longitude);
    trackedRoute.add(currentPosition!);
    currentElevation = pos.altitude;
    elevationData.add(currentElevation);

    setState(() {});

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) _mapController.move(currentPosition!, 16);
    });

    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
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

    trackingDuration = DateTime.now().difference(startTime);

    currentSpeedKmh = pos.speed > 0 ? pos.speed * 3.6 : 0;
    avgSpeedKmh = trackingDuration.inSeconds > 0
        ? (totalDistance / 1000) / (trackingDuration.inSeconds / 3600)
        : 0;

    trackedRoute.add(newPoint);
    currentPosition = newPoint;
    currentElevation = pos.altitude;
    elevationData.add(currentElevation);
    currentSteps = (totalDistance / STEP_LENGTH).round();

    if (mounted) setState(() {});
    if (!_isDisposed) _mapController.move(newPoint, _mapController.camera.zoom);

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
    if (_isDisposed || trackingSessionId == null) return;

    try {
      await supabase.from('tracking_points').insert({
        'session_id': trackingSessionId,
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        'elevation': pos.altitude,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    if (currentPosition == null) {
      return Scaffold(
        body: Column(
          children: [
            _header(),
            const Expanded(child: Center(child: CircularProgressIndicator())),
          ],
        ),
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color.fromARGB(255, 0, 133, 234),
        icon: const Icon(Icons.flag),
        label: const Text("Akhiri Pendakian"),
        onPressed: () async {
          await _safeEndSession();
          if (mounted) Navigator.pop(context);
        },
      ),
      body: Column(
        children: [
          _header(),
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

  Widget _header() {
    return const AppHeader(
      title: "Tracking Jalur dan Elevasi",
      showBack: true,
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
            child: const Text("Mode SOS"),
          ),
        ),
      ],
    );
  }

  // ================= STATS =================
  Widget _statCard(String label, String value, IconData icon) {
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

  Widget _statsSection() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        _statCard("Durasi", "${trackingDuration.inMinutes} mnt", Icons.timer),
        _statCard("Jarak", "${(totalDistance / 1000).toStringAsFixed(2)} km",
            Icons.route),
        _statCard("Langkah", "$currentSteps", Icons.directions_walk),
        _statCard(
            "Speed", "${currentSpeedKmh.toStringAsFixed(1)} km/h", Icons.speed),
        _statCard("Avg Speed", "${avgSpeedKmh.toStringAsFixed(1)} km/h",
            Icons.trending_up),
        _statCard("Elevation Gain", "${elevationGain.toStringAsFixed(0)} m",
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

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
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
            ),
          ],
        ),
      ),
    );
  }
}
