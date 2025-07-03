// lib/providers/output_screen_provider.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum QrCodeLayout {
  qrLeftTextRight,
  qrRightTextLeft,
  qrTopTextBottom,
  qrBottomTextTop,
}

class OutputScreenProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  // --- Title ---
  bool _showTitle = true;
  String _titleText = 'Thank You!';
  double _titleFontSize = 48.0;
  FontWeight _titleFontWeight = FontWeight.bold;
  Color _titleColor = AppColors.white;
  double _titleOpacity = 1.0;
  bool _isTitleItalic = false;
  TextAlign _titleAlignment = TextAlign.center;
  double _titleTop = 0.1;
  double _titleWidth = 1.0;

  // --- Unified Output Image ---
  double _imageTop = 0.25;
  double _imageLeft = 0.1;
  double _imageWidth = 0.8;
  double _imageHeight = 0.5;
  bool _showImageBorder = true;
  double _imageBorderRadius = 15.0;
  double _imageBorderWidth = 5.0;
  Color _imageBorderColor = AppColors.white;

  // --- QR Code & Text ---
  double _qrCodeSize = 200.0;
  double _qrCodeSectionLeft = 0.37;
  double _qrCodeSectionBottom = 0.05;
  bool _showQrCodeText = true;
  String _qrCodeText = 'Scan to download your image!';
  double _qrCodeTextFontSize = 18.0;
  double _qrLabelWidth = 100.0;
  Color _qrCodeTextColor = AppColors.black;
  FontWeight _qrCodeTextFontWeight = FontWeight.w500;
  QrCodeLayout _qrCodeLayout = QrCodeLayout.qrLeftTextRight;
  CrossAxisAlignment _qrCodeRowAlignment = CrossAxisAlignment.center;
  CrossAxisAlignment _qrCodeColumnAlignment = CrossAxisAlignment.center;

  // --- "Done" Button ---
  bool _useDoneButtonImage = true;
  String? _doneButtonImagePath = 'assets/images/home_btn.png';
  bool _isDoneButtonImageAsset = true;
  String _doneButtonText = 'Done';
  double _doneButtonWidth = 0.32;
  double _doneButtonHeight = 0.09;
  double _doneButtonLeft = 0.34;
  double _doneButtonBottom = 0.05;

  // --- Background ---
  String? _backgroundImagePath = 'assets/images/common_bg.png';
  bool _isBackgroundImageAsset = true;
  bool _showBackground = true;
// --- Getters ---
  bool get showTitle => _showTitle;
  String get titleText => _titleText;
  double get titleFontSize => _titleFontSize;
  FontWeight get titleFontWeight => _titleFontWeight;
  Color get titleColor => _titleColor;
  double get titleOpacity => _titleOpacity;
  bool get isTitleItalic => _isTitleItalic;
  TextAlign get titleAlignment => _titleAlignment;
  double get titleTop => _titleTop;
  double get titleWidth => _titleWidth;
  double get imageTop => _imageTop;
  double get imageLeft => _imageLeft;
  double get imageWidth => _imageWidth;
  double get imageHeight => _imageHeight;
  bool get showImageBorder => _showImageBorder;
  double get imageBorderRadius => _imageBorderRadius;
  double get imageBorderWidth => _imageBorderWidth;
  Color get imageBorderColor => _imageBorderColor;
  double get qrCodeSize => _qrCodeSize;
  double get qrCodeSectionLeft => _qrCodeSectionLeft;
  double get qrCodeSectionBottom => _qrCodeSectionBottom;
  bool get showQrCodeText => _showQrCodeText;
  String get qrCodeText => _qrCodeText;
  double get qrCodeTextFontSize => _qrCodeTextFontSize;
  double get qrLabelWidth => _qrLabelWidth;
  FontWeight get qrCodeTextFontWeight => _qrCodeTextFontWeight;
  Color get qrCodeTextColor => _qrCodeTextColor;
  QrCodeLayout get qrCodeLayout => _qrCodeLayout;
  CrossAxisAlignment get qrCodeRowAlignment => _qrCodeRowAlignment;
  CrossAxisAlignment get qrCodeColumnAlignment => _qrCodeColumnAlignment;
  bool get useDoneButtonImage => _useDoneButtonImage;
  String? get doneButtonImagePath => _doneButtonImagePath;
  bool get isDoneButtonImageAsset => _isDoneButtonImageAsset;
  String get doneButtonText => _doneButtonText;
  double get doneButtonWidth => _doneButtonWidth;
  double get doneButtonHeight => _doneButtonHeight;
  double get doneButtonLeft => _doneButtonLeft;
  double get doneButtonBottom => _doneButtonBottom;
  String? get backgroundImagePath => _backgroundImagePath;
  bool get isBackgroundImageAsset => _isBackgroundImageAsset;
  bool get showBackground => _showBackground;

  // --- Setters ---
  void setQrCodeStyle(
      {double? size,
      bool? showText,
      String? text,
      double? textFontSize,
      double? qrLabelWidth,
      FontWeight? textFontWeight,
      Color? textColor,
      QrCodeLayout? layout,
      CrossAxisAlignment? rowAlignment,
      CrossAxisAlignment? columnAlignment}) {
    if (size != null) _qrCodeSize = size;
    if (showText != null) _showQrCodeText = showText;
    if (text != null) _qrCodeText = text;
    if (textFontSize != null) _qrCodeTextFontSize = textFontSize;
    if (qrLabelWidth != null) _qrLabelWidth = qrLabelWidth;
    if (textFontWeight != null) _qrCodeTextFontWeight = textFontWeight;
    if (textColor != null) _qrCodeTextColor = textColor;
    if (layout != null) _qrCodeLayout = layout;
    if (rowAlignment != null) _qrCodeRowAlignment = rowAlignment;
    if (columnAlignment != null) _qrCodeColumnAlignment = columnAlignment;
    _notifyAndSave();
  }

  void setShowTitle(bool show) {
    _showTitle = show;
    _notifyAndSave();
  }

  void setTitleStyle(
      {String? text,
      double? fontSize,
      FontWeight? fontWeight,
      Color? color,
      double? opacity,
      bool? isItalic,
      TextAlign? alignment}) {
    if (text != null) _titleText = text;
    if (fontSize != null) _titleFontSize = fontSize;
    if (fontWeight != null) _titleFontWeight = fontWeight;
    if (color != null) _titleColor = color;
    if (opacity != null) _titleOpacity = opacity;
    if (isItalic != null) _isTitleItalic = isItalic;
    if (alignment != null) _titleAlignment = alignment;
    _notifyAndSave();
  }

  void setTitlePosition({double? top, double? width}) {
    if (top != null) _titleTop = top;
    if (width != null) _titleWidth = width;
    _notifyAndSave();
  }

  void setImagePosition({double? left, double? top}) {
    if (left != null) _imageLeft = left;
    if (top != null) _imageTop = top;
    _notifyAndSave();
  }

  void setImageDimensions({double? width, double? height}) {
    if (width != null) _imageWidth = width;
    if (height != null) _imageHeight = height;
    _notifyAndSave();
  }

  void setImageStyle(
      {bool? showBorder,
      double? borderRadius,
      double? borderWidth,
      Color? borderColor}) {
    if (showBorder != null) _showImageBorder = showBorder;
    if (borderRadius != null) _imageBorderRadius = borderRadius;
    if (borderWidth != null) _imageBorderWidth = borderWidth;
    if (borderColor != null) _imageBorderColor = borderColor;
    _notifyAndSave();
  }

  void setQrCodePosition({double? left, double? bottom}) {
    if (left != null) _qrCodeSectionLeft = left;
    if (bottom != null) _qrCodeSectionBottom = bottom;
    _notifyAndSave();
  }

  void setDoneButtonPosition({double? left, double? bottom}) {
    if (left != null) _doneButtonLeft = left;
    if (bottom != null) _doneButtonBottom = bottom;
    _notifyAndSave();
  }

  void setDoneButtonDimensions({double? width, double? height}) {
    if (width != null) _doneButtonWidth = width;
    if (height != null) _doneButtonHeight = height;
    _notifyAndSave();
  }

  void setUseDoneButtonImage(bool use) {
    _useDoneButtonImage = use;
    _notifyAndSave();
  }

  Future<void> setDoneButtonImage(String? path) async {
    await _setFile(path, (p, a) {
      _doneButtonImagePath = p;
      _isDoneButtonImageAsset = a;
    });
  }

  void setShowBackground(bool show) {
    _showBackground = show;
    _notifyAndSave();
  }

  Future<void> setBackgroundImage(String? path) async {
    await _setFile(path, (p, a) {
      _backgroundImagePath = p;
      _isBackgroundImageAsset = a;
    });
  }

  Future<void> _setFile(
      String? sourcePath, Function(String?, bool) updateState) async {
    if (sourcePath == null) {
      updateState(null, true);
    } else {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName =
            'output_${DateTime.now().millisecondsSinceEpoch}${p.extension(sourcePath)}';
        final destinationPath = p.join(appDir.path, fileName);
        await File(sourcePath).copy(destinationPath);
        updateState(destinationPath, false);
      } catch (e) {
        debugPrint('Error copying file: $e');
        return;
      }
    }
    _notifyAndSave();
  }

  Future<void> init() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    await loadSettings();
    _isInitialized = true;
  }

  void _notifyAndSave() {
    notifyListeners();
    _saveSettings();
  }

  Future<void> loadSettings() async {
    final s = _prefs.getString('output_screen_settings_v3');
    if (s != null) {
      final Map<String, dynamic> settings = jsonDecode(s);
      const double refWidth = 1080.0, refHeight = 1920.0;
      double toPercent(dynamic v, double d, double r) => v == null
          ? d
          : ((v as num).toDouble() > 1.0 ? (v).toDouble() / r : (v).toDouble());
      _showTitle = settings['showTitle'] ?? _showTitle;
      _titleText = settings['titleText'] ?? _titleText;
      _titleFontSize = settings['titleFontSize'] ?? _titleFontSize;
      _titleFontWeight = FontWeight
          .values[settings['titleFontWeight'] ?? _titleFontWeight.index];
      _titleColor = Color(settings['titleColor'] ?? _titleColor.value);
      _titleOpacity = settings['titleOpacity'] ?? _titleOpacity;
      _isTitleItalic = settings['isTitleItalic'] ?? _isTitleItalic;
      _titleAlignment =
          TextAlign.values[settings['titleAlignment'] ?? _titleAlignment.index];
      _titleTop = toPercent(settings['titleTop'], _titleTop, refHeight);
      _titleWidth = toPercent(settings['titleWidth'], _titleWidth, refWidth);
      _imageTop = toPercent(settings['imageTop'], _imageTop, refHeight);
      _imageLeft = toPercent(settings['imageLeft'], _imageLeft, refWidth);
      _imageWidth = toPercent(settings['imageWidth'], _imageWidth, refWidth);
      _imageHeight =
          toPercent(settings['imageHeight'], _imageHeight, refHeight);
      _showImageBorder = settings['showImageBorder'] ?? _showImageBorder;
      _imageBorderRadius = settings['imageBorderRadius'] ?? _imageBorderRadius;
      _imageBorderWidth = settings['imageBorderWidth'] ?? _imageBorderWidth;
      _imageBorderColor =
          Color(settings['imageBorderColor'] ?? _imageBorderColor.value);
      _qrCodeSize = settings['qrCodeSize'] ?? _qrCodeSize;
      _qrCodeSectionLeft = toPercent(
          settings['qrCodeSectionLeft'], _qrCodeSectionLeft, refWidth);
      _qrCodeSectionBottom = toPercent(
          settings['qrCodeSectionBottom'], _qrCodeSectionBottom, refHeight);
      _showQrCodeText = settings['showQrCodeText'] ?? _showQrCodeText;
      _qrCodeText = settings['qrCodeText'] ?? _qrCodeText;
      _qrCodeTextFontSize =
          settings['qrCodeTextFontSize'] ?? _qrCodeTextFontSize;
      _qrLabelWidth = settings['qrLabelWidth'] ?? _qrLabelWidth;
      _qrCodeTextFontWeight = FontWeight.values[
          settings['qrCodeTextFontWeight'] ?? _qrCodeTextFontWeight.index];
      _qrCodeTextColor =
          Color(settings['qrCodeTextColor'] ?? _qrCodeTextColor.value);
      _qrCodeLayout =
          QrCodeLayout.values[settings['qrCodeLayout'] ?? _qrCodeLayout.index];
      _qrCodeRowAlignment = CrossAxisAlignment
          .values[settings['qrCodeRowAlignment'] ?? _qrCodeRowAlignment.index];
      _qrCodeColumnAlignment = CrossAxisAlignment.values[
          settings['qrCodeColumnAlignment'] ?? _qrCodeColumnAlignment.index];
      _useDoneButtonImage =
          settings['useDoneButtonImage'] ?? _useDoneButtonImage;
      _doneButtonImagePath = settings['doneButtonImagePath'];
      _isDoneButtonImageAsset =
          settings['isDoneButtonImageAsset'] ?? _isDoneButtonImageAsset;
      _doneButtonText = settings['doneButtonText'] ?? _doneButtonText;
      _doneButtonWidth =
          toPercent(settings['doneButtonWidth'], _doneButtonWidth, refWidth);
      _doneButtonHeight =
          toPercent(settings['doneButtonHeight'], _doneButtonHeight, refHeight);
      _doneButtonLeft =
          toPercent(settings['doneButtonLeft'], _doneButtonLeft, refWidth);
      _doneButtonBottom =
          toPercent(settings['doneButtonBottom'], _doneButtonBottom, refHeight);
      _backgroundImagePath = settings['backgroundImagePath'];
      _isBackgroundImageAsset = settings['isBackgroundImageAsset'] ?? true;
      _showBackground = settings['showBackground'] ?? _showBackground;
    }
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final settings = {
      'showTitle': _showTitle,
      'titleText': _titleText,
      'titleFontSize': _titleFontSize,
      'titleFontWeight': _titleFontWeight.index,
      'titleColor': _titleColor.value,
      'titleOpacity': _titleOpacity,
      'isTitleItalic': _isTitleItalic,
      'titleAlignment': _titleAlignment.index,
      'titleTop': _titleTop,
      'titleWidth': _titleWidth,
      'imageTop': _imageTop,
      'imageLeft': _imageLeft,
      'imageWidth': _imageWidth,
      'imageHeight': _imageHeight,
      'showImageBorder': _showImageBorder,
      'imageBorderRadius': _imageBorderRadius,
      'imageBorderWidth': _imageBorderWidth,
      'imageBorderColor': _imageBorderColor.value,
      'qrCodeSize': _qrCodeSize,
      'qrCodeSectionLeft': _qrCodeSectionLeft,
      'qrCodeSectionBottom': _qrCodeSectionBottom,
      'showQrCodeText': _showQrCodeText,
      'qrCodeText': _qrCodeText,
      'qrCodeTextFontSize': _qrCodeTextFontSize,
      'qrLabelWidth': _qrLabelWidth,
      'qrCodeTextFontWeight': _qrCodeTextFontWeight.index,
      'qrCodeTextColor': _qrCodeTextColor.value,
      'qrCodeLayout': _qrCodeLayout.index,
      'qrCodeRowAlignment': _qrCodeRowAlignment.index,
      'qrCodeColumnAlignment': _qrCodeColumnAlignment.index,
      'useDoneButtonImage': _useDoneButtonImage,
      'doneButtonImagePath': _doneButtonImagePath,
      'isDoneButtonImageAsset': _isDoneButtonImageAsset,
      'doneButtonText': _doneButtonText,
      'doneButtonWidth': _doneButtonWidth,
      'doneButtonHeight': _doneButtonHeight,
      'doneButtonLeft': _doneButtonLeft,
      'doneButtonBottom': _doneButtonBottom,
      'backgroundImagePath': _backgroundImagePath,
      'isBackgroundImageAsset': _isBackgroundImageAsset,
      'showBackground': _showBackground,
    };
    await _prefs.setString('output_screen_settings_v3', jsonEncode(settings));
  }
}
