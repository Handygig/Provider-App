import 'package:provider_app/src/data/models/notifications/notification_preferences_model.dart';

abstract class NotificationPreferencesRemoteDataSource {
  Future<NotificationPreferencesModel> getPreferences();
  Future<NotificationPreferencesModel> updatePreferences(
      NotificationPreferencesModel preferences);
}
