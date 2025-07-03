// lib/providers/face_capture_provider.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FaceCaptureProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  // --- Title settings ---
  String _titleText = 'Strike a Pose';
  double _titleFontSize = 70.0;
  FontWeight _titleFontWeight = FontWeight.w600;
  Color _titleColor = AppColors.yellow;
  double _titleTop = 0.25;
  double _titleLeft = 0.0;
  double _titleWidth = 1.0; // New
  bool _showTitle = true;
  double _titleLineHeight = 1.0;
  double _titleOpacity = 1.0;
  TextAlign _titleAlignment = TextAlign.center;
  bool _isTitleItalic = false; // New

  // --- Camera preview settings ---
  double _previewWidth = 0.63;
  double _previewHeight = 0.42;
  double _previewBorderRadius = 5.0;
  Color _previewBorderColor = AppColors.white;
  double _previewBorderWidth = 2.0;
  bool _showPreviewBorder = true;
  double _previewTop = 0.30;
  double _previewLeft = 0.18;

  // --- Button settings ---
  bool _useImageButton = true;
  // Common
  double _buttonWidth = 0.54;
  double _buttonHeight = 0.078;
  double _buttonTop = 0.75;
  double _buttonLeft = 0.22;
  // Image Button
  String? _buttonImagePath = 'assets/images/capture_btn.png';
  bool _isButtonImageAsset = true;
  double _buttonImageOpacity = 1.0; // New
  // Text Button
  String _buttonText = 'Capture'; // New
  Color _buttonBackgroundColor = AppColors.yellow; // New
  Color _buttonForegroundColor = AppColors.black; // New
  double _buttonFontSize = 24.0; // New
  FontWeight _buttonFontWeight = FontWeight.bold; // New
  double _buttonBorderRadius = 30.0; // New

  // --- Background settings ---
  bool _showBackground = false;
  String? _backgroundImagePath;
  bool _isBackgroundImageAsset = true;

  int _selectedCameraIndex = 0;

  // --- Getters ---
  // Title
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
  double get titleWidth => _titleWidth;
  bool get isTitleItalic => _isTitleItalic;
  // Preview
  double get previewWidth => _previewWidth;
  double get previewHeight => _previewHeight;
  double get previewBorderRadius => _previewBorderRadius;
  Color get previewBorderColor => _previewBorderColor;
  double get previewBorderWidth => _previewBorderWidth;
  bool get showPreviewBorder => _showPreviewBorder;
  double get previewTop => _previewTop;
  double get previewLeft => _previewLeft;
  // Button
  double get buttonWidth => _buttonWidth;
  double get buttonHeight => _buttonHeight;
  double get buttonTop => _buttonTop;
  double get buttonLeft => _buttonLeft;
  bool get useImageButton => _useImageButton;
  String? get buttonImagePath => _buttonImagePath;
  bool get isButtonImageAsset => _isButtonImageAsset;
  double get buttonImageOpacity => _buttonImageOpacity;
  String get buttonText => _buttonText;
  Color get buttonBackgroundColor => _buttonBackgroundColor;
  Color get buttonForegroundColor => _buttonForegroundColor;
  double get buttonFontSize => _buttonFontSize;
  FontWeight get buttonFontWeight => _buttonFontWeight;
  double get buttonBorderRadius => _buttonBorderRadius;
  // Other
  bool get showBackground => _showBackground;
  String? get backgroundImagePath => _backgroundImagePath;
  bool get isBackgroundImageAsset => _isBackgroundImageAsset;
  int get selectedCameraIndex => _selectedCameraIndex;

  // --- Setters ---
  void setTitleStyle({
    String? text, double? fontSize, FontWeight? fontWeight,
    Color? color, double? lineHeight, double? opacity,
    TextAlign? alignment, bool? isItalic,
  }) {
    if (text != null) _titleText = text;
    if (fontSize != null) _titleFontSize = fontSize;
    if (fontWeight != null) _titleFontWeight = fontWeight;
    if (color != null) _titleColor = color;
    if (lineHeight != null) _titleLineHeight = lineHeight;
    if (opacity != null) _titleOpacity = opacity;
    if (alignment != null) _titleAlignment = alignment;
    if (isItalic != null) _isTitleItalic = isItalic;
    _saveAndNotify();
  }

  void setTitlePosition({double? top, double? left, double? width}) {
    if (top != null) _titleTop = top;
    if (left != null) _titleLeft = left;
    if (width != null) _titleWidth = width;
    _saveAndNotify();
  }

  void setPreviewStyle({
    bool? showBorder, double? borderWidth,
    Color? borderColor, double? borderRadius
  }) {
    if (showBorder != null) _showPreviewBorder = showBorder;
    if (borderWidth != null) _previewBorderWidth = borderWidth;
    if (borderColor != null) _previewBorderColor = borderColor;
    if (borderRadius != null) _previewBorderRadius = borderRadius;
    _saveAndNotify();
  }

  void setButtonStyle({
    // Text Button
    String? text, Color? backgroundColor, Color? foregroundColor,
    double? fontSize, FontWeight? fontWeight, double? borderRadius,
    // Image Button
    double? imageOpacity,
  }) {
    if (text != null) _buttonText = text;
    if (backgroundColor != null) _buttonBackgroundColor = backgroundColor;
    if (foregroundColor != null) _buttonForegroundColor = foregroundColor;
    if (fontSize != null) _buttonFontSize = fontSize;
    if (fontWeight != null) _buttonFontWeight = fontWeight;
    if (borderRadius != null) _buttonBorderRadius = borderRadius;
    if (imageOpacity != null) _buttonImageOpacity = imageOpacity;
    _saveAndNotify();
  }

  void setPreviewPosition(double left, double top) { _previewLeft = left; _previewTop = top; _saveAndNotify(); }
  void setButtonPosition(double left, double top) { _buttonLeft = left; _buttonTop = top; _saveAndNotify(); }
  void setShowTitle(bool show) { _showTitle = show; _saveAndNotify(); }
  void setPreviewDimensions(double width, double height) { _previewWidth = width; _previewHeight = height; _saveAndNotify(); }
  void setButtonDimensions(double width, double height) { _buttonWidth = width; _buttonHeight = height; _saveAndNotify(); }
  void setUseImageButton(bool use) { _useImageButton = use; _saveAndNotify(); }
  void setShowBackground(bool show) { _showBackground = show; _saveAndNotify(); }
  void setSelectedCameraIndex(int index) { _selectedCameraIndex = index; _saveAndNotify(); }
  
  Future<void> setButtonImagePath(String? path, {bool isAsset = true}) async { await _setImage(path, isAsset, (p, a) { _buttonImagePath = p; _isButtonImageAsset = a; }); }
  Future<void> setBackgroundImagePath(String? path, {bool isAsset = true}) async { await _setImage(path, isAsset, (p, a) { _backgroundImagePath = p; _isBackgroundImageAsset = a; }); }

  Future<void> _setImage(String? sourcePath, bool isAsset, Function(String?, bool) updateState) async { if (sourcePath == null) { updateState(null, true); } else if (isAsset) { updateState(sourcePath, true); } else { try { final appDir = await getApplicationDocumentsDirectory(); final fileName = 'capture_${DateTime.now().millisecondsSinceEpoch}${path.extension(sourcePath)}'; final destinationPath = path.join(appDir.path, fileName); await File(sourcePath).copy(destinationPath); updateState(destinationPath, false); } on Exception catch (e) { debugPrint('Error copying image: $e'); return; } } _saveAndNotify(); }
  Future<void> init() async { if (_isInitialized) return; _prefs = await SharedPreferences.getInstance(); await _loadSettings(); _isInitialized = true; }
  void _saveAndNotify() { if (!_isInitialized) return; _saveSettings(); notifyListeners(); }

  Future<void> _loadSettings() async {
    final settingsJson = _prefs.getString('face_capture_settings');
    if (settingsJson != null) {
      final settings = jsonDecode(settingsJson) as Map<String, dynamic>;
      const double refWidth = 1080.0;
      const double refHeight = 1920.0;
      double toPercent(dynamic value, double defaultValue, double reference) { if (value == null) return defaultValue; double val = (value as num).toDouble(); return val > 1.0 ? val / reference : val; }

      // Title
      _titleText = settings['titleText'] ?? _titleText;
      _titleFontSize = settings['titleFontSize'] ?? _titleFontSize;
      _titleFontWeight = FontWeight.values[settings['titleFontWeight'] ?? _titleFontWeight.index];
      _titleColor = Color(settings['titleColor'] ?? _titleColor.value);
      _showTitle = settings['showTitle'] ?? _showTitle;
      _titleLineHeight = settings['titleLineHeight'] ?? _titleLineHeight;
      _titleOpacity = settings['titleOpacity'] ?? _titleOpacity;
      _titleAlignment = TextAlign.values[settings['titleAlignment'] ?? 2];
      _isTitleItalic = settings['isTitleItalic'] ?? _isTitleItalic;
      _titleTop = toPercent(settings['titleTop'], _titleTop, refHeight);
      _titleLeft = toPercent(settings['titleLeft'], _titleLeft, refWidth);
      _titleWidth = toPercent(settings['titleWidth'], _titleWidth, refWidth);

      // Preview
      _previewWidth = toPercent(settings['previewWidth'], _previewWidth, refWidth);
      _previewHeight = toPercent(settings['previewHeight'], _previewHeight, refHeight);
      _previewBorderRadius = settings['previewBorderRadius'] ?? _previewBorderRadius;
      _previewBorderColor = Color(settings['previewBorderColor'] ?? _previewBorderColor.value);
      _previewBorderWidth = settings['previewBorderWidth'] ?? _previewBorderWidth;
      _showPreviewBorder = settings['showPreviewBorder'] ?? _showPreviewBorder;
      _previewTop = toPercent(settings['previewTop'], _previewTop, refHeight);
      _previewLeft = toPercent(settings['previewLeft'], _previewLeft, refWidth);

      // Button
      _buttonWidth = toPercent(settings['buttonWidth'], _buttonWidth, refWidth);
      _buttonHeight = toPercent(settings['buttonHeight'], _buttonHeight, refHeight);
      _buttonTop = toPercent(settings['buttonTop'], _buttonTop, refHeight);
      _buttonLeft = toPercent(settings['buttonLeft'], _buttonLeft, refWidth);
      _useImageButton = settings['useImageButton'] ?? _useImageButton;
      _buttonImagePath = settings['buttonImagePath'];
      _isButtonImageAsset = settings['isButtonImageAsset'] ?? _isButtonImageAsset;
      _buttonImageOpacity = settings['buttonImageOpacity'] ?? _buttonImageOpacity;
      _buttonText = settings['buttonText'] ?? _buttonText;
      _buttonBackgroundColor = Color(settings['buttonBackgroundColor'] ?? _buttonBackgroundColor.value);
      _buttonForegroundColor = Color(settings['buttonForegroundColor'] ?? _buttonForegroundColor.value);
      _buttonFontSize = settings['buttonFontSize'] ?? _buttonFontSize;
      _buttonFontWeight = FontWeight.values[settings['buttonFontWeight'] ?? _buttonFontWeight.index];
      _buttonBorderRadius = settings['buttonBorderRadius'] ?? _buttonBorderRadius;

      // Other
      _showBackground = settings['showBackground'] ?? _showBackground;
      _backgroundImagePath = settings['backgroundImagePath'];
      _isBackgroundImageAsset = settings['isBackgroundImageAsset'] ?? _isBackgroundImageAsset;
      _selectedCameraIndex = settings['selectedCameraIndex'] ?? _selectedCameraIndex;
    }
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settings = {
      // Title
      'titleText': _titleText, 'titleFontSize': _titleFontSize, 'titleFontWeight': _titleFontWeight.index,
      'titleColor': _titleColor.value, 'titleTop': _titleTop, 'titleLeft': _titleLeft, 'titleWidth': _titleWidth,
      'showTitle': _showTitle, 'titleLineHeight': _titleLineHeight, 'titleOpacity': _titleOpacity, 
      'titleAlignment': _titleAlignment.index, 'isTitleItalic': _isTitleItalic,
      // Preview
      'previewWidth': _previewWidth, 'previewHeight': _previewHeight, 'previewBorderRadius': _previewBorderRadius,
      'previewBorderColor': _previewBorderColor.value, 'previewBorderWidth': _previewBorderWidth,
      'showPreviewBorder': _showPreviewBorder, 'previewTop': _previewTop, 'previewLeft': _previewLeft,
      // Button
      'buttonWidth': _buttonWidth, 'buttonHeight': _buttonHeight, 'buttonTop': _buttonTop, 'buttonLeft': _buttonLeft,
      'useImageButton': _useImageButton, 'buttonImagePath': _buttonImagePath, 'isButtonImageAsset': _isButtonImageAsset,
      'buttonImageOpacity': _buttonImageOpacity, 'buttonText': _buttonText, 'buttonBackgroundColor': _buttonBackgroundColor.value,
      'buttonForegroundColor': _buttonForegroundColor.value, 'buttonFontSize': _buttonFontSize, 'buttonFontWeight': _buttonFontWeight.index,
      'buttonBorderRadius': _buttonBorderRadius,
      // Other
      'showBackground': _showBackground, 'backgroundImagePath': _backgroundImagePath,
      'isBackgroundImageAsset': _isBackgroundImageAsset, 'selectedCameraIndex': _selectedCameraIndex,
    };
    await prefs.setString('face_capture_settings', jsonEncode(settings));
  }
}