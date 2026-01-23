import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:essivi_mobile/theme/app_colors.dart';
import 'package:essivi_mobile/routes/app_routes.dart';
import 'package:essivi_mobile/l10n/app_localizations.dart';
import 'package:essivi_mobile/presentation/providers/auth_provider_simple.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    // Clear previous errors
    setState(() => _errorMessage = null);

    // Use Riverpod provider
    await ref.read(authProviderSimple.notifier).login(username, password);

    if (!mounted) return;

    // Check auth state
    final authState = ref.read(authProviderSimple);
    
    if (authState.isAuthenticated && authState.user != null) {
      // Navigate based on user role
      if (authState.user!.role == 'agent') {
        Navigator.pushReplacementNamed(context, AppRoutes.agentDashboard);
      } else {
        // All other roles (client, admin, etc.) go to home for now
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } else if (authState.error != null) {
      // Invalid credentials
      setState(() {
        _errorMessage = authState.error!.message;
      });
    }
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
            // Back Button Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  GestureDetector(
                  onTap: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
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
                ],
              ),
            ),
            // Login Form
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                Text(
                  AppLocalizations.of(context)!.welcomeBack,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.signInToContinue,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 40),
              
              // Username Field
              TextField(
                controller: _usernameController,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'Entrez votre nom d\'utilisateur',
                  hintStyle: theme.textTheme.bodySmall,
                  labelStyle: theme.textTheme.bodyMedium,
                  prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.dividerColor, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.dividerColor, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              
              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.changePassword.split(' ').last, // Use part of Change Password for "Password"
                  hintText: AppLocalizations.of(context)!.changePassword.split(' ').last,
                  labelStyle: theme.textTheme.bodyMedium,
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.dividerColor, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.dividerColor, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 8),
              
              // Error Message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.poppins(
                            color: Colors.red.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              
              // Login Button
              ElevatedButton(
                onPressed: ref.watch(authProviderSimple).isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: ref.watch(authProviderSimple).isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      AppLocalizations.of(context)!.login,
                      style: GoogleFonts.poppins(
                        fontSize: 16, 
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
              ),
              
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.dontHaveAccount,
                    style: GoogleFonts.poppins(color: theme.textTheme.bodySmall?.color),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.signup);
                    },
                    child: Text(
                      ' ${AppLocalizations.of(context)!.signUp}',
                      style: GoogleFonts.poppins(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
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
  }
}
