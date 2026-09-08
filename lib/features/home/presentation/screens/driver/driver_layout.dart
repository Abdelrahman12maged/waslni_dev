import 'package:flutter/material.dart';
import 'package:car_app/features/home/presentation/screens/driver/widgets/driver_layout_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Driver Layout
// ─────────────────────────────────────────────────────────────────────────────
class DriverLayout extends StatelessWidget {
  final dynamic currentIndex;

  const DriverLayout({super.key, this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return DriverLayoutView(currentIndex: currentIndex);
  }
}
