import 'dart:async';

import 'package:essivi_mobile/data/repositories/logistics_repository.dart';
import 'package:essivi_mobile/l10n/app_localizations.dart';
import 'package:essivi_mobile/services/phone_service.dart';
import 'package:essivi_mobile/services/routing_service.dart';
import 'package:essivi_mobile/theme/app_colors.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

class TrackDeliveryScreen extends StatefulWidget {
  final int deliveryId;
  final int agentId;
  final String agentName;
  final String agentPhone;
  final double? clientLatitude;
  final double? clientLongitude;

  const TrackDeliveryScreen({
    super.key,
    required this.deliveryId,
    required this.agentId,
    required this.agentName,
    required this.agentPhone,
    this.clientLatitude,
    this.clientLongitude,
  });

  @override
  State<TrackDeliveryScreen> createState() => _TrackDeliveryScreenState();
}

class _TrackDeliveryScreenState extends State<TrackDeliveryScreen> {
  final MapController _mapController = MapController();
  final _logisticsRepo = LogisticsRepository();
  final _routingService = RoutingService();

  Timer? _locationTimer;
  double? _agentLatitude;
  double? _agentLongitude;
  List<LatLng> _routePoints = [];
  double? _distance;
  int? _estimatedTime;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _startTracking() {
    // Charger immédiatement
    _updateAgentLocation();

    // Puis rafraîchir toutes les 5 secondes
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _updateAgentLocation();
    });
  }

  Future<void> _updateAgentLocation() async {
    try {
      final locations = await _logisticsRepo.getAgentLocations();

      if (locations.isEmpty) {
        if (mounted && _isLoading) {
          setState(() => _isLoading = false);
        }
        return;
      }

      final agentLocation = locations.firstWhere(
        (loc) => loc['agent_id'] == widget.agentId,
        orElse: () => {},
      );

      if (agentLocation.isNotEmpty && mounted) {
        final newLat = agentLocation['latitude'] as double;
        final newLng = agentLocation['longitude'] as double;

        // Only update route if location changed significantly
        bool shouldUpdateRoute =
            _agentLatitude == null ||
            (newLat - _agentLatitude!).abs() > 0.0001 ||
            (newLng - _agentLongitude!).abs() > 0.0001;

        setState(() {
          _agentLatitude = newLat;
          _agentLongitude = newLng;
          _isLoading = false;
        });

        if (shouldUpdateRoute) {
          _calculateRouteAndDistance();
        }
      } else {
        if (mounted && _isLoading) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      debugPrint('Erreur mise à jour position: $e');
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _calculateRouteAndDistance() async {
    if (_agentLatitude == null || widget.clientLatitude == null) return;

    final start = LatLng(_agentLatitude!, _agentLongitude!);
    final end = LatLng(widget.clientLatitude!, widget.clientLongitude!);

    // Get real route from OSRM
    final points = await _routingService.getRoute(start, end);

    if (mounted) {
      setState(() {
        _routePoints = points;

        // Calculate distance based on route if available, otherwise straight line
        if (points.isNotEmpty) {
          double totalDist = 0;
          for (int i = 0; i < points.length - 1; i++) {
            totalDist += Geolocator.distanceBetween(
              points[i].latitude,
              points[i].longitude,
              points[i + 1].latitude,
              points[i + 1].longitude,
            );
          }
          _distance = totalDist / 1000;
        } else {
          _distance =
              Geolocator.distanceBetween(
                widget.clientLatitude!,
                widget.clientLongitude!,
                _agentLatitude!,
                _agentLongitude!,
              ) /
              1000;
        }

        // Estimation based on distance
        _estimatedTime = (_distance! / 20 * 60).round();
      });
    }
  }

  Future<void> _callAgent() async {
    try {
      await PhoneService.makeCall(widget.agentPhone);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.callError('le livreur'),
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Default center if no coordinates
    final center = LatLng(
      widget.clientLatitude ?? 6.1319,
      widget.clientLongitude ?? 1.2228,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Suivi de Livraison',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Column(
              children: [
                // Carte
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: center,
                        initialZoom: 14.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.essivivi.water',
                        ),
                        // Route Line
                        if (_routePoints.isNotEmpty)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: _routePoints,
                                strokeWidth: 4.0,
                                color: AppColors.primary,
                              ),
                            ],
                          )
                        else if (widget.clientLatitude != null &&
                            widget.clientLongitude != null &&
                            _agentLatitude != null &&
                            _agentLongitude != null)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: [
                                  LatLng(
                                    widget.clientLatitude!,
                                    widget.clientLongitude!,
                                  ),
                                  LatLng(_agentLatitude!, _agentLongitude!),
                                ],
                                strokeWidth: 3.0,
                                color: AppColors.primary.withOpacity(0.5),
                                pattern: const StrokePattern.dotted(),
                              ),
                            ],
                          ),
                        // Markers
                        MarkerLayer(
                          markers: [
                            // Client Marker
                            if (widget.clientLatitude != null &&
                                widget.clientLongitude != null)
                              Marker(
                                point: LatLng(
                                  widget.clientLatitude!,
                                  widget.clientLongitude!,
                                ),
                                width: 50,
                                height: 50,
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            // Agent Marker
                            if (_agentLatitude != null &&
                                _agentLongitude != null)
                              Marker(
                                point: LatLng(
                                  _agentLatitude!,
                                  _agentLongitude!,
                                ),
                                width: 50,
                                height: 50,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.delivery_dining,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Informations
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Agent Info
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                FluentIcons.person_24_filled,
                                color: AppColors.primary,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.agentName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textMain,
                                    ),
                                  ),
                                  Text(
                                    'Votre livreur',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Distance et Temps
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                icon: FluentIcons.location_24_regular,
                                label: 'Distance',
                                value: _distance != null
                                    ? '${_distance!.toStringAsFixed(1)} km'
                                    : '-- km',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInfoCard(
                                icon: FluentIcons.clock_24_regular,
                                label: 'Arrivée',
                                value: _estimatedTime != null
                                    ? '~$_estimatedTime min'
                                    : '-- min',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Bouton Appeler
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _callAgent,
                            icon: const Icon(FluentIcons.call_24_filled),
                            label: Text(
                              AppLocalizations.of(context)!.callDriver,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
        ],
      ),
    );
  }
}
