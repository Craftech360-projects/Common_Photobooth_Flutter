import 'package:flutter/material.dart';
import 'package:photobooth_flutter/presentation/admin/admin_screen.dart';
import 'package:photobooth_flutter/presentation/admin/character_screen_settings.dart';
import 'package:photobooth_flutter/presentation/admin/face_capture_settings.dart';
import 'package:photobooth_flutter/presentation/admin/gender_screen_settings.dart';
import 'package:photobooth_flutter/presentation/admin/loading_screen_settings.dart';
import 'package:photobooth_flutter/presentation/admin/output_screen_settings.dart';
import 'package:photobooth_flutter/presentation/admin/registration_screen_settings.dart';
import 'package:photobooth_flutter/presentation/admin/welcome_screen_settings.dart';
import 'package:photobooth_flutter/presentation/face_capture_screen.dart';
import 'package:photobooth_flutter/presentation/character_selection_screen.dart';
import 'package:photobooth_flutter/presentation/gender_selection_screen.dart';
import 'package:photobooth_flutter/presentation/loading_screen.dart';
import 'package:photobooth_flutter/presentation/output_screen.dart';
import 'package:photobooth_flutter/presentation/registration_screen.dart';
import 'package:photobooth_flutter/presentation/welcome_screen.dart';

class AppRoutes {
  // Main app flow
  static const String welcomeScreen = '/';

  static const String participantDetails = '/participant_details';

  static const String genderSelection = '/gender_selection';

  static const String characterSelection = '/character_selection';

  static const String faceCapture = '/face_capture';

  static const String swappedFace = '/swapped_face';

  static const String loadingScreen = '/loading_screen';

  // Admin screens
  static const String adminScreen = '/admin_screen';

  static const String welcomeScreenSettings = '/admin/welcome_screen_settings';

  static const String registrationScreenSettings =
      '/admin/registration_screen_settings';

  static const String genderScreenSettings = '/admin/gender_screen_settings';

  static const String characterScreenSettings =
      '/admin/character_screen_settings';

  static const String faceCaptureSettings = '/face_capture_settings';

  static const String loadingScreenSettings = '/admin/loading_screen_settings';

  static const String outputScreenSettings = '/admin/output_screen_settings';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Main app flow
      case welcomeScreen:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());

      case participantDetails:
        return MaterialPageRoute(
            builder: (_) => const ParticipantDetailsScreen());

      case genderSelection:
        return MaterialPageRoute(builder: (_) => const GenderSelectionScreen());

      case characterSelection:
        return MaterialPageRoute(
            builder: (_) => const CharacterSelectionScreen());

      case faceCapture:
        return MaterialPageRoute(builder: (_) => const FaceCaptureScreen());

      case loadingScreen:
        return MaterialPageRoute(builder: (_) => const LoadingScreen());

      case swappedFace:
        return MaterialPageRoute(
          builder: (_) => const SwappedFaceScreen(),
          settings: settings,
        );

      // Admin screens
      case adminScreen:
        return MaterialPageRoute(builder: (_) => const AdminScreen());

      case welcomeScreenSettings:
        return MaterialPageRoute(builder: (_) => const WelcomeScreenSettings());

      case registrationScreenSettings:
        return MaterialPageRoute(
            builder: (_) => const RegistrationScreenSettings());

      case genderScreenSettings:
        return MaterialPageRoute(builder: (_) => const GenderScreenSettings());

      case AppRoutes.characterScreenSettings:
        return MaterialPageRoute(
            builder: (_) => const CharacterScreenSettings());

      case faceCaptureSettings:
        return MaterialPageRoute(builder: (_) => const FaceCaptureSettings());

      case loadingScreenSettings:
        return MaterialPageRoute(builder: (_) => const LoadingScreenSettings());

      case outputScreenSettings:
        return MaterialPageRoute(builder: (_) => const OutputScreenSettings());

      // Add more routes as needed
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
