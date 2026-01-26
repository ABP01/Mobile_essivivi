import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:essivi_mobile/theme/app_colors.dart';
import 'package:essivi_mobile/providers/shipment_provider.dart';
import 'package:essivi_mobile/data/repositories/auth_repository.dart';
import 'package:essivi_mobile/data/models/user_models.dart'; // CustomUser
import 'package:essivi_mobile/presentation/widgets/cards/shipment_card.dart';
import 'package:essivi_mobile/routes/app_routes.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  String _selectedFilter = 'All';
  CustomUser? _user;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
       final user = await AuthRepository().getCurrentUser();
       if (mounted) {
         setState(() {
           _user = user;
         });
         // Load shipments
         Provider.of<ShipmentProvider>(context, listen: false).loadShipments();
       }
    } catch(e) {
       // Handle error
    }
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    Provider.of<ShipmentProvider>(context, listen: false).loadShipments(status: filter == 'All' ? null : filter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        // CustomUser doesn't have agentProfile/photo directly visible here unless we fetch profile separately
                        // For now use default icon or placeholder
                        child: const Icon(Icons.person),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hello ${_user?.username ?? 'User'}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _user?.email ?? "Lomé, Togo", // CustomUser has no address in basic model, ClientProfile does.
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.notifications_none, color: Colors.white),
                      onPressed: () {
                         Navigator.pushNamed(context, AppRoutes.notifications);
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(height: 30),
              
              const Text(
                "Current Shipping",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Current Shipment Card
              Consumer<ShipmentProvider>(
                builder: (context, provider, child) {
                  final current = provider.currentShipment;
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (current == null) {
                    return Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      alignment: Alignment.center,
                      child: const Text("No active shipments", style: TextStyle(color: Colors.white)),
                    );
                  }
                  return CurrentShipmentCard(
                    shipment: current,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.clientTrackingRedesign, arguments: current);
                    },
                  );
                },
              ),
              
              const SizedBox(height: 30),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent Your Shipment",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text("View More", style: TextStyle(color: Colors.white54)),
                  )
                ],
              ),
              const SizedBox(height: 16),
              
              // Search & Filter
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.darkSurface,
                        hintText: 'Enter receipt number',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                        prefixIcon: const Icon(Icons.search, color: Colors.white54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      shape: BoxShape.circle, 
                      borderRadius: BorderRadius.circular(16)
                    ),
                    child: const Icon(Icons.qr_code_scanner, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Filter Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Pending', 'On Delivery', 'Delivered'].map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => _onFilterChanged(filter),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppColors.darkSurface,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              
              // List
              Consumer<ShipmentProvider>(
                builder: (context, provider, child) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.shipments.length,
                    itemBuilder: (context, index) {
                      final shipment = provider.shipments[index];
                      return RecentShipmentTile(
                        shipment: shipment,
                        onTap: () {
                           Navigator.pushNamed(context, AppRoutes.clientTrackingRedesign, arguments: shipment);
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 70,
      decoration: BoxDecoration(
         color: AppColors.darkSurface,
         borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(Icons.home_outlined, "Home", true),
          _navItem(Icons.mic_none, "", false), // Mic icon
          _navItem(Icons.person_outline, "", false),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive) {
     return Row(
       children: [
          Icon(icon, color: isActive ? AppColors.primary : Colors.white54),
          if (isActive) ...[
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))
          ]
       ],
     );
  }
}
