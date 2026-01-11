import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:essivi_mobile/theme/app_colors.dart';
import 'package:essivi_mobile/routes/app_routes.dart';
import 'package:essivi_mobile/l10n/app_localizations.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Retourground Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/delivery_man.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.9),
                  ],
                  stops: const [0.4, 0.6, 0.8, 1.0],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Spacer(), // Push content to bottom
                   Text(
                     AppLocalizations.of(context)!.onboardingTitle,
                     style: GoogleFonts.poppins(
                       fontSize: 40,
                       fontWeight: FontWeight.bold,
                       color: Colors.white,
                       height: 1.1,
                     ),
                   ),
                   const SizedBox(height: 16),
                   Text(
                     AppLocalizations.of(context)!.onboardingSubtitle,
                     style: GoogleFonts.poppins(
                       fontSize: 16,
                       color: Colors.white70,
                     ),
                   ),
                   const SizedBox(height: 40),
                   // Buttons Row
                   Row(
                     children: [
                       GestureDetector(
                         onTap: () {
                           Navigator.pushNamed(context, AppRoutes.login);
                         },
                         child: Row(
                           children: [
                             Text(
                               AppLocalizations.of(context)!.continueText,
                               style: GoogleFonts.poppins(
                                 fontSize: 16,
                                 color: Colors.white,
                                 fontWeight: FontWeight.w500,
                               ),
                             ),
                             const SizedBox(width: 8),
                             const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                           ],
                         ),
                       ),
                       const Spacer(),
                       SizedBox(
                         height: 56,
                         child: ElevatedButton(
                           onPressed: () {
                             Navigator.pushNamed(context, AppRoutes.login);
                           },
                           style: ElevatedButton.styleFrom(
                             backgroundColor: AppColors.primary,
                             shape: RoundedRectangleBorder(
                               borderRadius: BorderRadius.circular(30),
                             ),
                             padding: const EdgeInsets.symmetric(horizontal: 40),
                           ),
                           child: Text(
                             AppLocalizations.of(context)!.getStarted,
                             style: GoogleFonts.poppins(
                               fontSize: 16,
                               fontWeight: FontWeight.w600,
                               color: Colors.white,
                             ),
                           ),
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 20),
                   // Bas indicator line (iOS home indicator style)
                   Center(
                     child: Container(
                       width: 40,
                       height: 4,
                       decoration: BoxDecoration(
                         color: Colors.white54,
                         borderRadius: BorderRadius.circular(2),
                       ),
                     ),
                   ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
