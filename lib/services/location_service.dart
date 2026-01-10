import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../repositories/logistics_repository.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final LogisticsRepository _logisticsRepo = LogisticsRepository();
  StreamSubscription<Position>? _positionStream;
  bool _isTracking = false;
  int? _currentAgentId;

  /// Démarre le tracking GPS pour un agent
  Future<bool> startTracking(int agentId) async {
    if (_isTracking) {
      print('Tracking déjà actif');
      return true;
    }

    // Vérifier et demander les permissions
    final hasPermission = await _requestPermissions();
    if (!hasPermission) {
      print('Permissions GPS refusées');
      return false;
    }

    _currentAgentId = agentId;
    _isTracking = true;

    // Configuration du tracking
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Mise à jour tous les 10 mètres
    );

    // Écouter les changements de position
    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        _updateAgentLocation(position);
      },
      onError: (error) {
        print('Erreur tracking GPS: $error');
      },
    );

    print('Tracking GPS démarré pour agent $agentId');
    return true;
  }

  /// Arrête le tracking GPS
  Future<void> stopTracking() async {
    await _positionStream?.cancel();
    _positionStream = null;
    _isTracking = false;
    _currentAgentId = null;
    print('Tracking GPS arrêté');
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
      print('Position mise à jour: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('Erreur mise à jour position: $e');
    }
  }

  /// Obtient la position actuelle une seule fois
  Future<Position?> getCurrentPosition() async {
    final hasPermission = await _requestPermissions();
    if (!hasPermission) return null;

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Erreur obtention position: $e');
      return null;
    }
  }

  /// Demande les permissions de localisation
  Future<bool> _requestPermissions() async {
    // Vérifier si les services de localisation sont activés
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Services de localisation désactivés');
      return false;
    }

    // Vérifier les permissions
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Permission de localisation refusée');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Permission de localisation refusée définitivement');
      // Ouvrir les paramètres
      await openAppSettings();
      return false;
    }

    // Demander la permission en arrière-plan (Android)
    if (permission == LocationPermission.whileInUse) {
      // Pour Android 10+, demander la permission en arrière-plan
      var status = await Permission.locationAlways.request();
      if (!status.isGranted) {
        print('Permission arrière-plan refusée, tracking limité');
      }
    }

    return true;
  }

  /// Vérifie si le tracking est actif
  bool get isTracking => _isTracking;

  /// Obtient l'ID de l'agent en cours de tracking
  int? get currentAgentId => _currentAgentId;
}
