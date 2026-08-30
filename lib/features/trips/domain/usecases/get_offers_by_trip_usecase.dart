import 'package:car_app/core/error/failures.dart';
import 'package:car_app/features/trips/domain/entities/offer.dart';
import 'package:car_app/features/trips/domain/repositories/trips_repository.dart';
import 'package:dartz/dartz.dart';

class GetOffersByTripUseCase {
  final TripsRepository _repository;
  const GetOffersByTripUseCase(this._repository);

  Future<Either<Failure, List<Offer>>> call(int tripId) =>
      _repository.getOffersByTrip(tripId: tripId);
}
