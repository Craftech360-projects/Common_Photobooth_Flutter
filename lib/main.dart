import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_theme.dart';
import 'package:photobooth_flutter/providers/admin_settings_provider.dart';
import 'package:photobooth_flutter/providers/app_provider.dart';
import 'package:photobooth_flutter/providers/character_selection_provider.dart';
import 'package:photobooth_flutter/providers/face_capture_provider.dart';
import 'package:photobooth_flutter/providers/gender_selection_provider.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/providers/loading_screen_provider.dart';
import 'package:photobooth_flutter/providers/output_screen_provider.dart';
import 'package:photobooth_flutter/providers/registration_screen_provider.dart';
import 'package:photobooth_flutter/providers/welcome_screen_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize providers
  final globalSettings = GlobalSettingsProvider();
  await globalSettings.init();

  final welcomeSettings = WelcomeScreenProvider();
  await welcomeSettings.init();

  final adminSettings = AdminSettingsProvider();
  await adminSettings.init();

  final registrationSettings = RegistrationScreenProvider();
  await registrationSettings.init();

  final genderSettings = GenderSelectionProvider();
  await genderSettings.init();

  final characterSettings = CharacterSelectionProvider();
  await characterSettings.init();

  final faceCaptureProvider = FaceCaptureProvider();
  await faceCaptureProvider.init();

  final loadingScreenProvider = LoadingScreenProvider();
  await loadingScreenProvider.init();

  final outputScreenProvider = OutputScreenProvider();
  await outputScreenProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PhotoboothProvider()),
        ChangeNotifierProvider.value(value: globalSettings),
        ChangeNotifierProvider.value(value: welcomeSettings),
        ChangeNotifierProvider.value(value: adminSettings),
        ChangeNotifierProvider.value(value: registrationSettings),
        ChangeNotifierProvider.value(value: genderSettings),
        ChangeNotifierProvider.value(value: characterSettings),
        ChangeNotifierProvider.value(value: faceCaptureProvider),
        ChangeNotifierProvider.value(value: loadingScreenProvider),
        ChangeNotifierProvider.value(value: outputScreenProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photobooth App',
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      initialRoute: AppRoutes.welcomeScreen,
      // home: const SwappedFaceScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
