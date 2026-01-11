import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:essivi_mobile/theme/app_colors.dart';
import 'package:essivi_mobile/data/repositories/sales_repository.dart';
import 'package:essivi_mobile/data/models/sales_models.dart';

class TrackingScreen extends StatefulWidget {
  final int? commandeId;

  const TrackingScreen({super.key, this.commandeId});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final _salesRepo = SalesRepository();
  
  Commande? _commande;
  Livraison? _livraison;
  bool _isLoading = true;

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
        
        // Try to find associated delivery
        final deliveries = await _salesRepo.getLivraisons();
        try {
          _livraison = deliveries.firstWhere((d) => d.commandeId == widget.commandeId);
        } catch (e) {
          // No delivery found yet
        }
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.textTheme.bodyLarge?.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Track Shipment',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _commande == null
              ? const Center(child: Text('Order not found'))
              : RefreshIndicator(
                  onRefresh: _loadTracking,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order Info Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getStatusColor(),
                                _getStatusColor().withOpacity(0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Order #${_commande!.id}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _commande!.statutLabel,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(FluentIcons.money_24_regular, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_commande!.montant.toStringAsFixed(0)} FCFA',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Tracking Timeline
                        Text(
                          'Tracking Status',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildTimelineItem(
                          'Order Placed',
                          DateTime.parse(_commande!.createdAt).toString().substring(0, 16),
                          true,
                          true,
                        ),
                        _buildTimelineItem(
                          'Order Confirmed',
                          _commande!.statut != 'en_attente' ? 'Confirmed' : 'Pending',
                          _commande!.statut != 'en_attente',
                          _commande!.statut != 'en_attente',
                        ),
                        // New: En route status
                        _buildTimelineItem(
                          'En route',
                          _livraison?.isEnRoute == true || _livraison?.isArriving == true || _commande!.isDelivered
                              ? 'Agent en route'
                              : _livraison != null ? 'Assigné' : 'En attente',
                          _livraison?.isEnRoute == true || _livraison?.isArriving == true || _commande!.isDelivered,
                          _livraison?.isEnRoute == true || _livraison?.isArriving == true || _commande!.isDelivered,
                        ),
                        // New: Arriving status
                        _buildTimelineItem(
                          'Arriving Soon',
                          _livraison?.isArriving == true || _commande!.isDelivered
                              ? 'Arrive bientôt'
                              : 'En attente',
                          _livraison?.isArriving == true || _commande!.isDelivered,
                          _livraison?.isArriving == true || _commande!.isDelivered,
                        ),
                        _buildTimelineItem(
                          'Delivered',
                          _commande!.isDelivered ? 'Completed' : 'Pending',
                          _commande!.isDelivered,
                          false,
                        ),
                        const SizedBox(height: 24),

                        // GPS Location (if available)
                        if (_livraison != null && _livraison!.gpsLat != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Delivery Location',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark ? theme.cardColor : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(FluentIcons.location_24_filled, color: AppColors.primary),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Lieu de Livraison',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color: theme.textTheme.bodySmall?.color,
                                                ),
                                              ),
                                              Text(
                                                'Position confirmée',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: theme.textTheme.bodyLarge?.color,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (_commande!.statut == 'validated') ...[
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              'trackDelivery',
                                              arguments: {
                                                'deliveryId': _commande!.id,
                                                'agentId': _commande!.agentId ?? 0,
                                                'agentName': 'Livreur',
                                                'agentPhone': '',
                                                'clientLatitude': _commande!.deliveryLatitude,
                                                'clientLongitude': _commande!.deliveryLongitude,
                                              },
                                            );
                                          },
                                          icon: const Icon(FluentIcons.map_24_regular),
                                          label: const Text('Voir sur la carte'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Color _getStatusColor() {
    if (_commande!.isDelivered) return Colors.green;
    if (_commande!.statut == 'annulee') return Colors.red;
    if (_livraison != null) return Colors.blue;
    return Colors.orange;
  }

  Widget _buildTimelineItem(String title, String subtitle, bool isCompleted, bool showLine) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.primary : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? FluentIcons.checkmark_24_filled : FluentIcons.circle_24_regular,
                color: Colors.white,
                size: 16,
              ),
            ),
            if (showLine)
              Container(
                width: 2,
                height: 60,
                color: isCompleted ? AppColors.primary : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                if (showLine) const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
