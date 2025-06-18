import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_windows/camera_windows.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_theme.dart';
import 'package:photobooth_flutter/providers/admin_watermark_provider.dart';
import 'package:photobooth_flutter/providers/app_flow_provider.dart';
import 'package:photobooth_flutter/providers/auth_provider.dart';
import 'package:photobooth_flutter/providers/category_provider.dart';
import 'package:photobooth_flutter/providers/category_settings_provider.dart';
import 'package:photobooth_flutter/providers/face_capture_provider.dart';
import 'package:photobooth_flutter/providers/gender_selection_provider.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/providers/loading_screen_provider.dart';
import 'package:photobooth_flutter/providers/output_screen_provider.dart';
import 'package:photobooth_flutter/providers/photobooth_provider.dart';
import 'package:photobooth_flutter/providers/registration_screen_provider.dart';
import 'package:photobooth_flutter/providers/theme_selection_provider.dart';
import 'package:photobooth_flutter/providers/welcome_screen_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:photobooth_flutter/services/sqflite_service.dart';
import 'package:photobooth_flutter/services/supabase_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.database;

  // Initialize providers
  final globalSettings = GlobalSettingsProvider();
  try {
    await globalSettings.init();

    if (globalSettings.supabaseUrl != null &&
        globalSettings.supabaseAnonKey != null) {
      try {
        await SupabaseService.instance.initialize(
          url: globalSettings.supabaseUrl!,
          anonKey: globalSettings.supabaseAnonKey!,
        );
      } catch (e) {
        debugPrint('Failed to initialize Supabase: $e');
      }
    }
  } catch (e) {
    debugPrint('Error initializing global settings: $e');
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await globalSettings.init();
  }

  final authProvider = AuthProvider();
  await authProvider.init();

  final appFlowProvider = AppFlowProvider();
  await appFlowProvider.init();

  final welcomeSettings = WelcomeScreenProvider();
  await welcomeSettings.init();

  final registrationSettings = RegistrationScreenProvider();
  await registrationSettings.init();

  final genderSettings = GenderSelectionProvider();
  await genderSettings.init();

  final faceCaptureProvider = FaceCaptureProvider();
  await faceCaptureProvider.init();

  final loadingScreenProvider = LoadingScreenProvider();
  await loadingScreenProvider.init();

  final outputScreenProvider = OutputScreenProvider();
  await outputScreenProvider.init();

  final categorySettingsProvider = CategorySettingsProvider();
  await categorySettingsProvider.init();

  CameraPlatform.instance = CameraWindows();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PhotoboothProvider()),
        ChangeNotifierProvider(create: (_) => ThemeSelectionProvider()),
        ChangeNotifierProvider.value(value: globalSettings),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: appFlowProvider),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider.value(value: categorySettingsProvider),
        ChangeNotifierProvider.value(value: welcomeSettings),
        ChangeNotifierProvider.value(value: registrationSettings),
        ChangeNotifierProvider.value(value: genderSettings),
        ChangeNotifierProvider.value(value: faceCaptureProvider),
        ChangeNotifierProvider.value(value: loadingScreenProvider),
        ChangeNotifierProvider.value(value: outputScreenProvider),
        ChangeNotifierProvider(create: (_) => AdminWatermarkProvider()),
      ],
      child: const MyApp(),
    ),
  );

  doWhenWindowReady(() {
    const initialSize = Size(1080, 1920);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      authProvider.setContext(context);
      final watermarkProvider =
          Provider.of<AdminWatermarkProvider>(context, listen: false);
      watermarkProvider.setShowWatermark(!authProvider.isAuthenticated);
    });

    return MaterialApp(
      title: 'AI Photobooth',
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      initialRoute: authProvider.isAuthenticated
          ? AppRoutes.welcomeScreen
          : AppRoutes.authScreen,
      debugShowCheckedModeBanner: false,
    );
  }
}
