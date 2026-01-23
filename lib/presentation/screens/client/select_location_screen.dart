import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:essivi_mobile/theme/app_colors.dart';
import 'package:latlong2/latlong.dart';
import 'package:essivi_mobile/services/location_service.dart';

class SelectLocationScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const SelectLocationScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  final MapController _mapController = MapController();
  final _locationService = LocationService();
  LatLng? _selectedPosition;
  bool _isLoading = true;
  String _selectedAddress = 'Sélectionnez votre position sur la carte';

  // Position par défaut (Lomé, Togo)
  static const LatLng _defaultPosition = LatLng(6.1319, 1.2223);

  @override
  void initState() {
    super.initState();
    _initializePosition();
  }

  Future<void> _initializePosition() async {
    // Si une position initiale est fournie, l'utiliser
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      setState(() {
        _selectedPosition = LatLng(widget.initialLatitude!, widget.initialLongitude!);
        _isLoading = false;
      });
      return;
    }

    // Sinon, essayer d'obtenir la position actuelle
    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        setState(() {
          _selectedPosition = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
      } else {
        setState(() {
          _selectedPosition = _defaultPosition;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _selectedPosition = _defaultPosition;
        _isLoading = false;
      });
    }
  }

  void _onMapTapped(TapPosition tapPosition, LatLng point) {
    setState(() {
      _selectedPosition = point;
      _selectedAddress = 'Lat: ${point.latitude.toStringAsFixed(6)}, Lng: ${point.longitude.toStringAsFixed(6)}';
    });
  }

  void _confirmLocation() {
    if (_selectedPosition != null) {
      Navigator.pop(context, {
        'latitude': _selectedPosition!.latitude,
        'longitude': _selectedPosition!.longitude,
        'address': _selectedAddress,
      });
    }
  }

  void _getCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      if (position == null) throw Exception('Position unavailable');
      final newPosition = LatLng(position.latitude, position.longitude);
      
      setState(() {
        _selectedPosition = newPosition;
        _selectedAddress = 'Position actuelle';
      });

      _mapController.move(newPosition, 15);
    } catch (e) {
      debugPrint('Error getting location: $e');
      
      setState(() {
        _selectedPosition = _defaultPosition;
        _selectedAddress = 'Position par défaut (Lomé)';
      });
      
      _mapController.move(_defaultPosition, 15);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'GPS non disponible, utilisation de la position par défaut',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Flutter Map (OpenStreetMap)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedPosition ?? _defaultPosition,
              initialZoom: 14.0,
              onTap: _onMapTapped,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.essivivi.water',
              ),
              if (_selectedPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedPosition!,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back, color: AppColors.textMain),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Text(
                        'Sélectionnez votre position',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Position sélectionnée',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedAddress,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _getCurrentLocation,
                            icon: const Icon(Icons.my_location, size: 20),
                            label: Text(
                              'Ma position',
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _selectedPosition != null ? _confirmLocation : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Confirmer',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
