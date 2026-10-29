import 'package:dartz/dartz.dart';
import 'package:provider_app/core/errors/failures.dart';
import 'package:provider_app/src/data/data_sources/remote/notifications/notification_preferences_remote_data_source.dart';
import 'package:provider_app/src/data/models/notifications/notification_preferences_model.dart';
import 'package:provider_app/src/domain/entities/notifications/notification_preferences_entity.dart';
import 'package:provider_app/src/domain/repositories/notifications/notification_preferences_repository.dart';

class NotificationPreferencesRepositoryImpl
    implements NotificationPreferencesRepository {
  final NotificationPreferencesRemoteDataSource remoteDataSource;

  NotificationPreferencesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, NotificationPreferencesEntity>>
      getPreferences() async {
    try {
      final model = await remoteDataSource.getPreferences();
      return Right(model);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationPreferencesEntity>> updatePreferences(
      NotificationPreferencesEntity preferences) async {
    try {
      final model = preferences is NotificationPreferencesModel
          ? preferences
          : NotificationPreferencesModel(
              allNotificationsEnabled: preferences.allNotificationsEnabled,
              newJobRequests: preferences.newJobRequests,
              clientMessages: preferences.clientMessages,
              jobScheduleReminders: preferences.jobScheduleReminders,
              payoutAndPaymentAlerts: preferences.payoutAndPaymentAlerts,
              systemSecurityAlerts: preferences.systemSecurityAlerts,
              smsUrgentJobs: preferences.smsUrgentJobs,
              smsPaymentReceipts: preferences.smsPaymentReceipts,
              loudJobAlarmMode: preferences.loudJobAlarmMode,
              hapticFeedbackEnabled: preferences.hapticFeedbackEnabled,
              alertRingtone: preferences.alertRingtone,
              quietHoursEnabled: preferences.quietHoursEnabled,
              quietHoursStartHour: preferences.quietHoursStartHour,
              quietHoursStartMinute: preferences.quietHoursStartMinute,
              quietHoursEndHour: preferences.quietHoursEndHour,
              quietHoursEndMinute: preferences.quietHoursEndMinute,
            );
      final updated = await remoteDataSource.updatePreferences(model);
      return Right(updated);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
