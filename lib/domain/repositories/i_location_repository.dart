import 'package:geolocator/geolocator.dart';

abstract class ILocationRepository {
  /// Demande les permissions de localisation
  Future<bool> requestPermissions();

  /// Obtient la position actuelle
  Future<Position?> getCurrentPosition();

  /// Obtient un flux de positions
  Stream<Position> getPositionStream({LocationSettings? locationSettings});

  /// Vérifie si les services de localisation sont activés
  Future<bool> isLocationServiceEnabled();

  /// Calcule la distance entre deux points en mètres
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  );
}
