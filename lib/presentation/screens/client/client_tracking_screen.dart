import 'package:essivi_mobile/data/models/sales_models.dart';
import 'package:essivi_mobile/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ClientTrackingScreen extends StatefulWidget {
  final Commande? shipmentMock; // For argument passing

  const ClientTrackingScreen({super.key, this.shipmentMock});

  @override
  State<ClientTrackingScreen> createState() => _ClientTrackingScreenState();
}

class _ClientTrackingScreenState extends State<ClientTrackingScreen> {
  // Mock coordinates for demo (Lomé)
  final LatLng _source = const LatLng(6.13, 1.21); // Agency
  final LatLng _destination = const LatLng(6.17, 1.25); // Client
  final LatLng _courier = const LatLng(6.15, 1.23); // Current pos

  @override
  void initState() {
    super.initState();
    // Simulate real-time updates or listen to WebSocket
    _listenToLocationUpdates();
  }

  void _listenToLocationUpdates() {
    // Check if shipment has an agent assigned
    // WebSocketService().notifications.listen((data) {
    //   if (data['type'] == 'location_update' && data['agent_id'] == widget.shipmentMock?.agentId) {
    //      setState(() {
    //        _courier = LatLng(data['lat'], data['lng']);
    //      });
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    // Get shipment from arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    // Handle both ShipmentModel and Commande types
    final shipment = args is Commande ? args : widget.shipmentMock;

    // Use shipment data for source/dest if available
    // if (shipment != null) { ... }

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          // 1. Map (Full Screen)
          FlutterMap(
            options: MapOptions(
              // Use shipment location if available, else agency default
              initialCenter:
                  shipment?.deliveryLatitude != null &&
                      shipment?.deliveryLongitude != null
                  ? LatLng(
                      shipment!.deliveryLatitude!,
                      shipment!.deliveryLongitude!,
                    )
                  : _source,
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                // Dark map style usually matches design better
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [
                      _source,
                      // Current position if known
                      if (shipment?.deliveryLatitude != null &&
                          shipment?.deliveryLongitude != null)
                        LatLng(
                          shipment!.deliveryLatitude!,
                          shipment!.deliveryLongitude!,
                        )
                      else
                        _courier, // fallback to mock or last known
                      _destination,
                    ],
                    color: AppColors.primary,
                    strokeWidth: 4.0,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _source,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.store, color: Colors.white),
                  ),
                  Marker(
                    point:
                        _destination, // Client location (mock for now or from shipment.client.address)
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on,
                      color: AppColors.primary,
                      size: 40,
                    ),
                  ),
                  // Courier Marker
                  if (shipment?.deliveryLatitude != null &&
                      shipment?.deliveryLongitude != null)
                    Marker(
                      point: LatLng(
                        shipment!.deliveryLatitude!,
                        shipment!.deliveryLongitude!,
                      ),
                      width: 50,
                      height: 50,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(blurRadius: 10, color: Colors.black26),
                          ],
                        ),
                        padding: const EdgeInsets.all(8),
                        // Rotate icon based on bearing if available?
                        child: const Icon(
                          Icons.local_shipping,
                          color: AppColors.primary,
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
                      const Text(
                        "Live Tracking",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _circleButton(Icons.center_focus_strong, () {}),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Top Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.inventory_2,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "ID: ${shipment?.id ?? 'N/A'}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "ID:${shipment?.id}",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.2,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Driver Info
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(
                              'https://i.pravatar.cc/100?img=12',
                            ), // Mock driver
                          ),
                          const SizedBox(width: 16),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Jimmy Jordan",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Delivery Agent",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.call, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      const Text(
                        "Courier Status",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Timeline
                      _timelineRow(
                        "Picked",
                        "Bailey",
                        "2 Jun 2025",
                        true,
                        false,
                      ),
                      _timelineLine(true),
                      _timelineRow(
                        "Arriving",
                        "Mottison",
                        "3 Jun 2025",
                        true,
                        false,
                      ),
                      _timelineLine(true),
                      _timelineRow(
                        "Transit",
                        "Lakewood",
                        "4 Jun 2025",
                        true,
                        true,
                      ), // Active
                      _timelineLine(false),
                      _timelineRow(
                        "Delivered to",
                        "Denver",
                        "5 Jun 2025",
                        false,
                        false,
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
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _timelineRow(
    String title,
    String subtitle,
    String date,
    bool isCompleted,
    bool isActive,
  ) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? AppColors.primary : Colors.transparent,
            border: Border.all(
              color: isActive ? AppColors.primary : Colors.grey,
              width: 2,
            ),
          ),
          child: isCompleted
              ? const Icon(Icons.check, color: Colors.white, size: 14)
              : (isActive
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
        const Spacer(),
        Text(date, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }

  Widget _timelineLine(bool isActive) {
    return Container(
      margin: const EdgeInsets.only(left: 11),
      height: 30,
      width: 2,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        itemBuilder: (ctx, i) => Container(
          margin: const EdgeInsets.only(bottom: 4),
          height: 4,
          width: 2,
          color: isActive
              ? AppColors.primary.withOpacity(0.5)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
    );
  }
}
