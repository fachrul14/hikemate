import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latlong2/latlong.dart';

class TrackingService {
  final supabase = Supabase.instance.client;

  Future<String> createSession({
    required String mountainName,
  }) async {
    final res = await supabase
        .from('tracking_sessions')
        .insert({
          'mountain_name': mountainName,
        })
        .select()
        .single();

    return res['id'];
  }

  Future<void> insertPoint({
    required String sessionId,
    required LatLng point,
    required double elevation,
  }) async {
    await supabase.from('tracking_points').insert({
      'session_id': sessionId,
      'latitude': point.latitude,
      'longitude': point.longitude,
      'elevation': elevation,
    });
  }

  Future<void> finishSession({
    required String sessionId,
    required double totalDistance,
  }) async {
    await supabase.from('tracking_sessions').update({
      'end_time': DateTime.now().toIso8601String(),
      'total_distance': totalDistance,
    }).eq('id', sessionId);
  }
}
