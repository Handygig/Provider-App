import 'package:dartz/dartz.dart';
import 'package:provider_app/core/errors/failures.dart';
import 'package:provider_app/src/domain/entities/notifications/notification_preferences_entity.dart';

abstract class NotificationPreferencesRepository {
  Future<Either<Failure, NotificationPreferencesEntity>> getPreferences();
  Future<Either<Failure, NotificationPreferencesEntity>> updatePreferences(
      NotificationPreferencesEntity preferences);
}
