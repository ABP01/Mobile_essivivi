import 'package:essivi_mobile/data/models/sales_models.dart';
import 'package:essivi_mobile/data/repositories/sales_repository.dart';
import 'package:essivi_mobile/presentation/screens/agent/delivery_proof_screen.dart';
import 'package:essivi_mobile/presentation/widgets/cards/delivery_proof_card.dart';
import 'package:essivi_mobile/presentation/widgets/layout/custom_app_bar.dart';
import 'package:essivi_mobile/services/location_service.dart';
import 'package:essivi_mobile/theme/app_colors.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AgentDeliveryDetailsScreen extends StatefulWidget {
  final Livraison? livraison;
  final SalesRepository? salesRepo;
  final LocationService? locationService;

  const AgentDeliveryDetailsScreen({
    super.key,
    this.livraison,
    this.salesRepo,
    this.locationService,
  });

  @override
  State<AgentDeliveryDetailsScreen> createState() =>
      _AgentDeliveryDetailsScreenState();
}

class _AgentDeliveryDetailsScreenState
    extends State<AgentDeliveryDetailsScreen> {
  final SalesRepository _salesRepo = SalesRepository();
  Livraison? _livraison;
  bool _isLoading = false;
  bool _deliveredLocally = false;

  @override
  void initState() {
    super.initState();
    _livraison = widget.livraison;
  }

  Future<void> _updateStatus(
    String status, {
    double? gpsLat,
    double? gpsLng,
  }) async {
    if (_livraison == null) return;
    setState(() => _isLoading = true);
    try {
      final updated = await _salesRepo.updateDeliveryStatus(
        _livraison!.id,
        status,
        gpsLat: gpsLat,
        gpsLng: gpsLng,
      );
      setState(() {
        _livraison = updated;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Statut mis à jour: $status')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur mise à jour statut: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmDelivery({
    String? photoPath,
    String? signaturePath,
    double? gpsLat,
    double? gpsLng,
  }) async {
    if (_livraison == null) return;
    setState(() => _isLoading = true);
    try {
      final updated = await _salesRepo.submitProof(
        id: _livraison!.id,
        photoPath: photoPath,
        signaturePath: signaturePath,
        gpsLat: gpsLat,
        gpsLng: gpsLng,
      );
      setState(() {
        _livraison = updated;
        _deliveredLocally = true;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Livraison confirmée')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur confirmation: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final livraison = _livraison ?? widget.livraison;

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
                    livraison?.statutLivraison?.toUpperCase() ?? 'EN ATTENTE',
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
                          'Client #${livraison?.clientId ?? ''}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          livraison?.clientPhone ?? '+228...',
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
                              'Lat: ${livraison?.gpsLat ?? 'N/A'}, Lng: ${livraison?.gpsLng ?? 'N/A'}',
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
              onTapPhoto: () async {
                // Open proof screen and await capture result
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DeliveryProofScreen(
                      deliveryId: '${livraison?.id ?? ''}',
                      clientName: 'Client #${livraison?.clientId ?? ''}',
                      address:
                          'Lat:${livraison?.gpsLat ?? 'N/A'}, Lng:${livraison?.gpsLng ?? 'N/A'}',
                    ),
                  ),
                );

                if (result != null && result is Map<String, dynamic>) {
                  final gpsValidated = result['gpsValidated'] == true;
                  final photoTaken = result['photoTaken'] == true;
                  final signatureCaptured = result['signatureCaptured'] == true;
                  if (result['submitted'] == true) {
                    // Backend already processed proof; refresh livraison
                    try {
                      final refreshed = await _salesRepo.getLivraisonById(
                        livraison!.id,
                      );
                      setState(() {
                        _livraison = refreshed;
                        _deliveredLocally = refreshed.preuveValidee;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Preuve envoyée')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Erreur rafraîchissement: ${e.toString()}',
                          ),
                        ),
                      );
                    }
                  } else if (gpsValidated || photoTaken || signatureCaptured) {
                    // Submit without files (fallback)
                    await _confirmDelivery();
                  }
                }
              },
              onTapSignature: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DeliveryProofScreen(
                      deliveryId: '${livraison?.id ?? ''}',
                      clientName: 'Client #${livraison?.clientId ?? ''}',
                      address:
                          'Lat:${livraison?.gpsLat ?? 'N/A'}, Lng:${livraison?.gpsLng ?? 'N/A'}',
                    ),
                  ),
                );

                if (result != null && result is Map<String, dynamic>) {
                  if (result['submitted'] == true) {
                    try {
                      final refreshed = await _salesRepo.getLivraisonById(
                        livraison!.id,
                      );
                      setState(() {
                        _livraison = refreshed;
                        _deliveredLocally = refreshed.preuveValidee;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Preuve envoyée')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Erreur rafraîchissement: ${e.toString()}',
                          ),
                        ),
                      );
                    }
                  } else if (result['gpsValidated'] == true ||
                      result['photoTaken'] == true ||
                      result['signatureCaptured'] == true) {
                    await _confirmDelivery();
                  }
                }
              },
              onSubmit: () async {
                await _confirmDelivery();
              },
              actionLabel: 'Confirmer la preuve',
            ),
            const SizedBox(height: 24),

            // Actions
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          (livraison == null ||
                              (livraison?.statutLivraison == 'en_route'))
                          ? null
                          : () => _updateStatus('en_route'),
                      child: const Text('En route'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          (livraison == null ||
                              (livraison?.statutLivraison == 'arriving'))
                          ? null
                          : () => _updateStatus('arriving'),
                      child: const Text("J'arrive"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      (livraison == null ||
                          _deliveredLocally ||
                          (livraison?.statutLivraison == 'delivered') ||
                          (livraison?.preuveValidee == true))
                      ? null
                      : () async {
                          await _confirmDelivery();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _deliveredLocally
                        ? Colors.grey
                        : Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _deliveredLocally ? 'Livrée' : 'Confirmer Livraison',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
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
