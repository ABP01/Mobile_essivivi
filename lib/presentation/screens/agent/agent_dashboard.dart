import 'package:essivi_mobile/l10n/app_localizations.dart';
import 'package:essivi_mobile/providers/agent_provider.dart';
import 'package:essivi_mobile/routes/app_routes.dart';
import 'package:essivi_mobile/theme/app_colors.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AgentDashboard extends StatefulWidget {
  const AgentDashboard({super.key});

  @override
  State<AgentDashboard> createState() => _AgentDashboardState();
}

class _AgentDashboardState extends State<AgentDashboard> {
  @override
  void initState() {
    super.initState();
    // Load data via Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AgentProvider>(context, listen: false).loadDashboardData();
    });
  }

  // Tracking handled inside Provider toggleAvailability

  // Note: dispose of provider is not needed here as it's provided in main.dart
  // LocationService stopTracking should be handled in Provider's dispose or explicit method if needed
  // But Provider stays alive. Ideally we pause tracking on logout.

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<AgentProvider>(
      builder: (context, agentProvider, child) {
        final isLoading = agentProvider.isLoading;
        final user = agentProvider.currentUser;
        final activeDeliveries = agentProvider.activeDeliveries;
        final isAvailable = agentProvider.isAvailable;
        final completedCount = agentProvider.completedTodayCount;
        final activeTournee = agentProvider.activeTournee;
        final earnedToday = agentProvider.earnedToday;

        // Pass context to helper widgets explicitly if needed or use context from build

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : Column(
                    children: [
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
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.agentProfile,
                                      );
                                    },
                                    child: const CircleAvatar(
                                      radius: 24,
                                      backgroundImage: AssetImage(
                                        'assets/images/delivery_man.png',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.hello(user?.username ?? 'Agent'),
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: theme
                                                .textTheme
                                                .bodyLarge
                                                ?.color,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: isAvailable
                                                    ? Colors.green
                                                    : Colors.grey,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              isAvailable
                                                  ? AppLocalizations.of(
                                                      context,
                                                    )!.available
                                                  : AppLocalizations.of(
                                                      context,
                                                    )!.offline,
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: theme
                                                    .textTheme
                                                    .bodySmall
                                                    ?.color,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Availability Toggle
                                  Switch(
                                    value: isAvailable,
                                    onChanged: (value) {
                                      agentProvider.toggleAvailability(value);
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
                                    colors: [
                                      AppColors.primary,
                                      Color(0xFFFF8C42),
                                    ],
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.todaySummary,
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            DateTime.now().toString().substring(
                                              0,
                                              10,
                                            ), // Simple formatted date
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
                                            value:
                                                '${activeTournee?.stockInitial ?? 0}',
                                            label: AppLocalizations.of(
                                              context,
                                            )!.bottles,
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
                                            value:
                                                '${earnedToday.toStringAsFixed(0)} FCFA',
                                            label: AppLocalizations.of(
                                              context,
                                            )!.earned,
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
                                            value: '8h', // Mock hours
                                            label: AppLocalizations.of(
                                              context,
                                            )!.hours,
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
                                      icon:
                                          FluentIcons.vehicle_truck_24_regular,
                                      value: '${activeDeliveries.length}',
                                      label: AppLocalizations.of(
                                        context,
                                      )!.active,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatCard(
                                      context,
                                      icon: FluentIcons
                                          .checkmark_circle_24_filled,
                                      value: '$completedCount',
                                      label: AppLocalizations.of(
                                        context,
                                      )!.completed,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // Active Deliveries Section
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.activeDeliveries,
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: theme.textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.agentDeliveries,
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
                              if (activeDeliveries.isEmpty)
                                Center(
                                  child: Text(
                                    'No active deliveries',
                                    style: GoogleFonts.poppins(
                                      color: theme.textTheme.bodySmall?.color,
                                      fontSize: 14,
                                    ),
                                  ),
                                )
                              else
                                // Just show first 2 for dashboard preview
                                ...activeDeliveries
                                    .take(2)
                                    .map(
                                      (d) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8.0,
                                        ),
                                        child: Text(
                                          "Delivery #${d.id} - ${d.statutLivraison ?? 'Pending'}",
                                          style: TextStyle(
                                            color: theme
                                                .textTheme
                                                .bodyMedium
                                                ?.color,
                                          ),
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
                                      label: AppLocalizations.of(
                                        context,
                                      )!.earnings,
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.agentEarnings,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildActionButton(
                                      context,
                                      icon: FluentIcons.map_24_regular,
                                      label: AppLocalizations.of(
                                        context,
                                      )!.route,
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.agentDeliveries,
                                        );
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
                                      label: AppLocalizations.of(
                                        context,
                                      )!.history,
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.agentDeliveries,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildActionButton(
                                      context,
                                      icon: FluentIcons.chat_help_24_regular,
                                      label: AppLocalizations.of(
                                        context,
                                      )!.support,
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.helpCenter,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
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

  Widget _buildStatCard(
    BuildContext context, {
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

  Widget _buildActionButton(
    BuildContext context, {
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
