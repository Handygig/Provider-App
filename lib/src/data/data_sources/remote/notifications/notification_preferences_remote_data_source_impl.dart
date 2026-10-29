import 'package:dio/dio.dart';
import 'package:provider_app/core/constants/app_endpoints.dart';
import 'package:provider_app/core/errors/auth_exception.dart';
import 'package:provider_app/src/data/data_sources/remote/notifications/notification_preferences_remote_data_source.dart';
import 'package:provider_app/src/data/models/notifications/notification_preferences_model.dart';

class NotificationPreferencesRemoteDataSourceImpl
    implements NotificationPreferencesRemoteDataSource {
  final Dio dio;

  NotificationPreferencesRemoteDataSourceImpl({required this.dio});

  @override
  Future<NotificationPreferencesModel> getPreferences() async {
    try {
      final response =
          await dio.get('${AppEndpoints.providerProfile}/notification-preferences');
      final dynamic body = response.data;
      if (body is Map<String, dynamic> && body['data'] != null) {
        return NotificationPreferencesModel.fromJson(
            body['data'] as Map<String, dynamic>);
      } else if (body is Map<String, dynamic>) {
        return NotificationPreferencesModel.fromJson(body);
      }
      return const NotificationPreferencesModel();
    } on DioException {
      return const NotificationPreferencesModel();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<NotificationPreferencesModel> updatePreferences(
      NotificationPreferencesModel preferences) async {
    try {
      final response = await dio.put(
        '${AppEndpoints.providerProfile}/notification-preferences',
        data: preferences.toJson(),
      );
      final dynamic body = response.data;
      if (body is Map<String, dynamic> && body['data'] != null) {
        return NotificationPreferencesModel.fromJson(
            body['data'] as Map<String, dynamic>);
      }
      return preferences;
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message']?.toString() ??
            'Failed to save notification preferences',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
