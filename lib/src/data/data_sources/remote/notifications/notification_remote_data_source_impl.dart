import 'package:dio/dio.dart';
import 'package:provider_app/core/constants/app_endpoints.dart';
import 'package:provider_app/core/errors/auth_exception.dart';
import 'package:provider_app/src/data/data_sources/remote/notifications/notification_remote_data_source.dart';
import 'package:provider_app/src/data/models/notifications/notification_model.dart';

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final Dio dio;

  NotificationRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<NotificationModel>> getNotifications({
    String? type,
    String? category,
    bool? unreadOnly,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (type != null && type.isNotEmpty && type != 'all') {
        queryParams['type'] = type;
      }
      if (category != null && category.isNotEmpty && category != 'All') {
        queryParams['category'] = category;
      }
      if (unreadOnly == true) {
        queryParams['unread_only'] = true;
      }

      final response = await dio.get(
        AppEndpoints.providerNotifications,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

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
          .map((item) => NotificationModel.fromJson(item))
          .toList();
    } on DioException catch (e) {
      final msg = (e.response?.data is Map && e.response?.data['message'] != null)
          ? e.response!.data['message'].toString()
          : (e.message ?? 'Failed to fetch provider notifications');
      throw ServerException(msg);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> markAsRead(int id) async {
    try {
      await dio.patch(AppEndpoints.providerNotificationRead(id));
    } on DioException catch (e) {
      final msg = (e.response?.data is Map && e.response?.data['message'] != null)
          ? e.response!.data['message'].toString()
          : (e.message ?? 'Failed to mark notification as read');
      throw ServerException(msg);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await dio.post(AppEndpoints.providerNotificationMarkAllRead);
    } on DioException catch (e) {
      final msg = (e.response?.data is Map && e.response?.data['message'] != null)
          ? e.response!.data['message'].toString()
          : (e.message ?? 'Failed to mark all notifications as read');
      throw ServerException(msg);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteNotification(int id) async {
    try {
      await dio.delete(AppEndpoints.providerNotificationDelete(id));
    } on DioException catch (e) {
      final msg = (e.response?.data is Map && e.response?.data['message'] != null)
          ? e.response!.data['message'].toString()
          : (e.message ?? 'Failed to delete notification');
      throw ServerException(msg);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
