import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:provider_app/core/services/dio_client.dart';
import 'package:provider_app/core/services/network_service.dart';
import 'package:provider_app/core/services/device_name_service.dart';
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

  // Data Sources
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

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      sl<AuthRemoteDataSource>(),
      sl<NetworkService>(),
    ),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl<ProfileRemoteDataSource>()),
  );

  // Use Cases
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

  // Blocs & Cubits
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
  sl.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      getProfileUseCase: sl<GetProviderProfileUseCase>(),
      getDashboardUseCase: sl<GetProviderDashboardUseCase>(),
      toggleAvailabilityUseCase: sl<ToggleProviderAvailabilityUseCase>(),
      submitProviderKycUseCase: sl<SubmitProviderKycUseCase>(),
      updateProfileUseCase: sl<UpdateProviderProfileUseCase>(),
    ),
  );
}
