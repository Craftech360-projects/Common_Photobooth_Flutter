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

  // --- All layout values are now percentages (0.0 to 1.0) ---
  // Title settings
  String _titleText = 'Strike a Pose';
  double _titleFontSize = 70.0;
  FontWeight _titleFontWeight = FontWeight.w600;
  Color _titleColor = AppColors.yellow;
  double _titleTop = 0.25; // 488px / 1920px
  double _titleLeft = 0.0;
  bool _showTitle = true;
  double _titleLineHeight = 1.0;
  double _titleOpacity = 1.0;
  TextAlign _titleAlignment = TextAlign.center;

  // Camera preview settings
  double _previewWidth = 0.63; // 685px / 1080px
  double _previewHeight = 0.42; // 816px / 1920px
  double _previewBorderRadius = 5.0;
  Color _previewBorderColor = AppColors.white;
  double _previewBorderWidth = 2.0;
  bool _showPreviewBorder = true;
  double _previewTop = 0.30; // 590px / 1920px
  double _previewLeft = 0.18; // 196px / 1080px

  // Button settings
  bool _useImageButton = true;
  String? _buttonImagePath = 'assets/images/capture_btn.png';
  bool _isButtonImageAsset = true;
  double _buttonWidth = 0.54; // 585px / 1080px
  double _buttonHeight = 0.078; // 150px / 1920px
  double _buttonTop = 0.75; // 1455px / 1920px
  double _buttonLeft = 0.22; // 245px / 1080px
  
  // Background settings
  bool _showBackground = false;
  String? _backgroundImagePath;
  bool _isBackgroundImageAsset = true;
  
  int _selectedCameraIndex = 0;

  // --- Getters (no changes, they just return the private properties) ---
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
  double get previewWidth => _previewWidth;
  double get previewHeight => _previewHeight;
  double get previewBorderRadius => _previewBorderRadius;
  Color get previewBorderColor => _previewBorderColor;
  double get previewBorderWidth => _previewBorderWidth;
  bool get showPreviewBorder => _showPreviewBorder;
  double get previewTop => _previewTop;
  double get previewLeft => _previewLeft;
  double get buttonWidth => _buttonWidth;
  double get buttonHeight => _buttonHeight;
  double get buttonTop => _buttonTop;
  double get buttonLeft => _buttonLeft;
  bool get useImageButton => _useImageButton;
  String? get buttonImagePath => _buttonImagePath;
  bool get isButtonImageAsset => _isButtonImageAsset;
  bool get showBackground => _showBackground;
  String? get backgroundImagePath => _backgroundImagePath;
  bool get isBackgroundImageAsset => _isBackgroundImageAsset;
  int get selectedCameraIndex => _selectedCameraIndex;


  // --- Setters (no changes, they just update the private properties) ---
  void setTitleText(String text) { _titleText = text; _saveAndNotify(); }
  void setTitleFontSize(double size) { _titleFontSize = size; _saveAndNotify(); }
  void setTitleFontWeight(FontWeight weight) { _titleFontWeight = weight; _saveAndNotify(); }
  void setTitleColor(Color color) { _titleColor = color; _saveAndNotify(); }
  void setTitleLineHeight(double height) { _titleLineHeight = height; _saveAndNotify(); }
  void setTitleOpacity(double opacity) { _titleOpacity = opacity; _saveAndNotify(); }
  void setTitleAlignment(TextAlign alignment) { _titleAlignment = alignment; _saveAndNotify(); }
  void setTitleTop(double top) { _titleTop = top; _saveAndNotify(); }
  void setTitleLeft(double left) { _titleLeft = left; _saveAndNotify(); }
  void setPreviewTop(double top) { _previewTop = top; _saveAndNotify(); }
  void setPreviewLeft(double left) { _previewLeft = left; _saveAndNotify(); }
  void setButtonTop(double top) { _buttonTop = top; _saveAndNotify(); }
  void setButtonLeft(double left) { _buttonLeft = left; _saveAndNotify(); }
  void setShowTitle(bool show) { _showTitle = show; _saveAndNotify(); }
  void setPreviewWidth(double width) { _previewWidth = width; _saveAndNotify(); }
  void setPreviewHeight(double height) { _previewHeight = height; _saveAndNotify(); }
  void setPreviewBorderRadius(double radius) { _previewBorderRadius = radius; _saveAndNotify(); }
  void setPreviewBorderColor(Color color) { _previewBorderColor = color; _saveAndNotify(); }
  void setPreviewBorderWidth(double width) { _previewBorderWidth = width; _saveAndNotify(); }
  void setShowPreviewBorder(bool show) { _showPreviewBorder = show; _saveAndNotify(); }
  void setButtonWidth(double width) { _buttonWidth = width; _saveAndNotify(); }
  void setButtonHeight(double height) { _buttonHeight = height; _saveAndNotify(); }
  void setUseImageButton(bool use) { _useImageButton = use; _saveAndNotify(); }
  void setShowBackground(bool show) { _showBackground = show; _saveAndNotify(); }
  void setSelectedCameraIndex(int index) { _selectedCameraIndex = index; _saveAndNotify(); }

  Future<void> _setImage(String? sourcePath, bool isAsset, Function(String?, bool) updateState) async {
    if (sourcePath == null) {
      updateState(null, true);
    } else if (isAsset) {
      updateState(sourcePath, true);
    } else {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'capture_${DateTime.now().millisecondsSinceEpoch}${path.extension(sourcePath)}';
        final destinationPath = path.join(appDir.path, fileName);
        await File(sourcePath).copy(destinationPath);
        updateState(destinationPath, false);
      } on Exception catch (e) {
        debugPrint('Error copying image: $e');
        return;
      }
    }
    _saveAndNotify();
  }

  Future<void> setButtonImagePath(String? path, {bool isAsset = true}) async {
    await _setImage(path, isAsset, (p, a) {
      _buttonImagePath = p;
      _isButtonImageAsset = a;
    });
  }

  Future<void> setBackgroundImagePath(String? path, {bool isAsset = true}) async {
    await _setImage(path, isAsset, (p, a) {
      _backgroundImagePath = p;
      _isBackgroundImageAsset = a;
    });
  }

  Future<void> init() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
    _isInitialized = true;
  }

  void _saveAndNotify() {
    if (!_isInitialized) return;
    _saveSettings();
    notifyListeners();
  }
  
  Future<void> _loadSettings() async {
    final settingsJson = _prefs.getString('face_capture_settings');
    if (settingsJson != null) {
      final settings = jsonDecode(settingsJson) as Map<String, dynamic>;

      // Helper to convert old pixel values to new percentage values for migration
      const double refWidth = 1080.0;
      const double refHeight = 1920.0;
      double toPercent(dynamic value, double defaultValue, double reference) {
        if (value == null) return defaultValue;
        double val = (value as num).toDouble();
        // If value is > 1.0, it's likely an old pixel value, so convert it.
        // Otherwise, it's already a percentage.
        return val > 1.0 ? val / reference : val;
      }

      // Load all settings, applying the toPercent migration logic to layout values
      _titleText = settings['titleText'] ?? _titleText;
      _titleFontSize = settings['titleFontSize'] ?? _titleFontSize;
      _titleFontWeight = FontWeight.values[settings['titleFontWeight'] ?? _titleFontWeight.index];
      _titleColor = Color(settings['titleColor'] ?? _titleColor.value);
      _showTitle = settings['showTitle'] ?? _showTitle;
      _titleLineHeight = settings['titleLineHeight'] ?? _titleLineHeight;
      _titleOpacity = settings['titleOpacity'] ?? _titleOpacity;
      _titleAlignment = TextAlign.values[settings['titleAlignment'] ?? 2];
      
      _titleTop = toPercent(settings['titleTop'], _titleTop, refHeight);
      _titleLeft = toPercent(settings['titleLeft'], _titleLeft, refWidth);

      _previewWidth = toPercent(settings['previewWidth'], _previewWidth, refWidth);
      _previewHeight = toPercent(settings['previewHeight'], _previewHeight, refHeight);
      _previewBorderRadius = settings['previewBorderRadius'] ?? _previewBorderRadius;
      _previewBorderColor = Color(settings['previewBorderColor'] ?? _previewBorderColor.value);
      _previewBorderWidth = settings['previewBorderWidth'] ?? _previewBorderWidth;
      _showPreviewBorder = settings['showPreviewBorder'] ?? _showPreviewBorder;
      _previewTop = toPercent(settings['previewTop'], _previewTop, refHeight);
      _previewLeft = toPercent(settings['previewLeft'], _previewLeft, refWidth);

      _buttonWidth = toPercent(settings['buttonWidth'], _buttonWidth, refWidth);
      _buttonHeight = toPercent(settings['buttonHeight'], _buttonHeight, refHeight);
      _buttonTop = toPercent(settings['buttonTop'], _buttonTop, refHeight);
      _buttonLeft = toPercent(settings['buttonLeft'], _buttonLeft, refWidth);

      _useImageButton = settings['useImageButton'] ?? _useImageButton;
      _buttonImagePath = settings['buttonImagePath'];
      _isButtonImageAsset = settings['isButtonImageAsset'] ?? _isButtonImageAsset;
      
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
      // Save all properties as they are. They are now percentages.
      'titleText': _titleText, 'titleFontSize': _titleFontSize, 'titleFontWeight': _titleFontWeight.index,
      'titleColor': _titleColor.value, 'titleTop': _titleTop, 'titleLeft': _titleLeft, 'showTitle': _showTitle,
      'titleLineHeight': _titleLineHeight, 'titleOpacity': _titleOpacity, 'titleAlignment': _titleAlignment.index,
      'previewWidth': _previewWidth, 'previewHeight': _previewHeight, 'previewBorderRadius': _previewBorderRadius,
      'previewBorderColor': _previewBorderColor.value, 'previewBorderWidth': _previewBorderWidth,
      'showPreviewBorder': _showPreviewBorder, 'previewTop': _previewTop, 'previewLeft': _previewLeft,
      'buttonWidth': _buttonWidth, 'buttonHeight': _buttonHeight, 'buttonTop': _buttonTop,
      'buttonLeft': _buttonLeft, 'useImageButton': _useImageButton, 'buttonImagePath': _buttonImagePath,
      'isButtonImageAsset': _isButtonImageAsset, 'showBackground': _showBackground, 'backgroundImagePath': _backgroundImagePath,
      'isBackgroundImageAsset': _isBackgroundImageAsset, 'selectedCameraIndex': _selectedCameraIndex,
    };
    await prefs.setString('face_capture_settings', jsonEncode(settings));
  }
}