import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'config/theme/app_theme.dart';
import 'core/di/service_locator.dart';
import 'core/services/auth_manager.dart';
import 'core/services/language_manager.dart';
import 'src/presentation/blocs/auth/auth_bloc.dart';
import 'src/presentation/screens/welcome/welcome_screen.dart';
import 'src/presentation/screens/home/home_screen.dart';

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
    return BlocProvider<AuthBloc>(
      create: (context) => sl<AuthBloc>(),
      child: ScreenUtilInit(
        designSize: const Size(430, 932),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return ValueListenableBuilder<Locale>(
            valueListenable: LanguageManager.localeNotifier,
            builder: (context, locale, _) {
              return MaterialApp(
                title: 'Provider App',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                locale: locale,
                home: AuthManager.isLoggedIn
                    ? const HomeScreen()
                    : const WelcomeScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
