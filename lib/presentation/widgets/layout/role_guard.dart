import 'package:essivi_mobile/data/repositories/auth_repository.dart';
import 'package:essivi_mobile/routes/app_routes.dart';
import 'package:flutter/material.dart';

class RoleGuard extends StatefulWidget {
  final List<String> allowedRoles;
  final Widget child;
  final String? unauthorizedRoute;
  final String? unauthenticatedRoute;

  const RoleGuard({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.unauthorizedRoute,
    this.unauthenticatedRoute,
  });

  @override
  State<RoleGuard> createState() => _RoleGuardState();
}

class _RoleGuardState extends State<RoleGuard> {
  final _authRepo = AuthRepository();
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    try {
      final isAuth = await _authRepo.isAuthenticated();
      if (!isAuth) {
        _redirect(widget.unauthenticatedRoute ?? AppRoutes.login);
        return;
      }

      final role = (await _authRepo.getUserRole())?.toLowerCase();
      if (role == null || !widget.allowedRoles.contains(role)) {
        _redirect(widget.unauthorizedRoute ?? _defaultRouteForRole(role));
        return;
      }
    } catch (_) {
      _redirect(widget.unauthenticatedRoute ?? AppRoutes.login);
      return;
    }

    if (mounted) {
      setState(() => _isChecking = false);
    }
  }

  String _defaultRouteForRole(String? role) {
    if (role == 'agent') return AppRoutes.agentDashboard;
    return AppRoutes.home;
  }

  void _redirect(String route) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return widget.child;
  }
}
