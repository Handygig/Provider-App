import 'package:dio/dio.dart';
import 'package:provider_app/core/constants/app_endpoints.dart';
import 'package:provider_app/core/errors/auth_exception.dart';
import 'package:provider_app/src/data/data_sources/remote/jobs/job_remote_data_source.dart';
import 'package:provider_app/src/data/models/jobs/job_model.dart';

class JobRemoteDataSourceImpl implements JobRemoteDataSource {
  final Dio dio;

  JobRemoteDataSourceImpl({required this.dio});

  String _cleanJobId(String id) {
    if (id.startsWith('JOB-')) {
      final stripped = id.substring(4).replaceFirst(RegExp(r'^0+'), '');
      return stripped.isEmpty ? '0' : stripped;
    }
    return id;
  }

  List<JobModel> _extractList(dynamic body, {JobCategory? forceCategory}) {
    List<dynamic> items = [];
    if (body is Map<String, dynamic>) {
      if (body['data'] is List) {
        items = body['data'] as List<dynamic>;
      } else if (body['job_requests'] is List) {
        items = body['job_requests'] as List<dynamic>;
      } else if (body['jobs'] is List) {
        items = body['jobs'] as List<dynamic>;
      }
    } else if (body is List) {
      items = body;
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map((item) {
          final model = JobModel.fromJson(item);
          if (forceCategory != null) {
            model.status = forceCategory;
          }
          return model;
        })
        .toList();
  }

  JobModel _extractSingle(dynamic body) {
    if (body is Map<String, dynamic>) {
      final data = body['data'] ?? body['job'] ?? body['job_assignment'] ?? body;
      if (data is Map<String, dynamic>) {
        return JobModel.fromJson(data);
      }
    }
    throw ServerException('Invalid job response structure');
  }

  @override
  Future<List<JobModel>> getJobs({JobCategory? category, String? query}) async {
    try {
      List<JobModel> jobs = [];

      switch (category) {
        case JobCategory.toQuote:
          final response = await dio.get(AppEndpoints.providerJobRequests);
          jobs = _extractList(response.data, forceCategory: JobCategory.toQuote);
          break;

        case JobCategory.pendingApprove:
          final response = await dio.get(
            AppEndpoints.providerQuotations,
            queryParameters: {'status': 'pending'},
          );
          jobs = _extractList(response.data, forceCategory: JobCategory.pendingApprove);
          break;

        case JobCategory.toStart:
          final response = await dio.get(
            AppEndpoints.providerJobs,
            queryParameters: {'status': 'scheduled'},
          );
          jobs = _extractList(response.data, forceCategory: JobCategory.toStart);
          break;

        case JobCategory.ongoing:
          final response = await dio.get(
            AppEndpoints.providerJobs,
            queryParameters: {'stage': 'ongoing'},
          );
          jobs = _extractList(response.data, forceCategory: JobCategory.ongoing);
          break;

        case JobCategory.finished:
          final response = await dio.get(
            AppEndpoints.providerJobs,
            queryParameters: {'stage': 'finished'},
          );
          jobs = _extractList(response.data, forceCategory: JobCategory.finished);
          break;

        case null:
          final results = await Future.wait([
            dio.get(AppEndpoints.providerJobRequests).catchError((_) => Response(requestOptions: RequestOptions(path: ''), data: [])),
            dio.get(AppEndpoints.providerQuotations, queryParameters: {'status': 'pending'}).catchError((_) => Response(requestOptions: RequestOptions(path: ''), data: [])),
            dio.get(AppEndpoints.providerJobs).catchError((_) => Response(requestOptions: RequestOptions(path: ''), data: [])),
          ]);

          final quotes = _extractList(results[0].data, forceCategory: JobCategory.toQuote);
          final pending = _extractList(results[1].data, forceCategory: JobCategory.pendingApprove);
          final assignments = _extractList(results[2].data);

          jobs = [...quotes, ...pending, ...assignments];
          break;
      }

      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        jobs = jobs.where((j) {
          return j.serviceTitle.toLowerCase().contains(q) ||
              j.customerName.toLowerCase().contains(q) ||
              j.category.toLowerCase().contains(q) ||
              j.id.toLowerCase().contains(q);
        }).toList();
      }

      return jobs;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Failed to load jobs';
      throw ServerException(msg);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<JobModel> getJobById(String id) async {
    final cleanId = _cleanJobId(id);
    try {
      final response = await dio.get('${AppEndpoints.providerJobs}/$cleanId');
      return _extractSingle(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        try {
          final reqResponse = await dio.get('${AppEndpoints.providerJobRequests}/$cleanId');
          return _extractSingle(reqResponse.data);
        } catch (_) {}
      }
      final msg = e.response?.data?['message'] ?? e.message ?? 'Failed to load job details';
      throw ServerException(msg);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<JobModel> submitQuote({
    required String jobId,
    required double amount,
    String? notes,
  }) async {
    final cleanId = _cleanJobId(jobId);
    try {
      final response = await dio.post(
        AppEndpoints.providerJobRequestQuote(cleanId),
        data: {
          'quoted_price': amount,
          if (notes != null && notes.isNotEmpty) 'message': notes,
        },
      );
      return _extractSingle(response.data);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Failed to submit quotation';
      throw ServerException(msg);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<JobModel> updateJobStatus({
    required String jobId,
    required JobCategory status,
  }) async {
    final cleanId = _cleanJobId(jobId);
    try {
      if (status == JobCategory.ongoing || status == JobCategory.toStart) {
        final response = await dio.post(AppEndpoints.providerJobStart(cleanId));
        return _extractSingle(response.data);
      }
      final response = await dio.get('${AppEndpoints.providerJobs}/$cleanId');
      final job = _extractSingle(response.data);
      job.status = status;
      return job;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Failed to update job status';
      throw ServerException(msg);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<JobModel> requestExtraAmount({
    required String jobId,
    required double amount,
    required String reason,
  }) async {
    final cleanId = _cleanJobId(jobId);
    try {
      final response = await dio.post(
        AppEndpoints.providerJobExtraCharge(cleanId),
        data: {
          'extra_amount': amount,
          'extra_reason': reason,
        },
      );
      return _extractSingle(response.data);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Failed to request extra charge';
      throw ServerException(msg);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<JobModel> completeJob({
    required String jobId,
    double? finalRating,
    String? clientFeedback,
  }) async {
    final cleanId = _cleanJobId(jobId);
    try {
      final response = await dio.post(
        AppEndpoints.providerJobComplete(cleanId),
        data: {
          'payment_method': 'cash',
        },
      );
      return _extractSingle(response.data);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Failed to complete job';
      throw ServerException(msg);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
