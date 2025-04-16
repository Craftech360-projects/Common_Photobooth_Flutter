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

  // Welcome message styling
  double _welcomeMessageFontSize = 36.0;
  FontWeight _welcomeMessageFontWeight = FontWeight.bold;
  double _welcomeMessageLineHeight = 1.2;
  TextAlign _welcomeMessageTextAlign = TextAlign.center;
  Color _welcomeMessageColor = Colors.white;
  double _welcomeMessageOpacity = 1.0;
  bool _welcomeMessageItalic = false;
  double _welcomeMessageMarginTop = 0.0;
  double _welcomeMessageMarginBottom = 50.0;
  double _welcomeMessageMarginLeft = 40.0;
  double _welcomeMessageMarginRight = 40.0;

  // Button settings
  bool _useImageButton = false;
  String _welcomeButtonText = 'Get Started';
  Color _welcomeButtonColor = AppColors.goldenYellow;
  Color _welcomeButtonTextColor = AppColors.black;
  double _buttonWidth = 200.0;
  double _buttonHeight = 60.0;
  double _buttonBorderRadius = 4.0;

  // Text button additional styling
  double _buttonTextFontSize = 24.0;
  FontWeight _buttonTextFontWeight = FontWeight.bold;
  double _buttonTextLineHeight = 1.0;
  bool _buttonTextItalic = false;
  double _buttonTextOpacity = 1.0;
  double _buttonOpacity = 1.0;
  double _buttonMarginTop = 0.0;
  double _buttonMarginBottom = 0.0;
  double _buttonPaddingVertical = 8.0;
  double _buttonPaddingHorizontal = 16.0;

  // Image button settings
  String? _buttonImagePath;
  bool _isButtonImageAsset = true;
  double _buttonImageOpacity = 1.0;

  // Background settings
  String? _welcomeScreenBackground;
  bool _isWelcomeScreenBackgroundAsset = true;

  // Getters for welcome message styling
  double get welcomeMessageFontSize => _welcomeMessageFontSize;
  FontWeight get welcomeMessageFontWeight => _welcomeMessageFontWeight;
  double get welcomeMessageLineHeight => _welcomeMessageLineHeight;
  TextAlign get welcomeMessageTextAlign => _welcomeMessageTextAlign;
  Color get welcomeMessageColor => _welcomeMessageColor;
  double get welcomeMessageOpacity => _welcomeMessageOpacity;
  bool get welcomeMessageItalic => _welcomeMessageItalic;
  double get welcomeMessageMarginTop => _welcomeMessageMarginTop;
  double get welcomeMessageMarginBottom => _welcomeMessageMarginBottom;
  double get welcomeMessageMarginLeft => _welcomeMessageMarginLeft;
  double get welcomeMessageMarginRight => _welcomeMessageMarginRight;

  // Getters for button styling
  double get buttonTextFontSize => _buttonTextFontSize;
  FontWeight get buttonTextFontWeight => _buttonTextFontWeight;
  double get buttonTextLineHeight => _buttonTextLineHeight;
  bool get buttonTextItalic => _buttonTextItalic;
  double get buttonTextOpacity => _buttonTextOpacity;
  double get buttonOpacity => _buttonOpacity;
  double get buttonMarginTop => _buttonMarginTop;
  double get buttonMarginBottom => _buttonMarginBottom;
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
    _welcomeMessage =
        _prefs.getString('welcome_message') ?? 'Welcome to the AI Photobooth!';

    // Load welcome message styling
    _welcomeMessageFontSize =
        _prefs.getDouble('welcome_message_font_size') ?? 36.0;
    _welcomeMessageFontWeight = FontWeight.values[
        _prefs.getInt('welcome_message_font_weight') ?? 3]; // Bold is index 3
    _welcomeMessageLineHeight =
        _prefs.getDouble('welcome_message_line_height') ?? 1.2;
    _welcomeMessageTextAlign = TextAlign.values[
        _prefs.getInt('welcome_message_text_align') ?? 2]; // Center is index 2
    _welcomeMessageColor =
        Color(_prefs.getInt('welcome_message_color') ?? Colors.white.value);
    _welcomeMessageOpacity = _prefs.getDouble('welcome_message_opacity') ?? 1.0;
    _welcomeMessageItalic = _prefs.getBool('welcome_message_italic') ?? false;
    _welcomeMessageMarginTop =
        _prefs.getDouble('welcome_message_margin_top') ?? 0.0;
    _welcomeMessageMarginBottom =
        _prefs.getDouble('welcome_message_margin_bottom') ?? 50.0;
    _welcomeMessageMarginLeft =
        _prefs.getDouble('welcome_message_margin_left') ?? 40.0;
    _welcomeMessageMarginRight =
        _prefs.getDouble('welcome_message_margin_right') ?? 40.0;

    /// Load button settings
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

    // Load text button additional styling
    _buttonTextFontSize =
        _prefs.getDouble('welcome_button_text_font_size') ?? 24.0;
    _buttonTextFontWeight = FontWeight.values[
        _prefs.getInt('welcome_button_text_font_weight') ??
            3]; // Bold is index 3
    _buttonTextLineHeight =
        _prefs.getDouble('welcome_button_text_line_height') ?? 1.0;
    _buttonTextItalic = _prefs.getBool('welcome_button_text_italic') ?? false;
    _buttonTextOpacity = _prefs.getDouble('welcome_button_text_opacity') ?? 1.0;
    _buttonOpacity = _prefs.getDouble('welcome_button_opacity') ?? 1.0;
    _buttonMarginTop = _prefs.getDouble('welcome_button_margin_top') ?? 0.0;
    _buttonMarginBottom =
        _prefs.getDouble('welcome_button_margin_bottom') ?? 0.0;
    _buttonPaddingVertical =
        _prefs.getDouble('welcome_button_padding_vertical') ?? 8.0;
    _buttonPaddingHorizontal =
        _prefs.getDouble('welcome_button_padding_horizontal') ?? 16.0;

    // Load image button settings
    _buttonImagePath = _prefs.getString('welcome_button_image_path');
    _isButtonImageAsset =
        _prefs.getBool('welcome_is_button_image_asset') ?? true;
    _buttonImageOpacity =
        _prefs.getDouble('welcome_button_image_opacity') ?? 1.0;

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

  void setWelcomeMessageMargins(
      double top, double bottom, double left, double right) async {
    _welcomeMessageMarginTop = top;
    _welcomeMessageMarginBottom = bottom;
    _welcomeMessageMarginLeft = left;
    _welcomeMessageMarginRight = right;
    await _prefs.setDouble('welcome_message_margin_top', top);
    await _prefs.setDouble('welcome_message_margin_bottom', bottom);
    await _prefs.setDouble('welcome_message_margin_left', left);
    await _prefs.setDouble('welcome_message_margin_right', right);
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

  void setButtonMargins(double top, double bottom) async {
    _buttonMarginTop = top;
    _buttonMarginBottom = bottom;
    await _prefs.setDouble('welcome_button_margin_top', top);
    await _prefs.setDouble('welcome_button_margin_bottom', bottom);
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
