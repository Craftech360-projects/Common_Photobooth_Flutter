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
  String _welcomeMessage = '';

  // Welcome message styling
  double _welcomeMessageFontSize = 22.0;
  FontWeight _welcomeMessageFontWeight = FontWeight.w500;
  double _welcomeMessageLineHeight = 1.2;
  TextAlign _welcomeMessageTextAlign = TextAlign.center;
  Color _welcomeMessageColor = AppColors.white;
  double _welcomeMessageOpacity = 1.0;
  bool _welcomeMessageItalic = false;

  // Default to percentage-based positioning
  double _welcomeMessageLeft = 0.37; // ~400px on a 1080p screen
  double _welcomeMessageTop = 0.47; // ~900px on a 1920p screen
  double _welcomeMessageWidth = 0.28; // ~300px
  double _buttonLeft = 0.22; // ~245px
  double _buttonBottom = 0.34; // ~660px

  // Button settings
  bool _useImageButton = true; // Default to image button
  String _welcomeButtonText = 'Get Started';
  Color _welcomeButtonColor = AppColors.goldenYellow;
  Color _welcomeButtonTextColor = AppColors.black;
  double _buttonWidth = 585.0;
  double _buttonHeight = 150.0;
  double _buttonBorderRadius = 0.0;

  // Text button additional styling
  double _buttonTextFontSize = 18.0;
  FontWeight _buttonTextFontWeight = FontWeight.w500;
  double _buttonTextLineHeight = 1.2;
  bool _buttonTextItalic = false;
  double _buttonTextOpacity = 1.0;
  double _buttonOpacity = 1.0;
  double _buttonPaddingVertical = 0.0;
  double _buttonPaddingHorizontal = 0.0;

  // Image button settings
  String? _buttonImagePath =
      'assets/images/start_btn.png'; // Default button image
  bool _isButtonImageAsset = true;
  double _buttonImageOpacity = 1.0;

  // Background settings
  String? _welcomeScreenBackground =
      'assets/images/welcome_bg.png'; // Default background
  bool _isWelcomeScreenBackgroundAsset = true;

  // Getters for welcome message styling
  double get welcomeMessageFontSize => _welcomeMessageFontSize;
  FontWeight get welcomeMessageFontWeight => _welcomeMessageFontWeight;
  double get welcomeMessageLineHeight => _welcomeMessageLineHeight;
  TextAlign get welcomeMessageTextAlign => _welcomeMessageTextAlign;
  Color get welcomeMessageColor => _welcomeMessageColor;
  double get welcomeMessageOpacity => _welcomeMessageOpacity;
  bool get welcomeMessageItalic => _welcomeMessageItalic;

  double get welcomeMessageLeft => _welcomeMessageLeft;
  double get welcomeMessageTop => _welcomeMessageTop;
  double get welcomeMessageWidth => _welcomeMessageWidth;
  double get buttonLeft => _buttonLeft;
  double get buttonBottom => _buttonBottom;

  // Getters for button styling
  double get buttonTextFontSize => _buttonTextFontSize;
  FontWeight get buttonTextFontWeight => _buttonTextFontWeight;
  double get buttonTextLineHeight => _buttonTextLineHeight;
  bool get buttonTextItalic => _buttonTextItalic;
  double get buttonTextOpacity => _buttonTextOpacity;
  double get buttonOpacity => _buttonOpacity;
  double get buttonPaddingVertical => _buttonPaddingVertical;
  double get buttonPaddingHorizontal => _buttonPaddingHorizontal;

  // Getters for image button
  double get buttonImageOpacity => _buttonImageOpacity;

  // Existing getters
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
    _welcomeMessage = _prefs.getString('welcome_message') ?? _welcomeMessage;

    // Load welcome message styling
    _welcomeMessageFontSize = _prefs.getDouble('welcome_message_font_size') ??
        _welcomeMessageFontSize;
    _welcomeMessageFontWeight = FontWeight.values[
        _prefs.getInt('welcome_message_font_weight') ??
            _welcomeMessageFontWeight.index];
    _welcomeMessageLineHeight =
        _prefs.getDouble('welcome_message_line_height') ??
            _welcomeMessageLineHeight;
    _welcomeMessageTextAlign = TextAlign.values[
        _prefs.getInt('welcome_message_text_align') ??
            _welcomeMessageTextAlign.index];
    _welcomeMessageColor = Color(
        _prefs.getInt('welcome_message_color') ?? _welcomeMessageColor.value);
    _welcomeMessageOpacity =
        _prefs.getDouble('welcome_message_opacity') ?? _welcomeMessageOpacity;
    _welcomeMessageItalic =
        _prefs.getBool('welcome_message_italic') ?? _welcomeMessageItalic;

    const double refWidth = 1080.0;
    const double refHeight = 1920.0;

    double loadedLeft =
        _prefs.getDouble('welcome_message_left') ?? _welcomeMessageLeft;
    if (loadedLeft > 1.0) {
      // If it's an old pixel value
      _welcomeMessageLeft = loadedLeft / refWidth;
    } else {
      _welcomeMessageLeft = loadedLeft;
    }

    double loadedTop =
        _prefs.getDouble('welcome_message_top') ?? _welcomeMessageTop;
    if (loadedTop > 1.0) {
      _welcomeMessageTop = loadedTop / refHeight;
    } else {
      _welcomeMessageTop = loadedTop;
    }

    double loadedWidth =
        _prefs.getDouble('welcome_message_width') ?? _welcomeMessageWidth;
    if (loadedWidth > 1.0) {
      _welcomeMessageWidth = loadedWidth / refWidth;
    } else {
      _welcomeMessageWidth = loadedWidth;
    }

    double loadedButtonLeft =
        _prefs.getDouble('welcome_button_left') ?? _buttonLeft;
    if (loadedButtonLeft > 1.0) {
      _buttonLeft = loadedButtonLeft / refWidth;
    } else {
      _buttonLeft = loadedButtonLeft;
    }

    double loadedButtonBottom =
        _prefs.getDouble('welcome_button_bottom') ?? _buttonBottom;
    if (loadedButtonBottom > 1.0) {
      _buttonBottom = loadedButtonBottom / refHeight;
    } else {
      _buttonBottom = loadedButtonBottom;
    }

    // Load button settings
    _useImageButton =
        _prefs.getBool('welcome_use_image_button') ?? _useImageButton;
    _welcomeButtonText =
        _prefs.getString('welcome_button_text') ?? _welcomeButtonText;
    _welcomeButtonColor = Color(
        _prefs.getInt('welcome_button_color') ?? _welcomeButtonColor.value);
    _welcomeButtonTextColor = Color(
        _prefs.getInt('welcome_button_text_color') ??
            _welcomeButtonTextColor.value);
    _buttonWidth = _prefs.getDouble('welcome_button_width') ?? _buttonWidth;
    _buttonHeight = _prefs.getDouble('welcome_button_height') ?? _buttonHeight;
    _buttonBorderRadius =
        _prefs.getDouble('welcome_button_border_radius') ?? _buttonBorderRadius;

    // Load text button additional styling
    _buttonTextFontSize = _prefs.getDouble('welcome_button_text_font_size') ??
        _buttonTextFontSize;
    _buttonTextFontWeight = FontWeight.values[
        _prefs.getInt('welcome_button_text_font_weight') ??
            _buttonTextFontWeight.index];
    _buttonTextLineHeight =
        _prefs.getDouble('welcome_button_text_line_height') ??
            _buttonTextLineHeight;
    _buttonTextItalic =
        _prefs.getBool('welcome_button_text_italic') ?? _buttonTextItalic;
    _buttonTextOpacity =
        _prefs.getDouble('welcome_button_text_opacity') ?? _buttonTextOpacity;
    _buttonOpacity =
        _prefs.getDouble('welcome_button_opacity') ?? _buttonOpacity;
    _buttonPaddingVertical =
        _prefs.getDouble('welcome_button_padding_vertical') ??
            _buttonPaddingVertical;
    _buttonPaddingHorizontal =
        _prefs.getDouble('welcome_button_padding_horizontal') ??
            _buttonPaddingHorizontal;

    // Load image button settings
    _buttonImagePath =
        _prefs.getString('welcome_button_image_path') ?? _buttonImagePath;
    _isButtonImageAsset =
        _prefs.getBool('welcome_is_button_image_asset') ?? _isButtonImageAsset;
    _buttonImageOpacity =
        _prefs.getDouble('welcome_button_image_opacity') ?? _buttonImageOpacity;

    // Verify button image file exists if it's not an asset
    if (_buttonImagePath != null && !_isButtonImageAsset) {
      final file = File(_buttonImagePath!);
      if (!await file.exists()) {
        _buttonImagePath = null;
        await _prefs.remove('welcome_button_image_path');
      }
    }

    // Load background settings
    _welcomeScreenBackground = _prefs.getString('welcome_screen_background') ??
        _welcomeScreenBackground;
    _isWelcomeScreenBackgroundAsset =
        _prefs.getBool('welcome_is_screen_background_asset') ??
            _isWelcomeScreenBackgroundAsset;

    // Verify background image file exists if it's not an asset
    if (_welcomeScreenBackground != null && !_isWelcomeScreenBackgroundAsset) {
      final file = File(_welcomeScreenBackground!);
      if (!await file.exists()) {
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

  // Welcome message styling methods
  void setWelcomeMessageFontSize(double size) async {
    _welcomeMessageFontSize = size;
    await _prefs.setDouble('welcome_message_font_size', size);
    notifyListeners();
  }

  void setWelcomeMessageFontWeight(FontWeight weight) async {
    _welcomeMessageFontWeight = weight;
    await _prefs.setInt('welcome_message_font_weight', weight.index);
    notifyListeners();
  }

  void setWelcomeMessageLineHeight(double height) async {
    _welcomeMessageLineHeight = height;
    await _prefs.setDouble('welcome_message_line_height', height);
    notifyListeners();
  }

  void setWelcomeMessageTextAlign(TextAlign align) async {
    _welcomeMessageTextAlign = align;
    await _prefs.setInt('welcome_message_text_align', align.index);
    notifyListeners();
  }

  void setWelcomeMessageColor(Color color) async {
    _welcomeMessageColor = color;
    await _prefs.setInt('welcome_message_color', color.value);
    notifyListeners();
  }

  void setWelcomeMessageOpacity(double opacity) async {
    _welcomeMessageOpacity = opacity;
    await _prefs.setDouble('welcome_message_opacity', opacity);
    notifyListeners();
  }

  void setWelcomeMessageItalic(bool italic) async {
    _welcomeMessageItalic = italic;
    await _prefs.setBool('welcome_message_italic', italic);
    notifyListeners();
  }

  // Position methods
  void setWelcomeMessagePosition(double left, double top, double width) async {
    _welcomeMessageLeft = left;
    _welcomeMessageTop = top;
    _welcomeMessageWidth = width;
    await _prefs.setDouble('welcome_message_left', left);
    await _prefs.setDouble('welcome_message_top', top);
    await _prefs.setDouble('welcome_message_width', width);
    notifyListeners();
  }

  void setButtonPosition(double left, double bottom) async {
    _buttonLeft = left;
    _buttonBottom = bottom;
    await _prefs.setDouble('welcome_button_left', left);
    await _prefs.setDouble('welcome_button_bottom', bottom);
    notifyListeners();
  }

  // Button styling methods
  void setButtonTextFontSize(double size) async {
    _buttonTextFontSize = size;
    await _prefs.setDouble('welcome_button_text_font_size', size);
    notifyListeners();
  }

  void setButtonTextFontWeight(FontWeight weight) async {
    _buttonTextFontWeight = weight;
    await _prefs.setInt('welcome_button_text_font_weight', weight.index);
    notifyListeners();
  }

  void setButtonTextLineHeight(double height) async {
    _buttonTextLineHeight = height;
    await _prefs.setDouble('welcome_button_text_line_height', height);
    notifyListeners();
  }

  void setButtonTextItalic(bool italic) async {
    _buttonTextItalic = italic;
    await _prefs.setBool('welcome_button_text_italic', italic);
    notifyListeners();
  }

  void setButtonTextOpacity(double opacity) async {
    _buttonTextOpacity = opacity;
    await _prefs.setDouble('welcome_button_text_opacity', opacity);
    notifyListeners();
  }

  void setButtonOpacity(double opacity) async {
    _buttonOpacity = opacity;
    await _prefs.setDouble('welcome_button_opacity', opacity);
    notifyListeners();
  }

  void setButtonPadding(double vertical, double horizontal) async {
    _buttonPaddingVertical = vertical;
    _buttonPaddingHorizontal = horizontal;
    await _prefs.setDouble('welcome_button_padding_vertical', vertical);
    await _prefs.setDouble('welcome_button_padding_horizontal', horizontal);
    notifyListeners();
  }

  // Button settings methods
  void setUseImageButton(bool use) async {
    _useImageButton = use;
    await _prefs.setBool('welcome_use_image_button', use);
    notifyListeners();
  }

  void setButtonWidth(double width) async {
    _buttonWidth = width;
    await _prefs.setDouble('welcome_button_width', width);
    notifyListeners();
  }

  void setButtonHeight(double height) async {
    _buttonHeight = height;
    await _prefs.setDouble('welcome_button_height', height);
    notifyListeners();
  }

  void setButtonImageOpacity(double opacity) async {
    _buttonImageOpacity = opacity;
    await _prefs.setDouble('welcome_button_image_opacity', opacity);
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
