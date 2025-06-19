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

  // Title settings
  String _titleText = 'Strike a Pose';
  double _titleFontSize = 70.0;
  FontWeight _titleFontWeight = FontWeight.w600;
  Color _titleColor = AppColors.yellow;
  double _titleTop = 488.0;
  double _titleLeft = 0.0;
  double _titleRight = 0.0;
  bool _showTitle = true;
  double _titleLineHeight = 1.0;
  double _titleOpacity = 1.0;
  TextAlign _titleAlignment = TextAlign.center;

  // Camera preview settings
  double _previewWidth = 685.0;
  double _previewHeight = 816.0;
  double _previewBorderRadius = 5.0;
  Color _previewBorderColor = AppColors.white;
  double _previewBorderWidth = 2.0;
  bool _showPreviewBorder = true;
  double _previewTop = 590.0;
  double _previewLeft = 196.0;

  // Windows camera settings
  String _pictureFormat = 'jpeg';
  final String _pictureQuality = 'high';

  // Button settings
  String _buttonText = 'Capture';
  double _buttonFontSize = 18.0;
  FontWeight _buttonFontWeight = FontWeight.w500;
  Color _buttonColor = AppColors.white;
  Color _buttonTextColor = AppColors.black;
  double _buttonWidth = 585.0;
  double _buttonHeight = 150.0;
  double _buttonBorderRadius = 0.0;
  double _buttonTop = 1455.0;
  double _buttonLeft = 245.0;
  EdgeInsets _buttonPadding = const EdgeInsets.all(8.0);
  bool _buttonHasBorder = false;
  Color _buttonBorderColor = AppColors.orange;
  double _buttonBorderWidth = 2.0;

  // Image button settings
  bool _useImageButton = true;
  String? _buttonImagePath = 'assets/images/capture_btn.png';
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
  String get pictureFormat => _pictureFormat;
  String get pictureQuality => _pictureQuality;
  int get selectedCameraIndex => _selectedCameraIndex;

  // Setters
  void setTitleText(String text) {
    _titleText = text;
    _saveAndNotify();
  }

  void setTitleFontSize(double size) {
    _titleFontSize = size;
    _saveAndNotify();
  }

  void setTitleFontWeight(FontWeight weight) {
    _titleFontWeight = weight;
    _saveAndNotify();
  }

  void setPictureFormat(String format) {
    _pictureFormat = format;
    _saveAndNotify();
  }

  void setTitleColor(Color color) {
    _titleColor = color;
    _saveAndNotify();
  }

  void setTitleLineHeight(double height) {
    _titleLineHeight = height;
    _saveAndNotify();
  }

  void setTitleOpacity(double opacity) {
    _titleOpacity = opacity;
    _saveAndNotify();
  }

  void setTitleAlignment(TextAlign alignment) {
    _titleAlignment = alignment;
    _saveAndNotify();
  }

  void setTitleTop(double top) {
    _titleTop = top;
    _saveAndNotify();
  }

  void setTitleLeft(double left) {
    _titleLeft = left;
    _saveAndNotify();
  }

  void setTitleRight(double right) {
    _titleRight = right;
    _saveAndNotify();
  }

  void setPreviewTop(double top) {
    _previewTop = top;
    _saveAndNotify();
  }

  void setPreviewLeft(double left) {
    _previewLeft = left;
    _saveAndNotify();
  }

  void setButtonTop(double top) {
    _buttonTop = top;
    _saveAndNotify();
  }

  void setButtonLeft(double left) {
    _buttonLeft = left;
    _saveAndNotify();
  }

  void setButtonPadding(EdgeInsets padding) {
    _buttonPadding = padding;
    _saveAndNotify();
  }

  void setShowTitle(bool show) {
    _showTitle = show;
    _saveAndNotify();
  }

  void setPreviewWidth(double width) {
    _previewWidth = width;
    _saveAndNotify();
  }

  void setPreviewHeight(double height) {
    _previewHeight = height;
    _saveAndNotify();
  }

  void setPreviewBorderRadius(double radius) {
    _previewBorderRadius = radius;
    _saveAndNotify();
  }

  void setPreviewBorderColor(Color color) {
    _previewBorderColor = color;
    _saveAndNotify();
  }

  void setPreviewBorderWidth(double width) {
    _previewBorderWidth = width;
    _saveAndNotify();
  }

  void setShowPreviewBorder(bool show) {
    _showPreviewBorder = show;
    _saveAndNotify();
  }

  void setButtonText(String text) {
    _buttonText = text;
    _saveAndNotify();
  }

  void setButtonFontSize(double size) {
    _buttonFontSize = size;
    _saveAndNotify();
  }

  void setButtonFontWeight(FontWeight weight) {
    _buttonFontWeight = weight;
    _saveAndNotify();
  }

  void setButtonColor(Color color) {
    _buttonColor = color;
    _saveAndNotify();
  }

  void setButtonTextColor(Color color) {
    _buttonTextColor = color;
    _saveAndNotify();
  }

  void setButtonWidth(double width) {
    _buttonWidth = width;
    _saveAndNotify();
  }

  void setButtonHeight(double height) {
    _buttonHeight = height;
    _saveAndNotify();
  }

  void setButtonBorderRadius(double radius) {
    _buttonBorderRadius = radius;
    _saveAndNotify();
  }

  void setButtonHasBorder(bool hasBorder) {
    _buttonHasBorder = hasBorder;
    _saveAndNotify();
  }

  void setButtonBorderColor(Color color) {
    _buttonBorderColor = color;
    _saveAndNotify();
  }

  void setButtonBorderWidth(double width) {
    _buttonBorderWidth = width;
    _saveAndNotify();
  }

  void setUseImageButton(bool use) {
    _useImageButton = use;
    _saveAndNotify();
  }

  void setShowBackground(bool show) {
    _showBackground = show;
    _saveAndNotify();
  }

  void setSelectedCameraIndex(int index) {
    _selectedCameraIndex = index;
    _saveAndNotify();
  }

  Future<void> _setImage(String? sourcePath, bool isAsset,
      Function(String?, bool) updateState) async {
    if (sourcePath == null) {
      updateState(null, true);
    } else if (isAsset) {
      updateState(sourcePath, true);
    } else {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName =
            'capture_${DateTime.now().millisecondsSinceEpoch}${path.extension(sourcePath)}';
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

  Future<void> setBackgroundImagePath(String? path,
      {bool isAsset = true}) async {
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

      _useImageButton = settings['useImageButton'] ?? _useImageButton;
      _buttonImagePath = settings['buttonImagePath'] ??
          _buttonImagePath; // FIX: Preserve default if null
      _isButtonImageAsset =
          settings['isButtonImageAsset'] ?? _isButtonImageAsset;

      // ... Omitted for brevity: all other settings are loaded correctly
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
      _showBackground = settings['showBackground'] ?? _showBackground;
      _backgroundImagePath = settings['backgroundImagePath'];
      _isBackgroundImageAsset =
          settings['isBackgroundImageAsset'] ?? _isBackgroundImageAsset;
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
