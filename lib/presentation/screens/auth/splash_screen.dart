import 'package:essivi_mobile/data/repositories/auth_repository.dart';
import 'package:essivi_mobile/routes/app_routes.dart';
import 'package:essivi_mobile/theme/app_colors.dart';
import 'package:flutter/material.dart';

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
                debugPrint('Erreur chargement logo: $error');
                debugPrint('Stack trace: $stackTrace');
                return Container(
                  width: 180,
                  height: 180,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Text(
                      'Logo non trouvé',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                );
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
