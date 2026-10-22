import 'package:flutter/material.dart';

class NotificationPreferencesService extends ChangeNotifier {
  static final NotificationPreferencesService _instance =
      NotificationPreferencesService._internal();
  factory NotificationPreferencesService() => _instance;
  static NotificationPreferencesService get instance => _instance;

  NotificationPreferencesService._internal();

  // Master Notifications Toggle
  bool _allNotificationsEnabled = true;
  bool get allNotificationsEnabled => _allNotificationsEnabled;

  // Push Notifications Category
  bool _newJobRequests = true;
  bool get newJobRequests => _newJobRequests;

  bool _clientMessages = true;
  bool get clientMessages => _clientMessages;

  bool _jobScheduleReminders = true;
  bool get jobScheduleReminders => _jobScheduleReminders;

  bool _payoutAndPaymentAlerts = true;
  bool get payoutAndPaymentAlerts => _payoutAndPaymentAlerts;

  bool _systemSecurityAlerts = true;
  bool get systemSecurityAlerts => _systemSecurityAlerts;

  // SMS Notifications
  bool _smsUrgentJobs = true;
  bool get smsUrgentJobs => _smsUrgentJobs;

  bool _smsPaymentReceipts = true;
  bool get smsPaymentReceipts => _smsPaymentReceipts;

  // Sound & Vibrations
  bool _loudJobAlarmMode = true;
  bool get loudJobAlarmMode => _loudJobAlarmMode;

  bool _hapticFeedbackEnabled = true;
  bool get hapticFeedbackEnabled => _hapticFeedbackEnabled;

  String _alertRingtone = 'Radar Pulse (Default)';
  String get alertRingtone => _alertRingtone;

  static const List<String> availableRingtones = [
    'Radar Pulse (Default)',
    'High Priority Chime',
    'Industrial Bell',
    'Gentle Ripple',
    'Crisp Beep',
  ];

  // Quiet Hours (Do Not Disturb)
  bool _quietHoursEnabled = false;
  bool get quietHoursEnabled => _quietHoursEnabled;

  TimeOfDay _quietHoursStart = const TimeOfDay(hour: 22, minute: 0); // 10:00 PM
  TimeOfDay get quietHoursStart => _quietHoursStart;

  TimeOfDay _quietHoursEnd = const TimeOfDay(hour: 7, minute: 0); // 07:00 AM
  TimeOfDay get quietHoursEnd => _quietHoursEnd;

  bool _quietHoursBypassEmergency = true;
  bool get quietHoursBypassEmergency => _quietHoursBypassEmergency;

  // Marketing & Promotions
  bool _partnerBonusesAndIncentives = true;
  bool get partnerBonusesAndIncentives => _partnerBonusesAndIncentives;

  bool _communityTipsAndNews = false;
  bool get communityTipsAndNews => _communityTipsAndNews;

  // Summary for Profile Tab
  String get summary {
    if (!_allNotificationsEnabled) return 'All Notifications Paused';
    final parts = <String>[];
    if (_newJobRequests) parts.add('Instant Jobs');
    if (_loudJobAlarmMode) parts.add('Loud Alarm');
    if (_clientMessages) parts.add('Chat Alerts');
    if (parts.isEmpty) return 'Active';
    return parts.join(' • ');
  }

  // ---------------------------------------------------------------------------
  // Mutators
  // ---------------------------------------------------------------------------
  void toggleAllNotifications(bool val) {
    _allNotificationsEnabled = val;
    notifyListeners();
  }

  void toggleNewJobRequests(bool val) {
    _newJobRequests = val;
    notifyListeners();
  }

  void toggleClientMessages(bool val) {
    _clientMessages = val;
    notifyListeners();
  }

  void toggleJobScheduleReminders(bool val) {
    _jobScheduleReminders = val;
    notifyListeners();
  }

  void togglePayoutAndPaymentAlerts(bool val) {
    _payoutAndPaymentAlerts = val;
    notifyListeners();
  }

  void toggleSystemSecurityAlerts(bool val) {
    _systemSecurityAlerts = val;
    notifyListeners();
  }

  void toggleSmsUrgentJobs(bool val) {
    _smsUrgentJobs = val;
    notifyListeners();
  }

  void toggleSmsPaymentReceipts(bool val) {
    _smsPaymentReceipts = val;
    notifyListeners();
  }

  void toggleLoudJobAlarmMode(bool val) {
    _loudJobAlarmMode = val;
    notifyListeners();
  }

  void toggleHapticFeedback(bool val) {
    _hapticFeedbackEnabled = val;
    notifyListeners();
  }

  void setAlertRingtone(String tone) {
    _alertRingtone = tone;
    notifyListeners();
  }

  void toggleQuietHours(bool val) {
    _quietHoursEnabled = val;
    notifyListeners();
  }

  void updateQuietHours({TimeOfDay? start, TimeOfDay? end}) {
    if (start != null) _quietHoursStart = start;
    if (end != null) _quietHoursEnd = end;
    notifyListeners();
  }

  void toggleQuietHoursBypassEmergency(bool val) {
    _quietHoursBypassEmergency = val;
    notifyListeners();
  }

  void togglePartnerBonuses(bool val) {
    _partnerBonusesAndIncentives = val;
    notifyListeners();
  }

  void toggleCommunityTips(bool val) {
    _communityTipsAndNews = val;
    notifyListeners();
  }

  void resetToDefaults() {
    _allNotificationsEnabled = true;
    _newJobRequests = true;
    _clientMessages = true;
    _jobScheduleReminders = true;
    _payoutAndPaymentAlerts = true;
    _systemSecurityAlerts = true;
    _smsUrgentJobs = true;
    _smsPaymentReceipts = true;
    _loudJobAlarmMode = true;
    _hapticFeedbackEnabled = true;
    _alertRingtone = 'Radar Pulse (Default)';
    _quietHoursEnabled = false;
    _quietHoursStart = const TimeOfDay(hour: 22, minute: 0);
    _quietHoursEnd = const TimeOfDay(hour: 7, minute: 0);
    _quietHoursBypassEmergency = true;
    _partnerBonusesAndIncentives = true;
    _communityTipsAndNews = false;
    notifyListeners();
  }
}
