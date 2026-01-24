import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:essivi_mobile/theme/app_colors.dart';
import 'package:essivi_mobile/presentation/widgets/custom_button.dart';
import 'package:essivi_mobile/routes/app_routes.dart';

class ClientLandingScreen extends StatelessWidget {
  const ClientLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/delivery_man.png',
              fit: BoxFit.cover,
            ),
          ),
          // Gradient Overlay for readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.5, 0.8, 1.0],
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
                   // Skip/Back button if needed (not in design but good practice)
                   // const Spacer(), // Pushes content down
                   
                   const Spacer(),

                   // Main Text
                   Text(
                     'Receive the\nworld at your\nDoorstep',
                     style: GoogleFonts.poppins(
                       fontSize: 40,
                       fontWeight: FontWeight.bold,
                       color: Colors.white,
                       height: 1.1,
                     ),
                   ),
                   const SizedBox(height: 16),
                   
                   // Subtitle
                   Text(
                     'Enter your tracking number to get\npackage delivery detaile',
                     style: GoogleFonts.poppins(
                       fontSize: 16,
                       color: Colors.white.withOpacity(0.8),
                       height: 1.5,
                     ),
                   ),
                   
                   const SizedBox(height: 48),
                   
                   // Bottom Actions
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       TextButton(
                         onPressed: () {
                           Navigator.pushReplacementNamed(context, AppRoutes.login);
                         },
                         child: Row(
                           children: [
                             Text(
                               'Continue',
                               style: GoogleFonts.poppins(
                                 fontSize: 16,
                                 color: Colors.white,
                               ),
                             ),
                             const SizedBox(width: 8),
                             const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                           ],
                         ),
                       ),
                       CustomButton(
                         text: 'Get Started',
                         backgroundColor: AppColors.primary,
                         onTap: () {
                            Navigator.pushReplacementNamed(context, AppRoutes.login);
                         },
                       ),
                     ],
                   ),
                   const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
