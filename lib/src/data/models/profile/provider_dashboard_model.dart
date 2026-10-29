import 'package:provider_app/src/domain/entities/profile/provider_dashboard_entity.dart';

class ProviderDashboardModel extends ProviderDashboardEntity {
  const ProviderDashboardModel({
    required super.todayEarnings,
    required super.thisMonthEarnings,
    required super.completedJobsCount,
    required super.activeJobsCount,
    required super.pendingQuotesCount,
    required super.unreadAlertsCount,
    required super.isOnline,
  });

  factory ProviderDashboardModel.fromJson(Map<String, dynamic> json) {
    return ProviderDashboardModel(
      todayEarnings: json['today_earnings'] != null
          ? double.tryParse(json['today_earnings'].toString()) ?? 0.0
          : 0.0,
      thisMonthEarnings: json['this_month_earnings'] != null
          ? double.tryParse(json['this_month_earnings'].toString()) ?? 0.0
          : 0.0,
      completedJobsCount: json['completed_jobs_count'] is int
          ? json['completed_jobs_count']
          : int.tryParse(json['completed_jobs_count']?.toString() ?? '0') ?? 0,
      activeJobsCount: json['active_jobs_count'] is int
          ? json['active_jobs_count']
          : int.tryParse(json['active_jobs_count']?.toString() ?? '0') ?? 0,
      pendingQuotesCount: json['pending_quotes_count'] is int
          ? json['pending_quotes_count']
          : int.tryParse(json['pending_quotes_count']?.toString() ?? '0') ?? 0,
      unreadAlertsCount: json['unread_alerts_count'] is int
          ? json['unread_alerts_count']
          : int.tryParse(json['unread_alerts_count']?.toString() ?? '0') ?? 0,
      isOnline: json['is_online'] == true,
    );
  }
}
