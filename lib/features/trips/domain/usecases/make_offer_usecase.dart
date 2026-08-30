import 'package:car_app/core/error/failures.dart';
import 'package:car_app/features/trips/domain/repositories/trips_repository.dart';
import 'package:dartz/dartz.dart';

class MakeOfferUseCase {
  final TripsRepository repository;

  MakeOfferUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required Map<String, dynamic> offerData,
  }) async {
    return await repository.makeOffer(offerData: offerData);
  }
}
