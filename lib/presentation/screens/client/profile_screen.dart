import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:essivi_mobile/l10n/app_localizations.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:essivi_mobile/theme/app_colors.dart';
import 'package:essivi_mobile/routes/app_routes.dart';
import 'package:essivi_mobile/data/repositories/auth_repository.dart';
import 'package:essivi_mobile/data/repositories/user_repository.dart';
import 'package:essivi_mobile/data/repositories/sales_repository.dart';
import 'package:essivi_mobile/data/models/user_models.dart';
import 'package:essivi_mobile/data/models/sales_models.dart';
import 'package:essivi_mobile/presentation/providers/auth_provider_simple.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _authRepo = AuthRepository();
  final _userRepo = UserRepository();
  final _salesRepo = SalesRepository();
  
  // Computed properties
  int get _totalDeliveries => _orders.length;
  int get _activeOrders => _orders.where((o) => !o.isDelivered && o.statut != 'annulee').length;
  int get _completedOrders => _orders.where((o) => o.isDelivered).length;

  
  CustomUser? _user;
  ClientProfile? _clientProfile;
  List<Commande> _orders = [];
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      _user = await _authRepo.getCurrentUserLegacy();
      if (_user != null) {
        final clients = await _userRepo.getClients();
        _clientProfile = clients.firstWhere((c) => c.userId == _user!.id);
        
        // Charger les commandes pour les statistiques
        _orders = await _salesRepo.getCommandesByClient(_user!.id);
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _logout() async {
    await ref.read(authProviderSimple.notifier).logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? theme.cardColor : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        FluentIcons.arrow_left_24_regular,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),

                  const Spacer(),
                  Text(
                    AppLocalizations.of(context)!.profile,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.settings);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? theme.cardColor : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        FluentIcons.settings_24_regular,
                        size: 20,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.editProfile);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        FluentIcons.edit_24_regular,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Profile Avatar and Info
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage('assets/images/delivery_man.png'),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              FluentIcons.camera_24_filled,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _user?.username ?? 'Loading...',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          FluentIcons.location_24_regular,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _clientProfile?.adresse ?? 'Loading...',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Statistics Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: FluentIcons.box_24_regular,
                      value: '$_totalDeliveries',
                      label: 'Total Livraisons',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: FluentIcons.clock_24_regular,
                      value: '$_activeOrders',
                      label: 'En Cours',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: FluentIcons.checkmark_circle_24_regular,
                      value: '$_completedOrders',
                      label: 'Complétées',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: FluentIcons.star_24_regular,
                      value: '0.0',
                      label: 'Rating',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Account Information
              Text(
                AppLocalizations.of(context)!.account,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 16),

              _buildInfoTile(
                context,
                icon: FluentIcons.mail_24_regular,
                title: AppLocalizations.of(context)!.email,
                value: _user?.email ?? 'Loading...',
              ),
              const SizedBox(height: 12),
              _buildInfoTile(
                context,
                icon: FluentIcons.phone_24_regular,
                title: AppLocalizations.of(context)!.phone,
                value: _user?.phoneNumber ?? 'N/A',
              ),
              const SizedBox(height: 12),
              _buildInfoTile(
                context,
                icon: FluentIcons.calendar_24_regular,
                title: AppLocalizations.of(context)!.memberSince,
                value: '...',
              ),
              const SizedBox(height: 30),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.red.withOpacity(0.1) : Colors.red.shade50,
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(FluentIcons.sign_out_24_regular),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.logout,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
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
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                Text(
                  value,
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
    );
  }
}
