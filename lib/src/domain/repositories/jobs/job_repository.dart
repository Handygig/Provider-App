import 'package:dartz/dartz.dart';
import 'package:provider_app/core/errors/failures.dart';
import 'package:provider_app/src/domain/entities/jobs/job_entity.dart';

abstract class JobRepository {
  Future<Either<Failure, List<JobEntity>>> getJobs({
    JobCategory? category,
    String? query,
  });
  Future<Either<Failure, JobEntity>> getJobById(String id);
  Future<Either<Failure, JobEntity>> submitQuote({
    required String jobId,
    required double amount,
    String? notes,
  });
  Future<Either<Failure, JobEntity>> updateJobStatus({
    required String jobId,
    required JobCategory status,
  });
  Future<Either<Failure, JobEntity>> requestExtraAmount({
    required String jobId,
    required double amount,
    required String reason,
  });
  Future<Either<Failure, JobEntity>> completeJob({
    required String jobId,
    double? finalRating,
    String? clientFeedback,
  });
}
