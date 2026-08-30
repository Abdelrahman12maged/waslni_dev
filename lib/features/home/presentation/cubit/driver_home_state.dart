import 'package:car_app/features/home/domain/entities/driver_trips_summary.dart';

abstract class DriverHomeState {
  const DriverHomeState();
}

class DriverHomeInitial extends DriverHomeState {
  const DriverHomeInitial();
}

class DriverHomeLoading extends DriverHomeState {
  const DriverHomeLoading();
}

class DriverHomeLoaded extends DriverHomeState {
  final DriverTripsSummary summary;
  final String driverName;
  final String walletBalance;
  final String? driverPhotoUrl;
  final bool isKycActive;

  const DriverHomeLoaded({
    required this.summary,
    this.driverName = '',
    this.walletBalance = '0.0',
    this.driverPhotoUrl,
    this.isKycActive = false,
  });
}

class DriverHomeError extends DriverHomeState {
  final String message;
  const DriverHomeError(this.message);
}
