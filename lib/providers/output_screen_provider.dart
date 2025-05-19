import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum QrCodeLayout {
  below,
  above,
  leftOfQr,
  rightOfQr,
  sideBySide,
}

class OutputScreenProvider extends ChangeNotifier {
  late SharedPreferences _prefs;

  double _titleLeft = 279.0;
  double _titleTop = 434.0;
  double _titleWidth = 500.0;

  double _imageLeft = 119.0;
  double _imageTop = 540.0;

  double _qrCodeLeft = 408.0;
  double _qrCodeBottom = 380.0;

  double _buttonLeft = 458.0;
  double _buttonBottom = 310.0;

  // Title settings
  String _titleText = 'Your Image has been created';
  double _titleFontSize = 32.0;
  FontWeight _titleFontWeight = FontWeight.bold;
  Color _titleColor = AppColors.white;
  double _titlePadding = 20.0;
  bool _showTitle = true;

  // Image settings
  double _imageWidth = 400.0;
  double _imageHeight = 500.0;
  double _imageBorderRadius = 20.0;
  Color _imageBorderColor = AppColors.yellow;
  double _imageBorderWidth = 3.0;
  double _imageSpacing = 30.0;

  // QR code settings
  double _qrCodeSize = 150.0;
  Color _qrCodeBackgroundColor = AppColors.white;
  Color _qrCodeForegroundColor = AppColors.black;
  String _qrCodeText = 'Scan QR code to download your image';
  double _qrCodeTextFontSize = 18.0;
  Color _qrCodeTextColor = AppColors.white;
  QrCodeLayout _qrCodeLayout = QrCodeLayout.below;
  double _qrCodeSpacing = 20.0;

  // Button settings
  String _buttonText = 'Start Over';
  double _buttonFontSize = 18.0;
  Color _buttonColor = AppColors.yellow;
  Color _buttonTextColor = AppColors.black;
  double _buttonPaddingHorizontal = 32.0;
  double _buttonPaddingVertical = 18.0;
  double _buttonBorderRadius = 4.0;

  // Background settings
  String? _backgroundImagePath;
  bool _isBackgroundImageAsset = true;
  bool _showBackground = false;

  // Getters for other properties
  String get titleText => _titleText;
  double get titleFontSize => _titleFontSize;
  FontWeight get titleFontWeight => _titleFontWeight;
  Color get titleColor => _titleColor;
  double get titlePadding => _titlePadding;
  bool get showTitle => _showTitle;

  // Getters for position properties
  double get titleLeft => _titleLeft;
  double get titleTop => _titleTop;
  double get titleWidth => _titleWidth;

  double get imageLeft => _imageLeft;
  double get imageTop => _imageTop;

  double get qrCodeLeft => _qrCodeLeft;
  double get qrCodeBottom => _qrCodeBottom;

  double get buttonLeft => _buttonLeft;
  double get buttonBottom => _buttonBottom;

  double get imageWidth => _imageWidth;
  double get imageHeight => _imageHeight;
  double get imageBorderRadius => _imageBorderRadius;
  Color get imageBorderColor => _imageBorderColor;
  double get imageBorderWidth => _imageBorderWidth;
  double get imageSpacing => _imageSpacing;

  double get qrCodeSize => _qrCodeSize;
  Color get qrCodeBackgroundColor => _qrCodeBackgroundColor;
  Color get qrCodeForegroundColor => _qrCodeForegroundColor;
  String get qrCodeText => _qrCodeText;
  double get qrCodeTextFontSize => _qrCodeTextFontSize;
  Color get qrCodeTextColor => _qrCodeTextColor;
  QrCodeLayout get qrCodeLayout => _qrCodeLayout;
  double get qrCodeSpacing => _qrCodeSpacing;

  String get buttonText => _buttonText;
  double get buttonFontSize => _buttonFontSize;
  Color get buttonColor => _buttonColor;
  Color get buttonTextColor => _buttonTextColor;
  double get buttonPaddingHorizontal => _buttonPaddingHorizontal;
  double get buttonPaddingVertical => _buttonPaddingVertical;
  double get buttonBorderRadius => _buttonBorderRadius;

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

      // Load position properties
      _titleLeft = _prefs.getDouble('output_title_left') ?? _titleLeft;
      _titleTop = _prefs.getDouble('output_title_top') ?? _titleTop;
      _titleWidth = _prefs.getDouble('output_title_width') ?? _titleWidth;

      _imageLeft = _prefs.getDouble('output_image_left') ?? _imageLeft;
      _imageTop = _prefs.getDouble('output_image_top') ?? _imageTop;

      _qrCodeLeft = _prefs.getDouble('output_qrcode_left') ?? _qrCodeLeft;
      _qrCodeBottom = _prefs.getDouble('output_qrcode_bottom') ?? _qrCodeBottom;

      _buttonLeft = _prefs.getDouble('output_button_left') ?? _buttonLeft;
      _buttonBottom = _prefs.getDouble('output_button_bottom') ?? _buttonBottom;

      // Title settings
      _titleText = settings['titleText'] ?? _titleText;
      _titleFontSize = settings['titleFontSize'] ?? _titleFontSize;
      _titleFontWeight = FontWeight
          .values[settings['titleFontWeight'] ?? _titleFontWeight.index];
      _titleColor = Color(settings['titleColor'] ?? _titleColor.value);
      _titlePadding = settings['titlePadding'] ?? _titlePadding;
      _showTitle = settings['showTitle'] ?? _showTitle;

      // Image settings
      _imageWidth = settings['imageWidth'] ?? _imageWidth;
      _imageHeight = settings['imageHeight'] ?? _imageHeight;
      _imageBorderRadius = settings['imageBorderRadius'] ?? _imageBorderRadius;
      _imageBorderColor =
          Color(settings['imageBorderColor'] ?? _imageBorderColor.value);
      _imageBorderWidth = settings['imageBorderWidth'] ?? _imageBorderWidth;
      _imageSpacing = settings['imageSpacing'] ?? _imageSpacing;

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
      _buttonBorderRadius =
          settings['buttonBorderRadius'] ?? _buttonBorderRadius;

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
      // Title settings
      'titleText': _titleText,
      'titleFontSize': _titleFontSize,
      'titleFontWeight': _titleFontWeight.index,
      'titleColor': _titleColor.value,
      'titlePadding': _titlePadding,
      'showTitle': _showTitle,

      // Image settings
      'imageWidth': _imageWidth,
      'imageHeight': _imageHeight,
      'imageBorderRadius': _imageBorderRadius,
      'imageBorderColor': _imageBorderColor.value,
      'imageBorderWidth': _imageBorderWidth,
      'imageSpacing': _imageSpacing,

      // QR code settings
      'qrCodeSize': _qrCodeSize,
      'qrCodeBackgroundColor': _qrCodeBackgroundColor.value,
      'qrCodeForegroundColor': _qrCodeForegroundColor.value,
      'qrCodeText': _qrCodeText,
      'qrCodeTextFontSize': _qrCodeTextFontSize,
      'qrCodeTextColor': _qrCodeTextColor.value,
      'qrCodeLayout': _qrCodeLayout.index,
      'qrCodeSpacing': _qrCodeSpacing,

      // Button settings
      'buttonText': _buttonText,
      'buttonFontSize': _buttonFontSize,
      'buttonColor': _buttonColor.value,
      'buttonTextColor': _buttonTextColor.value,
      'buttonPaddingHorizontal': _buttonPaddingHorizontal,
      'buttonPaddingVertical': _buttonPaddingVertical,
      'buttonBorderRadius': _buttonBorderRadius,

      // Background settings
      'backgroundImagePath': _backgroundImagePath,
      'isBackgroundImageAsset': _isBackgroundImageAsset,
      'showBackground': _showBackground,
    };

    await _prefs.setString('output_screen_settings', jsonEncode(settings));
    // Save position properties
    await _prefs.setDouble('output_title_left', _titleLeft);
    await _prefs.setDouble('output_title_top', _titleTop);
    await _prefs.setDouble('output_title_width', _titleWidth);

    await _prefs.setDouble('output_image_left', _imageLeft);
    await _prefs.setDouble('output_image_top', _imageTop);

    await _prefs.setDouble('output_qrcode_left', _qrCodeLeft);
    await _prefs.setDouble('output_qrcode_bottom', _qrCodeBottom);

    await _prefs.setDouble('output_button_left', _buttonLeft);
    await _prefs.setDouble('output_button_bottom', _buttonBottom);
  }

  void setTitlePosition(double left, double top, double width) async {
    _titleLeft = left;
    _titleTop = top;
    _titleWidth = width;
    await _prefs.setDouble('output_title_left', left);
    await _prefs.setDouble('output_title_top', top);
    await _prefs.setDouble('output_title_width', width);
    notifyListeners();
  }

  void setImagePosition(double left, double top) async {
    _imageLeft = left;
    _imageTop = top;
    await _prefs.setDouble('output_image_left', left);
    await _prefs.setDouble('output_image_top', top);
    notifyListeners();
  }

  void setQrCodePosition(double left, double bottom) async {
    _qrCodeLeft = left;
    _qrCodeBottom = bottom;
    await _prefs.setDouble('output_qrcode_left', left);
    await _prefs.setDouble('output_qrcode_bottom', bottom);
    notifyListeners();
  }

  void setButtonPosition(double left, double bottom) async {
    _buttonLeft = left;
    _buttonBottom = bottom;
    await _prefs.setDouble('output_button_left', left);
    await _prefs.setDouble('output_button_bottom', bottom);
    notifyListeners();
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
    double? borderRadius,
  }) {
    if (fontSize != null) _buttonFontSize = fontSize;
    if (color != null) _buttonColor = color;
    if (textColor != null) _buttonTextColor = textColor;
    if (paddingHorizontal != null) _buttonPaddingHorizontal = paddingHorizontal;
    if (paddingVertical != null) _buttonPaddingVertical = paddingVertical;
    if (borderRadius != null) _buttonBorderRadius = borderRadius;
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
}
