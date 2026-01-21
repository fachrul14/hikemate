import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'tracking.dart';
import 'services/gpx_service.dart';

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
  List<LatLng> gpxRoute = [];
  List<GpxWaypoint> waypoints = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGpx();
  }

  Future<void> _loadGpx() async {
    final result = await GpxService.loadGpx(widget.gpxPath);

    setState(() {
      gpxRoute = result.route;
      waypoints = result.waypoints;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ================= HEADER =================
          Container(
            padding:
                const EdgeInsets.only(top: 30, bottom: 5, left: 10, right: 15),
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
                Image.asset(
                  "assets/images/logo.png",
                  width: 45,
                  height: 45,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.terrain, color: Colors.orange, size: 30),
                ),
                Expanded(
                  child: Text(
                    widget.namaGunung,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ================= CONTENT =================
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ================= MAP =================
                        Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.all(15),
                              height: 550,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black, width: 1.5),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black,
                                      offset: Offset(4, 4)),
                                ],
                              ),
                              child: FlutterMap(
                                options: MapOptions(
                                  initialCenter: gpxRoute.first,
                                  initialZoom: 14,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName:
                                        'com.example.hikemate',
                                  ),

                                  // ===== ROUTE GPX =====
                                  PolylineLayer(
                                    polylines: [
                                      Polyline(
                                        points: gpxRoute,
                                        color: Colors.blue,
                                        strokeWidth: 4,
                                      ),
                                    ],
                                  ),

                                  // ===== MARKERS =====
                                  MarkerLayer(
                                    markers: [
                                      // Marker Puncak
                                      Marker(
                                        point: LatLng(widget.lat, widget.lng),
                                        width: 40,
                                        height: 40,
                                        child: const Icon(
                                          Icons.flag,
                                          color: Colors.red,
                                          size: 35,
                                        ),
                                      ),

                                      // Marker Waypoint (Basecamp / Pos)
                                      ...waypoints.map(
                                        (wpt) => Marker(
                                          point: wpt.point,
                                          width: 120,
                                          height: 40,
                                          child: Column(
                                            children: [
                                              const Icon(
                                                Icons.place,
                                                color: Colors.green,
                                                size: 20,
                                              ),
                                              Text(
                                                wpt.name,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  backgroundColor: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // ================= BUTTONS =================
                            Positioned(
                              bottom: 30,
                              right: 25,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _mapButton(
                                    icon: Icons.cloud_download,
                                    label: "Download Rute",
                                    color: const Color(0xFF4FC3F7),
                                    onTap: () async {
                                      await GpxService.saveGpxOffline(
                                        widget.gpxPath,
                                        "${widget.namaGunung}.gpx",
                                      );

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "Rute berhasil disimpan untuk offline"),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
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
                                          builder: (_) =>
                                              const TrackingScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // ================= ROUTE LIST =================
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Text(
                            "Daftar Rute",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              _routeItem(
                                "Rute GPX Resmi",
                                "${(gpxRoute.length / 1000).toStringAsFixed(1)} km",
                                "GPX",
                                const Color(0xFF00FF85),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
          ),
        ],
      ),
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
          border: Border.all(color: Colors.black, width: 1),
          boxShadow: const [
            BoxShadow(color: Colors.black26, offset: Offset(2, 2))
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _routeItem(String name, String dist, String tag, Color tagColor) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.red, size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Text(name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Text(dist),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: tagColor,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: Text(
              tag,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
