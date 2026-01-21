import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:xml/xml.dart';

class GpxResult {
  final List<LatLng> route;
  final List<GpxWaypoint> waypoints;

  GpxResult({required this.route, required this.waypoints});
}

class GpxWaypoint {
  final LatLng point;
  final String name;

  GpxWaypoint({required this.point, required this.name});
}

class GpxService {
  // ================= LOAD GPX =================
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

  // ================= PARSER =================
  static GpxResult _parseGpx(String xmlString) {
    final document = XmlDocument.parse(xmlString);

    final List<LatLng> route = [];
    final List<GpxWaypoint> waypoints = [];

    // Track
    for (final trkpt in document.findAllElements('trkpt')) {
      final lat = double.parse(trkpt.getAttribute('lat')!);
      final lon = double.parse(trkpt.getAttribute('lon')!);
      route.add(LatLng(lat, lon));
    }

    // Waypoints
    for (final wpt in document.findAllElements('wpt')) {
      final lat = double.parse(wpt.getAttribute('lat')!);
      final lon = double.parse(wpt.getAttribute('lon')!);
      final name = wpt.getElement('name')?.text ?? 'Waypoint';
      waypoints.add(GpxWaypoint(point: LatLng(lat, lon), name: name));
    }

    return GpxResult(route: route, waypoints: waypoints);
  }
}
