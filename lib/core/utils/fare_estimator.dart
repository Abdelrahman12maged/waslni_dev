import 'package:car_app/features/trips/domain/entities/trip.dart';

/// Holds the result of a fare estimation.
class FareEstimate {
  /// The computed reference (suggested) price in JOD.
  final double referencePrice;

  /// Minimum price the passenger can set (referencePrice × 0.70).
  final double minimumPrice;

  /// Maximum price the passenger can set (referencePrice × 1.50).
  final double maximumPrice;

  const FareEstimate({
    required this.referencePrice,
    required this.minimumPrice,
    required this.maximumPrice,
  });
}

/// Per-vehicle-type rate card (JOD).
class _RateCard {
  final double baseFare;
  final double perKm;
  final double perMinute;
  const _RateCard({
    required this.baseFare,
    required this.perKm,
    required this.perMinute,
  });
}

/// Pure-Dart service that converts route metrics into a fare estimate.
class FareEstimator {
  FareEstimator._();

  static const _rates = {
    VehicleType.car: _RateCard(baseFare: 1.500, perKm: 0.400, perMinute: 0.050),
    VehicleType.motorcycle: _RateCard(baseFare: 0.800, perKm: 0.200, perMinute: 0.030),
    VehicleType.bicycle: _RateCard(baseFare: 0.300, perKm: 0.100, perMinute: 0.015),
  };

  /// Discount / premium multipliers for the negotiation band.
  static const double _minMultiplier = 0.70;
  static const double _maxMultiplier = 1.50;

  /// Returns a [FareEstimate] rounded to 2 decimal places (JOD standard).
  static FareEstimate estimate({
    required VehicleType vehicleType,
    required double distanceKm,
    required double durationMinutes,
  }) {
    final card = _rates[vehicleType] ?? _rates[VehicleType.car]!;
    final ref = card.baseFare + (distanceKm * card.perKm) + (durationMinutes * card.perMinute);
    final reference = _round(ref);
    return FareEstimate(
      referencePrice: reference,
      minimumPrice: _round(reference * _minMultiplier),
      maximumPrice: _round(reference * _maxMultiplier),
    );
  }

  static double _round(double v) => double.parse(v.toStringAsFixed(2));
}
