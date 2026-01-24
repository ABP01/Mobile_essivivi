import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:essivi_mobile/theme/app_colors.dart';

class SwippableButtonView extends StatefulWidget {
  final VoidCallback onFinish;
  final String label;
  final Color buttonColor;
  final Color backgroundColor;
  final Color labelColor;
  final IconData icon;

  const SwippableButtonView({
    super.key,
    required this.onFinish,
    this.label = 'Get Started',
    this.buttonColor = AppColors.primary,
    this.backgroundColor = const Color(0xFF1F2022),
    this.labelColor = Colors.white,
    this.icon = Icons.arrow_forward_ios,
  });

  @override
  State<SwippableButtonView> createState() => _SwippableButtonViewState();
}

class _SwippableButtonViewState extends State<SwippableButtonView> with SingleTickerProviderStateMixin {
  double _position = 0.0;
  double _maxDrag = 0.0;
  bool _isFinished = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double totalHeight = 70.0;
        const double buttonSize = 60.0;
        const double padding = (totalHeight - buttonSize) / 2;
        
        _maxDrag = constraints.maxWidth - buttonSize - (padding * 2);

        return ClipRRect(
          borderRadius: BorderRadius.circular(totalHeight / 2),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: totalHeight,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15), // Glassy background
                borderRadius: BorderRadius.circular(totalHeight / 2),
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
              ),
              child: Stack(
                children: [
                  // Label
                  Center(
                    child: Opacity(
                      opacity: 1 - (_position / _maxDrag).clamp(0.0, 1.0),
                      child: Text(
                        widget.label,
                        style: TextStyle(
                          color: widget.labelColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Button
                  Positioned(
                    left: _position + padding,
                    top: padding,
                    child: GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        if (_isFinished) return;
                        setState(() {
                          _position += details.delta.dx;
                          _position = _position.clamp(0.0, _maxDrag);
                        });
                      },
                      onHorizontalDragEnd: (details) {
                        if (_isFinished) return;
                        if (_position >= _maxDrag * 0.75) {
                          setState(() {
                            _position = _maxDrag;
                            _isFinished = true;
                          });
                          widget.onFinish();
                        } else {
                          setState(() {
                            _position = 0;
                            _isFinished = false;
                          });
                        }
                      },
                      child: Container(
                        height: buttonSize,
                        width: buttonSize,
                        decoration: BoxDecoration(
                          color: widget.buttonColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                             BoxShadow(
                               color: widget.buttonColor.withOpacity(0.4),
                               blurRadius: 10,
                               offset: const Offset(0, 4),
                             )
                          ]
                        ),
                        child: Icon(
                          widget.icon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
