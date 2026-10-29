import 'package:provider_app/src/data/models/jobs/job_model.dart';

abstract class JobRemoteDataSource {
  Future<List<JobModel>> getJobs({JobCategory? category, String? query});
  Future<JobModel> getJobById(String id);
  Future<JobModel> submitQuote({
    required String jobId,
    required double amount,
    String? notes,
  });
  Future<JobModel> updateJobStatus({
    required String jobId,
    required JobCategory status,
  });
  Future<JobModel> requestExtraAmount({
    required String jobId,
    required double amount,
    required String reason,
  });
  Future<JobModel> completeJob({
    required String jobId,
    double? finalRating,
    String? clientFeedback,
  });
}
