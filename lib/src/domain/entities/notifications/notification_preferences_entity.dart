import 'package:equatable/equatable.dart';

class NotificationPreferencesEntity extends Equatable {
  final bool allNotificationsEnabled;
  final bool newJobRequests;
  final bool clientMessages;
  final bool jobScheduleReminders;
  final bool payoutAndPaymentAlerts;
  final bool systemSecurityAlerts;
  final bool smsUrgentJobs;
  final bool smsPaymentReceipts;
  final bool loudJobAlarmMode;
  final bool hapticFeedbackEnabled;
  final String alertRingtone;
  final bool quietHoursEnabled;
  final int quietHoursStartHour;
  final int quietHoursStartMinute;
  final int quietHoursEndHour;
  final int quietHoursEndMinute;

  const NotificationPreferencesEntity({
    this.allNotificationsEnabled = true,
    this.newJobRequests = true,
    this.clientMessages = true,
    this.jobScheduleReminders = true,
    this.payoutAndPaymentAlerts = true,
    this.systemSecurityAlerts = true,
    this.smsUrgentJobs = true,
    this.smsPaymentReceipts = true,
    this.loudJobAlarmMode = true,
    this.hapticFeedbackEnabled = true,
    this.alertRingtone = 'Radar Pulse (Default)',
    this.quietHoursEnabled = false,
    this.quietHoursStartHour = 22,
    this.quietHoursStartMinute = 0,
    this.quietHoursEndHour = 6,
    this.quietHoursEndMinute = 30,
  });

  NotificationPreferencesEntity copyWith({
    bool? allNotificationsEnabled,
    bool? newJobRequests,
    bool? clientMessages,
    bool? jobScheduleReminders,
    bool? payoutAndPaymentAlerts,
    bool? systemSecurityAlerts,
    bool? smsUrgentJobs,
    bool? smsPaymentReceipts,
    bool? loudJobAlarmMode,
    bool? hapticFeedbackEnabled,
    String? alertRingtone,
    bool? quietHoursEnabled,
    int? quietHoursStartHour,
    int? quietHoursStartMinute,
    int? quietHoursEndHour,
    int? quietHoursEndMinute,
  }) {
    return NotificationPreferencesEntity(
      allNotificationsEnabled:
          allNotificationsEnabled ?? this.allNotificationsEnabled,
      newJobRequests: newJobRequests ?? this.newJobRequests,
      clientMessages: clientMessages ?? this.clientMessages,
      jobScheduleReminders:
          jobScheduleReminders ?? this.jobScheduleReminders,
      payoutAndPaymentAlerts:
          payoutAndPaymentAlerts ?? this.payoutAndPaymentAlerts,
      systemSecurityAlerts:
          systemSecurityAlerts ?? this.systemSecurityAlerts,
      smsUrgentJobs: smsUrgentJobs ?? this.smsUrgentJobs,
      smsPaymentReceipts: smsPaymentReceipts ?? this.smsPaymentReceipts,
      loudJobAlarmMode: loudJobAlarmMode ?? this.loudJobAlarmMode,
      hapticFeedbackEnabled:
          hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
      alertRingtone: alertRingtone ?? this.alertRingtone,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStartHour: quietHoursStartHour ?? this.quietHoursStartHour,
      quietHoursStartMinute:
          quietHoursStartMinute ?? this.quietHoursStartMinute,
      quietHoursEndHour: quietHoursEndHour ?? this.quietHoursEndHour,
      quietHoursEndMinute: quietHoursEndMinute ?? this.quietHoursEndMinute,
    );
  }

  @override
  List<Object?> get props => [
        allNotificationsEnabled,
        newJobRequests,
        clientMessages,
        jobScheduleReminders,
        payoutAndPaymentAlerts,
        systemSecurityAlerts,
        smsUrgentJobs,
        smsPaymentReceipts,
        loudJobAlarmMode,
        hapticFeedbackEnabled,
        alertRingtone,
        quietHoursEnabled,
        quietHoursStartHour,
        quietHoursStartMinute,
        quietHoursEndHour,
        quietHoursEndMinute,
      ];
}
