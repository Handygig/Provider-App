import 'package:dartz/dartz.dart';
import 'package:provider_app/core/errors/failures.dart';
import 'package:provider_app/core/usecases/usecases.dart';
import 'package:provider_app/src/domain/entities/coverage/working_hours_coverage_entity.dart';
import 'package:provider_app/src/domain/repositories/coverage/coverage_repository.dart';

class GetCoverageUseCase
    implements UseCase<WorkingHoursCoverageEntity, NoParams> {
  final CoverageRepository _repository;

  GetCoverageUseCase(this._repository);

  @override
  Future<Either<Failure, WorkingHoursCoverageEntity>> call(NoParams params) {
    return _repository.getCoverage();
  }
}

class UpdateCoverageUseCase
    implements UseCase<WorkingHoursCoverageEntity, WorkingHoursCoverageEntity> {
  final CoverageRepository _repository;

  UpdateCoverageUseCase(this._repository);

  @override
  Future<Either<Failure, WorkingHoursCoverageEntity>> call(
      WorkingHoursCoverageEntity params) {
    return _repository.updateCoverage(params);
  }
}

class ToggleAvailabilityUseCase implements UseCase<bool, bool> {
  final CoverageRepository _repository;

  ToggleAvailabilityUseCase(this._repository);

  @override
  Future<Either<Failure, bool>> call(bool params) {
    return _repository.toggleAvailability(params);
  }
}
