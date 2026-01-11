import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:essivi_mobile/l10n/app_localizations.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:essivi_mobile/theme/app_colors.dart';
import 'package:essivi_mobile/routes/app_routes.dart';
import 'package:essivi_mobile/data/repositories/sales_repository.dart';
import 'package:essivi_mobile/data/repositories/auth_repository.dart';
import 'package:essivi_mobile/data/models/sales_models.dart';

class AgentDeliveriesScreen extends StatefulWidget {
  const AgentDeliveriesScreen({super.key});

  @override
  State<AgentDeliveriesScreen> createState() => _AgentDeliveriesScreenState();
}

class _AgentDeliveriesScreenState extends State<AgentDeliveriesScreen> {
  String _selectedFilter = 'all';
  final List<String> _filters = ['all', 'pending', 'inTransit', 'delivered'];

  final _salesRepo = SalesRepository();
  final _authRepo = AuthRepository();
  
  List<Livraison> _deliveries = [];
  List<Commande> _availableOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authRepo.getCurrentUser();
      
      // Load all deliveries securely
      final allDeliveries = await _salesRepo.getLivraisons();

      // Load all orders securely
      // Ideally we should use getCommandesByAgent(user.id) but we need to cross-reference with Livraisons
      final agentOrders = await _salesRepo.getCommandesByAgent(user.id);
      final agentOrderIds = agentOrders.map((o) => o.id).toSet();
      
      // Filter deliveries that belong to this agent (via Commande ID)
      // Since Livraison connects to Commande, and Commande has Agent ID
      final myDeliveries = allDeliveries.where((d) => 
        d.commandeId != null && agentOrderIds.contains(d.commandeId)
      ).toList();
      
      // Load pending orders (available for pickup)
      final pendingOrders = await _salesRepo.getCommandesByStatus('pending');
      
      if (mounted) {
        setState(() {
          _deliveries = myDeliveries;
          // Filter out orders that are already assigned
          _availableOrders = pendingOrders.where((o) => o.agentId == null).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _acceptOrder(Commande order) async {
    setState(() => _isLoading = true);
    try {
      final user = await _authRepo.getCurrentUser();
      
      // 1. Update Commande with agent ID
      await _salesRepo.updateCommande(
        order.id, 
        UpdateCommandeRequest(agentId: user.id, statut: 'validated')
      );

      // 2. Create Livraison
      // Assuming active tournee ID 1 for simplicity if not managed yet
      // In a full app, we would select the tournee
      int tourneeId = 1; 
      
      await _salesRepo.createLivraison(
        request: CreateLivraisonRequest(
          tourneeId: tourneeId,
          clientId: order.clientId,
          commandeId: order.id,
        )
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Commande acceptée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData(); // Refresh lists
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'acceptation: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  List<Livraison> get _filteredDeliveries {
    if (_selectedFilter == 'all') return _deliveries;
    return _deliveries.where((d) {
      switch (_selectedFilter) {
        case 'delivered':
          return d.isDelivered;
        case 'pending': // "En attente" matches deliveries that are NOT delivered
           return !d.isDelivered;
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    const SizedBox(width: 48), // Spacer for where the back button was

                    const Spacer(),
                    Text(
                      AppLocalizations.of(context)!.myDeliveries,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 40), // Balance back button
                  ],
                ),
              ),

              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: isDark ? theme.cardColor : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: theme.textTheme.bodySmall?.color,
                  tabs: const [
                    Tab(text: 'Mes Livraisons'),
                    Tab(text: 'Disponibles'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Tab View
              Expanded(
                child: _isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      children: [
                        _buildMyDeliveriesTab(context, theme, isDark),
                        _buildAvailableOrdersTab(context, theme, isDark),
                      ],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyDeliveriesTab(BuildContext context, ThemeData theme, bool isDark) {
    // Calculate stats dynamically
    final todayCount = _deliveries.where((d) {
       // Simple check if created today
       // Assuming createdAt format YYYY-MM-DD...
       final now = DateTime.now();
       return d.createdAt.startsWith(now.toIso8601String().substring(0, 10));
    }).length;
    
    final activeCount = _deliveries.where((d) => !d.isDelivered).length;
    final completedCount = _deliveries.where((d) => d.isDelivered).length;

    return Column(
      children: [
        // Stats Summary
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              Expanded(
                child: _buildQuickStat(context, AppLocalizations.of(context)!.today, todayCount.toString(), Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStat(context, AppLocalizations.of(context)!.active, activeCount.toString(), AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStat(context, AppLocalizations.of(context)!.completed, completedCount.toString(), Colors.green),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Filter Chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                String label;
                final l10n = AppLocalizations.of(context)!;
                switch (filter) {
                  case 'pending':
                    label = l10n.pending;
                    break;
                  case 'inTransit':
                    label = l10n.inTransit;
                    break;
                  case 'delivered':
                    label = l10n.delivered;
                    break;
                  default:
                    label = l10n.all;
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: FilterChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    backgroundColor: isDark ? theme.cardColor : Colors.white,
                    selectedColor: AppColors.primary,
                    labelStyle: GoogleFonts.poppins(
                      color: isSelected ? Colors.white : theme.textTheme.bodySmall?.color,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide.none,
                    ),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Deliveries List
        Expanded(
          child: _filteredDeliveries.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Aucune livraison', style: GoogleFonts.poppins()),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                itemCount: _filteredDeliveries.length,
                itemBuilder: (context, index) {
                  final delivery = _filteredDeliveries[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _buildDeliveryCard(context, delivery),
                  );
                },
              ),
        ),
      ],
    );
  }

  Widget _buildAvailableOrdersTab(BuildContext context, ThemeData theme, bool isDark) {
    if (_availableOrders.isEmpty) {
       return Center(
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Icon(FluentIcons.box_dismiss_24_regular, size: 48, color: Colors.grey),
             const SizedBox(height: 16),
             Text('Aucune commande disponible', style: GoogleFonts.poppins(color: Colors.grey)),
           ],
         ),
       );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _availableOrders.length,
      itemBuilder: (context, index) {
        final order = _availableOrders[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? theme.cardColor : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                 BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                 ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Commande #${order.id}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    Text(
                      '${order.montant.toStringAsFixed(0)} FCFA',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Date souhaitée: ${order.dateSouhaitee.substring(0, 10)}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _acceptOrder(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Accepter la course',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStat(BuildContext context, String label, String value, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(BuildContext context, Livraison delivery) {
    String label;
    final l10n = AppLocalizations.of(context)!;
    Color statusColor;
    IconData statusIcon;

    if (delivery.isDelivered) {
      statusColor = Colors.green;
      statusIcon = FluentIcons.checkmark_circle_24_filled;
      label = l10n.delivered;
    } else {
      statusColor = AppColors.primary;
      statusIcon = FluentIcons.vehicle_truck_24_regular;
      label = l10n.pending;
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(FluentIcons.box_24_regular, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Livraison #${delivery.id}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      delivery.createdAt,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Route Info
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Point de collecte',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Client #${delivery.clientId}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bottom Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(FluentIcons.location_24_regular, size: 16, color: theme.textTheme.bodySmall?.color),
                  const SizedBox(width: 4),
                  Text(
                    '--- km',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
              Text(
                '500 FCFA',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          // Action Buttons (only for active deliveries)
          if (!delivery.isDelivered) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.shipmentDetails,
                        arguments: {
                          'title': 'Livraison #${delivery.id}',
                          'id': delivery.id.toString(),
                          'status': delivery.isDelivered ? 'delivered' : 'pending',
                          'isAgent': true,
                        },
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.viewDetails,
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: delivery.isDelivered ? null : () async {
                      // Marquer comme livrée
                      try {
                        await _salesRepo.submitProof(
                          id: delivery.id,
                          // On envoie des données vides car le backend gère le changement de statut
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Livraison marquée comme terminée !'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          _loadData(); // Refresh list to update UI state
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erreur: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: delivery.isDelivered ? Colors.grey : Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      delivery.isDelivered ? 'Livré' : 'Terminé',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
