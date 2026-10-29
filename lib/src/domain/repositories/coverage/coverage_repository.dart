import 'package:dartz/dartz.dart';
import 'package:provider_app/core/errors/failures.dart';
import 'package:provider_app/src/domain/entities/coverage/working_hours_coverage_entity.dart';

abstract class CoverageRepository {
  Future<Either<Failure, WorkingHoursCoverageEntity>> getCoverage();
  Future<Either<Failure, WorkingHoursCoverageEntity>> updateCoverage(
      WorkingHoursCoverageEntity coverage);
  Future<Either<Failure, bool>> toggleAvailability(bool isAvailable);
}
