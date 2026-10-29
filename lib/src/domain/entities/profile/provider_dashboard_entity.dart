class ProviderDashboardEntity {
  final double todayEarnings;
  final double thisMonthEarnings;
  final int completedJobsCount;
  final int activeJobsCount;
  final int pendingQuotesCount;
  final int unreadAlertsCount;
  final bool isOnline;

  const ProviderDashboardEntity({
    required this.todayEarnings,
    required this.thisMonthEarnings,
    required this.completedJobsCount,
    required this.activeJobsCount,
    required this.pendingQuotesCount,
    required this.unreadAlertsCount,
    required this.isOnline,
  });

  String get formattedThisMonthEarnings {
    if (thisMonthEarnings >= 1000) {
      final inK = (thisMonthEarnings / 1000).toStringAsFixed(1);
      return 'LKR ${inK}k';
    }
    return 'LKR ${thisMonthEarnings.toStringAsFixed(0)}';
  }
}
