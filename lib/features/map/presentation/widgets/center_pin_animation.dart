import 'package:flutter/material.dart';

/// Animated bouncing center pin for the map — used during drag-to-select mode.
/// The pin animates up/down to signal to the user that they can drag to select a location.
class CenterPinAnimation extends StatefulWidget {
  const CenterPinAnimation({
    super.key,
    this.pinColor,
    this.shadowColor,
    this.size = 48.0,
  });

  final Color? pinColor;
  final Color? shadowColor;
  final double size;

  @override
  State<CenterPinAnimation> createState() => _CenterPinAnimationState();
}

class _CenterPinAnimationState extends State<CenterPinAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _offsetAnimation = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _shadowAnimation = Tween<double>(begin: 0.8, end: 0.4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pinColor = widget.pinColor ?? Theme.of(context).colorScheme.primary;
    final shadowColor = widget.shadowColor ?? Colors.black26;

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pin
            Transform.translate(
              offset: Offset(0, _offsetAnimation.value),
              child: Icon(
                Icons.location_pin,
                color: pinColor,
                size: widget.size,
              ),
            ),

            const SizedBox(height: 4),

            // Shadow ellipse
            Opacity(
              opacity: _shadowAnimation.value,
              child: Container(
                width: widget.size * 0.5,
                height: 6,
                decoration: BoxDecoration(
                  color: shadowColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
