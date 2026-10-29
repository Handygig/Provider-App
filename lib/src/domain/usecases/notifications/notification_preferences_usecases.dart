import 'package:dartz/dartz.dart';
import 'package:provider_app/core/errors/failures.dart';
import 'package:provider_app/core/usecases/usecases.dart';
import 'package:provider_app/src/domain/entities/notifications/notification_preferences_entity.dart';
import 'package:provider_app/src/domain/repositories/notifications/notification_preferences_repository.dart';

class GetNotificationPreferencesUseCase
    implements UseCase<NotificationPreferencesEntity, NoParams> {
  final NotificationPreferencesRepository _repository;

  GetNotificationPreferencesUseCase(this._repository);

  @override
  Future<Either<Failure, NotificationPreferencesEntity>> call(NoParams params) {
    return _repository.getPreferences();
  }
}

class UpdateNotificationPreferencesUseCase
    implements
        UseCase<NotificationPreferencesEntity, NotificationPreferencesEntity> {
  final NotificationPreferencesRepository _repository;

  UpdateNotificationPreferencesUseCase(this._repository);

  @override
  Future<Either<Failure, NotificationPreferencesEntity>> call(
      NotificationPreferencesEntity params) {
    return _repository.updatePreferences(params);
  }
}
