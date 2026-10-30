import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEndpoints {
  AppEndpoints._();

  static String get baseUrl {
    final baseUrl = dotenv.env['BASE_URL'];
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      // Fallback to environment variable or standard localhost
      return const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://10.0.2.2:8000/api',
      );
    }
    return baseUrl;
  }

  // Auth endpoints
  static const String providerRegister = '/provider/register';
  static const String providerLogin = '/provider/login';
  static const String providerCompleteProfile = '/provider/complete-profile';

  // Profile & Dashboard
  static const String providerProfile = '/provider/profile';
  static const String providerDashboard = '/provider/dashboard';
  static const String providerStatus = '/provider/status';
  static const String providerLocation = '/provider/location';
  static const String providerKyc = '/provider/kyc';
  static const String providerPayoutAccounts = '/provider/payout-accounts';
  static const String providerWallet = '/provider/wallet';
  static const String providerWalletPayFees = '/provider/wallet/pay-fees';
  static const String providerPayouts = '/provider/payouts';
  static const String providerNotifications = '/provider/notifications';
  static String providerNotificationRead(int id) => '/provider/notifications/$id/read';
  static const String providerNotificationMarkAllRead = '/provider/notifications/mark-all-read';
  static String providerNotificationDelete(int id) => '/provider/notifications/$id';
  static const String providerServices = '/provider/services';
  static const String providerWorkingHours = '/provider/working-hours';
  static const String providerJobs = '/provider/jobs';
  static const String providerJobRequests = '/provider/job-requests';
  static const String providerQuotations = '/provider/quotations';
  static String providerJobStart(String id) => '/provider/jobs/$id/start';
  static String providerJobExtraCharge(String id) => '/provider/jobs/$id/extra-charge';
  static String providerJobComplete(String id) => '/provider/jobs/$id/complete';
  static String providerJobRequestQuote(String id) => '/provider/job-requests/$id/quotations';
  static const String providerNotificationPreferences = '/provider/notification-preferences';
  static const String services = '/services';
  static const String serviceCategories = '/service-categories';
}
