import 'package:dio/dio.dart';
import 'package:provider_app/core/constants/app_endpoints.dart';
import 'package:provider_app/core/errors/auth_exception.dart';
import 'package:provider_app/src/data/data_sources/remote/coverage/coverage_remote_data_source.dart';
import 'package:provider_app/src/data/models/coverage/working_hours_coverage_model.dart';

class CoverageRemoteDataSourceImpl implements CoverageRemoteDataSource {
  final Dio dio;

  CoverageRemoteDataSourceImpl({required this.dio});

  @override
  Future<WorkingHoursCoverageModel> getCoverage() async {
    try {
      final response =
          await dio.get('${AppEndpoints.providerProfile}/coverage');
      final dynamic body = response.data;
      if (body is Map<String, dynamic> && body['data'] != null) {
        return WorkingHoursCoverageModel.fromJson(
            body['data'] as Map<String, dynamic>);
      } else if (body is Map<String, dynamic>) {
        return WorkingHoursCoverageModel.fromJson(body);
      }
      return const WorkingHoursCoverageModel();
    } on DioException {
      // Fallback to default model if endpoint is being implemented
      return const WorkingHoursCoverageModel();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<WorkingHoursCoverageModel> updateCoverage(
      WorkingHoursCoverageModel coverage) async {
    try {
      final response = await dio.put(
        '${AppEndpoints.providerProfile}/coverage',
        data: coverage.toJson(),
      );
      final dynamic body = response.data;
      if (body is Map<String, dynamic> && body['data'] != null) {
        return WorkingHoursCoverageModel.fromJson(
            body['data'] as Map<String, dynamic>);
      }
      return coverage;
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message']?.toString() ??
            'Failed to update coverage settings',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> toggleAvailability(bool isAvailable) async {
    try {
      await dio.put(
        '${AppEndpoints.providerProfile}/availability',
        data: {'is_available': isAvailable},
      );
      return isAvailable;
    } on DioException {
      return isAvailable;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
