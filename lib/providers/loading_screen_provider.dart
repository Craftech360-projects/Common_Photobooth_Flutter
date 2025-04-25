import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingScreenProvider extends ChangeNotifier {
  late SharedPreferences _prefs;

  // Title settings
  String _titleText = 'Processing Your Image...';
  double _titleFontSize = 32.0;
  FontWeight _titleFontWeight = FontWeight.bold;
  Color _titleColor = Colors.white;
  EdgeInsets _titlePadding = const EdgeInsets.all(0);
  bool _showTitle = true;
  double _titleLineHeight = 1.2;
  double _titleOpacity = 1.0;
  EdgeInsets _titleMargin = const EdgeInsets.all(0);

  // Loader settings
  double _loaderWidth = 200.0;
  double _loaderHeight = 200.0;
  double _loaderBorderRadius = 0.0;
  Color _loaderBorderColor = Colors.white;
  double _loaderBorderWidth = 0.0;
  bool _showLoaderBorder = false;
  EdgeInsets _loaderMargin = const EdgeInsets.all(0);

  // Background settings
  bool _showBackground = true;
  String? _backgroundImagePath;
  bool _isBackgroundImageAsset = true;

  // Loader file settings
  String? _loaderFilePath;
  bool _isLoaderFileAsset = true;
  String _loaderFileType = 'gif'; // gif, json, mp4, mov

  // Getters
  String get titleText => _titleText;
  double get titleFontSize => _titleFontSize;
  FontWeight get titleFontWeight => _titleFontWeight;
  Color get titleColor => _titleColor;
  EdgeInsets get titlePadding => _titlePadding;
  bool get showTitle => _showTitle;
  double get titleLineHeight => _titleLineHeight;
  double get titleOpacity => _titleOpacity;
  EdgeInsets get titleMargin => _titleMargin;

  double get loaderWidth => _loaderWidth;
  double get loaderHeight => _loaderHeight;
  double get loaderBorderRadius => _loaderBorderRadius;
  Color get loaderBorderColor => _loaderBorderColor;
  double get loaderBorderWidth => _loaderBorderWidth;
  bool get showLoaderBorder => _showLoaderBorder;
  EdgeInsets get loaderMargin => _loaderMargin;

  bool get showBackground => _showBackground;
  String? get backgroundImagePath => _backgroundImagePath;
  bool get isBackgroundImageAsset => _isBackgroundImageAsset;

  String? get loaderFilePath => _loaderFilePath;
  bool get isLoaderFileAsset => _isLoaderFileAsset;
  String get loaderFileType => _loaderFileType;

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

  void setTitlePadding(EdgeInsets padding) {
    _titlePadding = padding;
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

  void setTitleMargin(EdgeInsets margin) {
    _titleMargin = margin;
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

  void setLoaderMargin(EdgeInsets margin) {
    _loaderMargin = margin;
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

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();

    // Verify file paths exist
    await _verifyFilePaths();
  }

  Future<void> _verifyFilePaths() async {
    // Check if loader file path exists
    if (_loaderFilePath != null && !_isLoaderFileAsset) {
      final file = File(_loaderFilePath!);
      if (!file.existsSync()) {
        _loaderFilePath = null;
        notifyListeners();
        await _saveSettings();
      }
    }

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
        _titleFontWeight = FontWeight.values[settings['titleFontWeight'] ?? 3];
        _titleColor = Color(settings['titleColor'] ?? _titleColor.value);
        _showTitle = settings['showTitle'] ?? _showTitle;
        _titleLineHeight = settings['titleLineHeight'] ?? _titleLineHeight;
        _titleOpacity = settings['titleOpacity'] ?? _titleOpacity;

        // Load title padding properly
        if (settings['titlePadding'] != null) {
          final paddingMap = settings['titlePadding'] as Map<String, dynamic>;
          _titlePadding = EdgeInsets.fromLTRB(
            paddingMap['left'] ?? 0.0,
            paddingMap['top'] ?? 0.0,
            paddingMap['right'] ?? 0.0,
            paddingMap['bottom'] ?? 0.0,
          );
        }

        // Load title margin
        if (settings['titleMargin'] != null) {
          final marginMap = settings['titleMargin'] as Map<String, dynamic>;
          _titleMargin = EdgeInsets.fromLTRB(
            marginMap['left'] ?? 0.0,
            marginMap['top'] ?? 0.0,
            marginMap['right'] ?? 0.0,
            marginMap['bottom'] ?? 0.0,
          );
        }

        _loaderWidth = settings['loaderWidth'] ?? _loaderWidth;
        _loaderHeight = settings['loaderHeight'] ?? _loaderHeight;
        _loaderBorderRadius =
            settings['loaderBorderRadius'] ?? _loaderBorderRadius;
        _loaderBorderColor =
            Color(settings['loaderBorderColor'] ?? _loaderBorderColor.value);
        _loaderBorderWidth =
            settings['loaderBorderWidth'] ?? _loaderBorderWidth;
        _showLoaderBorder = settings['showLoaderBorder'] ?? _showLoaderBorder;

        // Load loader margin
        if (settings['loaderMargin'] != null) {
          final marginMap = settings['loaderMargin'] as Map<String, dynamic>;
          _loaderMargin = EdgeInsets.fromLTRB(
            marginMap['left'] ?? 0.0,
            marginMap['top'] ?? 0.0,
            marginMap['right'] ?? 0.0,
            marginMap['bottom'] ?? 0.0,
          );
        }

        _showBackground = settings['showBackground'] ?? _showBackground;
        _backgroundImagePath = settings['backgroundImagePath'];
        _isBackgroundImageAsset =
            settings['isBackgroundImageAsset'] ?? _isBackgroundImageAsset;

        _loaderFilePath = settings['loaderFilePath'];
        _isLoaderFileAsset =
            settings['isLoaderFileAsset'] ?? _isLoaderFileAsset;
        _loaderFileType = settings['loaderFileType'] ?? _loaderFileType;
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
      
      // Properly serialize title padding
      'titlePadding': {
        'left': _titlePadding.left,
        'top': _titlePadding.top,
        'right': _titlePadding.right,
        'bottom': _titlePadding.bottom,
      },
      
      // Properly serialize title margin
      'titleMargin': {
        'left': _titleMargin.left,
        'top': _titleMargin.top,
        'right': _titleMargin.right,
        'bottom': _titleMargin.bottom,
      },
      
      'loaderWidth': _loaderWidth,
      'loaderHeight': _loaderHeight,
      'loaderBorderRadius': _loaderBorderRadius,
      'loaderBorderColor': _loaderBorderColor.value,
      'loaderBorderWidth': _loaderBorderWidth,
      'showLoaderBorder': _showLoaderBorder,
      'loaderMargin': {
        'left': _loaderMargin.left,
        'top': _loaderMargin.top,
        'right': _loaderMargin.right,
        'bottom': _loaderMargin.bottom,
      },
      'showBackground': _showBackground,
      'backgroundImagePath': _backgroundImagePath,
      'isBackgroundImageAsset': _isBackgroundImageAsset,
      'loaderFilePath': _loaderFilePath,
      'isLoaderFileAsset': _isLoaderFileAsset,
      'loaderFileType': _loaderFileType,
    };

    await _prefs.setString('loading_screen_settings', jsonEncode(settings));
  }

  void resetToDefaults() {
    _titleText = 'Processing Your Image...';
    _titleFontSize = 32.0;
    _titleFontWeight = FontWeight.bold;
    _titleColor = Colors.white;
    _titlePadding = const EdgeInsets.all(0);
    _showTitle = true;
    _titleLineHeight = 1.2;
    _titleOpacity = 1.0;
    _titleMargin = const EdgeInsets.all(0);

    _loaderWidth = 200.0;
    _loaderHeight = 200.0;
    _loaderBorderRadius = 0.0;
    _loaderBorderColor = Colors.white;
    _loaderBorderWidth = 0.0;
    _showLoaderBorder = false;
    _loaderMargin = const EdgeInsets.all(0);

    _showBackground = true;
    _backgroundImagePath = null;
    _isBackgroundImageAsset = true;

    _loaderFilePath = null;
    _isLoaderFileAsset = true;
    _loaderFileType = 'gif';

    notifyListeners();
    _saveSettings();
  }
}
