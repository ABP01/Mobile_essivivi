import 'package:flutter/material.dart';

class RoleBasedGuard extends StatelessWidget {
  final Widget child;
  final List<String> allowedRoles;
  final String userRole;

  const RoleBasedGuard({
    super.key,
    required this.child,
    required this.allowedRoles,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    if (!allowedRoles.contains(userRole)) {
      // Forbidden Access
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Accès non autorisé',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Cet écran est réservé aux ${allowedRoles.join(', ')}.'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
      );
    }
    return child;
  }
}
