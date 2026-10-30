import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:provider_app/core/services/dio_client.dart';
import 'package:provider_app/core/services/network_service.dart';
import 'package:provider_app/core/services/device_name_service.dart';

// Auth
import 'package:provider_app/src/data/data_sources/remote/auth/auth_remote_data_source.dart';
import 'package:provider_app/src/data/data_sources/remote/auth/auth_remote_data_source_impl.dart';
import 'package:provider_app/src/data/repositories/auth/auth_repository_impl.dart';
import 'package:provider_app/src/domain/repositories/auth/auth_repository.dart';
import 'package:provider_app/src/domain/usecases/auth/complete_profile_usecase.dart';
import 'package:provider_app/src/domain/usecases/auth/login_with_firebase_usecase.dart';
import 'package:provider_app/src/domain/usecases/auth/logout_usecase.dart';
import 'package:provider_app/src/domain/usecases/auth/resend_otp_usecase.dart';
import 'package:provider_app/src/domain/usecases/auth/send_otp_usecase.dart';
import 'package:provider_app/src/domain/usecases/auth/verify_otp_and_register_usecase.dart';
import 'package:provider_app/src/presentation/blocs/auth/auth_bloc.dart';

// Profile
import 'package:provider_app/src/data/data_sources/remote/profile/profile_remote_data_source.dart';
import 'package:provider_app/src/data/data_sources/remote/profile/profile_remote_data_source_impl.dart';
import 'package:provider_app/src/data/repositories/profile/profile_repository_impl.dart';
import 'package:provider_app/src/domain/repositories/profile/profile_repository.dart';
import 'package:provider_app/src/domain/usecases/profile/get_provider_dashboard_usecase.dart';
import 'package:provider_app/src/domain/usecases/profile/get_provider_profile_usecase.dart';
import 'package:provider_app/src/domain/usecases/profile/submit_provider_kyc_usecase.dart';
import 'package:provider_app/src/domain/usecases/profile/toggle_provider_availability_usecase.dart';
import 'package:provider_app/src/domain/usecases/profile/update_provider_profile_usecase.dart';
import 'package:provider_app/src/presentation/cubits/profile/profile_cubit.dart';

// Payout / Banking
import 'package:provider_app/src/data/data_sources/remote/payout/payout_remote_data_source.dart';
import 'package:provider_app/src/data/data_sources/remote/payout/payout_remote_data_source_impl.dart';
import 'package:provider_app/src/data/repositories/payout/payout_repository_impl.dart';
import 'package:provider_app/src/domain/repositories/payout/payout_repository.dart';
import 'package:provider_app/src/domain/usecases/payout/payout_usecases.dart';
import 'package:provider_app/src/presentation/cubits/payout/payout_cubit.dart';

// Managed Services & Skills
import 'package:provider_app/src/data/data_sources/remote/services/managed_services_remote_data_source.dart';
import 'package:provider_app/src/data/data_sources/remote/services/managed_services_remote_data_source_impl.dart';
import 'package:provider_app/src/data/repositories/services/managed_services_repository_impl.dart';
import 'package:provider_app/src/domain/repositories/services/managed_services_repository.dart';
import 'package:provider_app/src/domain/usecases/services/managed_services_usecases.dart';
import 'package:provider_app/src/presentation/cubits/services/managed_services_cubit.dart';

// Coverage & Working Hours
import 'package:provider_app/src/data/data_sources/remote/coverage/coverage_remote_data_source.dart';
import 'package:provider_app/src/data/data_sources/remote/coverage/coverage_remote_data_source_impl.dart';
import 'package:provider_app/src/data/repositories/coverage/coverage_repository_impl.dart';
import 'package:provider_app/src/domain/repositories/coverage/coverage_repository.dart';
import 'package:provider_app/src/domain/usecases/coverage/coverage_usecases.dart';
import 'package:provider_app/src/presentation/cubits/coverage/coverage_cubit.dart';

// Notification Preferences
import 'package:provider_app/src/data/data_sources/remote/notifications/notification_preferences_remote_data_source.dart';
import 'package:provider_app/src/data/data_sources/remote/notifications/notification_preferences_remote_data_source_impl.dart';
import 'package:provider_app/src/data/repositories/notifications/notification_preferences_repository_impl.dart';
import 'package:provider_app/src/domain/repositories/notifications/notification_preferences_repository.dart';
import 'package:provider_app/src/domain/usecases/notifications/notification_preferences_usecases.dart';
import 'package:provider_app/src/presentation/cubits/notifications/notification_preferences_cubit.dart';

// Notifications
import 'package:provider_app/src/data/data_sources/remote/notifications/notification_remote_data_source.dart';
import 'package:provider_app/src/data/data_sources/remote/notifications/notification_remote_data_source_impl.dart';
import 'package:provider_app/src/data/repositories/notifications/notification_repository_impl.dart';
import 'package:provider_app/src/domain/repositories/notifications/notification_repository.dart';
import 'package:provider_app/src/domain/usecases/notifications/notification_usecases.dart';
import 'package:provider_app/src/presentation/cubits/notifications/notification_cubit.dart';

// Jobs
import 'package:provider_app/src/data/data_sources/remote/jobs/job_remote_data_source.dart';
import 'package:provider_app/src/data/data_sources/remote/jobs/job_remote_data_source_impl.dart';
import 'package:provider_app/src/data/repositories/jobs/job_repository_impl.dart';
import 'package:provider_app/src/domain/repositories/jobs/job_repository.dart';
import 'package:provider_app/src/domain/usecases/jobs/job_usecases.dart';
import 'package:provider_app/src/presentation/cubits/jobs/jobs_cubit.dart';

// Reviews
import 'package:provider_app/src/data/data_sources/remote/reviews/reviews_remote_data_source.dart';
import 'package:provider_app/src/data/data_sources/remote/reviews/reviews_remote_data_source_impl.dart';
import 'package:provider_app/src/data/repositories/reviews/reviews_repository_impl.dart';
import 'package:provider_app/src/domain/repositories/reviews/reviews_repository.dart';
import 'package:provider_app/src/domain/usecases/reviews/get_reviews_usecase.dart';
import 'package:provider_app/src/presentation/cubits/reviews/reviews_cubit.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // External
  sl.registerLazySingleton<Dio>(() => DioClient.create());
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // Services
  sl.registerLazySingleton<DeviceNameService>(() => DeviceNameService());
  sl.registerLazySingleton<NetworkService>(
    () => NetworkService(connectivity: sl<Connectivity>()),
  );

  // -------------------------------------------------------------
  // Data Sources
  // -------------------------------------------------------------
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl<FirebaseAuth>(),
      dio: sl<Dio>(),
      deviceNameService: sl<DeviceNameService>(),
    ),
  );
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<PayoutRemoteDataSource>(
    () => PayoutRemoteDataSourceImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<ManagedServicesRemoteDataSource>(
    () => ManagedServicesRemoteDataSourceImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<CoverageRemoteDataSource>(
    () => CoverageRemoteDataSourceImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<NotificationPreferencesRemoteDataSource>(
    () => NotificationPreferencesRemoteDataSourceImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<JobRemoteDataSource>(
    () => JobRemoteDataSourceImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<ReviewsRemoteDataSource>(
    () => ReviewsRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // -------------------------------------------------------------
  // Repositories
  // -------------------------------------------------------------
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      sl<AuthRemoteDataSource>(),
      sl<NetworkService>(),
    ),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl<ProfileRemoteDataSource>()),
  );
  sl.registerLazySingleton<PayoutRepository>(
    () => PayoutRepositoryImpl(remoteDataSource: sl<PayoutRemoteDataSource>()),
  );
  sl.registerLazySingleton<ManagedServicesRepository>(
    () => ManagedServicesRepositoryImpl(
        remoteDataSource: sl<ManagedServicesRemoteDataSource>()),
  );
  sl.registerLazySingleton<CoverageRepository>(
    () => CoverageRepositoryImpl(
        remoteDataSource: sl<CoverageRemoteDataSource>()),
  );
  sl.registerLazySingleton<NotificationPreferencesRepository>(
    () => NotificationPreferencesRepositoryImpl(
        remoteDataSource: sl<NotificationPreferencesRemoteDataSource>()),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDataSource: sl<NotificationRemoteDataSource>(),
      networkService: sl<NetworkService>(),
    ),
  );
  sl.registerLazySingleton<JobRepository>(
    () => JobRepositoryImpl(remoteDataSource: sl<JobRemoteDataSource>()),
  );
  sl.registerLazySingleton<ReviewsRepository>(
    () => ReviewsRepositoryImpl(remoteDataSource: sl<ReviewsRemoteDataSource>()),
  );

  // -------------------------------------------------------------
  // Use Cases
  // -------------------------------------------------------------
  // Auth
  sl.registerLazySingleton<SendOtpUsecase>(
    () => SendOtpUsecase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<ResendOtpUsecase>(
    () => ResendOtpUsecase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<VerifyOtpAndRegisterUsecase>(
    () => VerifyOtpAndRegisterUsecase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<LoginWithFirebaseUsecase>(
    () => LoginWithFirebaseUsecase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<CompleteProfileUseCase>(
    () => CompleteProfileUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<LogoutUsecase>(
    () => LogoutUsecase(sl<AuthRepository>()),
  );

  // Profile
  sl.registerLazySingleton<GetProviderProfileUseCase>(
    () => GetProviderProfileUseCase(sl<ProfileRepository>()),
  );
  sl.registerLazySingleton<GetProviderDashboardUseCase>(
    () => GetProviderDashboardUseCase(sl<ProfileRepository>()),
  );
  sl.registerLazySingleton<ToggleProviderAvailabilityUseCase>(
    () => ToggleProviderAvailabilityUseCase(sl<ProfileRepository>()),
  );
  sl.registerLazySingleton<SubmitProviderKycUseCase>(
    () => SubmitProviderKycUseCase(repository: sl<ProfileRepository>()),
  );
  sl.registerLazySingleton<UpdateProviderProfileUseCase>(
    () => UpdateProviderProfileUseCase(repository: sl<ProfileRepository>()),
  );

  // Payout
  sl.registerLazySingleton<GetBankAccountsUseCase>(
    () => GetBankAccountsUseCase(sl<PayoutRepository>()),
  );
  sl.registerLazySingleton<AddBankAccountUseCase>(
    () => AddBankAccountUseCase(sl<PayoutRepository>()),
  );
  sl.registerLazySingleton<SetPrimaryBankAccountUseCase>(
    () => SetPrimaryBankAccountUseCase(sl<PayoutRepository>()),
  );
  sl.registerLazySingleton<DeleteBankAccountUseCase>(
    () => DeleteBankAccountUseCase(sl<PayoutRepository>()),
  );

  // Managed Services
  sl.registerLazySingleton<GetManagedServicesUseCase>(
    () => GetManagedServicesUseCase(sl<ManagedServicesRepository>()),
  );
  sl.registerLazySingleton<GetAvailableCatalogUseCase>(
    () => GetAvailableCatalogUseCase(sl<ManagedServicesRepository>()),
  );
  sl.registerLazySingleton<UpdateManagedServicesUseCase>(
    () => UpdateManagedServicesUseCase(sl<ManagedServicesRepository>()),
  );
  sl.registerLazySingleton<RequestCustomCategoryUseCase>(
    () => RequestCustomCategoryUseCase(sl<ManagedServicesRepository>()),
  );

  // Coverage
  sl.registerLazySingleton<GetCoverageUseCase>(
    () => GetCoverageUseCase(sl<CoverageRepository>()),
  );
  sl.registerLazySingleton<UpdateCoverageUseCase>(
    () => UpdateCoverageUseCase(sl<CoverageRepository>()),
  );
  sl.registerLazySingleton<ToggleAvailabilityUseCase>(
    () => ToggleAvailabilityUseCase(sl<CoverageRepository>()),
  );

  // Notification Preferences
  sl.registerLazySingleton<GetNotificationPreferencesUseCase>(
    () => GetNotificationPreferencesUseCase(
        sl<NotificationPreferencesRepository>()),
  );
  sl.registerLazySingleton<UpdateNotificationPreferencesUseCase>(
    () => UpdateNotificationPreferencesUseCase(
        sl<NotificationPreferencesRepository>()),
  );

  // Notifications
  sl.registerLazySingleton<GetNotificationsUseCase>(
    () => GetNotificationsUseCase(repository: sl<NotificationRepository>()),
  );
  sl.registerLazySingleton<MarkNotificationAsReadUseCase>(
    () => MarkNotificationAsReadUseCase(repository: sl<NotificationRepository>()),
  );
  sl.registerLazySingleton<MarkAllNotificationsAsReadUseCase>(
    () => MarkAllNotificationsAsReadUseCase(repository: sl<NotificationRepository>()),
  );
  sl.registerLazySingleton<DeleteNotificationUseCase>(
    () => DeleteNotificationUseCase(repository: sl<NotificationRepository>()),
  );

  // Jobs
  sl.registerLazySingleton<GetJobsUseCase>(
    () => GetJobsUseCase(sl<JobRepository>()),
  );
  sl.registerLazySingleton<GetJobDetailsUseCase>(
    () => GetJobDetailsUseCase(sl<JobRepository>()),
  );
  sl.registerLazySingleton<SubmitQuoteUseCase>(
    () => SubmitQuoteUseCase(sl<JobRepository>()),
  );
  sl.registerLazySingleton<UpdateJobStatusUseCase>(
    () => UpdateJobStatusUseCase(sl<JobRepository>()),
  );
  sl.registerLazySingleton<RequestExtraAmountUseCase>(
    () => RequestExtraAmountUseCase(sl<JobRepository>()),
  );
  sl.registerLazySingleton<CompleteJobUseCase>(
    () => CompleteJobUseCase(sl<JobRepository>()),
  );
  sl.registerLazySingleton<GetReviewsUseCase>(
    () => GetReviewsUseCase(repository: sl<ReviewsRepository>()),
  );

  // -------------------------------------------------------------
  // Blocs & Cubits
  // -------------------------------------------------------------
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      sendOtp: sl<SendOtpUsecase>(),
      resendOtp: sl<ResendOtpUsecase>(),
      verifyOtpAndRegister: sl<VerifyOtpAndRegisterUsecase>(),
      loginWithFirebase: sl<LoginWithFirebaseUsecase>(),
      completeProfile: sl<CompleteProfileUseCase>(),
      logout: sl<LogoutUsecase>(),
    ),
  );
  sl.registerLazySingleton<ProfileCubit>(
    () => ProfileCubit(
      getProfileUseCase: sl<GetProviderProfileUseCase>(),
      getDashboardUseCase: sl<GetProviderDashboardUseCase>(),
      toggleAvailabilityUseCase: sl<ToggleProviderAvailabilityUseCase>(),
      submitProviderKycUseCase: sl<SubmitProviderKycUseCase>(),
      updateProfileUseCase: sl<UpdateProviderProfileUseCase>(),
    ),
  );
  sl.registerLazySingleton<PayoutCubit>(
    () => PayoutCubit(
      getBankAccountsUseCase: sl<GetBankAccountsUseCase>(),
      addBankAccountUseCase: sl<AddBankAccountUseCase>(),
      setPrimaryBankAccountUseCase: sl<SetPrimaryBankAccountUseCase>(),
      deleteBankAccountUseCase: sl<DeleteBankAccountUseCase>(),
    ),
  );
  sl.registerLazySingleton<ManagedServicesCubit>(
    () => ManagedServicesCubit(
      getServicesUseCase: sl<GetManagedServicesUseCase>(),
      getCatalogUseCase: sl<GetAvailableCatalogUseCase>(),
      updateServicesUseCase: sl<UpdateManagedServicesUseCase>(),
      requestCustomCategoryUseCase: sl<RequestCustomCategoryUseCase>(),
    ),
  );
  sl.registerLazySingleton<CoverageCubit>(
    () => CoverageCubit(
      getCoverageUseCase: sl<GetCoverageUseCase>(),
      updateCoverageUseCase: sl<UpdateCoverageUseCase>(),
      toggleAvailabilityUseCase: sl<ToggleAvailabilityUseCase>(),
    ),
  );
  sl.registerLazySingleton<NotificationPreferencesCubit>(
    () => NotificationPreferencesCubit(
      getPreferencesUseCase: sl<GetNotificationPreferencesUseCase>(),
      updatePreferencesUseCase: sl<UpdateNotificationPreferencesUseCase>(),
    ),
  );
  sl.registerLazySingleton<NotificationCubit>(
    () => NotificationCubit(
      getNotificationsUseCase: sl<GetNotificationsUseCase>(),
      markNotificationAsReadUseCase: sl<MarkNotificationAsReadUseCase>(),
      markAllNotificationsAsReadUseCase: sl<MarkAllNotificationsAsReadUseCase>(),
      deleteNotificationUseCase: sl<DeleteNotificationUseCase>(),
    ),
  );
  sl.registerLazySingleton<JobsCubit>(
    () => JobsCubit(
      getJobsUseCase: sl<GetJobsUseCase>(),
      getJobDetailsUseCase: sl<GetJobDetailsUseCase>(),
      submitQuoteUseCase: sl<SubmitQuoteUseCase>(),
      updateJobStatusUseCase: sl<UpdateJobStatusUseCase>(),
      requestExtraAmountUseCase: sl<RequestExtraAmountUseCase>(),
      completeJobUseCase: sl<CompleteJobUseCase>(),
    ),
  );
  sl.registerLazySingleton<ReviewsCubit>(
    () => ReviewsCubit(getReviewsUseCase: sl<GetReviewsUseCase>()),
  );
}
