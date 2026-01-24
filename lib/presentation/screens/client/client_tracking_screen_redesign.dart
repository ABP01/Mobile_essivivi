import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:essivi_mobile/presentation/widgets/glass_card.dart';
import 'package:essivi_mobile/presentation/widgets/courier_status_card.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

class ClientTrackingRedesign extends StatelessWidget {
  const ClientTrackingRedesign({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            options: MapOptions(
              initialCenter: const LatLng(39.7392, -104.9903), // Denver
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.app',
              ),
              // Route Line (Dashed orange)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: const [
                       LatLng(39.7392, -104.9903), // Start
                       LatLng(39.7420, -104.9950),
                       LatLng(39.7450, -104.9850),
                       LatLng(39.7500, -104.9800), // End
                    ],
                    color: const Color(0xFFFF742F),
                    strokeWidth: 4.0,
                  ),
                ],
              ),
              // Markers
              MarkerLayer(
                markers: [
                  Marker(
                    point: const LatLng(39.7392, -104.9903),
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_on, color: Color(0xFFFF742F), size: 40),
                  ),
                  Marker(
                     point: const LatLng(39.7500, -104.9800),
                     width: 40,
                     height: 40,
                     child: Container(
                       padding: const EdgeInsets.all(8),
                       decoration: const BoxDecoration(
                         color: Colors.white,
                         shape: BoxShape.circle,
                       ),
                       child: const Icon(FluentIcons.vehicle_truck_24_filled, color: Color(0xFFFF742F), size: 20),
                     ),
                  ),
                ],
              ),
            ],
          ),

          // Content Overlay
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       GestureDetector(
                         onTap: () => Navigator.pop(context),
                         child: const Icon(Icons.arrow_back_ios, color: Colors.white),
                       ),
                       Text(
                         'Live Tracking',
                         style: GoogleFonts.poppins(
                           fontSize: 18,
                           fontWeight: FontWeight.w600,
                           color: Colors.white,
                         ),
                       ),
                       Container(
                         padding: const EdgeInsets.all(8),
                         decoration: BoxDecoration(
                           color: Colors.white.withOpacity(0.1),
                           shape: BoxShape.circle,
                         ),
                         child: const Icon(FluentIcons.scan_object_24_regular, color: Colors.white),
                       )
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Card Overlay
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const GlassCard(
                    title: 'Apple 2022 MacBook Pro...',
                    id: 'ID:V789456AR123',
                  ),
                ),
                
                const Spacer(),
                
                // Driver Status Card
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CourierStatusCard(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
