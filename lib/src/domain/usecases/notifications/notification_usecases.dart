import 'package:dartz/dartz.dart';
import 'package:provider_app/core/errors/failures.dart';
import 'package:provider_app/core/usecases/usecases.dart';
import 'package:provider_app/src/domain/entities/notifications/notification_entity.dart';
import 'package:provider_app/src/domain/repositories/notifications/notification_repository.dart';

class GetNotificationsParams {
  final String? type;
  final String? category;
  final bool? unreadOnly;

  const GetNotificationsParams({
    this.type,
    this.category,
    this.unreadOnly,
  });
}

class GetNotificationsUseCase
    implements UseCase<List<NotificationEntity>, GetNotificationsParams?> {
  final NotificationRepository repository;

  GetNotificationsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<NotificationEntity>>> call(
      GetNotificationsParams? params) {
    return repository.getNotifications(
      type: params?.type,
      category: params?.category,
      unreadOnly: params?.unreadOnly,
    );
  }
}

class MarkNotificationAsReadUseCase implements UseCase<void, int> {
  final NotificationRepository repository;

  MarkNotificationAsReadUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(int id) {
    return repository.markAsRead(id);
  }
}

class MarkAllNotificationsAsReadUseCase implements UseCase<void, NoParams> {
  final NotificationRepository repository;

  MarkAllNotificationsAsReadUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.markAllAsRead();
  }
}

class DeleteNotificationUseCase implements UseCase<void, int> {
  final NotificationRepository repository;

  DeleteNotificationUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(int id) {
    return repository.deleteNotification(id);
  }
}
