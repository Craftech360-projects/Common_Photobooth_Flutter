import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreenProvider extends ChangeNotifier {
  late SharedPreferences _prefs;

  // Welcome screen settings
  bool _showWelcomeScreen = true;
  String _welcomeMessage = 'Welcome to the AI Photobooth!';

  // Button settings
  bool _useImageButton = false;
  String _welcomeButtonText = 'Get Started';
  Color _welcomeButtonColor = AppColors.goldenYellow;
  Color _welcomeButtonTextColor = AppColors.black;
  double _buttonWidth = 200.0;
  double _buttonHeight = 60.0;
  double _buttonBorderRadius = 4.0;

  // Image button settings
  String? _buttonImagePath;
  bool _isButtonImageAsset = true;

  // Background settings
  String? _welcomeScreenBackground;
  bool _isWelcomeScreenBackgroundAsset = true;

  // Getters
  bool get showWelcomeScreen => _showWelcomeScreen;
  String get welcomeMessage => _welcomeMessage;
  bool get useImageButton => _useImageButton;
  String get welcomeButtonText => _welcomeButtonText;
  Color get welcomeButtonColor => _welcomeButtonColor;
  Color get welcomeButtonTextColor => _welcomeButtonTextColor;
  double get buttonWidth => _buttonWidth;
  double get buttonHeight => _buttonHeight;
  double get buttonBorderRadius => _buttonBorderRadius;
  String? get buttonImagePath => _buttonImagePath;
  bool get isButtonImageAsset => _isButtonImageAsset;
  String? get welcomeScreenBackground => _welcomeScreenBackground;
  bool get isWelcomeScreenBackgroundAsset => _isWelcomeScreenBackgroundAsset;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await loadSettings();
  }

  Future<void> loadSettings() async {
    // Load welcome screen settings
    _showWelcomeScreen = _prefs.getBool('welcome_show_screen') ?? true;
    _welcomeMessage =
        _prefs.getString('welcome_message') ?? 'Welcome to the AI Photobooth!';

    // Load button settings
    _useImageButton = _prefs.getBool('welcome_use_image_button') ?? false;
    _welcomeButtonText =
        _prefs.getString('welcome_button_text') ?? 'Get Started';
    _welcomeButtonColor = Color(
        _prefs.getInt('welcome_button_color') ?? AppColors.goldenYellow.value);
    _welcomeButtonTextColor = Color(
        _prefs.getInt('welcome_button_text_color') ?? AppColors.black.value);
    _buttonWidth = _prefs.getDouble('welcome_button_width') ?? 200.0;
    _buttonHeight = _prefs.getDouble('welcome_button_height') ?? 60.0;
    _buttonBorderRadius =
        _prefs.getDouble('welcome_button_border_radius') ?? 4.0;

    // Load image button settings
    _buttonImagePath = _prefs.getString('welcome_button_image_path');
    _isButtonImageAsset =
        _prefs.getBool('welcome_is_button_image_asset') ?? true;

    // Verify button image file exists if it's not an asset
    if (_buttonImagePath != null && !_isButtonImageAsset) {
      final file = File(_buttonImagePath!);
      if (!file.existsSync()) {
        _buttonImagePath = null;
        await _prefs.remove('welcome_button_image_path');
      }
    }

    // Load background settings
    _welcomeScreenBackground = _prefs.getString('welcome_screen_background');
    _isWelcomeScreenBackgroundAsset =
        _prefs.getBool('welcome_is_screen_background_asset') ?? true;

    // Verify background image file exists if it's not an asset
    if (_welcomeScreenBackground != null && !_isWelcomeScreenBackgroundAsset) {
      final file = File(_welcomeScreenBackground!);
      if (!file.existsSync()) {
        _welcomeScreenBackground = null;
        await _prefs.remove('welcome_screen_background');
      }
    }

    notifyListeners();
  }

  // Screen settings methods
  void setShowWelcomeScreen(bool show) async {
    _showWelcomeScreen = show;
    await _prefs.setBool('welcome_show_screen', show);
    notifyListeners();
  }

  void setWelcomeMessage(String message) async {
    _welcomeMessage = message;
    await _prefs.setString('welcome_message', message);
    notifyListeners();
  }

  // Button settings methods
  void setUseImageButton(bool use) async {
    _useImageButton = use;
    await _prefs.setBool('welcome_use_image_button', use);
    notifyListeners();
  }

  void setWelcomeButtonText(String text) async {
    _welcomeButtonText = text;
    await _prefs.setString('welcome_button_text', text);
    notifyListeners();
  }

  void setWelcomeButtonColor(Color color) async {
    _welcomeButtonColor = color;
    await _prefs.setInt('welcome_button_color', color.value);
    notifyListeners();
  }

  void setWelcomeButtonTextColor(Color color) async {
    _welcomeButtonTextColor = color;
    await _prefs.setInt('welcome_button_text_color', color.value);
    notifyListeners();
  }

  void setButtonDimensions(double width, double height) async {
    _buttonWidth = width;
    _buttonHeight = height;
    await _prefs.setDouble('welcome_button_width', width);
    await _prefs.setDouble('welcome_button_height', height);
    notifyListeners();
  }

  void setButtonBorderRadius(double radius) async {
    _buttonBorderRadius = radius;
    await _prefs.setDouble('welcome_button_border_radius', radius);
    notifyListeners();
  }

  // Image button methods
  Future<void> setButtonImage(String? sourcePath, {bool isAsset = true}) async {
    if (sourcePath == null) {
      _buttonImagePath = null;
      _isButtonImageAsset = true;
      await _prefs.remove('welcome_button_image_path');
      await _prefs.setBool('welcome_is_button_image_asset', true);
      notifyListeners();
      return;
    }

    if (isAsset) {
      // For asset images, just store the path
      _buttonImagePath = sourcePath;
      _isButtonImageAsset = true;
    } else {
      // For file images, copy to app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName =
          'welcome_button_${DateTime.now().millisecondsSinceEpoch}${path.extension(sourcePath)}';
      final destinationPath = path.join(appDir.path, fileName);

      try {
        final sourceFile = File(sourcePath);
        await sourceFile.copy(destinationPath);
        _buttonImagePath = destinationPath;
        _isButtonImageAsset = false;
      } on Exception catch (e) {
        debugPrint('Error copying button image: $e');
        return;
      }
    }

    await _prefs.setString('welcome_button_image_path', _buttonImagePath!);
    await _prefs.setBool('welcome_is_button_image_asset', _isButtonImageAsset);
    notifyListeners();
  }

  // Background methods
  Future<void> setWelcomeScreenBackground(String? sourcePath,
      {bool isAsset = true}) async {
    if (sourcePath == null) {
      _welcomeScreenBackground = null;
      _isWelcomeScreenBackgroundAsset = true;
      await _prefs.remove('welcome_screen_background');
      await _prefs.setBool('welcome_is_screen_background_asset', true);
      notifyListeners();
      return;
    }

    if (isAsset) {
      // For asset images, just store the path
      _welcomeScreenBackground = sourcePath;
      _isWelcomeScreenBackgroundAsset = true;
    } else {
      // For file images, copy to app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName =
          'welcome_background_${DateTime.now().millisecondsSinceEpoch}${path.extension(sourcePath)}';
      final destinationPath = path.join(appDir.path, fileName);

      try {
        final sourceFile = File(sourcePath);
        await sourceFile.copy(destinationPath);
        _welcomeScreenBackground = destinationPath;
        _isWelcomeScreenBackgroundAsset = false;
      } on Exception catch (e) {
        debugPrint('Error copying background image: $e');
        return;
      }
    }

    await _prefs.setString(
        'welcome_screen_background', _welcomeScreenBackground!);
    await _prefs.setBool(
        'welcome_is_screen_background_asset', _isWelcomeScreenBackgroundAsset);
    notifyListeners();
  }
}
