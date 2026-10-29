import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider_app/src/domain/entities/jobs/job_entity.dart';
import 'package:provider_app/src/domain/usecases/jobs/job_usecases.dart';
import 'package:provider_app/src/presentation/cubits/jobs/jobs_state.dart';

class JobsCubit extends Cubit<JobsState> {
  final GetJobsUseCase getJobsUseCase;
  final GetJobDetailsUseCase getJobDetailsUseCase;
  final SubmitQuoteUseCase submitQuoteUseCase;
  final UpdateJobStatusUseCase updateJobStatusUseCase;
  final RequestExtraAmountUseCase requestExtraAmountUseCase;
  final CompleteJobUseCase completeJobUseCase;

  List<JobEntity> _cachedJobs = const [];

  JobsCubit({
    required this.getJobsUseCase,
    required this.getJobDetailsUseCase,
    required this.submitQuoteUseCase,
    required this.updateJobStatusUseCase,
    required this.requestExtraAmountUseCase,
    required this.completeJobUseCase,
  }) : super(const JobsInitial());

  List<JobEntity> get jobs => _cachedJobs;

  Future<void> loadJobs({
    bool silent = false,
    JobCategory? category,
    String? query,
  }) async {
    if (!silent) {
      emit(const JobsLoading());
    }

    final result = await getJobsUseCase(GetJobsParams(
      category: null,
      query: query,
    ));

    result.fold(
      (failure) => emit(JobsError(failure.errorMessage)),
      (jobsList) {
        _cachedJobs = jobsList;
        emit(JobsLoaded(
          allJobs: List.unmodifiable(_cachedJobs),
          selectedCategory: category ?? JobCategory.toQuote,
          searchQuery: query ?? '',
        ));
      },
    );
  }

  void switchCategory(JobCategory category) {
    if (state is JobsLoaded) {
      final current = state as JobsLoaded;
      emit(current.copyWith(selectedCategory: category));
    } else {
      emit(JobsLoaded(
        allJobs: List.unmodifiable(_cachedJobs),
        selectedCategory: category,
      ));
    }
  }

  void updateSearchQuery(String query) {
    if (state is JobsLoaded) {
      final current = state as JobsLoaded;
      emit(current.copyWith(searchQuery: query));
    }
  }

  Future<JobEntity?> loadJobDetails(String jobId) async {
    final result = await getJobDetailsUseCase(jobId);
    return result.fold(
      (failure) {
        emit(JobsError(failure.errorMessage));
        return null;
      },
      (job) {
        if (state is JobsLoaded) {
          final current = state as JobsLoaded;
          emit(current.copyWith(activeJobDetails: job));
        }
        return job;
      },
    );
  }

  Future<bool> submitQuote({
    required String jobId,
    required double amount,
    String? notes,
  }) async {
    final result = await submitQuoteUseCase(SubmitQuoteParams(
      jobId: jobId,
      amount: amount,
      notes: notes,
    ));

    return result.fold(
      (failure) {
        emit(JobsError(failure.errorMessage));
        return false;
      },
      (updatedJob) {
        _cachedJobs = _cachedJobs.map((j) {
          return j.id == jobId ? updatedJob : j;
        }).toList();

        emit(const JobsActionSuccess('Quotation sent to customer'));
        emit(JobsLoaded(
          allJobs: List.unmodifiable(_cachedJobs),
          selectedCategory: JobCategory.pendingApprove,
          activeJobDetails: updatedJob,
        ));
        return true;
      },
    );
  }

  Future<bool> updateStatus({
    required String jobId,
    required JobCategory status,
  }) async {
    final result = await updateJobStatusUseCase(UpdateJobStatusParams(
      jobId: jobId,
      status: status,
    ));

    return result.fold(
      (failure) {
        emit(JobsError(failure.errorMessage));
        return false;
      },
      (updatedJob) {
        _cachedJobs = _cachedJobs.map((j) {
          return j.id == jobId ? updatedJob : j;
        }).toList();

        emit(JobsActionSuccess('Job moved to ${status.label}'));
        emit(JobsLoaded(
          allJobs: List.unmodifiable(_cachedJobs),
          selectedCategory: status,
          activeJobDetails: updatedJob,
        ));
        return true;
      },
    );
  }

  Future<bool> requestExtra({
    required String jobId,
    required double amount,
    required String reason,
  }) async {
    final result = await requestExtraAmountUseCase(RequestExtraAmountParams(
      jobId: jobId,
      amount: amount,
      reason: reason,
    ));

    return result.fold(
      (failure) {
        emit(JobsError(failure.errorMessage));
        return false;
      },
      (updatedJob) {
        _cachedJobs = _cachedJobs.map((j) {
          return j.id == jobId ? updatedJob : j;
        }).toList();

        emit(const JobsActionSuccess('Extra amount request sent to customer'));
        emit(JobsLoaded(
          allJobs: List.unmodifiable(_cachedJobs),
          activeJobDetails: updatedJob,
        ));
        return true;
      },
    );
  }

  Future<bool> completeJob({
    required String jobId,
    double? finalRating,
    String? clientFeedback,
  }) async {
    final result = await completeJobUseCase(CompleteJobParams(
      jobId: jobId,
      finalRating: finalRating,
      clientFeedback: clientFeedback,
    ));

    return result.fold(
      (failure) {
        emit(JobsError(failure.errorMessage));
        return false;
      },
      (updatedJob) {
        _cachedJobs = _cachedJobs.map((j) {
          return j.id == jobId ? updatedJob : j;
        }).toList();

        emit(const JobsActionSuccess('Job completed successfully'));
        emit(JobsLoaded(
          allJobs: List.unmodifiable(_cachedJobs),
          selectedCategory: JobCategory.finished,
          activeJobDetails: updatedJob,
        ));
        return true;
      },
    );
  }
}
