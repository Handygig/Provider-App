import 'package:dio/dio.dart';
import 'package:provider_app/core/constants/app_endpoints.dart';
import 'package:provider_app/core/errors/auth_exception.dart';
import 'package:provider_app/src/data/data_sources/remote/services/managed_services_remote_data_source.dart';
import 'package:provider_app/src/data/models/services/service_skill_model.dart';

class ManagedServicesRemoteDataSourceImpl
    implements ManagedServicesRemoteDataSource {
  final Dio dio;

  ManagedServicesRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ServiceSkillModel>> getServices() async {
    try {
      final response = await dio.get(AppEndpoints.providerServices);
      final dynamic body = response.data;
      final List<dynamic> list;
      if (body is Map<String, dynamic> && body['data'] is List) {
        list = body['data'] as List<dynamic>;
      } else if (body is List) {
        list = body;
      } else {
        list = [];
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map((item) => ServiceSkillModel.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message']?.toString() ??
            'Failed to load provider services',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ServiceSkillModel>> getAvailableCatalog() async {
    try {
      final response = await dio.get(AppEndpoints.serviceCategories);
      final dynamic body = response.data;
      final List<dynamic> list;
      if (body is Map<String, dynamic> && body['data'] is List) {
        list = body['data'] as List<dynamic>;
      } else if (body is List) {
        list = body;
      } else {
        list = [];
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map((item) => ServiceSkillModel.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message']?.toString() ??
            'Failed to load service categories',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ServiceSkillModel>> updateServices(
      List<ServiceSkillModel> services) async {
    try {
      final payload = {
        'services': services.map((s) => s.toJson()).toList(),
      };
      final response =
          await dio.put(AppEndpoints.providerServices, data: payload);
      final dynamic body = response.data;
      if (body is Map<String, dynamic> && body['data'] is List) {
        return (body['data'] as List)
            .whereType<Map<String, dynamic>>()
            .map((item) => ServiceSkillModel.fromJson(item))
            .toList();
      }
      return services;
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message']?.toString() ??
            'Failed to update services',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> requestCustomCategory({
    required String categoryName,
    required String notes,
  }) async {
    try {
      await dio.post(
        '${AppEndpoints.providerServices}/request-category',
        data: {'name': categoryName, 'notes': notes},
      );
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message']?.toString() ??
            'Failed to submit category request',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
