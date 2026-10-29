import 'package:dartz/dartz.dart';
import 'package:provider_app/core/errors/failures.dart';
import 'package:provider_app/src/data/data_sources/remote/jobs/job_remote_data_source.dart';
import 'package:provider_app/src/domain/entities/jobs/job_entity.dart';
import 'package:provider_app/src/domain/repositories/jobs/job_repository.dart';

class JobRepositoryImpl implements JobRepository {
  final JobRemoteDataSource remoteDataSource;

  JobRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<JobEntity>>> getJobs({
    JobCategory? category,
    String? query,
  }) async {
    try {
      final models = await remoteDataSource.getJobs(
        category: category,
        query: query,
      );
      return Right(models);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, JobEntity>> getJobById(String id) async {
    try {
      final model = await remoteDataSource.getJobById(id);
      return Right(model);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, JobEntity>> submitQuote({
    required String jobId,
    required double amount,
    String? notes,
  }) async {
    try {
      final model = await remoteDataSource.submitQuote(
        jobId: jobId,
        amount: amount,
        notes: notes,
      );
      return Right(model);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, JobEntity>> updateJobStatus({
    required String jobId,
    required JobCategory status,
  }) async {
    try {
      final model = await remoteDataSource.updateJobStatus(
        jobId: jobId,
        status: status,
      );
      return Right(model);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, JobEntity>> requestExtraAmount({
    required String jobId,
    required double amount,
    required String reason,
  }) async {
    try {
      final model = await remoteDataSource.requestExtraAmount(
        jobId: jobId,
        amount: amount,
        reason: reason,
      );
      return Right(model);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, JobEntity>> completeJob({
    required String jobId,
    double? finalRating,
    String? clientFeedback,
  }) async {
    try {
      final model = await remoteDataSource.completeJob(
        jobId: jobId,
        finalRating: finalRating,
        clientFeedback: clientFeedback,
      );
      return Right(model);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
