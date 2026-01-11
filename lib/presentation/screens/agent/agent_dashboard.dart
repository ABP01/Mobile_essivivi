import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:essivi_mobile/theme/app_colors.dart';
import 'agent_profile_screen.dart';
import 'agent_deliveries_screen.dart';
import 'agent_earnings_screen.dart';
import 'package:essivi_mobile/routes/app_routes.dart';
import 'package:essivi_mobile/l10n/app_localizations.dart';
import 'package:essivi_mobile/data/repositories/logistics_repository.dart';
import 'package:essivi_mobile/data/repositories/sales_repository.dart';
import 'package:essivi_mobile/data/repositories/auth_repository.dart';
import 'package:essivi_mobile/data/models/logistics_models.dart';
import 'package:essivi_mobile/data/models/sales_models.dart';
import 'package:essivi_mobile/services/location_service.dart';

class AgentDashboard extends StatefulWidget {
  const AgentDashboard({super.key});

  @override
  State<AgentDashboard> createState() => _AgentDashboardState();
}

class _AgentDashboardState extends State<AgentDashboard> {
  bool _isAvailable = true;
  bool _isLoading = true;
  
  final _logisticsRepo = LogisticsRepository();
  final _salesRepo = SalesRepository();
  final _authRepo = AuthRepository();
  final _locationService = LocationService();
  
  Tournee? _activeTournee;
  List<Livraison> _activeDeliveries = [];
  int _completedToday = 0;
  double _earnedToday = 0;
  int? _currentAgentId;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  @override
  void dispose() {
    // Arrêter le tracking GPS quand on quitte le dashboard
    _locationService.stopTracking();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    try {
      final user = await _authRepo.getCurrentUser();
      if (true) {
        // Sauvegarder l'ID de l'agent
        _currentAgentId = user.id;
        
        // Load active tournee
        final tournees = await _logisticsRepo.getActiveTournees();
        if (tournees.isNotEmpty) {
          _activeTournee = tournees.first;
        }
        
        // Load deliveries
        final allDeliveries = await _salesRepo.getLivraisons();
        _activeDeliveries = allDeliveries.where((d) => !d.isDelivered).toList();
        
        // Calculate stats
        final today = DateTime.now();
        _completedToday = allDeliveries.where((d) {
          final deliveryDate = DateTime.parse(d.createdAt);
          return d.isDelivered && 
                 deliveryDate.year == today.year &&
                 deliveryDate.month == today.month &&
                 deliveryDate.day == today.day;
        }).length;
        
        _earnedToday = _completedToday * 500.0; // 500 FCFA per delivery
        
        // Démarrer le tracking GPS si l'agent est disponible
        if (_isAvailable && _currentAgentId != null) {
          _startTracking();
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

  Future<void> _startTracking() async {
    if (_currentAgentId == null) return;
    
    final success = await _locationService.startTracking(_currentAgentId!);
    if (success) {
      debugPrint('✅ Tracking GPS démarré');
    } else {
      debugPrint('❌ Échec démarrage tracking GPS');
      // Afficher un message à l'utilisateur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Veuillez activer la localisation pour recevoir des livraisons',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Paramètres',
              textColor: Colors.white,
              onPressed: () async {
                // Ouvrir les paramètres
                await _locationService.getCurrentPosition();
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _toggleAvailability(bool value) async {
    setState(() => _isAvailable = value);
    
    if (value && _currentAgentId != null) {
      // Démarrer le tracking
      await _startTracking();
    } else {
      // Arrêter le tracking
      await _locationService.stopTracking();
      debugPrint('⏸️  Tracking GPS arrêté');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : Column(
                children: [
                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                    // Header
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AgentProfileScreen()),
                            );
                          },
                          child: const CircleAvatar(
                            radius: 24,
                            backgroundImage: AssetImage('assets/images/delivery_man.png'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.hello('Agent'),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _isAvailable ? Colors.green : Colors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _isAvailable ? AppLocalizations.of(context)!.available : AppLocalizations.of(context)!.offline,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: theme.textTheme.bodySmall?.color,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Availability Toggle
                        Switch(
                          value: _isAvailable,
                          onChanged: (value) {
                            _toggleAvailability(value);
                          },
                          activeThumbColor: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Today's Summary Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFFFF8C42)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
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
                                AppLocalizations.of(context)!.todaySummary,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
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
                                  'Date...',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildSummaryItem(
                                  icon: FluentIcons.drop_24_regular,
                                  value: '${_activeTournee?.stockInitial ?? 0}',
                                  label: AppLocalizations.of(context)!.bottles,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              Expanded(
                                child: _buildSummaryItem(
                                  icon: FluentIcons.money_24_regular,
                                  value: '${_earnedToday.toStringAsFixed(0)} FCFA',
                                  label: AppLocalizations.of(context)!.earned,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              Expanded(
                                child: _buildSummaryItem(
                                  icon: FluentIcons.clock_24_regular,
                                  value: '0h',
                                  label: AppLocalizations.of(context)!.hours,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Quick Stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            icon: FluentIcons.vehicle_truck_24_regular,
                            value: '${_activeDeliveries.length}',
                            label: AppLocalizations.of(context)!.active,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            icon: FluentIcons.checkmark_circle_24_filled,
                            value: '$_completedToday',
                            label: AppLocalizations.of(context)!.completed,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Active Deliveries Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.activeDeliveries,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AgentDeliveriesScreen()),
                            );
                          },
                          child: Text(
                            AppLocalizations.of(context)!.viewAll,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Active Delivery Cards
                    Center(
                      child: Text(
                        'No active deliveries',
                        style: GoogleFonts.poppins(
                          color: theme.textTheme.bodySmall?.color,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Quick Actions
                    Text(
                      AppLocalizations.of(context)!.quickActions,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            context,
                            icon: FluentIcons.money_24_regular,
                            label: AppLocalizations.of(context)!.earnings,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AgentEarningsScreen()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            context,
                            icon: FluentIcons.map_24_regular,
                            label: AppLocalizations.of(context)!.route,
                            onTap: () {
                              Navigator.pushNamed(context, AppRoutes.agentDeliveries);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            context,
                            icon: FluentIcons.history_24_regular,
                            label: AppLocalizations.of(context)!.history,
                            onTap: () {
                              Navigator.pushNamed(context, AppRoutes.agentDeliveries);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            context,
                            icon: FluentIcons.chat_help_24_regular,
                            label: AppLocalizations.of(context)!.support,
                            onTap: () {
                              Navigator.pushNamed(context, AppRoutes.helpCenter);
                            },
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
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
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



  Widget _buildActionButton(BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
