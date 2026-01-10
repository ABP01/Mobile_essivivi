import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:essivi_mobile/theme/app_colors.dart';
import 'package:essivi_mobile/routes/app_routes.dart';
import 'package:essivi_mobile/services/auth_service.dart';
import 'package:essivi_mobile/data/repositories/preferences_repository.dart';
import 'package:essivi_mobile/data/models/preferences_models.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();
  final _preferencesRepo = PreferencesRepository();
  
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'Français';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await _preferencesRepo.getPreferences();
      setState(() {
        _notificationsEnabled = prefs.notificationsEnabled;
        _emailNotifications = prefs.emailNotifications;
        _smsNotifications = prefs.smsNotifications;
        _selectedLanguage = _getLanguageLabel(prefs.language);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _getLanguageLabel(String code) {
    switch (code) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return 'Français';
    }
  }

  String _getLanguageCode(String label) {
    switch (label) {
      case 'Français':
        return 'fr';
      case 'English':
        return 'en';
      case 'Español':
        return 'es';
      default:
        return 'fr';
    }
  }

  Future<void> _updatePreference(Map<String, dynamic> update) async {
    try {
      await _preferencesRepo.updatePartialPreferences(update);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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
          'Settings',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            _buildSectionTitle('Account'),
            const SizedBox(height: 12),
            _buildSettingsTile(
              icon: FluentIcons.person_24_regular,
              title: 'Edit Profile',
              onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
            ),
            _buildSettingsTile(
              icon: FluentIcons.lock_closed_24_regular,
              title: 'Change Password',
              onTap: () => Navigator.pushNamed(context, AppRoutes.changePassword),
            ),
            const SizedBox(height: 24),

            // Notifications Section
            _buildSectionTitle('Notifications'),
            const SizedBox(height: 12),
            _buildSwitchTile(
              icon: FluentIcons.alert_24_regular,
              title: 'Push Notifications',
              subtitle: 'Receive push notifications',
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _notificationsEnabled = value);
                _updatePreference({'notifications_enabled': value});
              },
            ),
            _buildSwitchTile(
              icon: FluentIcons.mail_24_regular,
              title: 'Email Notifications',
              subtitle: 'Receive email updates',
              value: _emailNotifications,
              onChanged: (value) {
                setState(() => _emailNotifications = value);
                _updatePreference({'email_notifications': value});
              },
            ),
            _buildSwitchTile(
              icon: FluentIcons.phone_24_regular,
              title: 'SMS Notifications',
              subtitle: 'Receive SMS alerts',
              value: _smsNotifications,
              onChanged: (value) {
                setState(() => _smsNotifications = value);
                _updatePreference({'sms_notifications': value});
              },
            ),
            const SizedBox(height: 24),

            // Appearance Section
            _buildSectionTitle('Appearance'),
            const SizedBox(height: 12),
            _buildSwitchTile(
              icon: FluentIcons.dark_theme_24_regular,
              title: 'Dark Mode',
              subtitle: 'Enable dark theme',
              value: _darkModeEnabled,
              onChanged: (value) {
                setState(() => _darkModeEnabled = value);
                // Note: In a real app, this would trigger theme change
              },
            ),
            _buildSettingsTile(
              icon: FluentIcons.local_language_24_regular,
              title: 'Language',
              trailing: Text(
                _selectedLanguage,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
              onTap: () => _showLanguageDialog(),
            ),
            const SizedBox(height: 24),

            // Support Section
            _buildSectionTitle('Support'),
            const SizedBox(height: 12),
            _buildSettingsTile(
              icon: FluentIcons.chat_help_24_regular,
              title: 'Help Center',
              onTap: () => Navigator.pushNamed(context, AppRoutes.helpCenter),
            ),
            _buildSettingsTile(
              icon: FluentIcons.info_24_regular,
              title: 'About',
              onTap: () => _showAboutDialog(),
            ),
            _buildSettingsTile(
              icon: FluentIcons.document_text_24_regular,
              title: 'Terms & Conditions',
              onTap: () {
                // Navigate to terms
              },
            ),
            _buildSettingsTile(
              icon: FluentIcons.shield_checkmark_24_regular,
              title: 'Privacy Policy',
              onTap: () {
                // Navigate to privacy policy
              },
            ),
            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await _authService.logout();
                  if (!mounted) return;
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.red.withValues(alpha: 0.1) : Colors.red.shade50,
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
                      'Logout',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Version Info
            Center(
              child: Text(
                'Version 1.0.0',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: theme.textTheme.bodyLarge?.color,
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
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
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                ],
              ),
            ),
            trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Language',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('Français'),
            _buildLanguageOption('English'),
            _buildLanguageOption('Español'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language) {
    return RadioListTile<String>(
      title: Text(language, style: GoogleFonts.poppins()),
      value: language,
      groupValue: _selectedLanguage,
      onChanged: (value) {
        setState(() => _selectedLanguage = value!);
        _updatePreference({'language': _getLanguageCode(value!)});
        Navigator.pop(context);
      },
      activeColor: AppColors.primary,
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'About Essivi',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Essivi Water Delivery',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              'Your trusted partner for clean water delivery in Togo.',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            const SizedBox(height: 16),
            Text(
              '© 2024 Essivi. All rights reserved.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
