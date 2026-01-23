import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../domain/repositories/i_location_repository.dart';

class LocationRepositoryImpl implements ILocationRepository {
  @override
  Future<bool> isLocationServiceEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<bool> requestPermissions() async {
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Services de localisation désactivés');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Permission de localisation refusée');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('Permission de localisation refusée définitivement');
      await openAppSettings();
      return false;
    }

    // Demander la permission en arrière-plan (Android)
    if (permission == LocationPermission.whileInUse) {
        // Note: Sur Android 10+, requestPermission() pour 'always' peut nécessiter une UI spécifique ou renvoyer directement le statut
        // Ici on utilise permission_handler pour l'arrière-plan si nécessaire spécifique
        var status = await Permission.locationAlways.request();
        if (!status.isGranted) {
           debugPrint('Permission arrière-plan refusée ou non sélectionnée');
        }
    }

    return true;
  }

  @override
  Future<Position?> getCurrentPosition() async {
    final hasPermission = await requestPermissions();
    if (!hasPermission) return null;

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('Erreur obtention position: $e');
      return null;
    }
  }

  @override
  Stream<Position> getPositionStream({LocationSettings? locationSettings}) {
     return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  @override
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
}
