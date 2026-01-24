import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:essivi_mobile/theme/app_colors.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

class ShipmentItem extends StatelessWidget {
  final String title;
  final String id;
  final VoidCallback? onTap;

  const ShipmentItem({
    super.key,
    required this.title,
    required this.id,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Dark mode consideration: The design shows dark background.
    // I will use colors that adapt or hardcode to match the dark aesthetic if user wants strictly that.
    // The prompt asked to "reproduce fully", and the middle screen is Dark Mode.
    // I will assume the redesign home is Dark Mode for now, or adaptable.
    // Let's rely on the Theme context, but optimize for the look in the screenshot (Dark).
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white; // Custom dark shade

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2022), // Matching the dark card in screenshot
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D2D),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                FluentIcons.box_24_regular, 
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                   const SizedBox(height: 4),
                  Text(
                    id,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
