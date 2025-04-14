import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum WidgetPosition {
  topLeft,
  topCenter,
  topRight,
  centerLeft,
  center,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

enum QrCodeLayout {
  below,
  above,
  leftOfQr,
  rightOfQr,
  sideBySide,
}

class OutputScreenProvider extends ChangeNotifier {
  late SharedPreferences _prefs;

  // Offset properties for fine-tuning positions
  double _titleOffsetX = 0.0;
  double _titleOffsetY = 0.0;
  double _imageOffsetX = 0.0;
  double _imageOffsetY = 0.0;
  double _qrCodeOffsetX = 0.0;
  double _qrCodeOffsetY = 0.0;
  double _buttonOffsetX = 0.0;
  double _buttonOffsetY = 0.0;

  // Title settings
  String _titleText = 'Your Image has been created';
  double _titleFontSize = 32.0;
  FontWeight _titleFontWeight = FontWeight.bold;
  Color _titleColor = Colors.white;
  double _titlePadding = 20.0;
  bool _showTitle = true;
  WidgetPosition _titlePosition = WidgetPosition.topCenter;

  // Image settings
  double _imageWidth = 400.0;
  double _imageHeight = 500.0;
  double _imageBorderRadius = 20.0;
  Color _imageBorderColor = const Color(0xFFFFD700);
  double _imageBorderWidth = 3.0;
  double _imageSpacing = 30.0;
  WidgetPosition _imagePosition = WidgetPosition.center;

  // QR code settings
  double _qrCodeSize = 150.0;
  Color _qrCodeBackgroundColor = Colors.white;
  Color _qrCodeForegroundColor = Colors.black;
  String _qrCodeText = 'Scan QR code to download your image';
  double _qrCodeTextFontSize = 18.0;
  Color _qrCodeTextColor = Colors.white;
  QrCodeLayout _qrCodeLayout = QrCodeLayout.below;
  double _qrCodeSpacing = 20.0;
  WidgetPosition _qrCodePosition = WidgetPosition.bottomCenter;

  // Button settings
  String _buttonText = 'START OVER';
  double _buttonFontSize = 24.0;
  Color _buttonColor = const Color(0xFFFFD700);
  Color _buttonTextColor = Colors.black;
  double _buttonPaddingHorizontal = 40.0;
  double _buttonPaddingVertical = 15.0;
  double _buttonSpacing = 30.0;
  WidgetPosition _buttonPosition = WidgetPosition.bottomCenter;

  // Background settings
  String? _backgroundImagePath;
  bool _isBackgroundImageAsset = true;
  bool _showBackground = true;

  // Getters for offset properties
  double get titleOffsetX => _titleOffsetX;
  double get titleOffsetY => _titleOffsetY;
  double get imageOffsetX => _imageOffsetX;
  double get imageOffsetY => _imageOffsetY;
  double get qrCodeOffsetX => _qrCodeOffsetX;
  double get qrCodeOffsetY => _qrCodeOffsetY;
  double get buttonOffsetX => _buttonOffsetX;
  double get buttonOffsetY => _buttonOffsetY;

  // Getters for other properties
  String get titleText => _titleText;
  double get titleFontSize => _titleFontSize;
  FontWeight get titleFontWeight => _titleFontWeight;
  Color get titleColor => _titleColor;
  double get titlePadding => _titlePadding;
  bool get showTitle => _showTitle;
  WidgetPosition get titlePosition => _titlePosition;

  double get imageWidth => _imageWidth;
  double get imageHeight => _imageHeight;
  double get imageBorderRadius => _imageBorderRadius;
  Color get imageBorderColor => _imageBorderColor;
  double get imageBorderWidth => _imageBorderWidth;
  double get imageSpacing => _imageSpacing;
  WidgetPosition get imagePosition => _imagePosition;

  double get qrCodeSize => _qrCodeSize;
  Color get qrCodeBackgroundColor => _qrCodeBackgroundColor;
  Color get qrCodeForegroundColor => _qrCodeForegroundColor;
  String get qrCodeText => _qrCodeText;
  double get qrCodeTextFontSize => _qrCodeTextFontSize;
  Color get qrCodeTextColor => _qrCodeTextColor;
  QrCodeLayout get qrCodeLayout => _qrCodeLayout;
  double get qrCodeSpacing => _qrCodeSpacing;
  WidgetPosition get qrCodePosition => _qrCodePosition;

  String get buttonText => _buttonText;
  double get buttonFontSize => _buttonFontSize;
  Color get buttonColor => _buttonColor;
  Color get buttonTextColor => _buttonTextColor;
  double get buttonPaddingHorizontal => _buttonPaddingHorizontal;
  double get buttonPaddingVertical => _buttonPaddingVertical;
  double get buttonSpacing => _buttonSpacing;
  WidgetPosition get buttonPosition => _buttonPosition;

  String? get backgroundImagePath => _backgroundImagePath;
  bool get isBackgroundImageAsset => _isBackgroundImageAsset;
  bool get showBackground => _showBackground;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await loadSettings();
  }

  Future<void> loadSettings() async {
    final settingsJson = _prefs.getString('output_screen_settings');
    if (settingsJson != null) {
      final Map<String, dynamic> settings = jsonDecode(settingsJson);

      // Load offset values
      _titleOffsetX = settings['titleOffsetX'] ?? _titleOffsetX;
      _titleOffsetY = settings['titleOffsetY'] ?? _titleOffsetY;
      _imageOffsetX = settings['imageOffsetX'] ?? _imageOffsetX;
      _imageOffsetY = settings['imageOffsetY'] ?? _imageOffsetY;
      _qrCodeOffsetX = settings['qrCodeOffsetX'] ?? _qrCodeOffsetX;
      _qrCodeOffsetY = settings['qrCodeOffsetY'] ?? _qrCodeOffsetY;
      _buttonOffsetX = settings['buttonOffsetX'] ?? _buttonOffsetX;
      _buttonOffsetY = settings['buttonOffsetY'] ?? _buttonOffsetY;

      // Title settings
      _titleText = settings['titleText'] ?? _titleText;
      _titleFontSize = settings['titleFontSize'] ?? _titleFontSize;
      _titleFontWeight = FontWeight
          .values[settings['titleFontWeight'] ?? _titleFontWeight.index];
      _titleColor = Color(settings['titleColor'] ?? _titleColor.value);
      _titlePadding = settings['titlePadding'] ?? _titlePadding;
      _showTitle = settings['showTitle'] ?? _showTitle;
      _titlePosition = settings['titlePosition'] != null
          ? WidgetPosition.values[settings['titlePosition']]
          : _titlePosition;

      // Image settings
      _imageWidth = settings['imageWidth'] ?? _imageWidth;
      _imageHeight = settings['imageHeight'] ?? _imageHeight;
      _imageBorderRadius = settings['imageBorderRadius'] ?? _imageBorderRadius;
      _imageBorderColor =
          Color(settings['imageBorderColor'] ?? _imageBorderColor.value);
      _imageBorderWidth = settings['imageBorderWidth'] ?? _imageBorderWidth;
      _imageSpacing = settings['imageSpacing'] ?? _imageSpacing;
      _imagePosition = settings['imagePosition'] != null
          ? WidgetPosition.values[settings['imagePosition']]
          : _imagePosition;

      // QR code settings
      _qrCodeSize = settings['qrCodeSize'] ?? _qrCodeSize;
      _qrCodeBackgroundColor = Color(
          settings['qrCodeBackgroundColor'] ?? _qrCodeBackgroundColor.value);
      _qrCodeForegroundColor = Color(
          settings['qrCodeForegroundColor'] ?? _qrCodeForegroundColor.value);
      _qrCodeText = settings['qrCodeText'] ?? _qrCodeText;
      _qrCodeTextFontSize =
          settings['qrCodeTextFontSize'] ?? _qrCodeTextFontSize;
      _qrCodeTextColor =
          Color(settings['qrCodeTextColor'] ?? _qrCodeTextColor.value);
      _qrCodeLayout =
          QrCodeLayout.values[settings['qrCodeLayout'] ?? _qrCodeLayout.index];
      _qrCodeSpacing = settings['qrCodeSpacing'] ?? _qrCodeSpacing;
      _qrCodePosition = settings['qrCodePosition'] != null
          ? WidgetPosition.values[settings['qrCodePosition']]
          : _qrCodePosition;

      // Button settings
      _buttonText = settings['buttonText'] ?? _buttonText;
      _buttonFontSize = settings['buttonFontSize'] ?? _buttonFontSize;
      _buttonColor = Color(settings['buttonColor'] ?? _buttonColor.value);
      _buttonTextColor =
          Color(settings['buttonTextColor'] ?? _buttonTextColor.value);
      _buttonPaddingHorizontal =
          settings['buttonPaddingHorizontal'] ?? _buttonPaddingHorizontal;
      _buttonPaddingVertical =
          settings['buttonPaddingVertical'] ?? _buttonPaddingVertical;
      _buttonSpacing = settings['buttonSpacing'] ?? _buttonSpacing;
      _buttonPosition = settings['buttonPosition'] != null
          ? WidgetPosition.values[settings['buttonPosition']]
          : _buttonPosition;

      // Background settings
      _backgroundImagePath = settings['backgroundImagePath'];
      _isBackgroundImageAsset =
          settings['isBackgroundImageAsset'] ?? _isBackgroundImageAsset;
      _showBackground = settings['showBackground'] ?? _showBackground;
    }

    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final settings = {
      // Offset values
      'titleOffsetX': _titleOffsetX,
      'titleOffsetY': _titleOffsetY,
      'imageOffsetX': _imageOffsetX,
      'imageOffsetY': _imageOffsetY,
      'qrCodeOffsetX': _qrCodeOffsetX,
      'qrCodeOffsetY': _qrCodeOffsetY,
      'buttonOffsetX': _buttonOffsetX,
      'buttonOffsetY': _buttonOffsetY,
      
      // Title settings
      'titleText': _titleText,
      'titleFontSize': _titleFontSize,
      'titleFontWeight': _titleFontWeight.index,
      'titleColor': _titleColor.value,
      'titlePadding': _titlePadding,
      'showTitle': _showTitle,
      'titlePosition': _titlePosition.index,

      // Image settings
      'imageWidth': _imageWidth,
      'imageHeight': _imageHeight,
      'imageBorderRadius': _imageBorderRadius,
      'imageBorderColor': _imageBorderColor.value,
      'imageBorderWidth': _imageBorderWidth,
      'imageSpacing': _imageSpacing,
      'imagePosition': _imagePosition.index,

      // QR code settings
      'qrCodeSize': _qrCodeSize,
      'qrCodeBackgroundColor': _qrCodeBackgroundColor.value,
      'qrCodeForegroundColor': _qrCodeForegroundColor.value,
      'qrCodeText': _qrCodeText,
      'qrCodeTextFontSize': _qrCodeTextFontSize,
      'qrCodeTextColor': _qrCodeTextColor.value,
      'qrCodeLayout': _qrCodeLayout.index,
      'qrCodeSpacing': _qrCodeSpacing,
      'qrCodePosition': _qrCodePosition.index,

      // Button settings
      'buttonText': _buttonText,
      'buttonFontSize': _buttonFontSize,
      'buttonColor': _buttonColor.value,
      'buttonTextColor': _buttonTextColor.value,
      'buttonPaddingHorizontal': _buttonPaddingHorizontal,
      'buttonPaddingVertical': _buttonPaddingVertical,
      'buttonSpacing': _buttonSpacing,
      'buttonPosition': _buttonPosition.index,

      // Background settings
      'backgroundImagePath': _backgroundImagePath,
      'isBackgroundImageAsset': _isBackgroundImageAsset,
      'showBackground': _showBackground,
    };

    await _prefs.setString('output_screen_settings', jsonEncode(settings));
  }

  // Setters for offset properties
  void setTitleOffset(double x, double y) {
    _titleOffsetX = x;
    _titleOffsetY = y;
    notifyListeners();
    _saveSettings();
  }
  
  void setImageOffset(double x, double y) {
    _imageOffsetX = x;
    _imageOffsetY = y;
    notifyListeners();
    _saveSettings();
  }
  
  void setQrCodeOffset(double x, double y) {
    _qrCodeOffsetX = x;
    _qrCodeOffsetY = y;
    notifyListeners();
    _saveSettings();
  }
  
  void setButtonOffset(double x, double y) {
    _buttonOffsetX = x;
    _buttonOffsetY = y;
    notifyListeners();
    _saveSettings();
  }

  // Title setters
  void setShowTitle(bool show) {
    _showTitle = show;
    notifyListeners();
    _saveSettings();
  }

  void setTitleText(String text) {
    _titleText = text;
    notifyListeners();
    _saveSettings();
  }

  void setTitleStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? padding,
  }) {
    if (fontSize != null) _titleFontSize = fontSize;
    if (fontWeight != null) _titleFontWeight = fontWeight;
    if (color != null) _titleColor = color;
    if (padding != null) _titlePadding = padding;
    notifyListeners();
    _saveSettings();
  }

  void setTitlePosition(WidgetPosition position) {
    _titlePosition = position;
    notifyListeners();
    _saveSettings();
  }

  // Image setters
  void setImageDimensions(double width, double height) {
    _imageWidth = width;
    _imageHeight = height;
    notifyListeners();
    _saveSettings();
  }

  void setImageBorder({
    double? radius,
    Color? color,
    double? width,
  }) {
    if (radius != null) _imageBorderRadius = radius;
    if (color != null) _imageBorderColor = color;
    if (width != null) _imageBorderWidth = width;
    notifyListeners();
    _saveSettings();
  }

  void setImageSpacing(double spacing) {
    _imageSpacing = spacing;
    notifyListeners();
    _saveSettings();
  }

  void setImagePosition(WidgetPosition position) {
    _imagePosition = position;
    notifyListeners();
    _saveSettings();
  }

  // QR code setters
  void setQrCodeSize(double size) {
    _qrCodeSize = size;
    notifyListeners();
    _saveSettings();
  }

  void setQrCodeColors({
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    if (backgroundColor != null) _qrCodeBackgroundColor = backgroundColor;
    if (foregroundColor != null) _qrCodeForegroundColor = foregroundColor;
    notifyListeners();
    _saveSettings();
  }

  void setQrCodeText(String text) {
    _qrCodeText = text;
    notifyListeners();
    _saveSettings();
  }

  void setQrCodeTextStyle({
    double? fontSize,
    Color? color,
  }) {
    if (fontSize != null) _qrCodeTextFontSize = fontSize;
    if (color != null) _qrCodeTextColor = color;
    notifyListeners();
    _saveSettings();
  }

  void setQrCodeLayout(QrCodeLayout layout) {
    _qrCodeLayout = layout;
    notifyListeners();
    _saveSettings();
  }

  void setQrCodeSpacing(double spacing) {
    _qrCodeSpacing = spacing;
    notifyListeners();
    _saveSettings();
  }

  void setQrCodePosition(WidgetPosition position) {
    _qrCodePosition = position;
    notifyListeners();
    _saveSettings();
  }

  // Button setters
  void setButtonText(String text) {
    _buttonText = text;
    notifyListeners();
    _saveSettings();
  }

  void setButtonStyle({
    double? fontSize,
    Color? color,
    Color? textColor,
    double? paddingHorizontal,
    double? paddingVertical,
  }) {
    if (fontSize != null) _buttonFontSize = fontSize;
    if (color != null) _buttonColor = color;
    if (textColor != null) _buttonTextColor = textColor;
    if (paddingHorizontal != null) _buttonPaddingHorizontal = paddingHorizontal;
    if (paddingVertical != null) _buttonPaddingVertical = paddingVertical;
    notifyListeners();
    _saveSettings();
  }

  void setButtonSpacing(double spacing) {
    _buttonSpacing = spacing;
    notifyListeners();
    _saveSettings();
  }

  void setButtonPosition(WidgetPosition position) {
    _buttonPosition = position;
    notifyListeners();
    _saveSettings();
  }

  // Background setters
  void setBackgroundImage(String? path, {required bool isAsset}) {
    _backgroundImagePath = path;
    _isBackgroundImageAsset = isAsset;
    notifyListeners();
    _saveSettings();
  }

  void setShowBackground(bool show) {
    _showBackground = show;
    notifyListeners();
    _saveSettings();
  }

  // Reset to defaults
  void resetToDefaults() {
    // Title settings
    _titleText = 'Your Image has been created';
    _titleFontSize = 32.0;
    _titleFontWeight = FontWeight.bold;
    _titleColor = Colors.white;
    _titlePadding = 20.0;
    _showTitle = true;
    _titlePosition = WidgetPosition.topCenter;
    _titleOffsetX = 0.0;
    _titleOffsetY = 0.0;

    // Image settings
    _imageWidth = 400.0;
    _imageHeight = 500.0;
    _imageBorderRadius = 20.0;
    _imageBorderColor = const Color(0xFFFFD700);
    _imageBorderWidth = 3.0;
    _imageSpacing = 30.0;
    _imagePosition = WidgetPosition.center;
    _imageOffsetX = 0.0;
    _imageOffsetY = 0.0;

    // QR code settings
    _qrCodeSize = 150.0;
    _qrCodeBackgroundColor = Colors.white;
    _qrCodeForegroundColor = Colors.black;
    _qrCodeText = 'Scan QR code to download your image';
    _qrCodeTextFontSize = 18.0;
    _qrCodeTextColor = Colors.white;
    _qrCodeLayout = QrCodeLayout.below;
    _qrCodeSpacing = 20.0;
    _qrCodePosition = WidgetPosition.bottomCenter;
    _qrCodeOffsetX = 0.0;
    _qrCodeOffsetY = 0.0;

    // Button settings
    _buttonText = 'START OVER';
    _buttonFontSize = 24.0;
    _buttonColor = const Color(0xFFFFD700);
    _buttonTextColor = Colors.black;
    _buttonPaddingHorizontal = 40.0;
    _buttonPaddingVertical = 15.0;
    _buttonSpacing = 30.0;
    _buttonPosition = WidgetPosition.bottomCenter;
    _buttonOffsetX = 0.0;
    _buttonOffsetY = 0.0;

    // Background settings
    _backgroundImagePath = null;
    _isBackgroundImageAsset = true;
    _showBackground = true;

    notifyListeners();
    _saveSettings();
  }
}