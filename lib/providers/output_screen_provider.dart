// lib/providers/output_screen_provider.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OutputScreenProvider extends ChangeNotifier {
  late SharedPreferences _prefs;

  // Title
  bool _showTitle = false;
  String _titleText = 'Thank You!';
  double _titleFontSize = 48.0;
  FontWeight _titleFontWeight = FontWeight.bold;
  Color _titleColor = Colors.white;
  double _titleLeft = 0.0, _titleTop = 200.0, _titleWidth = 1080.0;

  // AI Artistry Image
  double _aiArtistryLeft = 90.0, _aiArtistryTop = 710.0;

  // Swaplab Image
  double _swaplabLeft = 315.0, _swaplabTop = 450.0;
  double _swaplabImageWidth = 450.0, _swaplabImageHeight = 675.0;

  // QR Code
  double _qrCodeSize = 200.0;
  double _qrCodeLeft = 150.0, _qrCodeBottom = 100.0;

  // Done Button
  bool _useDoneButtonImage = true;
  String? _doneButtonImagePath = 'assets/images/home_btn.png';
  bool _isDoneButtonImageAsset = true;
  String _doneButtonText = 'Done';
  double _doneButtonWidth = 350.0, _doneButtonHeight = 180.0;
  double _doneButtonLeft = 580.0, _doneButtonBottom = 100.0;

  // Download Button
  bool _useDownloadButtonImage = false;
  String? _downloadButtonImagePath;
  bool _isDownloadButtonImageAsset = true;
  String _downloadButtonText = 'Download';
  double _downloadButtonWidth = 200.0, _downloadButtonHeight = 80.0;
  double _downloadButtonLeft = 580.0, _downloadButtonBottom = 280.0;

  // Background
  String? _backgroundImagePath;
  bool _isBackgroundImageAsset = true;
  bool _showBackground = false;

  // --- Getters ---
  bool get showTitle => _showTitle;
  String get titleText => _titleText;
  double get titleFontSize => _titleFontSize;
  FontWeight get titleFontWeight => _titleFontWeight;
  Color get titleColor => _titleColor;
  double get titleLeft => _titleLeft;
  double get titleTop => _titleTop;
  double get titleWidth => _titleWidth;

  double get aiArtistryLeft => _aiArtistryLeft;
  double get aiArtistryTop => _aiArtistryTop;

  double get swaplabLeft => _swaplabLeft;
  double get swaplabTop => _swaplabTop;
  double get swaplabImageWidth => _swaplabImageWidth;
  double get swaplabImageHeight => _swaplabImageHeight;

  double get qrCodeSize => _qrCodeSize;
  double get qrCodeLeft => _qrCodeLeft;
  double get qrCodeBottom => _qrCodeBottom;

  bool get useDoneButtonImage => _useDoneButtonImage;
  String? get doneButtonImagePath => _doneButtonImagePath;
  bool get isDoneButtonImageAsset => _isDoneButtonImageAsset;
  String get doneButtonText => _doneButtonText;
  double get doneButtonWidth => _doneButtonWidth;
  double get doneButtonHeight => _doneButtonHeight;
  double get doneButtonLeft => _doneButtonLeft;
  double get doneButtonBottom => _doneButtonBottom;

  bool get useDownloadButtonImage => _useDownloadButtonImage;
  String? get downloadButtonImagePath => _downloadButtonImagePath;
  bool get isDownloadButtonImageAsset => _isDownloadButtonImageAsset;
  String get downloadButtonText => _downloadButtonText;
  double get downloadButtonWidth => _downloadButtonWidth;
  double get downloadButtonHeight => _downloadButtonHeight;
  double get downloadButtonLeft => _downloadButtonLeft;
  double get downloadButtonBottom => _downloadButtonBottom;

  String? get backgroundImagePath => _backgroundImagePath;
  bool get isBackgroundImageAsset => _isBackgroundImageAsset;
  bool get showBackground => _showBackground;

  // --- Methods ---
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await loadSettings();
  }

  Future<void> loadSettings() async {
    final settingsJson = _prefs.getString('output_screen_settings');
    if (settingsJson != null) {
      final Map<String, dynamic> s = jsonDecode(settingsJson);
      _showTitle = s['showTitle'] ?? _showTitle;
      _titleText = s['titleText'] ?? _titleText;
      _titleFontSize = s['titleFontSize'] ?? _titleFontSize;
      _titleFontWeight =
          FontWeight.values[s['titleFontWeight'] ?? _titleFontWeight.index];
      _titleColor = Color(s['titleColor'] ?? _titleColor.value);
      _titleLeft = s['titleLeft'] ?? _titleLeft;
      _titleTop = s['titleTop'] ?? _titleTop;
      _titleWidth = s['titleWidth'] ?? _titleWidth;

      _aiArtistryLeft = s['aiArtistryLeft'] ?? _aiArtistryLeft;
      _aiArtistryTop = s['aiArtistryTop'] ?? _aiArtistryTop;

      _swaplabLeft = s['swaplabLeft'] ?? _swaplabLeft;
      _swaplabTop = s['swaplabTop'] ?? _swaplabTop;
      _swaplabImageWidth = s['swaplabImageWidth'] ?? _swaplabImageWidth;
      _swaplabImageHeight = s['swaplabImageHeight'] ?? _swaplabImageHeight;

      _qrCodeSize = s['qrCodeSize'] ?? _qrCodeSize;
      _qrCodeLeft = s['qrCodeLeft'] ?? _qrCodeLeft;
      _qrCodeBottom = s['qrCodeBottom'] ?? _qrCodeBottom;

      _useDoneButtonImage = s['useDoneButtonImage'] ?? _useDoneButtonImage;
      _doneButtonImagePath = s['doneButtonImagePath'];
      _isDoneButtonImageAsset =
          s['isDoneButtonImageAsset'] ?? _isDoneButtonImageAsset;
      _doneButtonText = s['doneButtonText'] ?? _doneButtonText;
      _doneButtonWidth = s['doneButtonWidth'] ?? _doneButtonWidth;
      _doneButtonHeight = s['doneButtonHeight'] ?? _doneButtonHeight;
      _doneButtonLeft = s['doneButtonLeft'] ?? _doneButtonLeft;
      _doneButtonBottom = s['doneButtonBottom'] ?? _doneButtonBottom;

      _useDownloadButtonImage =
          s['useDownloadButtonImage'] ?? _useDownloadButtonImage;
      _downloadButtonImagePath = s['downloadButtonImagePath'];
      _isDownloadButtonImageAsset =
          s['isDownloadButtonImageAsset'] ?? _isDownloadButtonImageAsset;
      _downloadButtonText = s['downloadButtonText'] ?? _downloadButtonText;
      _downloadButtonWidth = s['downloadButtonWidth'] ?? _downloadButtonWidth;
      _downloadButtonHeight =
          s['downloadButtonHeight'] ?? _downloadButtonHeight;
      _downloadButtonLeft = s['downloadButtonLeft'] ?? _downloadButtonLeft;
      _downloadButtonBottom =
          s['downloadButtonBottom'] ?? _downloadButtonBottom;

      _backgroundImagePath = s['backgroundImagePath'];
      _isBackgroundImageAsset = s['isBackgroundImageAsset'] ?? true;
      _showBackground = s['showBackground'] ?? _showBackground;
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
      'titleLeft': _titleLeft,
      'titleTop': _titleTop,
      'titleWidth': _titleWidth,
      'aiArtistryLeft': _aiArtistryLeft,
      'aiArtistryTop': _aiArtistryTop,
      'swaplabLeft': _swaplabLeft,
      'swaplabTop': _swaplabTop,
      'swaplabImageWidth': _swaplabImageWidth,
      'swaplabImageHeight': _swaplabImageHeight,
      'qrCodeSize': _qrCodeSize,
      'qrCodeLeft': _qrCodeLeft,
      'qrCodeBottom': _qrCodeBottom,
      'useDoneButtonImage': _useDoneButtonImage,
      'doneButtonImagePath': _doneButtonImagePath,
      'isDoneButtonImageAsset': _isDoneButtonImageAsset,
      'doneButtonText': _doneButtonText,
      'doneButtonWidth': _doneButtonWidth,
      'doneButtonHeight': _doneButtonHeight,
      'doneButtonLeft': _doneButtonLeft,
      'doneButtonBottom': _doneButtonBottom,
      'useDownloadButtonImage': _useDownloadButtonImage,
      'downloadButtonImagePath': _downloadButtonImagePath,
      'isDownloadButtonImageAsset': _isDownloadButtonImageAsset,
      'downloadButtonText': _downloadButtonText,
      'downloadButtonWidth': _downloadButtonWidth,
      'downloadButtonHeight': _downloadButtonHeight,
      'downloadButtonLeft': _downloadButtonLeft,
      'downloadButtonBottom': _downloadButtonBottom,
      'backgroundImagePath': _backgroundImagePath,
      'isBackgroundImageAsset': _isBackgroundImageAsset,
      'showBackground': _showBackground,
    };
    await _prefs.setString('output_screen_settings', jsonEncode(settings));
  }

  // --- Setters ---
  void setShowTitle(bool show) {
    _showTitle = show;
    notifyListeners();
    _saveSettings();
  }

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

  void setTitleColor(Color color) {
    _titleColor = color;
    notifyListeners();
    _saveSettings();
  }

  void setTitleStyle({FontWeight? fontWeight, Color? color}) {
    if (fontWeight != null) _titleFontWeight = fontWeight;
    if (color != null) _titleColor = color;
    notifyListeners();
    _saveSettings();
  }

  void setTitlePosition(double left, double top, double width) {
    _titleLeft = left;
    _titleTop = top;
    _titleWidth = width;
    notifyListeners();
    _saveSettings();
  }

  void setAiArtistryPosition(double left, double top) {
    _aiArtistryLeft = left;
    _aiArtistryTop = top;
    notifyListeners();
    _saveSettings();
  }

  void setSwaplabPosition(double left, double top) {
    _swaplabLeft = left;
    _swaplabTop = top;
    notifyListeners();
    _saveSettings();
  }

  void setSwaplabImageDimensions(double width, double height) {
    _swaplabImageWidth = width;
    _swaplabImageHeight = height;
    notifyListeners();
    _saveSettings();
  }

  void setQrCodeSize(double size) {
    _qrCodeSize = size;
    notifyListeners();
    _saveSettings();
  }

  void setQrCodePosition(double left, double bottom) {
    _qrCodeLeft = left;
    _qrCodeBottom = bottom;
    notifyListeners();
    _saveSettings();
  }

  // Done Button Setters
  void setUseDoneButtonImage(bool use) {
    _useDoneButtonImage = use;
    notifyListeners();
    _saveSettings();
  }

  void setDoneButtonText(String text) {
    _doneButtonText = text;
    notifyListeners();
    _saveSettings();
  }

  void setDoneButtonWidth(double width) {
    _doneButtonWidth = width;
    notifyListeners();
    _saveSettings();
  }

  void setDoneButtonHeight(double height) {
    _doneButtonHeight = height;
    notifyListeners();
    _saveSettings();
  }

  void setDoneButtonPosition(double left, double bottom) {
    _doneButtonLeft = left;
    _doneButtonBottom = bottom;
    notifyListeners();
    _saveSettings();
  }

  Future<void> setDoneButtonImage(String? path) async {
    await _setButtonImage(path, isDone: true);
    _saveSettings();
  }

  // Download Button Setters
  void setUseDownloadButtonImage(bool use) {
    _useDownloadButtonImage = use;
    notifyListeners();
    _saveSettings();
  }

  void setDownloadButtonText(String text) {
    _downloadButtonText = text;
    notifyListeners();
    _saveSettings();
  }

  void setDownloadButtonWidth(double width) {
    _downloadButtonWidth = width;
    notifyListeners();
    _saveSettings();
  }

  void setDownloadButtonHeight(double height) {
    _downloadButtonHeight = height;
    notifyListeners();
    _saveSettings();
  }

  void setDownloadButtonPosition(double left, double bottom) {
    _downloadButtonLeft = left;
    _downloadButtonBottom = bottom;
    notifyListeners();
    _saveSettings();
  }

  Future<void> setDownloadButtonImage(String? path) async {
    await _setButtonImage(path, isDone: false);
    _saveSettings();
  }

  Future<void> _setButtonImage(String? sourcePath,
      {required bool isDone}) async {
    String? imagePath;
    bool isAsset = true;

    if (sourcePath != null) {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final btnType = isDone ? 'done' : 'download';
        final fileName =
            'output_${btnType}_btn_${DateTime.now().millisecondsSinceEpoch}${p.extension(sourcePath)}';
        final destinationPath = p.join(appDir.path, fileName);
        await File(sourcePath).copy(destinationPath);
        imagePath = destinationPath;
        isAsset = false;
      } on Exception catch (e) {
        debugPrint('Error copying button image: $e');
        return;
      }
    }

    if (isDone) {
      _doneButtonImagePath = imagePath;
      _isDoneButtonImageAsset = isAsset;
    } else {
      _downloadButtonImagePath = imagePath;
      _isDownloadButtonImageAsset = isAsset;
    }
    notifyListeners();
  }

  void setShowBackground(bool show) {
    _showBackground = show;
    notifyListeners();
    _saveSettings();
  }

  Future<void> setBackgroundImage(String? path) async {
    if (path == null) {
      _backgroundImagePath = null;
    } else {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName =
            'output_bg_${DateTime.now().millisecondsSinceEpoch}${p.extension(path)}';
        final destinationPath = p.join(appDir.path, fileName);
        await File(path).copy(destinationPath);
        _backgroundImagePath = destinationPath;
        _isBackgroundImageAsset = false;
      } on Exception catch (e) {
        debugPrint('Error copying background image: $e');
        return;
      }
    }
    notifyListeners();
    _saveSettings();
  }
}
