import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_app/core/di/injection_container.dart' as di;
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/features/ratings/presentation/cubit/ratings_cubit.dart';
import 'package:car_app/features/ratings/presentation/widgets/driver_ratings_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Driver Ratings Screen
// ─────────────────────────────────────────────────────────────────────────────
class DriverRatingsScreen extends StatelessWidget {
  final int driverId;
  final String? driverName;

  const DriverRatingsScreen({
    super.key,
    required this.driverId,
    this.driverName,
  });

  int get _effectiveDriverId {
    if (driverId > 0) return driverId;
    try {
      final storage = di.sl<LocalStorage>();
      return int.tryParse(
            storage.read(key: 'userid')?.toString() ??
            storage.read(key: 'user_id')?.toString() ??
            storage.read(key: 'driver_id')?.toString() ??
            '',
          ) ??
          0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveId = _effectiveDriverId;
    return BlocProvider(
      create: (_) =>
          di.sl<RatingsCubit>()..getDriverRatings(driverId: effectiveId),
      child: DriverRatingsView(
        driverId: effectiveId,
        driverName: driverName,
      ),
    );
  }
}
