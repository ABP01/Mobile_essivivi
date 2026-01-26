import 'package:flutter/material.dart';
import 'package:essivi_mobile/data/repositories/auth_repository.dart';
import 'package:essivi_mobile/routes/app_routes.dart';
import 'package:essivi_mobile/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _authRepo = AuthRepository();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // 🚀 Optimisation: Démarrage immédiat sans délai artificiel de 2s.
    // L'expérience est fluide : si le tel est rapide, l'app s'ouvre instantanément.
    
    try {
      final isAuthenticated = await _authRepo.isAuthenticated();

      if (!mounted) return;

      if (isAuthenticated) {
         final role = await _authRepo.getUserRole();
         if (!mounted) return;
         
         if (role == 'agent') {
           Navigator.pushReplacementNamed(context, AppRoutes.agentDashboard);
         } else {
           Navigator.pushReplacementNamed(context, AppRoutes.clientHomeRedesign);
         }
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.clientLanding);
      }
    } catch (e) {
      // Sécurité : En cas d'erreur (ex: stockage corrompu), on redirige vers l'accueil/login
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.clientLanding);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ Correction: Fond blanc pour matcher le "launch_background.xml" natif et éviter le flash noir/blanc.
      backgroundColor: Colors.white, 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ Identité: On garde le logo visible pendant chargement
            Image.asset(
              'assets/logo/splashlogo.png',
              width: 180,
              height: 180,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.water_drop, size: 100, color: AppColors.primary);
              },
            ),
            const SizedBox(height: 48),
            // ✅ UX: Feedback visuel subtil
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
