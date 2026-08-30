import 'package:car_app/features/home/domain/entities/nearby_trip.dart';

abstract class PassengerHomeState {
  const PassengerHomeState();
}

class PassengerHomeInitial extends PassengerHomeState {
  const PassengerHomeInitial();
}

class PassengerHomeLoading extends PassengerHomeState {
  const PassengerHomeLoading();
}

class PassengerHomeLoaded extends PassengerHomeState {
  final List<NearbyTrip> nearbyTrips;
  final int carouselIndex;

  const PassengerHomeLoaded({
    required this.nearbyTrips,
    this.carouselIndex = 0,
  });

  PassengerHomeLoaded copyWith({
    List<NearbyTrip>? nearbyTrips,
    int? carouselIndex,
  }) {
    return PassengerHomeLoaded(
      nearbyTrips: nearbyTrips ?? this.nearbyTrips,
      carouselIndex: carouselIndex ?? this.carouselIndex,
    );
  }
}

class PassengerHomeError extends PassengerHomeState {
  final String message;
  const PassengerHomeError(this.message);
}
