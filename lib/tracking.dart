import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'sos.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  // ================= SUPABASE =================
  final supabase = Supabase.instance.client;
  String? trackingSessionId;

  // ================= DATA =================
  final List<LatLng> trackedRoute = [];
  final List<double> elevationData = [];

  StreamSubscription<Position>? positionStream;

  double totalDistance = 0;
  double currentElevation = 0;
  LatLng? currentPosition;

  // ================= INIT =================
  @override
  void initState() {
    super.initState();
    _createTrackingSession();
    _initLocation();
  }

  @override
  void dispose() {
    _endTrackingSession();
    positionStream?.cancel();
    super.dispose();
  }

  // ================= TRACKING SESSION =================
  Future<void> _createTrackingSession() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('tracking_sessions')
        .insert({
          'user_id': user.id,
          'start_time': DateTime.now().toIso8601String(),
          'total_distance': 0,
        })
        .select()
        .single();

    trackingSessionId = response['id'];
  }

  Future<void> _endTrackingSession() async {
    if (trackingSessionId == null) return;

    await supabase.from('tracking_sessions').update({
      'end_time': DateTime.now().toIso8601String(),
      'total_distance': totalDistance,
    }).eq('id', trackingSessionId!);
  }

  // ================= LOCATION =================
  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    ).listen(_onLocationUpdate);
  }

  void _onLocationUpdate(Position pos) {
    if (trackingSessionId == null) return;

    final newPoint = LatLng(pos.latitude, pos.longitude);

    setState(() {
      if (trackedRoute.isNotEmpty) {
        totalDistance += Geolocator.distanceBetween(
          trackedRoute.last.latitude,
          trackedRoute.last.longitude,
          pos.latitude,
          pos.longitude,
        );
      }

      trackedRoute.add(newPoint);
      currentElevation = pos.altitude;
      elevationData.add(currentElevation);
      currentPosition = newPoint;
    });

    _saveTrackingPoint(pos);
  }

  Future<void> _saveTrackingPoint(Position pos) async {
    await supabase.from('tracking_points').insert({
      'session_id': trackingSessionId,
      'latitude': pos.latitude,
      'longitude': pos.longitude,
      'elevation': pos.altitude,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  const SizedBox(height: 25),
                  const Text(
                    "Grafik Elevasi",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  _elevationChart(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _header() {
    return Container(
      padding: const EdgeInsets.only(top: 30, bottom: 5, left: 10, right: 15),
      decoration: const BoxDecoration(
        color: Color(0xFF0097B2),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              "Tracking Jalur dan Elevasi",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= MAP =================
  Widget _mapSection() {
    return Stack(
      children: [
        Container(
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: FlutterMap(
            options: MapOptions(
              initialCenter: trackedRoute.isEmpty
                  ? const LatLng(-6.8, 107.0)
                  : trackedRoute.last,
              initialZoom: 16,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.hikemate',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: trackedRoute,
                    color: Colors.yellow,
                    strokeWidth: 5,
                  ),
                ],
              ),
              if (currentPosition != null)
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SosScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              "Mode SOS",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  // ================= ELEVATION CHART =================
  Widget _elevationChart() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Elevasi Saat Ini : ${currentElevation.toStringAsFixed(0)} mdpl",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
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
          ),
        ],
      ),
    );
  }
}
