import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum QrCodeLayout { below, above, leftOfQr, rightOfQr, sideBySide }

class OutputScreenProvider extends ChangeNotifier {
  late SharedPreferences _prefs;

  double _titleLeft = 279.0, _titleTop = 434.0, _titleWidth = 500.0;
  double _imageLeft = 90.0, _imageTop = 710.0;
  double _qrCodeLeft = 373.0, _qrCodeBottom = 310.0;
  double _buttonLeft = 360.0, _buttonBottom = 420.0;
  String _titleText = '';
  double _titleFontSize = 22.0;
  FontWeight _titleFontWeight = FontWeight.w500;
  Color _titleColor = AppColors.white;
  bool _showTitle = false;

  // AI Artistry Image settings
  double _imageWidth = 906.0, _imageHeight = 506.0;
  double _imageBorderRadius = 12.0;
  Color _imageBorderColor = Colors.transparent;
  double _imageBorderWidth = 0.0;

  // NEW: Swaplab Image settings
  double _swaplabImageWidth = 450.0;
  double _swaplabImageHeight = 675.0;

  String _buttonText = 'Start Over';
  double _buttonFontSize = 18.0;
  Color _buttonColor = AppColors.yellow, _buttonTextColor = AppColors.black;
  double _buttonPaddingHorizontal = 32.0, _buttonPaddingVertical = 18.0;
  double _buttonBorderRadius = 0.0;
  double _buttonWidth = 370.0, _buttonHeight = 200.0;

  bool _useImageButton = true;
  String? _buttonImagePath = 'assets/images/home_btn.png';
  bool _isButtonImageAsset = true;

  String _backgroundImagePath = 'assets/images/common_bg.png';
  bool _isBackgroundImageAsset = true;
  bool _showBackground = true;

  // Getters
  bool get useImageButton => _useImageButton;
  String? get buttonImagePath => _buttonImagePath;
  bool get isButtonImageAsset => _isButtonImageAsset;

  String get titleText => _titleText;
  double get titleFontSize => _titleFontSize;
  FontWeight get titleFontWeight => _titleFontWeight;
  Color get titleColor => _titleColor;
  bool get showTitle => _showTitle;

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

  // NEW: Getters for Swaplab dimensions
  double get swaplabImageWidth => _swaplabImageWidth;
  double get swaplabImageHeight => _swaplabImageHeight;

  String get buttonText => _buttonText;
  double get buttonFontSize => _buttonFontSize;
  double get buttonWidth => _buttonWidth;
  double get buttonHeight => _buttonHeight;
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

  // Setters
  void setUseImageButton(bool use) {
    _useImageButton = use;
    notifyListeners();
    _saveSettings();
  }

  // NEW: Setter for Swaplab image dimensions
  void setSwaplabImageDimensions(double width, double height) {
    _swaplabImageWidth = width;
    _swaplabImageHeight = height;
    notifyListeners();
    _saveSettings();
  }

  Future<void> setButtonImage(String? sourcePath,
      {required bool isAsset}) async {
    if (sourcePath == null) {
      _buttonImagePath = null;
      _isButtonImageAsset = true;
    } else if (isAsset) {
      _buttonImagePath = sourcePath;
      _isButtonImageAsset = true;
    } else {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName =
            'output_btn_${DateTime.now().millisecondsSinceEpoch}${path.extension(sourcePath)}';
        final destinationPath = path.join(appDir.path, fileName);
        await File(sourcePath).copy(destinationPath);
        _buttonImagePath = destinationPath;
        _isButtonImageAsset = false;
      } on Exception catch (e) {
        debugPrint('Error copying button image: $e');
        return;
      }
    }
    _saveSettings();
    notifyListeners();
  }

  Future<void> loadSettings() async {
    final settingsJson = _prefs.getString('output_screen_settings');
    if (settingsJson != null) {
      final Map<String, dynamic> settings = jsonDecode(settingsJson);

      _titleLeft = settings['titleLeft'] ?? _titleLeft;
      _titleTop = settings['titleTop'] ?? _titleTop;
      _titleWidth = settings['titleWidth'] ?? _titleWidth;
      _imageLeft = settings['imageLeft'] ?? _imageLeft;
      _imageTop = settings['imageTop'] ?? _imageTop;
      _qrCodeLeft = settings['qrCodeLeft'] ?? _qrCodeLeft;
      _qrCodeBottom = settings['qrCodeBottom'] ?? _qrCodeBottom;
      _buttonLeft = settings['buttonLeft'] ?? _buttonLeft;
      _buttonBottom = settings['buttonBottom'] ?? _buttonBottom;
      _titleText = settings['titleText'] ?? _titleText;
      _titleFontSize = settings['titleFontSize'] ?? _titleFontSize;
      _titleFontWeight = FontWeight
          .values[settings['titleFontWeight'] ?? _titleFontWeight.index];
      _titleColor = Color(settings['titleColor'] ?? _titleColor.value);
      _showTitle = settings['showTitle'] ?? _showTitle;
      _imageWidth = settings['imageWidth'] ?? _imageWidth;
      _imageHeight = settings['imageHeight'] ?? _imageHeight;

      _swaplabImageWidth = settings['swaplabImageWidth'] ?? _swaplabImageWidth;
      _swaplabImageHeight =
          settings['swaplabImageHeight'] ?? _swaplabImageHeight;

      _imageBorderRadius = settings['imageBorderRadius'] ?? _imageBorderRadius;
      _imageBorderColor =
          Color(settings['imageBorderColor'] ?? _imageBorderColor.value);
      _imageBorderWidth = settings['imageBorderWidth'] ?? _imageBorderWidth;
      _useImageButton = settings['useImageButton'] ?? _useImageButton;
      _buttonImagePath = settings['buttonImagePath'] ?? _buttonImagePath;
      _isButtonImageAsset =
          settings['isButtonImageAsset'] ?? _isButtonImageAsset;
      _buttonWidth = settings['buttonWidth'] ?? _buttonWidth;
      _buttonHeight = settings['buttonHeight'] ?? _buttonHeight;
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
      _backgroundImagePath =
          settings['backgroundImagePath'] ?? 'assets/images/common_bg.png';
      _isBackgroundImageAsset =
          settings['isBackgroundImageAsset'] ?? _isBackgroundImageAsset;
      _showBackground = settings['showBackground'] ?? _showBackground;
    }

    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final settings = {
      'titleText': _titleText,
      'titleFontSize': _titleFontSize,
      'titleFontWeight': _titleFontWeight.index,
      'titleColor': _titleColor.value,
      'showTitle': _showTitle,
      'titleLeft': _titleLeft,
      'titleTop': _titleTop,
      'titleWidth': _titleWidth,
      'imageLeft': _imageLeft,
      'imageTop': _imageTop,
      'qrCodeLeft': _qrCodeLeft,
      'qrCodeBottom': _qrCodeBottom,
      'buttonLeft': _buttonLeft,
      'buttonBottom': _buttonBottom,
      'imageWidth': _imageWidth,
      'imageHeight': _imageHeight,
      'swaplabImageWidth': _swaplabImageWidth,
      'swaplabImageHeight': _swaplabImageHeight,
      'imageBorderRadius': _imageBorderRadius,
      'imageBorderColor': _imageBorderColor.value,
      'imageBorderWidth': _imageBorderWidth,
      'useImageButton': _useImageButton,
      'buttonImagePath': _buttonImagePath,
      'isButtonImageAsset': _isButtonImageAsset,
      'buttonWidth': _buttonWidth,
      'buttonHeight': _buttonHeight,
      'buttonText': _buttonText,
      'buttonFontSize': _buttonFontSize,
      'buttonColor': _buttonColor.value,
      'buttonTextColor': _buttonTextColor.value,
      'buttonPaddingHorizontal': _buttonPaddingHorizontal,
      'buttonPaddingVertical': _buttonPaddingVertical,
      'buttonBorderRadius': _buttonBorderRadius,
      'backgroundImagePath': _backgroundImagePath,
      'isBackgroundImageAsset': _isBackgroundImageAsset,
      'showBackground': _showBackground,
    };

    await _prefs.setString('output_screen_settings', jsonEncode(settings));
  }

  void setTitlePosition(double left, double top, double width) {
    _titleLeft = left;
    _titleTop = top;
    _titleWidth = width;
    notifyListeners();
    _saveSettings();
  }

  void setImagePosition(double left, double top) {
    _imageLeft = left;
    _imageTop = top;
    notifyListeners();
    _saveSettings();
  }

  void setQrCodePosition(double left, double bottom) {
    _qrCodeLeft = left;
    _qrCodeBottom = bottom;
    notifyListeners();
    _saveSettings();
  }

  void setButtonPosition(double left, double bottom) {
    _buttonLeft = left;
    _buttonBottom = bottom;
    notifyListeners();
    _saveSettings();
  }

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

    notifyListeners();
    _saveSettings();
  }

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

  void setButtonText(String text) {
    _buttonText = text;
    notifyListeners();
    _saveSettings();
  }

  void setButtonStyle({
    double? width,
    double? height,
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
    if (width != null) _buttonWidth = width;
    if (height != null) _buttonHeight = height;
    if (paddingHorizontal != null) _buttonPaddingHorizontal = paddingHorizontal;
    if (paddingVertical != null) _buttonPaddingVertical = paddingVertical;
    if (borderRadius != null) _buttonBorderRadius = borderRadius;
    notifyListeners();
    _saveSettings();
  }

  void setBackgroundImage(String? path, {required bool isAsset}) {
    if (path == null) {
      _backgroundImagePath = 'assets/images/common_bg.png';
      _isBackgroundImageAsset = true;
    } else {
      _backgroundImagePath = path;
      _isBackgroundImageAsset = isAsset;
    }
    notifyListeners();
    _saveSettings();
  }

  void setShowBackground(bool show) {
    _showBackground = show;
    notifyListeners();
    _saveSettings();
  }
}