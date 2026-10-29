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

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      sl<AuthRemoteDataSource>(),
      sl<NetworkService>(),
    ),
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

  // Blocs
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
}
