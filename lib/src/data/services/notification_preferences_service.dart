import 'package:flutter/material.dart';
import 'package:provider_app/core/di/service_locator.dart';
import 'package:provider_app/src/domain/entities/notifications/notification_preferences_entity.dart';
import 'package:provider_app/src/presentation/cubits/notifications/notification_preferences_cubit.dart';

export 'package:provider_app/src/domain/entities/notifications/notification_preferences_entity.dart';

class NotificationPreferencesService extends ChangeNotifier {
  static final NotificationPreferencesService _instance =
      NotificationPreferencesService._internal();
  factory NotificationPreferencesService() => _instance;
  static NotificationPreferencesService get instance => _instance;

  NotificationPreferencesService._internal();

  NotificationPreferencesCubit get _cubit =>
      sl<NotificationPreferencesCubit>();

  bool get allNotificationsEnabled => _cubit.preferences.allNotificationsEnabled;
  bool get newJobRequests => _cubit.preferences.newJobRequests;
  bool get clientMessages => _cubit.preferences.clientMessages;
  bool get jobScheduleReminders => _cubit.preferences.jobScheduleReminders;
  bool get payoutAndPaymentAlerts => _cubit.preferences.payoutAndPaymentAlerts;
  bool get systemSecurityAlerts => _cubit.preferences.systemSecurityAlerts;
  bool get smsUrgentJobs => _cubit.preferences.smsUrgentJobs;
  bool get smsPaymentReceipts => _cubit.preferences.smsPaymentReceipts;
  bool get loudJobAlarmMode => _cubit.preferences.loudJobAlarmMode;
  bool get hapticFeedbackEnabled => _cubit.preferences.hapticFeedbackEnabled;
  String get alertRingtone => _cubit.preferences.alertRingtone;
  bool get quietHoursEnabled => _cubit.preferences.quietHoursEnabled;

  TimeOfDay get quietHoursStart => TimeOfDay(
        hour: _cubit.preferences.quietHoursStartHour,
        minute: _cubit.preferences.quietHoursStartMinute,
      );

  TimeOfDay get quietHoursEnd => TimeOfDay(
        hour: _cubit.preferences.quietHoursEndHour,
        minute: _cubit.preferences.quietHoursEndMinute,
      );

  static const List<String> availableRingtones = [
    'Radar Pulse (Default)',
    'High Priority Chime',
    'Industrial Bell',
    'Gentle Ripple',
    'Crisp Beep',
  ];

  void toggleAllNotifications(bool value) {
    _cubit.savePreferences(
        _cubit.preferences.copyWith(allNotificationsEnabled: value));
    notifyListeners();
  }

  void toggleNewJobRequests(bool value) {
    _cubit.savePreferences(_cubit.preferences.copyWith(newJobRequests: value));
    notifyListeners();
  }

  void toggleClientMessages(bool value) {
    _cubit.savePreferences(_cubit.preferences.copyWith(clientMessages: value));
    notifyListeners();
  }

  void toggleJobScheduleReminders(bool value) {
    _cubit.savePreferences(
        _cubit.preferences.copyWith(jobScheduleReminders: value));
    notifyListeners();
  }

  void togglePayoutAndPaymentAlerts(bool value) {
    _cubit.savePreferences(
        _cubit.preferences.copyWith(payoutAndPaymentAlerts: value));
    notifyListeners();
  }

  void toggleSystemSecurityAlerts(bool value) {
    _cubit.savePreferences(
        _cubit.preferences.copyWith(systemSecurityAlerts: value));
    notifyListeners();
  }

  void toggleSmsUrgentJobs(bool value) {
    _cubit.savePreferences(_cubit.preferences.copyWith(smsUrgentJobs: value));
    notifyListeners();
  }

  void toggleSmsPaymentReceipts(bool value) {
    _cubit.savePreferences(
        _cubit.preferences.copyWith(smsPaymentReceipts: value));
    notifyListeners();
  }

  void toggleLoudJobAlarmMode(bool value) {
    _cubit.savePreferences(_cubit.preferences.copyWith(loudJobAlarmMode: value));
    notifyListeners();
  }

  void toggleHapticFeedback(bool value) {
    _cubit.savePreferences(
        _cubit.preferences.copyWith(hapticFeedbackEnabled: value));
    notifyListeners();
  }

  void setRingtone(String ringtone) {
    _cubit.savePreferences(_cubit.preferences.copyWith(alertRingtone: ringtone));
    notifyListeners();
  }

  void setAlertRingtone(String ringtone) => setRingtone(ringtone);

  void resetToDefaults() {
    _cubit.savePreferences(const NotificationPreferencesEntity());
    notifyListeners();
  }

  void toggleQuietHours(bool value) {
    _cubit.savePreferences(_cubit.preferences.copyWith(quietHoursEnabled: value));
    notifyListeners();
  }

  void setQuietHoursStart(TimeOfDay time) {
    _cubit.savePreferences(_cubit.preferences.copyWith(
      quietHoursStartHour: time.hour,
      quietHoursStartMinute: time.minute,
    ));
    notifyListeners();
  }

  void setQuietHoursEnd(TimeOfDay time) {
    _cubit.savePreferences(_cubit.preferences.copyWith(
      quietHoursEndHour: time.hour,
      quietHoursEndMinute: time.minute,
    ));
    notifyListeners();
  }
}
