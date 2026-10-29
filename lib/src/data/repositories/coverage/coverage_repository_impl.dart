import 'package:dartz/dartz.dart';
import 'package:provider_app/core/errors/failures.dart';
import 'package:provider_app/src/data/data_sources/remote/coverage/coverage_remote_data_source.dart';
import 'package:provider_app/src/data/models/coverage/working_hours_coverage_model.dart';
import 'package:provider_app/src/domain/entities/coverage/working_hours_coverage_entity.dart';
import 'package:provider_app/src/domain/repositories/coverage/coverage_repository.dart';

class CoverageRepositoryImpl implements CoverageRepository {
  final CoverageRemoteDataSource remoteDataSource;

  CoverageRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, WorkingHoursCoverageEntity>> getCoverage() async {
    try {
      final model = await remoteDataSource.getCoverage();
      return Right(model);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WorkingHoursCoverageEntity>> updateCoverage(
      WorkingHoursCoverageEntity coverage) async {
    try {
      final model = coverage is WorkingHoursCoverageModel
          ? coverage
          : WorkingHoursCoverageModel(
              isAvailableNow: coverage.isAvailableNow,
              schedules: coverage.schedules,
              baseLocation: coverage.baseLocation,
              baseLatitude: coverage.baseLatitude,
              baseLongitude: coverage.baseLongitude,
              radiusKm: coverage.radiusKm,
              catalogZones: coverage.catalogZones,
              selectedZones: coverage.selectedZones,
              acceptEmergencyJobs: coverage.acceptEmergencyJobs,
              emergencyMultiplier: coverage.emergencyMultiplier,
              allowExtraDistance: coverage.allowExtraDistance,
              extraDistanceRatePerKm: coverage.extraDistanceRatePerKm,
            );
      final updated = await remoteDataSource.updateCoverage(model);
      return Right(updated);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleAvailability(bool isAvailable) async {
    try {
      final result = await remoteDataSource.toggleAvailability(isAvailable);
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
