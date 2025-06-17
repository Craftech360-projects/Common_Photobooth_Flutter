import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingScreenProvider extends ChangeNotifier {
  late SharedPreferences _prefs;

  // Title settings
  String _titleText = '';
  double _titleFontSize = 22.0;
  FontWeight _titleFontWeight = FontWeight.w500;
  Color _titleColor = AppColors.white;
  bool _showTitle = false;
  double _titleLineHeight = 1.0;
  double _titleOpacity = 1.0;
  double _titleTop = 455.0;
  double _titleLeft = 0.0;
  double _titleRight = 0.0;

  // Loader settings
  double _loaderWidth = 100.0;
  double _loaderHeight = 100.0;
  double _loaderBorderRadius = 0.0;
  Color _loaderBorderColor = AppColors.white;
  double _loaderBorderWidth = 0.0;
  bool _showLoaderBorder = false;
  // Loader position
  double _loaderTop = 915.0;
  double _loaderLeft = 0.0;
  double _loaderRight = 0.0;

  // Background settings
  bool _showBackground = false;
  String? _backgroundImagePath;
  bool _isBackgroundImageAsset = true;

  // // Loader file settings (COMMENTED OUT)
  // String? _loaderFilePath;
  // bool _isLoaderFileAsset = true;
  // String _loaderFileType = 'gif'; // gif, json, mp4, mov

  // Getters
  String get titleText => _titleText;
  double get titleFontSize => _titleFontSize;
  FontWeight get titleFontWeight => _titleFontWeight;
  Color get titleColor => _titleColor;
  double get titleTop => _titleTop;
  double get titleLeft => _titleLeft;
  double get titleRight => _titleRight;
  bool get showTitle => _showTitle;
  double get titleLineHeight => _titleLineHeight;
  double get titleOpacity => _titleOpacity;

  double get loaderWidth => _loaderWidth;
  double get loaderHeight => _loaderHeight;
  double get loaderBorderRadius => _loaderBorderRadius;
  Color get loaderBorderColor => _loaderBorderColor;
  double get loaderBorderWidth => _loaderBorderWidth;
  bool get showLoaderBorder => _showLoaderBorder;
  double get loaderTop => _loaderTop;
  double get loaderLeft => _loaderLeft;
  double get loaderRight => _loaderRight;

  bool get showBackground => _showBackground;
  String? get backgroundImagePath => _backgroundImagePath;
  bool get isBackgroundImageAsset => _isBackgroundImageAsset;

  // // Loader file getters (COMMENTED OUT)
  // String? get loaderFilePath => _loaderFilePath;
  // bool get isLoaderFileAsset => _isLoaderFileAsset;
  // String get loaderFileType => _loaderFileType;

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

  void setTitleColor(Color color) {
    _titleColor = color;
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

  void setTitleLineHeight(double lineHeight) {
    _titleLineHeight = lineHeight;
    notifyListeners();
    _saveSettings();
  }

  void setTitleOpacity(double opacity) {
    _titleOpacity = opacity;
    notifyListeners();
    _saveSettings();
  }

  void setShowTitle(bool show) {
    _showTitle = show;
    notifyListeners();
    _saveSettings();
  }

  void setLoaderWidth(double width) {
    _loaderWidth = width;
    notifyListeners();
    _saveSettings();
  }

  void setLoaderHeight(double height) {
    _loaderHeight = height;
    notifyListeners();
    _saveSettings();
  }

  void setLoaderTop(double top) {
    _loaderTop = top;
    notifyListeners();
    _saveSettings();
  }

  void setLoaderLeft(double left) {
    _loaderLeft = left;
    notifyListeners();
    _saveSettings();
  }

  void setLoaderRight(double right) {
    _loaderRight = right;
    notifyListeners();
    _saveSettings();
  }

  void setLoaderBorderRadius(double radius) {
    _loaderBorderRadius = radius;
    notifyListeners();
    _saveSettings();
  }

  void setLoaderBorderColor(Color color) {
    _loaderBorderColor = color;
    notifyListeners();
    _saveSettings();
  }

  void setLoaderBorderWidth(double width) {
    _loaderBorderWidth = width;
    notifyListeners();
    _saveSettings();
  }

  void setShowLoaderBorder(bool show) {
    _showLoaderBorder = show;
    notifyListeners();
    _saveSettings();
  }

  void setShowBackground(bool show) {
    _showBackground = show;
    notifyListeners();
    _saveSettings();
  }

  void setBackgroundImage(String? path, bool isAsset) {
    _backgroundImagePath = path;
    _isBackgroundImageAsset = isAsset;
    notifyListeners();
    _saveSettings();
  }

  // // Loader file setter (COMMENTED OUT)
  // void setLoaderFile(String? path, bool isAsset, String fileType) {
  //   _loaderFilePath = path;
  //   _isLoaderFileAsset = isAsset;
  //   _loaderFileType = fileType;
  //   notifyListeners();
  //   _saveSettings();
  // }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
    await _verifyFilePaths();
  }

  Future<void> _verifyFilePaths() async {
    // Check if background image path exists
    if (_backgroundImagePath != null && !_isBackgroundImageAsset) {
      final file = File(_backgroundImagePath!);
      if (!file.existsSync()) {
        _backgroundImagePath = null;
        notifyListeners();
        await _saveSettings();
      }
    }
  }

  Future<void> _loadSettings() async {
    final settingsJson = _prefs.getString('loading_screen_settings');
    if (settingsJson != null) {
      try {
        final settings = jsonDecode(settingsJson) as Map<String, dynamic>;

        _titleText = settings['titleText'] ?? _titleText;
        _titleFontSize = settings['titleFontSize'] ?? _titleFontSize;
        _titleFontWeight = FontWeight.values[settings['titleFontWeight'] ?? 4];
        _titleColor = Color(settings['titleColor'] ?? _titleColor.value);
        _showTitle = settings['showTitle'] ?? _showTitle;
        _titleLineHeight = settings['titleLineHeight'] ?? _titleLineHeight;
        _titleOpacity = settings['titleOpacity'] ?? _titleOpacity;

        _titleTop = settings['titleTop'] ?? _titleTop;
        _titleLeft = settings['titleLeft'] ?? _titleLeft;
        _titleRight = settings['titleRight'] ?? _titleRight;

        _loaderWidth = settings['loaderWidth'] ?? _loaderWidth;
        _loaderHeight = settings['loaderHeight'] ?? _loaderHeight;
        _loaderBorderRadius =
            settings['loaderBorderRadius'] ?? _loaderBorderRadius;
        _loaderBorderColor =
            Color(settings['loaderBorderColor'] ?? _loaderBorderColor.value);
        _loaderBorderWidth =
            settings['loaderBorderWidth'] ?? _loaderBorderWidth;
        _showLoaderBorder = settings['showLoaderBorder'] ?? _showLoaderBorder;

        _loaderTop = settings['loaderTop'] ?? _loaderTop;
        _loaderLeft = settings['loaderLeft'] ?? _loaderLeft;
        _loaderRight = settings['loaderRight'] ?? _loaderRight;

        _showBackground = settings['showBackground'] ?? _showBackground;
        _backgroundImagePath = settings['backgroundImagePath'];
        _isBackgroundImageAsset =
            settings['isBackgroundImageAsset'] ?? _isBackgroundImageAsset;
        
        // // Loader file settings (COMMENTED OUT)
        // _loaderFilePath = settings['loaderFilePath'];
        // _isLoaderFileAsset =
        //     settings['isLoaderFileAsset'] ?? _isLoaderFileAsset;
        // _loaderFileType = settings['loaderFileType'] ?? _loaderFileType;

      } on Exception catch (e) {
        debugPrint('Error loading settings: $e');
      }
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
      'titleLineHeight': _titleLineHeight,
      'titleOpacity': _titleOpacity,
      'titleTop': _titleTop,
      'titleLeft': _titleLeft,
      'titleRight': _titleRight,
      'loaderWidth': _loaderWidth,
      'loaderHeight': _loaderHeight,
      'loaderBorderRadius': _loaderBorderRadius,
      'loaderBorderColor': _loaderBorderColor.value,
      'loaderBorderWidth': _loaderBorderWidth,
      'showLoaderBorder': _showLoaderBorder,
      'loaderTop': _loaderTop,
      'loaderLeft': _loaderLeft,
      'loaderRight': _loaderRight,
      'showBackground': _showBackground,
      'backgroundImagePath': _backgroundImagePath,
      'isBackgroundImageAsset': _isBackgroundImageAsset,
      // // Loader file settings (COMMENTED OUT)
      // 'loaderFilePath': _loaderFilePath,
      // 'isLoaderFileAsset': _isLoaderFileAsset,
      // 'loaderFileType': _loaderFileType,
    };

    await _prefs.setString('loading_screen_settings', jsonEncode(settings));
  }
}