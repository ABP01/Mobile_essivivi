import 'package:essivi_mobile/data/repositories/auth_repository.dart';
import 'package:essivi_mobile/data/repositories/user_repository.dart';
import 'package:essivi_mobile/presentation/widgets/layout/custom_app_bar.dart';
import 'package:essivi_mobile/providers/agent_provider.dart';
import 'package:essivi_mobile/routes/app_routes.dart';
import 'package:essivi_mobile/theme/app_colors.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AgentSettingsScreen extends StatefulWidget {
  const AgentSettingsScreen({super.key});

  @override
  State<AgentSettingsScreen> createState() => _AgentSettingsScreenState();
}

class _AgentSettingsScreenState extends State<AgentSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userRepo = UserRepository();
  final _authRepo = AuthRepository();

  bool _isLoading = false;
  bool _notificationsEnabled = true;
  bool _isDarkMode = true;
  String _selectedLanguage = 'Français';

  // Form controllers
  final _vehicleTypeController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _zoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _vehicleTypeController.dispose();
    _licensePlateController.dispose();
    _phoneController.dispose();
    _zoneController.dispose();
    super.dispose();
  }

  void _loadSettings() {
    final agentProvider = Provider.of<AgentProvider>(context, listen: false);
    final agentProfile = agentProvider.agentProfile;
    final user = agentProvider.currentUser;

    if (agentProfile != null) {
      _vehicleTypeController.text = agentProfile.vehicleType ?? '';
      _licensePlateController.text = agentProfile.licensePlate ?? '';
      _zoneController.text = agentProfile.zoneAssignee ?? '';
    }
    if (user != null) {
      _phoneController.text = user.phoneNumber ?? '';
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final agentProvider = Provider.of<AgentProvider>(context, listen: false);
      final agentProfile = agentProvider.agentProfile;

      if (agentProfile != null) {
        await _userRepo.updateAgent(agentProfile.id, {
          'tricycle_plate': _licensePlateController.text,
          'zone_assignee': _zoneController.text,
        });

        // Refresh data
        await agentProvider.loadDashboardData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Paramètres sauvegardés avec succès',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur: ${e.toString()}',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Déconnexion',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir vous déconnecter ?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Déconnecter', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authRepo.logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(title: 'Paramètres Agent'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Vehicle Info Section
                  _buildSectionHeader('Véhicule'),
                  _buildEditableTile(
                    icon: FluentIcons.vehicle_truck_24_regular,
                    title: 'Type de véhicule',
                    controller: _vehicleTypeController,
                    hintText: 'Ex: Tricycle, Moto',
                    enabled: false, // Usually set by admin
                  ),
                  const SizedBox(height: 12),
                  _buildEditableTile(
                    icon: FluentIcons.number_symbol_24_regular,
                    title: 'Plaque d\'immatriculation',
                    controller: _licensePlateController,
                    hintText: 'Ex: TG-1234-AB',
                  ),
                  const SizedBox(height: 12),
                  _buildEditableTile(
                    icon: FluentIcons.location_24_regular,
                    title: 'Zone assignée',
                    controller: _zoneController,
                    hintText: 'Ex: Bè, Agoè, Tokoin',
                  ),

                  const SizedBox(height: 24),
                  _buildSectionHeader('Préférences'),
                  _buildSettingsTile(
                    icon: FluentIcons.alert_24_regular,
                    title: 'Notifications',
                    trailing: Switch(
                      value: _notificationsEnabled,
                      onChanged: (v) {
                        setState(() => _notificationsEnabled = v);
                      },
                      activeColor: AppColors.primary,
                    ),
                    onTap: () {
                      setState(() => _notificationsEnabled = !_notificationsEnabled);
                    },
                  ),
                  _buildSettingsTile(
                    icon: FluentIcons.local_language_24_regular,
                    title: 'Langue',
                    subtitle: _selectedLanguage,
                    onTap: () => _showLanguageDialog(),
                  ),
                  _buildSettingsTile(
                    icon: FluentIcons.dark_theme_24_regular,
                    title: 'Mode Sombre',
                    trailing: Switch(
                      value: isDark,
                      onChanged: (v) {
                        // Theme switching would be handled by a ThemeProvider
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Changement de thème bientôt disponible',
                              style: GoogleFonts.poppins(),
                            ),
                          ),
                        );
                      },
                      activeColor: AppColors.primary,
                    ),
                    onTap: () {},
                  ),

                  const SizedBox(height: 24),
                  _buildSectionHeader('Activité'),
                  _buildSettingsTile(
                    icon: FluentIcons.shifts_24_regular,
                    title: 'Disponibilité',
                    subtitle: 'Gérer votre statut en ligne',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.agentAvailability);
                    },
                  ),
                  _buildSettingsTile(
                    icon: FluentIcons.history_24_regular,
                    title: 'Historique des livraisons',
                    subtitle: 'Voir vos missions passées',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.agentHistory);
                    },
                  ),
                  _buildSettingsTile(
                    icon: FluentIcons.money_24_regular,
                    title: 'Mes gains',
                    subtitle: 'Consulter vos commissions',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.agentEarnings);
                    },
                  ),

                  const SizedBox(height: 24),
                  _buildSectionHeader('Compte'),
                  _buildSettingsTile(
                    icon: FluentIcons.phone_24_regular,
                    title: 'Numéro de téléphone',
                    subtitle: _phoneController.text.isNotEmpty
                        ? _phoneController.text
                        : 'Non défini',
                    onTap: () => _showEditPhoneDialog(),
                  ),
                  _buildSettingsTile(
                    icon: FluentIcons.password_24_regular,
                    title: 'Changer le mot de passe',
                    onTap: () {
                      // Navigate to change password screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Fonctionnalité bientôt disponible',
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Sauvegarder les modifications',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _logout,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(FluentIcons.sign_out_24_regular),
                          const SizedBox(width: 8),
                          Text(
                            'Se déconnecter',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Version 1.0.0',
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildEditableTile({
    required IconData icon,
    required String title,
    required TextEditingController controller,
    String? hintText,
    bool enabled = true,
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
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller,
            enabled: enabled,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: enabled
                  ? theme.textTheme.bodyLarge?.color
                  : Colors.grey,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        subtitle: subtitle != null
            ? Text(subtitle, style: GoogleFonts.poppins(fontSize: 13))
            : null,
        trailing: trailing ??
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Choisir la langue',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _languageOption('Français'),
            _languageOption('English'),
          ],
        ),
      ),
    );
  }

  Widget _languageOption(String language) {
    return ListTile(
      title: Text(language, style: GoogleFonts.poppins()),
      trailing: _selectedLanguage == language
          ? const Icon(Icons.check, color: AppColors.primary)
          : null,
      onTap: () {
        setState(() => _selectedLanguage = language);
        Navigator.pop(context);
      },
    );
  }

  void _showEditPhoneDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Modifier le téléphone',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: GoogleFonts.poppins(),
          decoration: InputDecoration(
            hintText: '+228 XX XX XX XX',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // The phone will be saved when the user clicks save
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text('OK', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }
}
