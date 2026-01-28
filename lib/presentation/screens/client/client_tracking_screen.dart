import 'dart:async';

import 'package:essivi_mobile/data/models/sales_models.dart';
import 'package:essivi_mobile/data/repositories/logistics_repository.dart';
import 'package:essivi_mobile/services/phone_service.dart';
import 'package:essivi_mobile/services/routing_service.dart';
import 'package:essivi_mobile/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

class ClientTrackingScreen extends StatefulWidget {
  final Commande? shipmentMock;

  const ClientTrackingScreen({super.key, this.shipmentMock});

  @override
  State<ClientTrackingScreen> createState() => _ClientTrackingScreenState();
}

class _ClientTrackingScreenState extends State<ClientTrackingScreen> {
  final MapController _mapController = MapController();
  final LogisticsRepository _logisticsRepo = LogisticsRepository();
  final RoutingService _routingService = RoutingService();

  Timer? _locationTimer;
  
  // Agent position (real-time from backend)
  double? _agentLatitude;
  double? _agentLongitude;
  String _agentName = 'Agent';
  String _agentPhone = '';
  
  // Route calculation
  List<LatLng> _routePoints = [];
  double? _distance;
  int? _estimatedTime;
  bool _isLoading = true;

  // Default positions (Lomé center)
  final LatLng _defaultCenter = const LatLng(6.1319, 1.2228);
  
  Commande? _shipment;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _initializeData() {
    // Get shipment from arguments or widget
    final args = ModalRoute.of(context)?.settings.arguments;
    _shipment = args is Commande ? args : widget.shipmentMock;
    
    if (_shipment != null) {
      setState(() {
        _isLoading = false;
      });
      _startRealTimeTracking();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startRealTimeTracking() {
    // Load immediately
    _fetchAgentLocation();
    
    // Then refresh every 3 seconds for real-time tracking
    _locationTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _fetchAgentLocation();
    });
  }

  Future<void> _fetchAgentLocation() async {
    if (_shipment?.agentId == null) return;

    try {
      final locations = await _logisticsRepo.getAgentLocations();
      
      if (locations.isEmpty) return;

      // Find the agent assigned to this order
      final agentLocation = locations.firstWhere(
        (loc) => loc['agent_id'] == _shipment!.agentId,
        orElse: () => {},
      );

      if (agentLocation.isNotEmpty && mounted) {
        final newLat = agentLocation['latitude'] as double?;
        final newLng = agentLocation['longitude'] as double?;
        
        if (newLat != null && newLng != null) {
          // Check if location changed significantly
          bool shouldUpdateRoute = _agentLatitude == null ||
              (newLat - _agentLatitude!).abs() > 0.0001 ||
              (newLng - _agentLongitude!).abs() > 0.0001;

          setState(() {
            _agentLatitude = newLat;
            _agentLongitude = newLng;
            _agentName = agentLocation['agent_name'] ?? 'Agent';
            _agentPhone = agentLocation['agent_phone'] ?? '';
          });

          if (shouldUpdateRoute) {
            _calculateRouteAndDistance();
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching agent location: $e');
    }
  }

  Future<void> _calculateRouteAndDistance() async {
    if (_agentLatitude == null || _shipment?.deliveryLatitude == null) return;

    final agentPos = LatLng(_agentLatitude!, _agentLongitude!);
    final clientPos = LatLng(_shipment!.deliveryLatitude!, _shipment!.deliveryLongitude!);

    // Get real route from OSRM
    final points = await _routingService.getRoute(agentPos, clientPos);

    if (mounted) {
      setState(() {
        _routePoints = points;

        // Calculate distance
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
          _distance = Geolocator.distanceBetween(
            _shipment!.deliveryLatitude!,
            _shipment!.deliveryLongitude!,
            _agentLatitude!,
            _agentLongitude!,
          ) / 1000;
        }

        // Estimated time (assuming 20 km/h average speed)
        _estimatedTime = (_distance! / 20 * 60).round();
      });
    }
  }

  Future<void> _callAgent() async {
    if (_agentPhone.isEmpty && _shipment?.agentPhone != null) {
      _agentPhone = _shipment!.agentPhone!;
    }
    
    if (_agentPhone.isNotEmpty) {
      try {
        await PhoneService.makeCall(_agentPhone);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de l\'appel'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _getStatusText() {
    if (_shipment == null) return 'En attente';
    switch (_shipment!.statut) {
      case 'pending': return 'En attente de validation';
      case 'validated': return 'Validée - Agent en route';
      case 'en_route': return 'En cours de livraison';
      case 'arriving': return 'Arrivée imminente';
      case 'delivered': return 'Livrée';
      case 'cancelled': return 'Annulée';
      default: return _shipment!.statut;
    }
  }

  @override
  Widget build(BuildContext context) {
    final destinationLat = _shipment?.deliveryLatitude ?? _defaultCenter.latitude;
    final destinationLng = _shipment?.deliveryLongitude ?? _defaultCenter.longitude;
    
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Stack(
              children: [
                // 1. Full-screen Map
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _agentLatitude != null
                        ? LatLng(_agentLatitude!, _agentLongitude!)
                        : LatLng(destinationLat, destinationLng),
                    initialZoom: 14.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    // Route polyline
                    if (_routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            color: AppColors.primary,
                            strokeWidth: 4.0,
                          ),
                        ],
                      )
                    else if (_agentLatitude != null && _shipment?.deliveryLatitude != null)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: [
                              LatLng(_agentLatitude!, _agentLongitude!),
                              LatLng(destinationLat, destinationLng),
                            ],
                            color: AppColors.primary.withOpacity(0.5),
                            strokeWidth: 3.0,
                            pattern: const StrokePattern.dotted(),
                          ),
                        ],
                      ),
                    // Markers
                    MarkerLayer(
                      markers: [
                        // Client destination marker
                        Marker(
                          point: LatLng(destinationLat, destinationLng),
                          width: 50,
                          height: 50,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                        // Agent marker (real-time position)
                        if (_agentLatitude != null && _agentLongitude != null)
                          Marker(
                            point: LatLng(_agentLatitude!, _agentLongitude!),
                            width: 50,
                            height: 50,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.delivery_dining,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                // 2. Top Bar
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _circleButton(
                              Icons.arrow_back_ios_new,
                              () => Navigator.pop(context),
                            ),
                            Text(
                              "Suivi en Direct",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            _circleButton(
                              Icons.my_location,
                              () {
                                if (_agentLatitude != null) {
                                  _mapController.move(
                                    LatLng(_agentLatitude!, _agentLongitude!),
                                    15,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Info Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.darkSurface.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.local_shipping,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Commande #${_shipment?.id ?? 'N/A'}",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _getStatusText(),
                                        style: GoogleFonts.poppins(
                                          color: AppColors.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. Bottom Sheet with Agent info
                DraggableScrollableSheet(
                  initialChildSize: 0.35,
                  minChildSize: 0.15,
                  maxChildSize: 0.6,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Handle bar
                            Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey[600],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Agent Info Row
                            Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: AppColors.primary,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _agentName,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "Votre livreur",
                                        style: GoogleFonts.poppins(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _callAgent,
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.call,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Distance and Time info
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoCard(
                                    icon: Icons.route,
                                    label: "Distance",
                                    value: _distance != null
                                        ? "${_distance!.toStringAsFixed(1)} km"
                                        : "-- km",
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildInfoCard(
                                    icon: Icons.access_time,
                                    label: "Arrivée",
                                    value: _estimatedTime != null
                                        ? "~$_estimatedTime min"
                                        : "-- min",
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Real-time indicator
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.green.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    _agentLatitude != null
                                        ? "Position mise à jour en direct"
                                        : "En attente de position...",
                                    style: GoogleFonts.poppins(
                                      color: Colors.green,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
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
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
