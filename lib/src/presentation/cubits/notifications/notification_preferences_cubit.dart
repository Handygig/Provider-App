import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider_app/core/usecases/usecases.dart';
import 'package:provider_app/src/domain/entities/notifications/notification_preferences_entity.dart';
import 'package:provider_app/src/domain/usecases/notifications/notification_preferences_usecases.dart';
import 'package:provider_app/src/presentation/cubits/notifications/notification_preferences_state.dart';

class NotificationPreferencesCubit extends Cubit<NotificationPreferencesState> {
  final GetNotificationPreferencesUseCase getPreferencesUseCase;
  final UpdateNotificationPreferencesUseCase updatePreferencesUseCase;

  NotificationPreferencesEntity _preferences =
      const NotificationPreferencesEntity();

  NotificationPreferencesCubit({
    required this.getPreferencesUseCase,
    required this.updatePreferencesUseCase,
  }) : super(const NotificationPreferencesInitial());

  NotificationPreferencesEntity get preferences => _preferences;

  Future<void> loadPreferences({bool silent = false}) async {
    if (!silent) {
      emit(const NotificationPreferencesLoading());
    }

    final result = await getPreferencesUseCase(NoParams());
    result.fold(
      (failure) => emit(NotificationPreferencesError(failure.errorMessage)),
      (data) {
        _preferences = data;
        emit(NotificationPreferencesLoaded(_preferences));
      },
    );
  }

  Future<bool> savePreferences(
      NotificationPreferencesEntity newPreferences) async {
    final previous = _preferences;
    _preferences = newPreferences;
    emit(NotificationPreferencesLoaded(_preferences));

    final result = await updatePreferencesUseCase(newPreferences);
    return result.fold(
      (failure) {
        _preferences = previous;
        emit(NotificationPreferencesError(failure.errorMessage));
        emit(NotificationPreferencesLoaded(_preferences));
        return false;
      },
      (saved) {
        _preferences = saved;
        emit(const NotificationPreferencesActionSuccess(
            'Preferences updated successfully'));
        emit(NotificationPreferencesLoaded(_preferences));
        return true;
      },
    );
  }
}
