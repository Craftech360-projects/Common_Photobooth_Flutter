import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_theme.dart';
import 'package:photobooth_flutter/providers/admin_settings_provider.dart';
import 'package:photobooth_flutter/providers/app_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final adminSettings = AdminSettingsProvider();
  await adminSettings.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PhotoboothProvider()),
        ChangeNotifierProvider.value(value: adminSettings),
      ],
      child: const PhotoboothApp(),
    ),
  );
}

class PhotoboothApp extends StatelessWidget {
  const PhotoboothApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Photobooth',
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.participantDetails,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
