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
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;

    final isAuthenticated = await _authService.isAuthenticated();

    if (isAuthenticated) {
       final role = await _authService.getCurrentUserRole();
       if (!mounted) return;
       
       if (role == UserRole.agent) {
         Navigator.pushReplacementNamed(context, AppRoutes.agentDashboard);
       } else {
         Navigator.pushReplacementNamed(context, AppRoutes.clientHomeRedesign);
       }
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.clientLanding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0D0D0D), // Dark background for consistency
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}
