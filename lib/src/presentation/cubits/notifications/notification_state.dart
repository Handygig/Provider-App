import 'package:equatable/equatable.dart';
import 'package:provider_app/src/domain/entities/notifications/notification_entity.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> notifications;
  final String activeFilter;
  final int unreadCount;

  const NotificationLoaded({
    required this.notifications,
    this.activeFilter = 'All',
    this.unreadCount = 0,
  });

  @override
  List<Object?> get props => [notifications, activeFilter, unreadCount];
}

class NotificationActionSuccess extends NotificationState {
  final String message;

  const NotificationActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}
