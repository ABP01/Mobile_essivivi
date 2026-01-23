import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../utils/logger.dart';

class RoutingService {
  static const String _osrmBaseUrl = 'https://router.project-osrm.org/route/v1/driving';

  Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    try {
      final url = '$_osrmBaseUrl/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final coordinates = data['routes'][0]['geometry']['coordinates'] as List;
          return coordinates.map((c) => LatLng(c[1].toDouble(), c[0].toDouble())).toList();
        }
      }
      return [];
    } catch (e) {
      logger.e('Routing error: $e');
      return [];
    }
  }
}
