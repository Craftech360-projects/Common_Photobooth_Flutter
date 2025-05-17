import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FaceCaptureProvider extends ChangeNotifier {
  // Title settings
  String _titleText = 'Smile Please... 😃';
  double _titleFontSize = 22.0;
  FontWeight _titleFontWeight = FontWeight.w500;
  Color _titleColor = AppColors.white;
  double _titleTop = 460.0;
  double _titleLeft = 0.0;
  double _titleRight = 0.0;
  bool _showTitle = true;
  double _titleLineHeight = 1.0;
  double _titleOpacity = 1.0;
  TextAlign _titleAlignment = TextAlign.center;

  // Camera preview settings
  double _previewWidth = 850.0;
  double _previewHeight = 850.0;
  double _previewBorderRadius = 5.0;
  Color _previewBorderColor = AppColors.orange;
  double _previewBorderWidth = 2.0;
  bool _showPreviewBorder = true;
  double _previewTop = 533.0;
  double _previewLeft = 116.0; // Centered by default (1080 - 375) / 2

  // Windows camera settings
  String _pictureFormat = 'jpeg'; // Windows camera typically uses jpeg
  final String _pictureQuality = 'high'; // high, medium, low

  // Button settings
  String _buttonText = 'Capture';
  double _buttonFontSize = 18.0;
  FontWeight _buttonFontWeight = FontWeight.w500;
  Color _buttonColor = AppColors.white;
  Color _buttonTextColor = AppColors.black;
  double _buttonWidth = 200.0;
  double _buttonHeight = 45.0;
  double _buttonBorderRadius = 5.0;
  double _buttonTop = 1430.0;
  double _buttonLeft = 440.0; // Centered by default (1080 - 200) / 2
  EdgeInsets _buttonPadding = const EdgeInsets.all(8.0);
  bool _buttonHasBorder = false;
  Color _buttonBorderColor = AppColors.orange;
  double _buttonBorderWidth = 2.0;

  // Image button settings
  bool _useImageButton = false;
  String? _buttonImagePath;
  bool _isButtonImageAsset = true;

  // Background settings
  bool _showBackground = false;
  String? _backgroundImagePath;
  bool _isBackgroundImageAsset = true;

  // Camera settings
  int _selectedCameraIndex = 0;

  // Getters
  String get titleText => _titleText;
  double get titleFontSize => _titleFontSize;
  FontWeight get titleFontWeight => _titleFontWeight;
  Color get titleColor => _titleColor;
  bool get showTitle => _showTitle;
  double get titleLineHeight => _titleLineHeight;
  double get titleOpacity => _titleOpacity;
  TextAlign get titleAlignment => _titleAlignment;
  double get titleTop => _titleTop;
  double get titleLeft => _titleLeft;
  double get titleRight => _titleRight;
  EdgeInsets get buttonPadding => _buttonPadding;

  double get previewWidth => _previewWidth;
  double get previewHeight => _previewHeight;
  double get previewBorderRadius => _previewBorderRadius;
  Color get previewBorderColor => _previewBorderColor;
  double get previewBorderWidth => _previewBorderWidth;
  bool get showPreviewBorder => _showPreviewBorder;
  double get previewTop => _previewTop;
  double get previewLeft => _previewLeft;

  String get buttonText => _buttonText;
  double get buttonFontSize => _buttonFontSize;
  FontWeight get buttonFontWeight => _buttonFontWeight;
  Color get buttonColor => _buttonColor;
  Color get buttonTextColor => _buttonTextColor;
  double get buttonWidth => _buttonWidth;
  double get buttonHeight => _buttonHeight;
  double get buttonBorderRadius => _buttonBorderRadius;
  bool get buttonHasBorder => _buttonHasBorder;
  Color get buttonBorderColor => _buttonBorderColor;
  double get buttonBorderWidth => _buttonBorderWidth;
  double get buttonTop => _buttonTop;
  double get buttonLeft => _buttonLeft;

  bool get useImageButton => _useImageButton;
  String? get buttonImagePath => _buttonImagePath;
  bool get isButtonImageAsset => _isButtonImageAsset;

  bool get showBackground => _showBackground;
  String? get backgroundImagePath => _backgroundImagePath;
  bool get isBackgroundImageAsset => _isBackgroundImageAsset;

  // Update getters
  String get pictureFormat => _pictureFormat;
  String get pictureQuality => _pictureQuality;
  int get selectedCameraIndex => _selectedCameraIndex;

  // Setters
  void setTitleText(String text) {
    _titleText = text;
    notifyListeners();
    _saveSettings();
  }

  void setTitleFontSize(double size) {
    _titleFontSize = size;
    notifyListeners();
    _saveSettings();
  }

  void setTitleFontWeight(FontWeight weight) {
    _titleFontWeight = weight;
    notifyListeners();
    _saveSettings();
  }

  void setPictureFormat(String format) {
    _pictureFormat = format;
    notifyListeners();
    _saveSettings();
  }

  void setTitleColor(Color color) {
    _titleColor = color;
    notifyListeners();
    _saveSettings();
  }

  void setTitleLineHeight(double height) {
    _titleLineHeight = height;
    notifyListeners();
    _saveSettings();
  }

  void setTitleOpacity(double opacity) {
    _titleOpacity = opacity;
    notifyListeners();
    _saveSettings();
  }

  void setTitleAlignment(TextAlign alignment) {
    _titleAlignment = alignment;
    notifyListeners();
    _saveSettings();
  }

  void setTitleTop(double top) {
    _titleTop = top;
    notifyListeners();
    _saveSettings();
  }

  void setTitleLeft(double left) {
    _titleLeft = left;
    notifyListeners();
    _saveSettings();
  }

  void setTitleRight(double right) {
    _titleRight = right;
    notifyListeners();
    _saveSettings();
  }

  void setPreviewTop(double top) {
    _previewTop = top;
    notifyListeners();
    _saveSettings();
  }

  void setPreviewLeft(double left) {
    _previewLeft = left;
    notifyListeners();
    _saveSettings();
  }

  void setButtonTop(double top) {
    _buttonTop = top;
    notifyListeners();
    _saveSettings();
  }

  void setButtonLeft(double left) {
    _buttonLeft = left;
    notifyListeners();
    _saveSettings();
  }

  void setButtonPadding(EdgeInsets padding) {
    _buttonPadding = padding;
    notifyListeners();
    _saveSettings();
  }

  void setShowTitle(bool show) {
    _showTitle = show;
    notifyListeners();
    _saveSettings();
  }

  void setPreviewWidth(double width) {
    _previewWidth = width;
    notifyListeners();
    _saveSettings();
  }

  void setPreviewHeight(double height) {
    _previewHeight = height;
    notifyListeners();
    _saveSettings();
  }

  void setPreviewBorderRadius(double radius) {
    _previewBorderRadius = radius;
    notifyListeners();
    _saveSettings();
  }

  void setPreviewBorderColor(Color color) {
    _previewBorderColor = color;
    notifyListeners();
    _saveSettings();
  }

  void setPreviewBorderWidth(double width) {
    _previewBorderWidth = width;
    notifyListeners();
    _saveSettings();
  }

  void setShowPreviewBorder(bool show) {
    _showPreviewBorder = show;
    notifyListeners();
    _saveSettings();
  }

  void setButtonText(String text) {
    _buttonText = text;
    notifyListeners();
    _saveSettings();
  }

  void setButtonFontSize(double size) {
    _buttonFontSize = size;
    notifyListeners();
    _saveSettings();
  }

  void setButtonFontWeight(FontWeight weight) {
    _buttonFontWeight = weight;
    notifyListeners();
    _saveSettings();
  }

  void setButtonColor(Color color) {
    _buttonColor = color;
    notifyListeners();
    _saveSettings();
  }

  void setButtonTextColor(Color color) {
    _buttonTextColor = color;
    notifyListeners();
    _saveSettings();
  }

  void setButtonWidth(double width) {
    _buttonWidth = width;
    notifyListeners();
    _saveSettings();
  }

  void setButtonHeight(double height) {
    _buttonHeight = height;
    notifyListeners();
    _saveSettings();
  }

  void setButtonBorderRadius(double radius) {
    _buttonBorderRadius = radius;
    notifyListeners();
    _saveSettings();
  }

  void setButtonHasBorder(bool hasBorder) {
    _buttonHasBorder = hasBorder;
    notifyListeners();
    _saveSettings();
  }

  void setButtonBorderColor(Color color) {
    _buttonBorderColor = color;
    notifyListeners();
    _saveSettings();
  }

  void setButtonBorderWidth(double width) {
    _buttonBorderWidth = width;
    notifyListeners();
    _saveSettings();
  }

  void setUseImageButton(bool use) {
    _useImageButton = use;
    notifyListeners();
    _saveSettings();
  }

  void setButtonImagePath(String? path, {bool isAsset = true}) {
    _buttonImagePath = path;
    _isButtonImageAsset = isAsset;
    notifyListeners();
    _saveSettings();
  }

  void setShowBackground(bool show) {
    _showBackground = show;
    notifyListeners();
    _saveSettings();
  }

  void setBackgroundImagePath(String? path, {bool isAsset = true}) {
    _backgroundImagePath = path;
    _isBackgroundImageAsset = isAsset;
    notifyListeners();
    _saveSettings();
  }

  void setSelectedCameraIndex(int index) {
    _selectedCameraIndex = index;
    notifyListeners();
    _saveSettings();
  }

  // Initialize from SharedPreferences
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('face_capture_settings');

    if (settingsJson != null) {
      final settings = jsonDecode(settingsJson) as Map<String, dynamic>;

      // Title settings
      _titleText = settings['titleText'] ?? _titleText;
      _titleFontSize = settings['titleFontSize'] ?? _titleFontSize;
      _titleFontWeight = FontWeight
          .values[settings['titleFontWeight'] ?? _titleFontWeight.index];
      _titleColor = Color(settings['titleColor'] ?? _titleColor.value);

      _titleTop = settings['titleTop'] ?? _titleTop;
      _titleLeft = settings['titleLeft'] ?? _titleLeft;
      _titleRight = settings['titleRight'] ?? _titleRight;

      _showTitle = settings['showTitle'] ?? _showTitle;
      _titleLineHeight = settings['titleLineHeight'] ?? _titleLineHeight;
      _titleOpacity = settings['titleOpacity'] ?? _titleOpacity;
      _titleAlignment = TextAlign.values[settings['titleAlignment'] ?? 2];

      // Camera preview settings
      _previewWidth = settings['previewWidth'] ?? _previewWidth;
      _previewHeight = settings['previewHeight'] ?? _previewHeight;
      _previewBorderRadius =
          settings['previewBorderRadius'] ?? _previewBorderRadius;
      _previewBorderColor =
          Color(settings['previewBorderColor'] ?? _previewBorderColor.value);
      _previewBorderWidth =
          settings['previewBorderWidth'] ?? _previewBorderWidth;
      _showPreviewBorder = settings['showPreviewBorder'] ?? _showPreviewBorder;
      _previewTop = settings['previewTop'] ?? _previewTop;
      _previewLeft = settings['previewLeft'] ?? _previewLeft;

      // Button settings
      _buttonText = settings['buttonText'] ?? _buttonText;
      _buttonFontSize = settings['buttonFontSize'] ?? _buttonFontSize;
      _buttonFontWeight = FontWeight
          .values[settings['buttonFontWeight'] ?? _buttonFontWeight.index];
      _buttonColor = Color(settings['buttonColor'] ?? _buttonColor.value);
      _buttonTextColor =
          Color(settings['buttonTextColor'] ?? _buttonTextColor.value);
      _buttonWidth = settings['buttonWidth'] ?? _buttonWidth;
      _buttonHeight = settings['buttonHeight'] ?? _buttonHeight;
      _buttonBorderRadius =
          settings['buttonBorderRadius'] ?? _buttonBorderRadius;
      _buttonTop = settings['buttonTop'] ?? _buttonTop;
      _buttonLeft = settings['buttonLeft'] ?? _buttonLeft;

      // Fix the button padding initialization
      if (settings['buttonPadding'] is Map) {
        final paddingMap = settings['buttonPadding'] as Map<String, dynamic>;
        _buttonPadding = EdgeInsets.fromLTRB(
          (paddingMap['left'] as num?)?.toDouble() ?? 16.0,
          (paddingMap['top'] as num?)?.toDouble() ?? 8.0,
          (paddingMap['right'] as num?)?.toDouble() ?? 16.0,
          (paddingMap['bottom'] as num?)?.toDouble() ?? 8.0,
        );
      }
      _buttonHasBorder = settings['buttonHasBorder'] ?? _buttonHasBorder;
      _buttonBorderColor =
          Color(settings['buttonBorderColor'] ?? _buttonBorderColor.value);
      _buttonBorderWidth = settings['buttonBorderWidth'] ?? _buttonBorderWidth;

      // Image button settings
      _useImageButton = settings['useImageButton'] ?? _useImageButton;
      _buttonImagePath = settings['buttonImagePath'];
      _isButtonImageAsset =
          settings['isButtonImageAsset'] ?? _isButtonImageAsset;

      // Background settings
      _showBackground = settings['showBackground'] ?? _showBackground;
      _backgroundImagePath = settings['backgroundImagePath'];
      _isBackgroundImageAsset =
          settings['isBackgroundImageAsset'] ?? _isBackgroundImageAsset;

      // Camera settings
      _selectedCameraIndex =
          settings['selectedCameraIndex'] ?? _selectedCameraIndex;
    }

    notifyListeners();
  }

  // Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final settings = {
      // Title settings
      'titleText': _titleText,
      'titleFontSize': _titleFontSize,
      'titleFontWeight': _titleFontWeight.index,
      'titleColor': _titleColor.value,
      'titleTop': _titleTop,
      'titleLeft': _titleLeft,
      'titleRight': _titleRight,
      'showTitle': _showTitle,
      'titleLineHeight': _titleLineHeight,
      'titleOpacity': _titleOpacity,
      'titleAlignment': _titleAlignment.index,

      // Camera preview settings
      'previewWidth': _previewWidth,
      'previewHeight': _previewHeight,
      'previewBorderRadius': _previewBorderRadius,
      'previewBorderColor': _previewBorderColor.value,
      'previewBorderWidth': _previewBorderWidth,
      'showPreviewBorder': _showPreviewBorder,
      'previewTop': _previewTop,
      'previewLeft': _previewLeft,

      // Button settings
      'buttonText': _buttonText,
      'buttonFontSize': _buttonFontSize,
      'buttonFontWeight': _buttonFontWeight.index,
      'buttonColor': _buttonColor.value,
      'buttonTextColor': _buttonTextColor.value,
      'buttonWidth': _buttonWidth,
      'buttonHeight': _buttonHeight,
      'buttonBorderRadius': _buttonBorderRadius,
      'buttonPadding': {
        'left': _buttonPadding.left,
        'top': _buttonPadding.top,
        'right': _buttonPadding.right,
        'bottom': _buttonPadding.bottom,
      },
      'buttonTop': _buttonTop,
      'buttonLeft': _buttonLeft,
      'buttonHasBorder': _buttonHasBorder,
      'buttonBorderColor': _buttonBorderColor.value,
      'buttonBorderWidth': _buttonBorderWidth,

      // Image button settings
      'useImageButton': _useImageButton,
      'buttonImagePath': _buttonImagePath,
      'isButtonImageAsset': _isButtonImageAsset,

      // Background settings
      'showBackground': _showBackground,
      'backgroundImagePath': _backgroundImagePath,
      'isBackgroundImageAsset': _isBackgroundImageAsset,

      // Camera settings
      'selectedCameraIndex': _selectedCameraIndex,
    };

    await prefs.setString('face_capture_settings', jsonEncode(settings));
  }
}
