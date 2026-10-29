import 'package:dartz/dartz.dart';
import 'package:provider_app/core/errors/failures.dart';
import 'package:provider_app/core/usecases/usecases.dart';
import 'package:provider_app/src/domain/entities/jobs/job_entity.dart';
import 'package:provider_app/src/domain/repositories/jobs/job_repository.dart';

class GetJobsParams {
  final JobCategory? category;
  final String? query;

  const GetJobsParams({this.category, this.query});
}

class GetJobsUseCase implements UseCase<List<JobEntity>, GetJobsParams> {
  final JobRepository _repository;

  GetJobsUseCase(this._repository);

  @override
  Future<Either<Failure, List<JobEntity>>> call(GetJobsParams params) {
    return _repository.getJobs(
      category: params.category,
      query: params.query,
    );
  }
}

class GetJobDetailsUseCase implements UseCase<JobEntity, String> {
  final JobRepository _repository;

  GetJobDetailsUseCase(this._repository);

  @override
  Future<Either<Failure, JobEntity>> call(String jobId) {
    return _repository.getJobById(jobId);
  }
}

class SubmitQuoteParams {
  final String jobId;
  final double amount;
  final String? notes;

  const SubmitQuoteParams({
    required this.jobId,
    required this.amount,
    this.notes,
  });
}

class SubmitQuoteUseCase implements UseCase<JobEntity, SubmitQuoteParams> {
  final JobRepository _repository;

  SubmitQuoteUseCase(this._repository);

  @override
  Future<Either<Failure, JobEntity>> call(SubmitQuoteParams params) {
    return _repository.submitQuote(
      jobId: params.jobId,
      amount: params.amount,
      notes: params.notes,
    );
  }
}

class UpdateJobStatusParams {
  final String jobId;
  final JobCategory status;

  const UpdateJobStatusParams({
    required this.jobId,
    required this.status,
  });
}

class UpdateJobStatusUseCase
    implements UseCase<JobEntity, UpdateJobStatusParams> {
  final JobRepository _repository;

  UpdateJobStatusUseCase(this._repository);

  @override
  Future<Either<Failure, JobEntity>> call(UpdateJobStatusParams params) {
    return _repository.updateJobStatus(
      jobId: params.jobId,
      status: params.status,
    );
  }
}

class RequestExtraAmountParams {
  final String jobId;
  final double amount;
  final String reason;

  const RequestExtraAmountParams({
    required this.jobId,
    required this.amount,
    required this.reason,
  });
}

class RequestExtraAmountUseCase
    implements UseCase<JobEntity, RequestExtraAmountParams> {
  final JobRepository _repository;

  RequestExtraAmountUseCase(this._repository);

  @override
  Future<Either<Failure, JobEntity>> call(RequestExtraAmountParams params) {
    return _repository.requestExtraAmount(
      jobId: params.jobId,
      amount: params.amount,
      reason: params.reason,
    );
  }
}

class CompleteJobParams {
  final String jobId;
  final double? finalRating;
  final String? clientFeedback;

  const CompleteJobParams({
    required this.jobId,
    this.finalRating,
    this.clientFeedback,
  });
}

class CompleteJobUseCase implements UseCase<JobEntity, CompleteJobParams> {
  final JobRepository _repository;

  CompleteJobUseCase(this._repository);

  @override
  Future<Either<Failure, JobEntity>> call(CompleteJobParams params) {
    return _repository.completeJob(
      jobId: params.jobId,
      finalRating: params.finalRating,
      clientFeedback: params.clientFeedback,
    );
  }
}
