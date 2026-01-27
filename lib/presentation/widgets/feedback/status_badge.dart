import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum StatusType {
  pending,
  processing,
  completed,
  cancelled,
  error,
}

class StatusBadge extends StatelessWidget {
  final String label;
  final StatusType type;

  const StatusBadge({
    super.key,
    required this.label,
    this.type = StatusType.pending,
  });

  Color _getBackgroundColor(StatusType type) {
    switch (type) {
      case StatusType.pending:
        return Colors.orange.withOpacity(0.1);
      case StatusType.processing:
        return Colors.blue.withOpacity(0.1);
      case StatusType.completed:
        return Colors.green.withOpacity(0.1);
      case StatusType.cancelled:
      case StatusType.error:
        return Colors.red.withOpacity(0.1);
    }
  }

  Color _getTextColor(StatusType type) {
    switch (type) {
      case StatusType.pending:
        return Colors.orange;
      case StatusType.processing:
        return Colors.blue;
      case StatusType.completed:
        return Colors.green;
      case StatusType.cancelled:
      case StatusType.error:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getBackgroundColor(type),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _getTextColor(type),
        ),
      ),
    );
  }
}
