import 'package:essivi_mobile/data/models/sales_models.dart';
import 'package:essivi_mobile/presentation/widgets/layout/custom_app_bar.dart';
import 'package:essivi_mobile/providers/agent_provider.dart';
import 'package:essivi_mobile/routes/app_routes.dart';
import 'package:essivi_mobile/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class AgentMapScreen extends StatefulWidget {
  const AgentMapScreen({super.key});

  @override
  State<AgentMapScreen> createState() => _AgentMapScreenState();
}

class _AgentMapScreenState extends State<AgentMapScreen> {
  final MapController _mapController = MapController();
  final LatLng _center = const LatLng(6.1375, 1.2125); // Lomé default

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AgentProvider>(context, listen: false).loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AgentProvider>(
      builder: (context, agentProvider, _) {
        final deliveries = agentProvider.activeDeliveries;
        final agentLocation = agentProvider.agentProfile?.latitude != null 
             ? LatLng(agentProvider.agentProfile!.latitude!, agentProvider.agentProfile!.longitude!)
             : _center;

        return Scaffold(
          appBar: const CustomAppBar(
            title: 'Carte des Livraisons',
            showBackButton: false,
          ),
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: agentLocation,
                  initialZoom: 13.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.essivivi.mobile',
                  ),
                  MarkerLayer(
                    markers: [
                      // Agent Position
                      Marker(
                         point: agentLocation,
                         width: 60,
                         height: 60,
                         child: Container(
                           decoration: BoxDecoration(
                             color: AppColors.primary,
                             shape: BoxShape.circle,
                             border: Border.all(color: Colors.white, width: 3),
                             boxShadow: [
                               BoxShadow(
                                 color: Colors.black.withOpacity(0.2),
                                 blurRadius: 10,
                               ),
                             ],
                           ),
                           child: const Icon(
                             Icons.directions_bike,
                             color: Colors.white,
                             size: 30,
                           ),
                         ),
                      ),
                      // Deliveries
                      ...deliveries.map((delivery) {
                        // Use delivery coords if available, else mock offset
                        final pos = (delivery.gpsLat != null && delivery.gpsLng != null)
                             ? LatLng(delivery.gpsLat!, delivery.gpsLng!)
                             : LatLng(_center.latitude + 0.01, _center.longitude + 0.01); // fallback
                        
                        return Marker(
                          point: pos,
                          width: 50,
                          height: 50,
                          child: GestureDetector(
                            onTap: () {
                              _showDeliveryPreview(context, delivery);
                            },
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
              
              // Refresh Button
              Positioned(
                bottom: 20,
                right: 20,
                child: FloatingActionButton(
                  onPressed: () {
                     _mapController.move(agentLocation, 15);
                     agentProvider.refreshDeliveries();
                  },
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.my_location, color: Colors.black),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeliveryPreview(BuildContext context, Livraison delivery) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Livraison #${delivery.id}',
                style: const TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 10),
              Text('Client ID: ${delivery.clientId}'), // Ideally lookup name
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context, 
                    AppRoutes.agentDeliveryDetails, 
                    arguments: delivery
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Voir Détails', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }
}
