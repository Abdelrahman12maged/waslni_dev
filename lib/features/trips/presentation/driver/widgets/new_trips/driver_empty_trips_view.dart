import 'dart:async';
import 'package:flutter/material.dart';
import 'package:car_app/generated/l10n.dart';

/// Empty state when no new trips are available.
class DriverEmptyTripsView extends StatelessWidget {
  final bool isPrivate;

  const DriverEmptyTripsView({super.key, required this.isPrivate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPrivate ? Icons.directions_car_outlined : Icons.group_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 14),
            Text(
              isPrivate
                  ? S.of(context).noNewPrivateTrips
                  : S.of(context).noNewSharedTrips,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              S.of(context).expandSearchRadiusHint,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Auto-refresh wrapper widget that triggers a periodic callback.
class DriverAutoRefreshView extends StatefulWidget {
  final Widget child;
  final VoidCallback onRefresh;

  const DriverAutoRefreshView({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  State<DriverAutoRefreshView> createState() => _DriverAutoRefreshViewState();
}

class _DriverAutoRefreshViewState extends State<DriverAutoRefreshView> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      widget.onRefresh();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
