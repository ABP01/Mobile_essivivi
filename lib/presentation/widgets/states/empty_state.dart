import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;

  const EmptyState({
    super.key,
    required this.message,
    required this.icon,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           Icon(icon, size: 80, color: Colors.grey[300]),
           const SizedBox(height: 16),
           Text(
             message,
             textAlign: TextAlign.center,
             style: GoogleFonts.poppins(
               fontSize: 16,
               color: Colors.grey[600],
             ),
           ),
           if (onRetry != null) ...[
             const SizedBox(height: 24),
             TextButton.icon(
               onPressed: onRetry,
               icon: const Icon(Icons.refresh),
               label: const Text('Réessayer'),
             ),
           ],
        ],
      ),
    );
  }
}
