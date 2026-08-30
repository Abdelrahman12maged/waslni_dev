import 'package:car_app/core/error/failures.dart';
import 'package:car_app/core/usecases/usecase.dart';
import 'package:car_app/features/driver_documents/domain/entities/driver_documents_status.dart';
import 'package:car_app/features/driver_documents/domain/repositories/driver_documents_repository.dart';
import 'package:dartz/dartz.dart';

/// Fetch the driver's current document statuses and KYC account state.
class GetDriverDocumentsUseCase implements UseCase<DriverDocumentsStatus, NoParams> {
  final DriverDocumentsRepository repository;

  GetDriverDocumentsUseCase(this.repository);

  @override
  Future<Either<Failure, DriverDocumentsStatus>> call(NoParams params) {
    return repository.getDocuments();
  }
}
