import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../data/repositories/logistics_repository.dart';
import '../data/repositories/location_repository_impl.dart';
import '../domain/repositories/i_location_repository.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final LogisticsRepository _logisticsRepo = LogisticsRepository();
  final ILocationRepository _locationRepo = LocationRepositoryImpl();
  
  StreamSubscription<Position>? _positionStream;
  bool _isTracking = false;
  int? _currentAgentId;

  /// Démarre le tracking GPS pour un agent
  Future<bool> startTracking(int agentId) async {
    if (_isTracking) {
      debugPrint('Tracking déjà actif');
      return true;
    }

    // Vérifier et demander les permissions via le repo
    final hasPermission = await _locationRepo.requestPermissions();
    if (!hasPermission) {
      debugPrint('Permissions GPS refusées');
      return false;
    }

    _currentAgentId = agentId;
    _isTracking = true;

    // Configuration du tracking
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Mise à jour tous les 10 mètres
    );

    // Écouter les changements de position via le repo
    _positionStream = _locationRepo.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        _updateAgentLocation(position);
      },
      onError: (error) {
        debugPrint('Erreur tracking GPS: $error');
      },
    );

    debugPrint('Tracking GPS démarré pour agent $agentId');
    return true;
  }

  /// Arrête le tracking GPS
  Future<void> stopTracking() async {
    await _positionStream?.cancel();
    _positionStream = null;
    _isTracking = false;
    _currentAgentId = null;
    debugPrint('Tracking GPS arrêté');
  }

  /// Envoie la position actuelle au backend
  Future<void> _updateAgentLocation(Position position) async {
    if (_currentAgentId == null) return;

    try {
      await _logisticsRepo.updateAgentLocation(
        _currentAgentId!,
        position.latitude,
        position.longitude,
        position.accuracy,
        position.speed * 3.6, // Convertir m/s en km/h
        position.heading,
      );
      debugPrint('Position mise à jour: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      debugPrint('Erreur mise à jour position: $e');
    }
  }

  /// Obtient la position actuelle une seule fois
  Future<Position?> getCurrentPosition() async {
    return _locationRepo.getCurrentPosition();
  }

  /// Vérifie si le tracking est actif
  bool get isTracking => _isTracking;

  /// Obtient l'ID de l'agent en cours de tracking
  int? get currentAgentId => _currentAgentId;

  /// Calcule la distance entre deux points (en mètres)
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return _locationRepo.calculateDistance(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
}
