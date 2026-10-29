import 'package:equatable/equatable.dart';
import 'package:provider_app/src/domain/entities/notifications/notification_preferences_entity.dart';

abstract class NotificationPreferencesState extends Equatable {
  const NotificationPreferencesState();

  @override
  List<Object?> get props => [];
}

class NotificationPreferencesInitial extends NotificationPreferencesState {
  const NotificationPreferencesInitial();
}

class NotificationPreferencesLoading extends NotificationPreferencesState {
  const NotificationPreferencesLoading();
}

class NotificationPreferencesLoaded extends NotificationPreferencesState {
  final NotificationPreferencesEntity preferences;

  const NotificationPreferencesLoaded(this.preferences);

  @override
  List<Object?> get props => [preferences];
}

class NotificationPreferencesActionSuccess extends NotificationPreferencesState {
  final String message;

  const NotificationPreferencesActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class NotificationPreferencesError extends NotificationPreferencesState {
  final String message;

  const NotificationPreferencesError(this.message);

  @override
  List<Object?> get props => [message];
}
