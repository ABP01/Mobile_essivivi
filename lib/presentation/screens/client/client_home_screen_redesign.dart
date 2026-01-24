import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:essivi_mobile/theme/app_colors.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:essivi_mobile/presentation/widgets/shipping_card.dart';
import 'package:essivi_mobile/presentation/widgets/shipment_item.dart';
import 'package:essivi_mobile/presentation/widgets/custom_bottom_bar.dart';
import 'package:essivi_mobile/routes/app_routes.dart';

class ClientHomeRedesign extends StatefulWidget {
  const ClientHomeRedesign({super.key});

  @override
  State<ClientHomeRedesign> createState() => _ClientHomeRedesignState();
}

class _ClientHomeRedesignState extends State<ClientHomeRedesign> {
  int _selectedIndex = 1; // Start at Home

  @override
  Widget build(BuildContext context) {
    // Force dark background for this specific design
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage('assets/images/delivery_man.png'), // Placeholder
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello Daniel',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Colorado, USA',
                            style: GoogleFonts.poppins(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                         padding: const EdgeInsets.all(8),
                         decoration: const BoxDecoration(
                           color: Color(0xFF1F2022),
                           shape: BoxShape.circle,
                         ),
                         child: const Icon(FluentIcons.alert_24_regular, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // "Current Shipping"
                        Text(
                          'Curront Shipping', // Keeping typo from design or correcting? Design says "Curront". I will correct to "Current".
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        ShippingCard(
                          title: 'Premium Box\nPacking',
                          id: 'ID:V789456AR123',
                          onTap: () {
                             // Navigate to tracking
                             Navigator.pushNamed(context, AppRoutes.clientTrackingRedesign);
                          },
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // "Recent Your Shipment"
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Your Shipment',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'View More',
                              style: GoogleFonts.poppins(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Search
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F2022),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              const Icon(FluentIcons.search_24_regular, color: Colors.grey),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  style: GoogleFonts.poppins(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'Enter receipt number',
                                    hintStyle: GoogleFonts.poppins(color: Colors.grey),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              const Icon(FluentIcons.scan_object_24_regular, color: Colors.grey),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Filters
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip('All', true),
                              _buildFilterChip('Pending', false),
                              _buildFilterChip('On Delivery', false),
                              _buildFilterChip('Delivered', false),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // List
                        ShipmentItem(
                          title: 'Apple 2022 MacBook Pro...',
                          id: 'ID:V789456AR123',
                           onTap: () {},
                        ),
                        ShipmentItem(
                           title: 'Iphone 14 pro max (purple)',
                           id: 'ID:V789456AR123',
                           onTap: () {},
                        ),
                        ShipmentItem(
                           title: 'Nike Air Jordan',
                           id: 'ID:V789456AR123',
                           onTap: () {},
                        ),

                        const SizedBox(height: 100), // Space for bottom bar
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Floating Bottom Bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CustomBottomBar(
                selectedIndex: _selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : const Color(0xFF1F2022),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: isSelected ? Colors.white : Colors.grey,
          fontSize: 14,
        ),
      ),
    );
  }
}
