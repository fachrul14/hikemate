import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:xml/xml.dart';

class GpxResult {
  final List<List<LatLng>> polylines;
  final List<List<double>> elevations;
  final double totalDistance;
  final List<GpxWaypoint> waypoints;

  GpxResult({
    required this.polylines,
    required this.elevations,
    required this.totalDistance,
    required this.waypoints,
  });
}

class GpxWaypoint {
  final LatLng point;
  final String name;

  GpxWaypoint({
    required this.point,
    required this.name,
  });
}

class GpxService {
  static const double _MAX_POINT_DISTANCE = 500; // meter (anti GPX rusak)
  static final Distance _distance = const Distance();

  // ================= LOAD GPX ASSET =================
  static Future<GpxResult> loadGpx(String assetPath) async {
    final xmlString = await rootBundle.loadString(assetPath);
    return _parseGpx(xmlString);
  }

  // ================= SAVE OFFLINE =================
  static Future<File> saveGpxOffline(String assetPath, String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');

    final data = await rootBundle.load(assetPath);
    await file.writeAsBytes(data.buffer.asUint8List());

    return file;
  }

  // ================= LOAD OFFLINE =================
  static Future<GpxResult> loadOfflineGpx(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');

    if (!file.existsSync()) {
      throw Exception("File GPX offline tidak ditemukan");
    }

    final xmlString = await file.readAsString();
    return _parseGpx(xmlString);
  }

  // ================= PARSER GPX =================
  static GpxResult _parseGpx(String xmlString) {
    final document = XmlDocument.parse(xmlString);

    final List<List<LatLng>> polylines = [];
    final List<List<double>> elevations = [];
    final List<GpxWaypoint> waypoints = [];

    double totalDistance = 0;

    // ===== WAYPOINT =====
    for (final wpt in document.findAllElements('wpt')) {
      final lat = double.tryParse(wpt.getAttribute('lat') ?? '');
      final lon = double.tryParse(wpt.getAttribute('lon') ?? '');
      if (lat == null || lon == null) continue;

      waypoints.add(
        GpxWaypoint(
          point: LatLng(lat, lon),
          name: wpt.getElement('name')?.text ?? 'Waypoint',
        ),
      );
    }

    // ===== TRACK SEGMENTS =====
    for (final trkseg in document.findAllElements('trkseg')) {
      final List<LatLng> segmentPoints = [];
      final List<double> segmentElevations = [];

      LatLng? lastPoint;

      for (final pt in trkseg.findElements('trkpt')) {
        final lat = double.tryParse(pt.getAttribute('lat') ?? '');
        final lon = double.tryParse(pt.getAttribute('lon') ?? '');
        if (lat == null || lon == null) continue;

        final point = LatLng(lat, lon);
        final elevation =
            double.tryParse(pt.getElement('ele')?.text ?? '') ?? 0;

        if (lastPoint != null) {
          final dist = _distance.as(
            LengthUnit.Meter,
            lastPoint,
            point,
          );

          // 🔒 Filter lonjakan GPX rusak
          if (dist > _MAX_POINT_DISTANCE) continue;

          totalDistance += dist;
        }

        segmentPoints.add(point);
        segmentElevations.add(elevation);
        lastPoint = point;
      }

      if (segmentPoints.length > 1) {
        polylines.add(segmentPoints);
        elevations.add(segmentElevations);
      }
    }

    return GpxResult(
      polylines: polylines,
      elevations: elevations,
      totalDistance: totalDistance,
      waypoints: waypoints,
    );
  }
}
