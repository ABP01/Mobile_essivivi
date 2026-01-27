import 'package:essivi_mobile/data/models/sales_models.dart';
import 'package:essivi_mobile/presentation/widgets/cards/delivery_proof_card.dart';
import 'package:essivi_mobile/presentation/widgets/layout/custom_app_bar.dart';
import 'package:essivi_mobile/routes/app_routes.dart';
import 'package:essivi_mobile/theme/app_colors.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AgentDeliveryDetailsScreen extends StatelessWidget {
  final Livraison? livraison;

  const AgentDeliveryDetailsScreen({super.key, this.livraison});

  @override
  Widget build(BuildContext context) {
    if (livraison == null) {
      // Fallback or error state
      return const Scaffold(
        appBar: CustomAppBar(title: 'Détails'),
        body: Center(child: Text('Aucune donnée de livraison')),
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(title: 'Détails Livraison'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange),
                  const SizedBox(width: 12),
                  Text(
                    livraison!.statutLivraison?.toUpperCase() ?? 'EN ATTENTE',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Client Info
            _buildSectionHeader('Client'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? theme.cardColor : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text('CL', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Client #${livraison!.clientId}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          livraison!.clientPhone ?? '+228...',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      FluentIcons.call_24_filled,
                      color: Colors.green,
                    ),
                    onPressed: () {
                      // Call action
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Address
            _buildSectionHeader('Destination'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? theme.cardColor : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        FluentIcons.location_24_regular,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Position GPS',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Lat: ${livraison!.gpsLat ?? 'N/A'}, Lng: ${livraison!.gpsLng ?? 'N/A'}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Launch maps
                      },
                      icon: const Icon(Icons.navigation),
                      label: const Text('Ouvrir Maps'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            DeliveryProofCard(
              timestamp: DateTime.now(),
              onTapPhoto: () {
                Navigator.pushNamed(context, AppRoutes.deliveryProof);
              },
              onTapSignature: () {
                Navigator.pushNamed(context, AppRoutes.deliveryProof);
              },
              onSubmit: () {
                Navigator.pushNamed(context, AppRoutes.deliveryProof);
              },
              actionLabel: 'Confirmer la preuve',
            ),
            const SizedBox(height: 24),

            // Actions
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to proof screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Confirmer Livraison',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}
