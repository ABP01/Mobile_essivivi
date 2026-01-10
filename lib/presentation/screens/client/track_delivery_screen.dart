import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:essivi_mobile/theme/app_colors.dart';
import 'package:essivi_mobile/data/repositories/logistics_repository.dart';
import 'package:essivi_mobile/services/phone_service.dart';

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
  GoogleMapController? _mapController;
  final _logisticsRepo = LogisticsRepository();
  
  Timer? _locationTimer;
  double? _agentLatitude;
  double? _agentLongitude;
  double? _distance;
  int? _estimatedTime;
  bool _isLoading = true;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _mapController?.dispose();
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
      final agentLocation = locations.firstWhere(
        (loc) => loc['agent_id'] == widget.agentId,
        orElse: () => {},
      );

      if (agentLocation.isNotEmpty && mounted) {
        setState(() {
          _agentLatitude = agentLocation['latitude'];
          _agentLongitude = agentLocation['longitude'];
          _isLoading = false;
        });

        _updateMapMarkers();
        _calculateDistance();
      }
    } catch (e) {
      print('Erreur mise à jour position: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _updateMapMarkers() {
    _markers.clear();

    // Marqueur client
    if (widget.clientLatitude != null && widget.clientLongitude != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('client'),
          position: LatLng(widget.clientLatitude!, widget.clientLongitude!),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'Votre position'),
        ),
      );
    }

    // Marqueur agent
    if (_agentLatitude != null && _agentLongitude != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('agent'),
          position: LatLng(_agentLatitude!, _agentLongitude!),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(title: widget.agentName),
        ),
      );

      // Ligne entre client et agent
      if (widget.clientLatitude != null && widget.clientLongitude != null) {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: [
              LatLng(widget.clientLatitude!, widget.clientLongitude!),
              LatLng(_agentLatitude!, _agentLongitude!),
            ],
            color: AppColors.primary,
            width: 3,
            patterns: [PatternItem.dash(20), PatternItem.gap(10)],
          ),
        );
      }
    }

    // Centrer la carte
    if (_mapController != null && _markers.length == 2) {
      _fitMapToMarkers();
    }
  }

  void _fitMapToMarkers() {
    if (_agentLatitude == null || widget.clientLatitude == null) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        _agentLatitude! < widget.clientLatitude! ? _agentLatitude! : widget.clientLatitude!,
        _agentLongitude! < widget.clientLongitude! ? _agentLongitude! : widget.clientLongitude!,
      ),
      northeast: LatLng(
        _agentLatitude! > widget.clientLatitude! ? _agentLatitude! : widget.clientLatitude!,
        _agentLongitude! > widget.clientLongitude! ? _agentLongitude! : widget.clientLongitude!,
      ),
    );

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100),
    );
  }

  void _calculateDistance() {
    if (_agentLatitude == null || widget.clientLatitude == null) return;

    final distanceInMeters = Geolocator.distanceBetween(
      widget.clientLatitude!,
      widget.clientLongitude!,
      _agentLatitude!,
      _agentLongitude!,
    );

    setState(() {
      _distance = distanceInMeters / 1000; // Convertir en km
      // Estimation: 20 km/h en moyenne en ville
      _estimatedTime = ((distanceInMeters / 1000) / 20 * 60).round();
    });
  }

  Future<void> _callAgent() async {
    try {
      await PhoneService.makeCall(widget.agentPhone);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Impossible d\'appeler le livreur',
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
    return Scaffold(
      backgroundColor: AppColors.background,
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
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          widget.clientLatitude ?? 6.1319,
                          widget.clientLongitude ?? 1.2228,
                        ),
                        zoom: 14,
                      ),
                      markers: _markers,
                      polylines: _polylines,
                      onMapCreated: (controller) {
                        _mapController = controller;
                        if (_markers.length == 2) {
                          _fitMapToMarkers();
                        }
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: false,
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
                          color: Colors.black.withValues(alpha: 0.05),
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
                                color: AppColors.primary.withValues(alpha: 0.1),
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
                              'Appeler le Livreur',
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
