import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderStatusStepper extends StatelessWidget {
  final String status;
  final List<_StepItem> steps;

  OrderStatusStepper({super.key, required this.status, List<_StepItem>? steps})
    : steps = steps ?? _defaultSteps;

  static final List<_StepItem> _defaultSteps = [
    _StepItem(key: 'pending', label: 'En attente'),
    _StepItem(key: 'validated', label: 'Validée'),
    _StepItem(key: 'on_delivery', label: 'En livraison'),
    _StepItem(key: 'delivered', label: 'Livrée'),
  ];

  int _currentIndex() {
    final idx = steps.indexWhere((s) => s.key == status);
    if (idx == -1 && status == 'cancelled') return 0;
    return idx == -1 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = _currentIndex();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progression',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(steps.length, (index) {
            final isActive = index <= current;
            final isLast = index == steps.length - 1;

            return Expanded(
              child: Row(
                children: [
                  _StepDot(isActive: isActive),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: isActive
                            ? theme.primaryColor
                            : Colors.grey.shade300,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          children: steps.map((step) {
            final isActive = steps.indexOf(step) <= current;
            return Expanded(
              child: Text(
                step.label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? theme.primaryColor : Colors.grey,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _StepItem {
  final String key;
  final String label;

  const _StepItem({required this.key, required this.label});
}

class _StepDot extends StatelessWidget {
  final bool isActive;

  const _StepDot({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: isActive ? theme.primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? theme.primaryColor : Colors.grey.shade300,
          width: 2,
        ),
      ),
    );
  }
}
