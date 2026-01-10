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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeliveries();
  }

  Future<void> _loadDeliveries() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authRepo.getCurrentUser();
      if (user != null) {
        final allDeliveries = await _salesRepo.getLivraisons();
        _deliveries = allDeliveries;
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
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
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  GestureDetector(
                  onTap: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushReplacementNamed(context, AppRoutes.home);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? theme.cardColor : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 20,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                  const Spacer(),
                  Text(
                    AppLocalizations.of(context)!.myDeliveries, // Assuming this exists or I'll add it
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const Spacer(),
                  const Icon(FluentIcons.map_24_regular, size: 20),
                ],
              ),
            ),

            // Stats Summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildQuickStat(context, AppLocalizations.of(context)!.today, '8', Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickStat(context, AppLocalizations.of(context)!.active, '3', AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickStat(context, AppLocalizations.of(context)!.completed, '5', Colors.green),
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
              child: ListView.builder(
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
        ),
      ),
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
            color: Colors.black.withValues(alpha: 0.03),
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

  Widget _buildDeliveryCard(BuildContext context, Map<String, dynamic> delivery) {
    final status = delivery['status'] as String;
    String label;
    final l10n = AppLocalizations.of(context)!;
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = FluentIcons.clock_24_regular;
        label = l10n.pending;
        break;
      case 'inTransit':
        statusColor = AppColors.primary;
        statusIcon = FluentIcons.vehicle_truck_24_regular;
        label = l10n.inTransit;
        break;
      case 'delivered':
        statusColor = Colors.green;
        statusIcon = FluentIcons.checkmark_circle_24_filled;
        label = l10n.delivered;
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusIcon = FluentIcons.box_24_regular;
        label = status;
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
            color: Colors.black.withValues(alpha: 0.03),
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
                  color: AppColors.primary.withValues(alpha: 0.1),
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
                      delivery['title'],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      delivery['id'],
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
                  color: statusColor.withValues(alpha: 0.1),
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
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            delivery['from'],
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
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            delivery['to'],
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
                    delivery['distance'],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
              Text(
                delivery['earnings'],
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          // Action Buttons (only for active deliveries)
          if (status != 'Delivered') ...[
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
                          'title': delivery['title'],
                          'id': delivery['id'],
                          'status': delivery['status'],
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
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.tracking);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      status == 'pending' ? AppLocalizations.of(context)!.start : AppLocalizations.of(context)!.navigate,
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
