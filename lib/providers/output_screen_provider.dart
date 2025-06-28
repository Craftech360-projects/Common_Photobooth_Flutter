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

  // AI Artistry Image (Defaults for a 500x500 image on a 1080px screen)
  double _aiArtistryLeft = 290.0; // (1080 - 500) / 2
  double _aiArtistryTop = 710.0; // (1920 - 500) / 2

  // Swaplab Image (Defaults for a 600x900 image on a 1080px screen)
  double _swaplabLeft = 240.0; // (1080 - 600) / 2
  double _swaplabTop = 510.0; // (1920 - 900) / 2
  double _swaplabImageWidth = 600.0;
  double _swaplabImageHeight = 900.0;
  
  // NEW: Image border properties
  bool _showImageBorder = false;
  double _imageBorderRadius = 15.0;
  double _imageBorderWidth = 5.0;
  Color _imageBorderColor = Colors.white;

  // QR Code
  double _qrCodeSize = 200.0;
  double _qrCodeLeft = 150.0, _qrCodeBottom = 100.0;

  // "Done" button is now the only button
  bool _useDoneButtonImage = true;
  String? _doneButtonImagePath = 'assets/images/home_btn.png';
  bool _isDoneButtonImageAsset = true;
  String _doneButtonText = 'Done';
  double _doneButtonWidth = 350.0;
  double _doneButtonHeight = 180.0;
  // NEW: Centered horizontally by default
  double _doneButtonLeft = 365.0; // (1080 - 350) / 2
  double _doneButtonBottom = 100.0;

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

  bool get showImageBorder => _showImageBorder;
  double get imageBorderRadius => _imageBorderRadius;
  double get imageBorderWidth => _imageBorderWidth;
  Color get imageBorderColor => _imageBorderColor;

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
  
  String? get backgroundImagePath => _backgroundImagePath;
  bool get isBackgroundImageAsset => _isBackgroundImageAsset;
  bool get showBackground => _showBackground;

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
      
      _showImageBorder = s['showImageBorder'] ?? _showImageBorder;
      _imageBorderRadius = s['imageBorderRadius'] ?? _imageBorderRadius;
      _imageBorderWidth = s['imageBorderWidth'] ?? _imageBorderWidth;
      _imageBorderColor = Color(s['imageBorderColor'] ?? _imageBorderColor.value);

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
      'showImageBorder': _showImageBorder,
      'imageBorderRadius': _imageBorderRadius,
      'imageBorderWidth': _imageBorderWidth,
      'imageBorderColor': _imageBorderColor.value,
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
      'backgroundImagePath': _backgroundImagePath,
      'isBackgroundImageAsset': _isBackgroundImageAsset,
      'showBackground': _showBackground,
    };
    await _prefs.setString('output_screen_settings', jsonEncode(settings));
  }
  
  void _notifyAndSave() {
    notifyListeners();
    _saveSettings();
  }

  // --- Setters ---
  void setShowTitle(bool show) { _showTitle = show; _notifyAndSave(); }
  void setTitleText(String text) { _titleText = text; _notifyAndSave(); }
  void setTitleFontSize(double size) { _titleFontSize = size; _notifyAndSave(); }
  void setTitleColor(Color color) { _titleColor = color; _notifyAndSave(); }
  
  void setTitlePosition(double left, double top, double width) {
    _titleLeft = left; _titleTop = top; _titleWidth = width;
    _notifyAndSave();
  }

  void setAiArtistryPosition(double left, double top) {
    _aiArtistryLeft = left; _aiArtistryTop = top;
    _notifyAndSave();
  }

  void setSwaplabPosition(double left, double top) {
    _swaplabLeft = left; _swaplabTop = top;
    _notifyAndSave();
  }

  void setSwaplabImageDimensions(double width, double height) {
    _swaplabImageWidth = width; _swaplabImageHeight = height;
    _notifyAndSave();
  }
  
  void setShowImageBorder(bool show) { _showImageBorder = show; _notifyAndSave(); }
  void setImageBorderRadius(double radius) { _imageBorderRadius = radius; _notifyAndSave(); }
  void setImageBorderWidth(double width) { _imageBorderWidth = width; _notifyAndSave(); }
  void setImageBorderColor(Color color) { _imageBorderColor = color; _notifyAndSave(); }

  void setQrCodeSize(double size) { _qrCodeSize = size; _notifyAndSave(); }
  void setQrCodePosition(double left, double bottom) {
    _qrCodeLeft = left; _qrCodeBottom = bottom;
    _notifyAndSave();
  }

  // Done Button Setters
  void setUseDoneButtonImage(bool use) { _useDoneButtonImage = use; _notifyAndSave(); }
  void setDoneButtonText(String text) { _doneButtonText = text; _notifyAndSave(); }
  void setDoneButtonWidth(double width) { _doneButtonWidth = width; _notifyAndSave(); }
  void setDoneButtonHeight(double height) { _doneButtonHeight = height; _notifyAndSave(); }
  
  void setDoneButtonPosition(double left, double bottom) {
    _doneButtonLeft = left; _doneButtonBottom = bottom;
    _notifyAndSave();
  }

  Future<void> setDoneButtonImage(String? path) async {
    await _setButtonImage(path);
    _saveSettings();
  }

  Future<void> _setButtonImage(String? sourcePath) async {
    String? imagePath;
    bool isAsset = true;

    if (sourcePath != null) {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'output_done_btn_${DateTime.now().millisecondsSinceEpoch}${p.extension(sourcePath)}';
        final destinationPath = p.join(appDir.path, fileName);
        await File(sourcePath).copy(destinationPath);
        imagePath = destinationPath;
        isAsset = false;
      } catch (e) {
        debugPrint('Error copying button image: $e');
        return;
      }
    }

    _doneButtonImagePath = imagePath;
    _isDoneButtonImageAsset = isAsset;
    notifyListeners();
  }

  void setShowBackground(bool show) { _showBackground = show; _notifyAndSave(); }

  Future<void> setBackgroundImage(String? path) async {
    if (path == null) {
      _backgroundImagePath = null;
    } else {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'output_bg_${DateTime.now().millisecondsSinceEpoch}${p.extension(path)}';
        final destinationPath = p.join(appDir.path, fileName);
        await File(path).copy(destinationPath);
        _backgroundImagePath = destinationPath;
        _isBackgroundImageAsset = false;
      } catch (e) {
        debugPrint('Error copying background image: $e');
        return;
      }
    }
    _notifyAndSave();
  }
}