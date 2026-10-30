import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider_app/config/router/app_routes.dart';
import 'package:provider_app/core/services/auth_manager.dart';
import 'package:provider_app/src/data/models/jobs/job_model.dart';
import 'package:provider_app/src/presentation/screens/welcome/welcome_screen.dart';
import 'package:provider_app/src/presentation/screens/language/language_selection_screen.dart';
import 'package:provider_app/src/presentation/screens/auth/mobile_number_screen.dart';
import 'package:provider_app/src/presentation/screens/auth/otp_verification_screen.dart';
import 'package:provider_app/src/presentation/screens/auth/provider_details_screen.dart';
import 'package:provider_app/src/presentation/screens/auth/service_assignment_screen.dart';
import 'package:provider_app/src/presentation/screens/auth/living_details_screen.dart';
import 'package:provider_app/src/presentation/screens/auth/verification_screen.dart';
import 'package:provider_app/src/presentation/screens/auth/under_review_screen.dart';
import 'package:provider_app/src/presentation/screens/home/home_screen.dart';
import 'package:provider_app/src/presentation/screens/jobs/jobs_screen.dart';
import 'package:provider_app/src/presentation/screens/jobs/job_details_screen.dart';
import 'package:provider_app/src/presentation/screens/coverage/working_hours_coverage_screen.dart';
import 'package:provider_app/src/presentation/screens/services/managed_services_skills_screen.dart';
import 'package:provider_app/src/presentation/screens/verification/license_verification_screen.dart';
import 'package:provider_app/src/presentation/screens/payout/bank_payout_details_screen.dart';
import 'package:provider_app/src/presentation/screens/notifications/notification_preferences_screen.dart';
import 'package:provider_app/src/presentation/screens/chat/chat_screen.dart';
import 'package:provider_app/src/presentation/screens/reviews/customer_reviews_screen.dart';

class AppRouter {
  AppRouter._();

  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation:
        AuthManager.isLoggedIn ? AppRoutes.home : AppRoutes.welcome,
    routes: [
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.languageSelection,
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.mobileNumber,
        builder: (context, state) => const MobileNumberScreen(),
      ),
      GoRoute(
        path: AppRoutes.otpVerification,
        builder: (context, state) {
          final extra = state.extra is Map<String, dynamic>
              ? state.extra as Map<String, dynamic>
              : null;
          final phone = extra?['phoneNumber'] as String? ??
              (state.extra is String ? state.extra as String : '');
          final verId = extra?['verificationId'] as String? ?? '';
          return OtpVerificationScreen(
            phoneNumber: phone,
            verificationId: verId,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.providerDetails,
        builder: (context, state) => const ProviderDetailsScreen(),
      ),
      GoRoute(
        path: AppRoutes.serviceAssignment,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ServiceAssignmentScreen(
            firstName: extra['firstName'] as String? ?? '',
            lastName: extra['lastName'] as String? ?? '',
            phoneNumber: extra['phoneNumber'] as String? ?? '',
            email: extra['email'] as String? ?? '',
            providerType: extra['providerType'] as String? ?? '',
            addressLine1: extra['addressLine1'] as String? ?? '',
            addressLine2: extra['addressLine2'] as String?,
            city: extra['city'] as String? ?? '',
            postalCode: extra['postalCode'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.livingDetails,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return LivingDetailsScreen(
            firstName: extra['firstName'] as String? ?? '',
            lastName: extra['lastName'] as String? ?? '',
            phoneNumber: extra['phoneNumber'] as String? ?? '',
            email: extra['email'] as String? ?? '',
            providerType: extra['providerType'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.verification,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return VerificationScreen(
            firstName: extra['firstName'] as String? ?? '',
            lastName: extra['lastName'] as String? ?? '',
            phoneNumber: extra['phoneNumber'] as String? ?? '',
            email: extra['email'] as String? ?? '',
            providerType: extra['providerType'] as String? ?? '',
            addressLine1: extra['addressLine1'] as String? ?? '',
            addressLine2: extra['addressLine2'] as String?,
            city: extra['city'] as String? ?? '',
            postalCode: extra['postalCode'] as String? ?? '',
            services: (extra['services'] as List<dynamic>?)?.cast<String>() ??
                const [],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.underReview,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final firstName = extra['firstName'] as String? ??
              (state.extra is String ? state.extra as String : '');
          return UnderReviewScreen(firstName: firstName);
        },
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.jobs,
        builder: (context, state) {
          final category =
              state.extra as JobCategory? ?? JobCategory.toQuote;
          return JobsScreen(initialCategory: category);
        },
      ),
      GoRoute(
        path: AppRoutes.jobDetails,
        builder: (context, state) {
          final job = state.extra;
          final model = job is JobModel
              ? job
              : (job is JobEntity ? JobModel.fromEntity(job) : null);
          if (model == null) {
            return const Scaffold(
              body: Center(child: Text('Job not found')),
            );
          }
          return JobDetailsScreen(job: model);
        },
      ),
      GoRoute(
        path: AppRoutes.coverage,
        builder: (context, state) => const WorkingHoursCoverageScreen(),
      ),
      GoRoute(
        path: AppRoutes.managedServices,
        builder: (context, state) => const ManagedServicesSkillsScreen(),
      ),
      GoRoute(
        path: AppRoutes.licenseVerification,
        builder: (context, state) => const LicenseVerificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.payout,
        builder: (context, state) => const BankPayoutDetailsScreen(),
      ),
      GoRoute(
        path: AppRoutes.notificationPreferences,
        builder: (context, state) => const NotificationPreferencesScreen(),
      ),
      GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) {
          final job = state.extra;
          final model = job is JobModel
              ? job
              : (job is JobEntity ? JobModel.fromEntity(job) : null);
          if (model == null) {
            return const Scaffold(
              body: Center(child: Text('Job not found')),
            );
          }
          return ChatScreen(job: model);
        },
      ),
      GoRoute(
        path: AppRoutes.reviews,
        builder: (context, state) => const CustomerReviewsScreen(),
      ),
    ],
  );
}
