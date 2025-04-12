import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingScreenProvider extends ChangeNotifier {
  late SharedPreferences _prefs;

  // Title settings
  String _titleText = 'Processing Your Image...';
  double _titleFontSize = 32.0;
  FontWeight _titleFontWeight = FontWeight.bold;
  Color _titleColor = Colors.white;
  double _titlePadding = 20.0;
  bool _showTitle = true;

  // Loader settings
  double _loaderWidth = 200.0;
  double _loaderHeight = 200.0;
  double _loaderBorderRadius = 0.0;
  Color _loaderBorderColor = Colors.white;
  double _loaderBorderWidth = 0.0;
  bool _showLoaderBorder = false;

  // Background settings
  bool _showBackground = true;
  String? _backgroundImagePath;
  bool _isBackgroundImageAsset = true;

  // Loader file settings
  String? _loaderFilePath;
  bool _isLoaderFileAsset = true;
  String _loaderFileType = 'gif'; // gif, json, mp4, mov

  // Duration settings
  int _loaderDurationSeconds = 10;

  // Getters
  String get titleText => _titleText;
  double get titleFontSize => _titleFontSize;
  FontWeight get titleFontWeight => _titleFontWeight;
  Color get titleColor => _titleColor;
  double get titlePadding => _titlePadding;
  bool get showTitle => _showTitle;

  double get loaderWidth => _loaderWidth;
  double get loaderHeight => _loaderHeight;
  double get loaderBorderRadius => _loaderBorderRadius;
  Color get loaderBorderColor => _loaderBorderColor;
  double get loaderBorderWidth => _loaderBorderWidth;
  bool get showLoaderBorder => _showLoaderBorder;

  bool get showBackground => _showBackground;
  String? get backgroundImagePath => _backgroundImagePath;
  bool get isBackgroundImageAsset => _isBackgroundImageAsset;

  String? get loaderFilePath => _loaderFilePath;
  bool get isLoaderFileAsset => _isLoaderFileAsset;
  String get loaderFileType => _loaderFileType;

  int get loaderDurationSeconds => _loaderDurationSeconds;

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

  void setLoaderFile(String? path, bool isAsset, String fileType) {
    _loaderFilePath = path;
    _isLoaderFileAsset = isAsset;
    _loaderFileType = fileType;
    notifyListeners();
    _saveSettings();
  }

  void setLoaderDuration(int seconds) {
    _loaderDurationSeconds = seconds;
    notifyListeners();
    _saveSettings();
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settingsJson = _prefs.getString('loading_screen_settings');
    if (settingsJson != null) {
      final settings = jsonDecode(settingsJson) as Map<String, dynamic>;

      _titleText = settings['titleText'] ?? _titleText;
      _titleFontSize = settings['titleFontSize'] ?? _titleFontSize;
      _titleFontWeight = FontWeight.values[settings['titleFontWeight'] ?? 3];
      _titleColor = Color(settings['titleColor'] ?? _titleColor.value);
      _titlePadding = settings['titlePadding'] ?? _titlePadding;
      _showTitle = settings['showTitle'] ?? _showTitle;

      _loaderWidth = settings['loaderWidth'] ?? _loaderWidth;
      _loaderHeight = settings['loaderHeight'] ?? _loaderHeight;
      _loaderBorderRadius = settings['loaderBorderRadius'] ?? _loaderBorderRadius;
      _loaderBorderColor = Color(settings['loaderBorderColor'] ?? _loaderBorderColor.value);
      _loaderBorderWidth = settings['loaderBorderWidth'] ?? _loaderBorderWidth;
      _showLoaderBorder = settings['showLoaderBorder'] ?? _showLoaderBorder;

      _showBackground = settings['showBackground'] ?? _showBackground;
      _backgroundImagePath = settings['backgroundImagePath'];
      _isBackgroundImageAsset = settings['isBackgroundImageAsset'] ?? _isBackgroundImageAsset;

      _loaderFilePath = settings['loaderFilePath'];
      _isLoaderFileAsset = settings['isLoaderFileAsset'] ?? _isLoaderFileAsset;
      _loaderFileType = settings['loaderFileType'] ?? _loaderFileType;

      _loaderDurationSeconds = settings['loaderDurationSeconds'] ?? _loaderDurationSeconds;
    }
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final settings = {
      'titleText': _titleText,
      'titleFontSize': _titleFontSize,
      'titleFontWeight': _titleFontWeight.index,
      'titleColor': _titleColor.value,
      'titlePadding': _titlePadding,
      'showTitle': _showTitle,

      'loaderWidth': _loaderWidth,
      'loaderHeight': _loaderHeight,
      'loaderBorderRadius': _loaderBorderRadius,
      'loaderBorderColor': _loaderBorderColor.value,
      'loaderBorderWidth': _loaderBorderWidth,
      'showLoaderBorder': _showLoaderBorder,

      'showBackground': _showBackground,
      'backgroundImagePath': _backgroundImagePath,
      'isBackgroundImageAsset': _isBackgroundImageAsset,

      'loaderFilePath': _loaderFilePath,
      'isLoaderFileAsset': _isLoaderFileAsset,
      'loaderFileType': _loaderFileType,

      'loaderDurationSeconds': _loaderDurationSeconds,
    };

    await _prefs.setString('loading_screen_settings', jsonEncode(settings));
  }

  void resetToDefaults() {
    _titleText = 'Processing Your Image...';
    _titleFontSize = 32.0;
    _titleFontWeight = FontWeight.bold;
    _titleColor = Colors.white;
    _titlePadding = 20.0;
    _showTitle = true;

    _loaderWidth = 200.0;
    _loaderHeight = 200.0;
    _loaderBorderRadius = 0.0;
    _loaderBorderColor = Colors.white;
    _loaderBorderWidth = 0.0;
    _showLoaderBorder = false;

    _showBackground = true;
    _backgroundImagePath = null;
    _isBackgroundImageAsset = true;

    _loaderFilePath = null;
    _isLoaderFileAsset = true;
    _loaderFileType = 'gif';

    _loaderDurationSeconds = 10;

    notifyListeners();
    _saveSettings();
  }
}