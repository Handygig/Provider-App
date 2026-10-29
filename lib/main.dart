import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'config/router/app_router.dart';
import 'config/theme/app_theme.dart';
import 'core/di/service_locator.dart';
import 'core/services/auth_manager.dart';
import 'core/services/language_manager.dart';

// Blocs & Cubits
import 'src/presentation/blocs/auth/auth_bloc.dart';
import 'src/presentation/cubits/profile/profile_cubit.dart';
import 'src/presentation/cubits/jobs/jobs_cubit.dart';
import 'src/presentation/cubits/payout/payout_cubit.dart';
import 'src/presentation/cubits/services/managed_services_cubit.dart';
import 'src/presentation/cubits/coverage/coverage_cubit.dart';
import 'src/presentation/cubits/notifications/notification_preferences_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initServiceLocator();
  await AuthManager.init();
  await LanguageManager.init();
  runApp(const ProviderApp());
}

class ProviderApp extends StatelessWidget {
  const ProviderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(create: (context) => sl<AuthBloc>()),
            BlocProvider<ProfileCubit>(
              create: (context) => sl<ProfileCubit>()..loadProfile(),
            ),
            BlocProvider<JobsCubit>(
              create: (context) => sl<JobsCubit>()..loadJobs(),
            ),
            BlocProvider<PayoutCubit>(
              create: (context) => sl<PayoutCubit>()..loadAccounts(),
            ),
            BlocProvider<ManagedServicesCubit>(
              create: (context) => sl<ManagedServicesCubit>()..loadServices(),
            ),
            BlocProvider<CoverageCubit>(
              create: (context) => sl<CoverageCubit>()..loadCoverage(),
            ),
            BlocProvider<NotificationPreferencesCubit>(
              create: (context) =>
                  sl<NotificationPreferencesCubit>()..loadPreferences(),
            ),
          ],
          child: ValueListenableBuilder<Locale>(
            valueListenable: LanguageManager.localeNotifier,
            builder: (context, locale, _) {
              return MaterialApp.router(
                title: 'Provider App',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                locale: locale,
                routerConfig: AppRouter.router,
              );
            },
          ),
        );
      },
    );
  }
}
