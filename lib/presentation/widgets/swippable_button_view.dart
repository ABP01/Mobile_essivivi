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
        _maxDrag = constraints.maxWidth - 60; // 60 is button width approx

        return Container(
          height: 60,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
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
                left: _position,
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
                    height: 60,
                    width: 60,
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
        );
      },
    );
  }
}
