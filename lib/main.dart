import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_windows/camera_windows.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_theme.dart';
import 'package:photobooth_flutter/providers/admin_settings_provider.dart';
import 'package:photobooth_flutter/providers/admin_watermark_provider.dart';
import 'package:photobooth_flutter/providers/app_flow_provider.dart';
import 'package:photobooth_flutter/providers/auth_provider.dart';
import 'package:photobooth_flutter/providers/character_selection_provider.dart';
import 'package:photobooth_flutter/providers/face_capture_provider.dart';
import 'package:photobooth_flutter/providers/gender_selection_provider.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/providers/loading_screen_provider.dart';
import 'package:photobooth_flutter/providers/output_screen_provider.dart';
import 'package:photobooth_flutter/providers/photobooth_provider.dart';
import 'package:photobooth_flutter/providers/registration_screen_provider.dart';
import 'package:photobooth_flutter/providers/welcome_screen_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:photobooth_flutter/services/auth_service.dart';
import 'package:photobooth_flutter/services/supabase_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize auth service
  await AuthService.instance.initialize(
    apiUrl: 'http://localhost:2321',
  );

  // Initialize providers
  final globalSettings = GlobalSettingsProvider();
  try {
    await globalSettings.init();

    // Initialize Supabase if URL and key are available
    if (globalSettings.supabaseUrl != null &&
        globalSettings.supabaseAnonKey != null) {
      try {
        await SupabaseService.instance.initialize(
          url: globalSettings.supabaseUrl!,
          anonKey: globalSettings.supabaseAnonKey!,
        );
      } on Exception catch (e) {
        debugPrint('Failed to initialize Supabase: $e');
      }
    }
  } on Exception catch (e) {
    debugPrint('Error initializing global settings: $e');

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await globalSettings.init();
  }

  // Initialize auth provider
  final authProvider = AuthProvider();
  await authProvider.init();

  // Initialize app flow provider
  final appFlowProvider = AppFlowProvider();
  await appFlowProvider.init();

  final welcomeSettings = WelcomeScreenProvider();
  try {
    await welcomeSettings.init();
  } on Exception catch (e) {
    debugPrint('Error initializing welcome settings: $e');
  }

  final adminSettings = AdminSettingsProvider();
  await adminSettings.init();

  final registrationSettings = RegistrationScreenProvider();
  await registrationSettings.init();

  final genderSettings = GenderSelectionProvider();
  await genderSettings.init();

  final characterSettings = CharacterSelectionProvider();
  try {
    await characterSettings.init();
  } on Exception catch (e) {
    debugPrint('Error initializing character settings: $e');

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('character_selection_settings');
    await characterSettings.init();
  }

  final faceCaptureProvider = FaceCaptureProvider();
  await faceCaptureProvider.init();

  final loadingScreenProvider = LoadingScreenProvider();
  await loadingScreenProvider.init();

  final outputScreenProvider = OutputScreenProvider();
  await outputScreenProvider.init();

  CameraPlatform.instance = CameraWindows();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PhotoboothProvider()),
        ChangeNotifierProvider.value(value: globalSettings),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: appFlowProvider),
        ChangeNotifierProvider.value(value: welcomeSettings),
        ChangeNotifierProvider.value(value: adminSettings),
        ChangeNotifierProvider.value(value: registrationSettings),
        ChangeNotifierProvider.value(value: genderSettings),
        ChangeNotifierProvider.value(value: characterSettings),
        ChangeNotifierProvider.value(value: faceCaptureProvider),
        ChangeNotifierProvider.value(value: loadingScreenProvider),
        ChangeNotifierProvider.value(value: outputScreenProvider),
        ChangeNotifierProvider(create: (_) => AdminWatermarkProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Set context in AuthProvider for watermark control
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authProvider.setContext(context);

      // Initialize watermark state based on current authentication
      final watermarkProvider =
          Provider.of<AdminWatermarkProvider>(context, listen: false);
      watermarkProvider.setShowWatermark(!authProvider.isAuthenticated);
    });

    return MaterialApp(
      title: 'Photobooth App',
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      // initialRoute: AppRoutes.welcomeScreen,
      initialRoute: authProvider.isAuthenticated
          ? AppRoutes.welcomeScreen
          : AppRoutes.authScreen,
      // home: const LoadingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
