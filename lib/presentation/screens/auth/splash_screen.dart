import 'package:flutter/material.dart';
import 'package:essivi_mobile/services/auth_service.dart';
import 'package:essivi_mobile/routes/app_routes.dart';
import 'package:essivi_mobile/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Petit délai pour montrer le logo
    await Future.delayed(const Duration(seconds: 1));
    
    // Déconnecter l'utilisateur s'il était connecté
    await _authService.logout();
    
    if (!mounted) return;
    
    // Toujours aller vers le login
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
