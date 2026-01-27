import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:essivi_mobile/theme/app_colors.dart';
import 'package:essivi_mobile/data/repositories/sales_repository.dart';
import 'package:essivi_mobile/data/models/sales_models.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:essivi_mobile/presentation/widgets/layout/custom_app_bar.dart';

class TrackingScreen extends StatefulWidget {
  final int? commandeId;

  const TrackingScreen({super.key, this.commandeId});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final _salesRepo = SalesRepository();
  final MapController _mapController = MapController();
  
  Commande? _commande;
  Livraison? _livraison;
  bool _isLoading = true;
  LatLng? _agentLocation;
  LatLng? _destinationLocation; // Mock or from order

  @override
  void initState() {
    super.initState();
    _loadTracking();
  }

  Future<void> _loadTracking() async {
    setState(() => _isLoading = true);
    
    try {
      if (widget.commandeId != null) {
        _commande = await _salesRepo.getCommande(widget.commandeId!);
        
        // Mock locations for demo if real data is missing
        if (_commande!.deliveryLatitude != null && _commande!.deliveryLongitude != null) {
          _destinationLocation = LatLng(_commande!.deliveryLatitude!, _commande!.deliveryLongitude!);
        } else {
           _destinationLocation = const LatLng(6.1375, 1.2125); // Lome default
        }

        // Try to find associated delivery
        final deliveries = await _salesRepo.getLivraisons();
        try {
          _livraison = deliveries.firstWhere((d) => d.commandeId == widget.commandeId);
          if (_livraison!.gpsLat != null && _livraison!.gpsLng != null) {
             _agentLocation = LatLng(_livraison!.gpsLat!, _livraison!.gpsLng!);
          } else {
             // Mock agent moving
             _agentLocation = LatLng(_destinationLocation!.latitude + 0.005, _destinationLocation!.longitude + 0.005);
          }
        } catch (e) {
          // No delivery found yet
        }
      }
    } catch (e) {
      // Handle error
      debugPrint('Error loading tracking: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _commande == null
              ? const Center(child: Text('Order not found'))
              : Stack(
                  children: [
                    // Map Layer
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _destinationLocation ?? const LatLng(6.1375, 1.2125),
                        initialZoom: 14.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.essivivi.mobile',
                        ),
                        MarkerLayer(
                          markers: [
                            // Destination
                            if (_destinationLocation != null)
                              Marker(
                                point: _destinationLocation!,
                                width: 50,
                                height: 50,
                                child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                              ),
                            // Agent
                            if (_agentLocation != null)
                              Marker(
                                point: _agentLocation!,
                                width: 40,
                                height: 40,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black26)],
                                  ),
                                  child: const Icon(Icons.directions_bike, color: AppColors.primary, size: 24),
                                ),
                              ),
                          ],
                        ),
                        // Route Line (Mock)
                        if (_agentLocation != null && _destinationLocation != null)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: [_agentLocation!, _destinationLocation!],
                                strokeWidth: 4.0,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                      ],
                    ),

                    // Top Bar
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12)],
                                  ),
                                  child: const Icon(Icons.arrow_back),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Bottom Sheet Info
                    DraggableScrollableSheet(
                      initialChildSize: 0.35,
                      minChildSize: 0.2,
                      maxChildSize: 0.5,
                      builder: (context, scrollController) {
                        return Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                            boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black12)],
                          ),
                          child: SingleChildScrollView(
                            controller: scrollController,
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Container(
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(FluentIcons.box_24_filled, color: AppColors.primary),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Commande #${_commande!.id}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          _commande!.statutLabel,
                                          style: GoogleFonts.poppins(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          'Temps estimé',
                                          style: TextStyle(color: Colors.grey, fontSize: 12),
                                        ),
                                        Text(
                                          '15 min',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                const Divider(),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      backgroundImage: AssetImage('assets/images/delivery_man.png'),
                                      radius: 24,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Votre Livreur',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Row(
                                            children: const [
                                              Icon(Icons.star, size: 16, color: Colors.orange),
                                              Text(' 4.8'),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {},
                                      icon: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(FluentIcons.call_24_filled, color: Colors.green),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Call support or action
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[100],
                                      foregroundColor: Colors.black,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Text('Contacter le support'),
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
}
