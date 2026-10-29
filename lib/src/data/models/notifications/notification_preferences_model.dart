import 'package:provider_app/src/domain/entities/notifications/notification_preferences_entity.dart';

class NotificationPreferencesModel extends NotificationPreferencesEntity {
  const NotificationPreferencesModel({
    super.allNotificationsEnabled = true,
    super.newJobRequests = true,
    super.clientMessages = true,
    super.jobScheduleReminders = true,
    super.payoutAndPaymentAlerts = true,
    super.systemSecurityAlerts = true,
    super.smsUrgentJobs = true,
    super.smsPaymentReceipts = true,
    super.loudJobAlarmMode = true,
    super.hapticFeedbackEnabled = true,
    super.alertRingtone = 'Radar Pulse (Default)',
    super.quietHoursEnabled = false,
    super.quietHoursStartHour = 22,
    super.quietHoursStartMinute = 0,
    super.quietHoursEndHour = 6,
    super.quietHoursEndMinute = 30,
  });

  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) {
    return NotificationPreferencesModel(
      allNotificationsEnabled: json['all_notifications_enabled'] == true ||
          json['allNotificationsEnabled'] == true,
      newJobRequests: json['new_job_requests'] == true ||
          json['newJobRequests'] == true,
      clientMessages: json['client_messages'] == true ||
          json['clientMessages'] == true,
      jobScheduleReminders: json['job_schedule_reminders'] == true ||
          json['jobScheduleReminders'] == true,
      payoutAndPaymentAlerts: json['payout_and_payment_alerts'] == true ||
          json['payoutAndPaymentAlerts'] == true,
      systemSecurityAlerts: json['system_security_alerts'] == true ||
          json['systemSecurityAlerts'] == true,
      smsUrgentJobs: json['sms_urgent_jobs'] == true ||
          json['smsUrgentJobs'] == true,
      smsPaymentReceipts: json['sms_payment_receipts'] == true ||
          json['smsPaymentReceipts'] == true,
      loudJobAlarmMode: json['loud_job_alarm_mode'] == true ||
          json['loudJobAlarmMode'] == true,
      hapticFeedbackEnabled: json['haptic_feedback_enabled'] == true ||
          json['hapticFeedbackEnabled'] == true,
      alertRingtone: json['alert_ringtone']?.toString() ??
          json['alertRingtone']?.toString() ??
          'Radar Pulse (Default)',
      quietHoursEnabled: json['quiet_hours_enabled'] == true ||
          json['quietHoursEnabled'] == true,
      quietHoursStartHour: json['quiet_hours_start_hour'] ??
          json['quietHoursStartHour'] ??
          22,
      quietHoursStartMinute: json['quiet_hours_start_minute'] ??
          json['quietHoursStartMinute'] ??
          0,
      quietHoursEndHour:
          json['quiet_hours_end_hour'] ?? json['quietHoursEndHour'] ?? 6,
      quietHoursEndMinute: json['quiet_hours_end_minute'] ??
          json['quietHoursEndMinute'] ??
          30,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'all_notifications_enabled': allNotificationsEnabled,
      'new_job_requests': newJobRequests,
      'client_messages': clientMessages,
      'job_schedule_reminders': jobScheduleReminders,
      'payout_and_payment_alerts': payoutAndPaymentAlerts,
      'system_security_alerts': systemSecurityAlerts,
      'sms_urgent_jobs': smsUrgentJobs,
      'sms_payment_receipts': smsPaymentReceipts,
      'loud_job_alarm_mode': loudJobAlarmMode,
      'haptic_feedback_enabled': hapticFeedbackEnabled,
      'alert_ringtone': alertRingtone,
      'quiet_hours_enabled': quietHoursEnabled,
      'quiet_hours_start_hour': quietHoursStartHour,
      'quiet_hours_start_minute': quietHoursStartMinute,
      'quiet_hours_end_hour': quietHoursEndHour,
      'quiet_hours_end_minute': quietHoursEndMinute,
    };
  }
}
