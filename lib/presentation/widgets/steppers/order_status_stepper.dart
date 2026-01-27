import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderStatusStepper extends StatelessWidget {
  final List<String> steps;
  final int currentStep;

  const OrderStatusStepper({
    super.key,
    required this.steps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < steps.length; i++)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                   Container(
                     width: 24,
                     height: 24,
                     decoration: BoxDecoration(
                       shape: BoxShape.circle,
                       color: i <= currentStep ? Colors.green : Colors.grey[300],
                       border: Border.all(
                         color: i <= currentStep ? Colors.green : Colors.grey[300]!,
                         width: 2,
                       ),
                     ),
                     child: i <= currentStep
                         ? const Icon(Icons.check, size: 16, color: Colors.white)
                         : null,
                   ),
                   if (i < steps.length - 1)
                     Container(
                       width: 2,
                       height: 40,
                       color: i < currentStep ? Colors.green : Colors.grey[300],
                     ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      steps[i],
                      style: GoogleFonts.poppins(
                        fontWeight: i <= currentStep ? FontWeight.bold : FontWeight.normal,
                        color: i <= currentStep ? Colors.black : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 30), // Match the line height logic roughly
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}
