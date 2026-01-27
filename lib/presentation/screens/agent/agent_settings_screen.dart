import 'package:essivi_mobile/presentation/widgets/layout/custom_app_bar.dart';
import 'package:essivi_mobile/routes/app_routes.dart';
import 'package:essivi_mobile/theme/app_colors.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

class AgentSettingsScreen extends StatelessWidget {
  const AgentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(title: 'Paramètres Agent'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Vehicle Info Section
          _buildSectionHeader(context, 'Véhicule'),
          _buildSettingsTile(
            context,
            icon: FluentIcons.vehicle_truck_24_regular,
            title: 'Type de véhicule',
            subtitle: 'Tricycle',
            onTap: () {},
          ),
          _buildSettingsTile(
            context,
            icon: FluentIcons.number_symbol_24_regular,
            title: 'Plaque d\'immatriculation',
            subtitle: 'TG-1234-AB',
            onTap: () {},
          ),

          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Préférences'),
          _buildSettingsTile(
            context,
            icon: FluentIcons.alert_24_regular,
            title: 'Notifications',
            trailing: Switch(
              value: true,
              onChanged: (v) {},
              activeColor: AppColors.primary,
            ),
            onTap: () {},
          ),
          _buildSettingsTile(
            context,
            icon: FluentIcons.local_language_24_regular,
            title: 'Langue',
            subtitle: 'Français',
            onTap: () {},
          ),
          _buildSettingsTile(
            context,
            icon: FluentIcons.dark_theme_24_regular,
            title: 'Mode Sombre',
            trailing: Switch(
              value: isDark,
              onChanged: (v) {},
              activeColor: AppColors.primary,
            ),
            onTap: () {},
          ),

          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Activité'),
          _buildSettingsTile(
            context,
            icon: FluentIcons.shifts_24_regular,
            title: 'Disponibilité',
            subtitle: 'En ligne / Hors ligne',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.agentAvailability);
            },
          ),
          _buildSettingsTile(
            context,
            icon: FluentIcons.history_24_regular,
            title: 'Historique des livraisons',
            subtitle: 'Missions passées',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.agentHistory);
            },
          ),

          const SizedBox(height: 48),
          Center(
            child: TextButton(
              onPressed: () {
                // Logout logic
              },
              child: const Text(
                'Se déconnecter',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
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
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing:
            trailing ??
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
