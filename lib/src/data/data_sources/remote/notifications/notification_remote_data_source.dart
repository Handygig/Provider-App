import 'package:provider_app/src/data/models/notifications/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({
    String? type,
    String? category,
    bool? unreadOnly,
  });

  Future<void> markAsRead(int id);

  Future<void> markAllAsRead();

  Future<void> deleteNotification(int id);
}
