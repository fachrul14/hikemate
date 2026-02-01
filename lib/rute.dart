import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'tracking.dart';
import 'services/gpx_service.dart';
import 'package:hikemate/widgets/app_header.dart';

class RutePage extends StatefulWidget {
  final String namaGunung;
  final double lat;
  final double lng;
  final String gpxPath;

  const RutePage({
    super.key,
    required this.namaGunung,
    required this.lat,
    required this.lng,
    required this.gpxPath,
  });

  @override
  State<RutePage> createState() => _RutePageState();
}

class _RutePageState extends State<RutePage> {
  final MapController _mapController = MapController();

  bool isLoading = true;
  String? errorMessage;
  late List<Polyline> _cachedPolylines = [];

  List<List<LatLng>> gpxPolylines = [];
  List<GpxWaypoint> waypoints = [];
  double gpxDistanceKm = 0;

  @override
  void initState() {
    super.initState();
    _loadGpx();
  }

  // ================= LOAD GPX (OFFLINE FIRST) =================
  Future<void> _loadGpx() async {
    try {
      final fileName = "${widget.namaGunung}.gpx";
      GpxResult result;

      // 🔁 coba load offline dulu
      try {
        result = await GpxService.loadOfflineGpx(fileName);
      } catch (_) {
        result = await GpxService.loadGpx(widget.gpxPath);
      }

      if (!mounted) return;

      setState(() {
        gpxPolylines = result.polylines;
        waypoints = result.waypoints;
        gpxDistanceKm = result.totalDistance / 1000;

        _cachedPolylines = result.polylines
            .map(
              (segment) => Polyline(
                points: segment,
                strokeWidth: 4,
                color: Colors.blue,
              ),
            )
            .toList();

        isLoading = false;
      });

      _fitMapBounds();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = "Gagal memuat rute GPX";
      });
    }
  }

  // ================= MAP FIT =================
  void _fitMapBounds() {
    if (gpxPolylines.isEmpty) return;

    final points = gpxPolylines.expand((e) => e).toList();
    final bounds = LatLngBounds.fromPoints(points);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : Stack(
                  children: [
                    _buildMap(),
                    _buildHeader(),
                    _buildFloatingButtons(),
                    _buildBottomInfo(),
                  ],
                ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AppHeader(
        title: widget.namaGunung,
        showBack: true,
        onBack: () => Navigator.pop(context),
      ),
    );
  }

  // ================= MAP =================
  Widget _buildMap() {
    return GpxMap(
      mapController: _mapController,
      polylines: _cachedPolylines,
      waypoints: waypoints,
      lat: widget.lat,
      lng: widget.lng,
    );
  }

  // ================= FLOATING BUTTON =================
  Widget _buildFloatingButtons() {
    return Positioned(
      right: 20,
      bottom: 140,
      child: Column(
        children: [
          _mapButton(
            icon: Icons.cloud_download,
            label: "Download",
            color: Colors.blue,
            onTap: () async {
              try {
                await GpxService.saveGpxOffline(
                  widget.gpxPath,
                  "${widget.namaGunung}.gpx",
                );

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Rute disimpan offline")),
                );
              } catch (e) {
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Gagal menyimpan rute")),
                );
              }
            },
          ),
          const SizedBox(height: 10),
          _mapButton(
            icon: Icons.location_on,
            label: "Mulai Tracking",
            color: const Color(0xFF0097B2),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TrackingPage(
                    gpxPolylines: gpxPolylines,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ================= BOTTOM INFO =================
  Widget _buildBottomInfo() {
    return DraggableScrollableSheet(
      initialChildSize: 0.12,
      minChildSize: 0.12,
      maxChildSize: 0.35,
      builder: (_, controller) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
          ),
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              _routeItem(
                "Rekomendasi Rute",
                "${gpxDistanceKm.toStringAsFixed(2)} km",
                "GPX",
                const Color(0xFF00FF85),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= COMPONENT =================
  Widget _mapButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black26, offset: Offset(2, 2))
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _routeItem(String name, String dist, String tag, Color tagColor) {
    return Row(
      children: [
        const Icon(Icons.alt_route, color: Colors.blue),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Text(dist),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: tagColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            tag,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class GpxMap extends StatelessWidget {
  final MapController mapController;
  final List<Polyline> polylines;
  final List<GpxWaypoint> waypoints;
  final double lat;
  final double lng;

  const GpxMap({
    super.key,
    required this.mapController,
    required this.polylines,
    required this.waypoints,
    required this.lat,
    required this.lng,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: const MapOptions(
        initialZoom: 13,
        keepAlive: true,
        interactionOptions: InteractionOptions(
          flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.hikemate',
        ),

        /// ROUTE
        PolylineLayer(polylines: polylines),

        /// MARKER
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(lat, lng),
              width: 40,
              height: 40,
              child: const Icon(Icons.flag, color: Colors.red, size: 35),
            ),
            ...waypoints.take(50).map(
                  (wpt) => Marker(
                    point: wpt.point,
                    width: 120,
                    height: 40,
                    child: Column(
                      children: [
                        const Icon(Icons.place, color: Colors.green, size: 18),
                        Text(
                          wpt.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ],
    );
  }
}
