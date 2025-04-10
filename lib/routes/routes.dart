import 'package:flutter/material.dart';
import 'package:photobooth_flutter/presentation/admin_screen.dart';
import 'package:photobooth_flutter/presentation/character_selection_screen.dart';
import 'package:photobooth_flutter/presentation/face_capture_screen.dart';
import 'package:photobooth_flutter/presentation/gender_selection_screen.dart';
import 'package:photobooth_flutter/presentation/participant_details_screen.dart';
import 'package:photobooth_flutter/presentation/swapped_face_screen.dart';

class AppRoutes {
  static const String participantDetails = '/';
  static const String genderSelection = '/gender-selection';
  static const String characterSelection = '/character-selection';
  static const String faceCapture = '/face-capture';
  static const String swappedFace = '/swapped-face';
  static const String adminScreen = '/admin-screen';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
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
      case swappedFace:
        return MaterialPageRoute(builder: (_) => const SwappedFaceScreen());
      case adminScreen:
        return MaterialPageRoute(builder: (_) => const AdminScreen());
      default:
        return MaterialPageRoute(
            builder: (_) => const ParticipantDetailsScreen());
    }
  }
}
