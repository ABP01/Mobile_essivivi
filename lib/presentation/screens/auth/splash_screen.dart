import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:essivi_mobile/routes/app_routes.dart';
import 'package:essivi_mobile/theme/app_colors.dart';
import 'package:essivi_mobile/presentation/providers/auth_provider_simple.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Petit délai pour montrer le logo
    await Future.delayed(const Duration(seconds: 1));
    
    // Déconnecter l'utilisateur s'il était connecté
    await ref.read(authProviderSimple.notifier).logout();
    
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
