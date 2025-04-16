import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FaceCaptureProvider extends ChangeNotifier {
  // Title settings
  String _titleText = 'Capture Your Face';
  double _titleFontSize = 32.0;
  FontWeight _titleFontWeight = FontWeight.bold;
  Color _titleColor = Colors.white;
  double _titlePadding = 20.0;
  bool _showTitle = true;

  // Camera preview settings
  double _previewWidth = 350.0;
  double _previewHeight = 500.0;
  double _previewBorderRadius = 26.0;
  Color _previewBorderColor = Colors.amber;
  double _previewBorderWidth = 5.0;
  bool _showPreviewBorder = true;
  // Replace macOS-specific settings with Windows-specific settings
  // String _pictureFormat = 'jpeg'; // or 'tiff', 'heic'
  // String _pictureResolution = 'max'; // or 'medium', 'low'

  // Windows camera settings
  String _pictureFormat = 'jpeg'; // Windows camera typically uses jpeg
  final String _pictureQuality = 'high'; // high, medium, low

  // Button settings
  String _buttonText = 'CAPTURE';
  double _buttonFontSize = 30.0;
  Color _buttonColor = Colors.white;
  Color _buttonTextColor = Colors.black;
  double _buttonWidth = 200.0;
  double _buttonHeight = 60.0;
  double _buttonBorderRadius = 40.0;
  double _buttonMarginTop = 40.0;
  bool _buttonHasBorder = false;
  Color _buttonBorderColor = Colors.amber;
  double _buttonBorderWidth = 2.0;

  // Image button settings
  bool _useImageButton = false;
  String? _buttonImagePath;
  bool _isButtonImageAsset = true;

  // Background settings
  bool _showBackground = true;
  String? _backgroundImagePath;
  bool _isBackgroundImageAsset = true;

  // Camera settings
  int _selectedCameraIndex = 0;

  // Getters
  String get titleText => _titleText;
  double get titleFontSize => _titleFontSize;
  FontWeight get titleFontWeight => _titleFontWeight;
  Color get titleColor => _titleColor;
  double get titlePadding => _titlePadding;
  bool get showTitle => _showTitle;

  double get previewWidth => _previewWidth;
  double get previewHeight => _previewHeight;
  double get previewBorderRadius => _previewBorderRadius;
  Color get previewBorderColor => _previewBorderColor;
  double get previewBorderWidth => _previewBorderWidth;
  bool get showPreviewBorder => _showPreviewBorder;

  String get buttonText => _buttonText;
  double get buttonFontSize => _buttonFontSize;
  Color get buttonColor => _buttonColor;
  Color get buttonTextColor => _buttonTextColor;
  double get buttonWidth => _buttonWidth;
  double get buttonHeight => _buttonHeight;
  double get buttonBorderRadius => _buttonBorderRadius;
  double get buttonMarginTop => _buttonMarginTop;
  bool get buttonHasBorder => _buttonHasBorder;
  Color get buttonBorderColor => _buttonBorderColor;
  double get buttonBorderWidth => _buttonBorderWidth;

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

  void setTitlePadding(double padding) {
    _titlePadding = padding;
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

  void setButtonMarginTop(double margin) {
    _buttonMarginTop = margin;
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
      _titlePadding = settings['titlePadding'] ?? _titlePadding;
      _showTitle = settings['showTitle'] ?? _showTitle;

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

      // Button settings
      _buttonText = settings['buttonText'] ?? _buttonText;
      _buttonFontSize = settings['buttonFontSize'] ?? _buttonFontSize;
      _buttonColor = Color(settings['buttonColor'] ?? _buttonColor.value);
      _buttonTextColor =
          Color(settings['buttonTextColor'] ?? _buttonTextColor.value);
      _buttonWidth = settings['buttonWidth'] ?? _buttonWidth;
      _buttonHeight = settings['buttonHeight'] ?? _buttonHeight;
      _buttonBorderRadius =
          settings['buttonBorderRadius'] ?? _buttonBorderRadius;
      _buttonMarginTop = settings['buttonMarginTop'] ?? _buttonMarginTop;
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
      'titlePadding': _titlePadding,
      'showTitle': _showTitle,

      // Camera preview settings
      'previewWidth': _previewWidth,
      'previewHeight': _previewHeight,
      'previewBorderRadius': _previewBorderRadius,
      'previewBorderColor': _previewBorderColor.value,
      'previewBorderWidth': _previewBorderWidth,
      'showPreviewBorder': _showPreviewBorder,

      // Button settings
      'buttonText': _buttonText,
      'buttonFontSize': _buttonFontSize,
      'buttonColor': _buttonColor.value,
      'buttonTextColor': _buttonTextColor.value,
      'buttonWidth': _buttonWidth,
      'buttonHeight': _buttonHeight,
      'buttonBorderRadius': _buttonBorderRadius,
      'buttonMarginTop': _buttonMarginTop,
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
