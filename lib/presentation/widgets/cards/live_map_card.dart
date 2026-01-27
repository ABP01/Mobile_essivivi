import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LiveMapCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onOpenMap;

  const LiveMapCard({
    super.key,
    this.title = 'Suivi en direct',
    this.subtitle = 'Voir la position du livreur sur la carte',
    this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        children: [
          const Icon(Icons.map_outlined, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
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
          if (onOpenMap != null)
            IconButton(
              onPressed: onOpenMap,
              icon: const Icon(Icons.chevron_right),
            ),
        ],
      ),
    );
  }
}
