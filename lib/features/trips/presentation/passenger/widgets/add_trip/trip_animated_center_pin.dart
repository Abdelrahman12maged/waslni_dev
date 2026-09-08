import 'package:flutter/material.dart';

/// Animated bouncing center pin on the map indicating current picking step.
class TripAnimatedCenterPin extends StatelessWidget {
  final Animation<double> pinOffset;
  final Color stepColor;
  final int step;

  const TripAnimatedCenterPin({
    super.key,
    required this.pinOffset,
    required this.stepColor,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: pinOffset,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, pinOffset.value - 28),
          child: child,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: stepColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: stepColor.withOpacity(0.45),
                    blurRadius: 16,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Icon(
                step == 0 ? Icons.my_location : Icons.flag_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            Container(width: 2, height: 18, color: stepColor),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: stepColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
