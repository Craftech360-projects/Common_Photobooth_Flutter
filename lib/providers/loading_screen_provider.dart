// lib/providers/loading_screen_provider.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingScreenProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  // --- Title settings ---
  bool _showTitle = false;
  String _titleText = 'Generating your image...';
  double _titleFontSize = 48.0;
  FontWeight _titleFontWeight = FontWeight.bold;
  Color _titleColor = AppColors.white;
  double _titleOpacity = 1.0;
  double _titleTop = 0.8; // Percentage from top
  double _titleWidth = 0.8; // Percentage of screen width
  TextAlign _titleAlignment = TextAlign.center;

  // --- Loader settings ---
  String _loaderAssetPath = 'assets/videos/loading_bg.mp4';
  bool _isLoaderAsset = true;
  String _loaderAssetType = 'video'; // 'video' or 'gif'
  bool _loaderIsFullscreen = true;
  // Non-fullscreen settings
  double _loaderWidth = 0.5;
  double _loaderHeight = 0.5;
  double _loaderTop = 0.25;
  double _loaderLeft = 0.25;

  // --- Background settings ---
  bool _showBackground = true;
  String? _backgroundImagePath = 'assets/images/common_bg.png';
  bool _isBackgroundImageAsset = true;

  // --- Getters ---
  bool get showTitle => _showTitle;
  String get titleText => _titleText;
  double get titleFontSize => _titleFontSize;
  FontWeight get titleFontWeight => _titleFontWeight;
  Color get titleColor => _titleColor;
  double get titleOpacity => _titleOpacity;
  double get titleTop => _titleTop;
  double get titleWidth => _titleWidth;
  TextAlign get titleAlignment => _titleAlignment;

  String get loaderAssetPath => _loaderAssetPath;
  bool get isLoaderAsset => _isLoaderAsset;
  String get loaderAssetType => _loaderAssetType;
  bool get loaderIsFullscreen => _loaderIsFullscreen;
  double get loaderWidth => _loaderWidth;
  double get loaderHeight => _loaderHeight;
  double get loaderTop => _loaderTop;
  double get loaderLeft => _loaderLeft;

  bool get showBackground => _showBackground;
  String? get backgroundImagePath => _backgroundImagePath;
  bool get isBackgroundImageAsset => _isBackgroundImageAsset;

  // --- Setters ---
  void setTitleStyle({
    bool? show, String? text, double? fontSize,
    FontWeight? fontWeight, Color? color, double? opacity,
    TextAlign? alignment,
  }) {
    if (show != null) _showTitle = show;
    if (text != null) _titleText = text;
    if (fontSize != null) _titleFontSize = fontSize;
    if (fontWeight != null) _titleFontWeight = fontWeight;
    if (color != null) _titleColor = color;
    if (opacity != null) _titleOpacity = opacity;
    if (alignment != null) _titleAlignment = alignment;
    _saveAndNotify();
  }

  void setTitlePosition({double? top, double? width}) {
    if (top != null) _titleTop = top;
    if (width != null) _titleWidth = width;
    _saveAndNotify();
  }

  void setLoaderStyle({bool? isFullscreen}) {
    if (isFullscreen != null) _loaderIsFullscreen = isFullscreen;
    _saveAndNotify();
  }

  void setLoaderPosition({double? top, double? left}) {
    if (top != null) _loaderTop = top;
    if (left != null) _loaderLeft = left;
    _saveAndNotify();
  }

  void setLoaderDimensions({double? width, double? height}) {
    if (width != null) _loaderWidth = width;
    if (height != null) _loaderHeight = height;
    _saveAndNotify();
  }

  Future<void> setLoaderAsset(String? sourcePath) async {
    if (sourcePath == null) return;
    final extension = path.extension(sourcePath).toLowerCase();
    final type = (extension == '.mp4' || extension == '.mov') ? 'video' : 'gif';
    
    await _setFile(sourcePath, false, (p, a) {
      _loaderAssetPath = p!;
      _isLoaderAsset = a;
      _loaderAssetType = type;
    });
  }

  void setShowBackground(bool show) { _showBackground = show; _saveAndNotify(); }
  Future<void> setBackgroundImage(String? path) async { await _setFile(path, false, (p, a) { _backgroundImagePath = p; _isBackgroundImageAsset = a; }); }

  Future<void> _setFile(String? sourcePath, bool isAsset, Function(String?, bool) updateState) async {
    if (sourcePath == null) { updateState(null, true); }
    else if (isAsset) { updateState(sourcePath, true); }
    else {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'loading_${DateTime.now().millisecondsSinceEpoch}${path.extension(sourcePath)}';
        final destinationPath = path.join(appDir.path, fileName);
        await File(sourcePath).copy(destinationPath);
        updateState(destinationPath, false);
      } on Exception catch (e) { debugPrint('Error copying file: $e'); return; }
    }
    _saveAndNotify();
  }

  Future<void> init() async { if (_isInitialized) return; _prefs = await SharedPreferences.getInstance(); await _loadSettings(); _isInitialized = true; }
  void _saveAndNotify() { if (!_isInitialized) return; _saveSettings(); notifyListeners(); }

  Future<void> _loadSettings() async {
    final jsonString = _prefs.getString('loading_screen_settings_v2');
    if (jsonString != null) {
      final settings = jsonDecode(jsonString);
      // Title
      _showTitle = settings['showTitle'] ?? _showTitle;
      _titleText = settings['titleText'] ?? _titleText;
      _titleFontSize = settings['titleFontSize'] ?? _titleFontSize;
      _titleFontWeight = FontWeight.values[settings['titleFontWeight'] ?? _titleFontWeight.index];
      _titleColor = Color(settings['titleColor'] ?? _titleColor.value);
      _titleOpacity = settings['titleOpacity'] ?? _titleOpacity;
      _titleTop = settings['titleTop'] ?? _titleTop;
      _titleWidth = settings['titleWidth'] ?? _titleWidth;
      _titleAlignment = TextAlign.values[settings['titleAlignment'] ?? _titleAlignment.index];
      // Loader
      _loaderAssetPath = settings['loaderAssetPath'] ?? _loaderAssetPath;
      _isLoaderAsset = settings['isLoaderAsset'] ?? _isLoaderAsset;
      _loaderAssetType = settings['loaderAssetType'] ?? _loaderAssetType;
      _loaderIsFullscreen = settings['loaderIsFullscreen'] ?? _loaderIsFullscreen;
      _loaderWidth = settings['loaderWidth'] ?? _loaderWidth;
      _loaderHeight = settings['loaderHeight'] ?? _loaderHeight;
      _loaderTop = settings['loaderTop'] ?? _loaderTop;
      _loaderLeft = settings['loaderLeft'] ?? _loaderLeft;
      // Background
      _showBackground = settings['showBackground'] ?? _showBackground;
      _backgroundImagePath = settings['backgroundImagePath'];
      _isBackgroundImageAsset = settings['isBackgroundImageAsset'] ?? _isBackgroundImageAsset;
    }
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final settings = {
      // Title
      'showTitle': _showTitle, 'titleText': _titleText, 'titleFontSize': _titleFontSize,
      'titleFontWeight': _titleFontWeight.index, 'titleColor': _titleColor.value,
      'titleOpacity': _titleOpacity, 'titleTop': _titleTop, 'titleWidth': _titleWidth,
      'titleAlignment': _titleAlignment.index,
      // Loader
      'loaderAssetPath': _loaderAssetPath, 'isLoaderAsset': _isLoaderAsset,
      'loaderAssetType': _loaderAssetType, 'loaderIsFullscreen': _loaderIsFullscreen,
      'loaderWidth': _loaderWidth, 'loaderHeight': _loaderHeight,
      'loaderTop': _loaderTop, 'loaderLeft': _loaderLeft,
      // Background
      'showBackground': _showBackground, 'backgroundImagePath': _backgroundImagePath,
      'isBackgroundImageAsset': _isBackgroundImageAsset,
    };
    await _prefs.setString('loading_screen_settings_v2', jsonEncode(settings));
  }
}