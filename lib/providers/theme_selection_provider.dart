import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Theme {
  final String name;
  final String imagePath;
  Theme({required this.name, required this.imagePath});
}

class ThemeSelectionProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isInitialized = false; // Flag to check if init() has completed

  final List<Theme> _themes = [
    Theme(
        name: 'Stranger Things',
        imagePath: 'assets/characters/stranger_things.png'),
    Theme(
        name: 'Jurassic Rebirth',
        imagePath: 'assets/characters/jurassic_rebirth.png'),
    Theme(
        name: 'Final Destination',
        imagePath: 'assets/characters/final_destination.png'),
    Theme(name: 'Superheroes', imagePath: 'assets/characters/superheroes.png'),
    Theme(
        name: 'Supervillains',
        imagePath: 'assets/characters/supervillains.png'),
  ];

  // Title
  bool _showTitle = true;
  String _titleText = 'Set the scene';
  double _titleFontSize = 80.0;
  FontWeight _titleFontWeight = FontWeight.w700;
  Color _titleColor = AppColors.yellow;
  double _titleTop = 505.0;

  // Carousel
  double _carouselTop = 570.0;
  double _carouselHeight = 795.0;
  double _arrowSpacing = 100.0;

  // Cards
  double _cardWidth = 548.0;
  double _cardHeight = 640.0;
  double _cardBorderRadius = 0.0;

  // Button
  bool _useImageButton = true;
  String? _buttonImagePath = 'assets/images/next_btn.png';
  bool _isButtonImageAsset = true;
  double _buttonWidth = 585.0;
  double _buttonHeight = 150.0;
  double _buttonBottom = 395.0;

  // Background
  bool _showBackground = true;
  String? _backgroundImagePath = 'assets/images/common_bg.png';
  bool _isBackgroundImageAsset = true;

  // --- Getters ---
  List<Theme> get themes => _themes;
  bool get showTitle => _showTitle;
  String get titleText => _titleText;
  double get titleFontSize => _titleFontSize;
  FontWeight get titleFontWeight => _titleFontWeight;
  Color get titleColor => _titleColor;
  double get titleTop => _titleTop;
  double get carouselTop => _carouselTop;
  double get carouselHeight => _carouselHeight;
  double get arrowSpacing => _arrowSpacing;
  double get cardWidth => _cardWidth;
  double get cardHeight => _cardHeight;
  double get cardBorderRadius => _cardBorderRadius;
  bool get useImageButton => _useImageButton;
  String? get buttonImagePath => _buttonImagePath;
  bool get isButtonImageAsset => _isButtonImageAsset;
  double get buttonWidth => _buttonWidth;
  double get buttonHeight => _buttonHeight;
  double get buttonBottom => _buttonBottom;
  bool get showBackground => _showBackground;
  String? get backgroundImagePath => _backgroundImagePath;
  bool get isBackgroundImageAsset => _isBackgroundImageAsset;

  Future<void> init() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
    _isInitialized = true;
  }

  // --- Setters ---
  void setShowTitle(bool value) {
    _showTitle = value;
    _saveAndNotify();
  }

  void setTitleText(String value) {
    _titleText = value;
    _saveAndNotify();
  }

  void setTitleFontSize(double value) {
    _titleFontSize = value;
    _saveAndNotify();
  }

  void setTitleFontWeight(FontWeight value) {
    _titleFontWeight = value;
    _saveAndNotify();
  }

  void setTitleColor(Color value) {
    _titleColor = value;
    _saveAndNotify();
  }

  void setTitleTop(double value) {
    _titleTop = value;
    _saveAndNotify();
  }

  void setCarouselTop(double value) {
    _carouselTop = value;
    _saveAndNotify();
  }

  void setCarouselHeight(double value) {
    _carouselHeight = value;
    _saveAndNotify();
  }

  void setArrowSpacing(double value) {
    _arrowSpacing = value;
    _saveAndNotify();
  }

  void setCardWidth(double value) {
    _cardWidth = value;
    _saveAndNotify();
  }

  void setCardHeight(double value) {
    _cardHeight = value;
    _saveAndNotify();
  }

  void setCardBorderRadius(double value) {
    _cardBorderRadius = value;
    _saveAndNotify();
  }

  void setUseImageButton(bool value) {
    _useImageButton = value;
    _saveAndNotify();
  }

  void setButtonWidth(double value) {
    _buttonWidth = value;
    _saveAndNotify();
  }

  void setButtonHeight(double value) {
    _buttonHeight = value;
    _saveAndNotify();
  }

  void setButtonBottom(double value) {
    _buttonBottom = value;
    _saveAndNotify();
  }

  void setShowBackground(bool value) {
    _showBackground = value;
    _saveAndNotify();
  }

  Future<void> setButtonImage(String? sourcePath, {bool isAsset = true}) async {
    await _setImage(sourcePath, isAsset, (p, a) {
      _buttonImagePath = p;
      _isButtonImageAsset = a;
    });
  }

  Future<void> setBackgroundImage(String? sourcePath,
      {required bool isAsset}) async {
    await _setImage(sourcePath, isAsset, (p, a) {
      _backgroundImagePath = p;
      _isBackgroundImageAsset = a;
    });
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
            'theme_${DateTime.now().millisecondsSinceEpoch}${path.extension(sourcePath)}';
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

  // --- Persistence ---
  void _saveAndNotify() {
    _saveSettings();
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    // FIX: Add a guard clause to prevent saving before initialization is complete.
    if (!_isInitialized) return;

    await _prefs.setBool('theme_showTitle', _showTitle);
    await _prefs.setString('theme_titleText', _titleText);
    await _prefs.setDouble('theme_titleFontSize', _titleFontSize);
    await _prefs.setInt('theme_titleFontWeight', _titleFontWeight.index);
    await _prefs.setInt('theme_titleColor', _titleColor.value);
    await _prefs.setDouble('theme_titleTop', _titleTop);
    await _prefs.setDouble('theme_carouselTop', _carouselTop);
    await _prefs.setDouble('theme_carouselHeight', _carouselHeight);
    await _prefs.setDouble('theme_arrowSpacing', _arrowSpacing);
    await _prefs.setDouble('theme_cardWidth', _cardWidth);
    await _prefs.setDouble('theme_cardHeight', _cardHeight);
    await _prefs.setDouble('theme_cardBorderRadius', _cardBorderRadius);
    await _prefs.setDouble('theme_buttonWidth', _buttonWidth);
    await _prefs.setDouble('theme_buttonHeight', _buttonHeight);
    await _prefs.setDouble('theme_buttonBottom', _buttonBottom);
    await _prefs.setBool('theme_use_image_button', _useImageButton);
    await _prefs.setString('theme_button_image_path', _buttonImagePath ?? '');
    await _prefs.setBool('theme_is_button_image_asset', _isButtonImageAsset);
    await _prefs.setBool('theme_show_background', _showBackground);
    await _prefs.setString(
        'theme_background_image_path', _backgroundImagePath ?? '');
    await _prefs.setBool(
        'theme_is_background_image_asset', _isBackgroundImageAsset);
  }

  Future<void> _loadSettings() async {
    _showTitle = _prefs.getBool('theme_showTitle') ?? _showTitle;
    _titleText = _prefs.getString('theme_titleText') ?? _titleText;
    _titleFontSize = _prefs.getDouble('theme_titleFontSize') ?? _titleFontSize;
    _titleFontWeight = FontWeight.values[
        _prefs.getInt('theme_titleFontWeight') ?? _titleFontWeight.index];
    _titleColor = Color(_prefs.getInt('theme_titleColor') ?? _titleColor.value);
    _titleTop = _prefs.getDouble('theme_titleTop') ?? _titleTop;
    _carouselTop = _prefs.getDouble('theme_carouselTop') ?? _carouselTop;
    _carouselHeight =
        _prefs.getDouble('theme_carouselHeight') ?? _carouselHeight;
    _arrowSpacing = _prefs.getDouble('theme_arrowSpacing') ?? _arrowSpacing;
    _cardWidth = _prefs.getDouble('theme_cardWidth') ?? _cardWidth;
    _cardHeight = _prefs.getDouble('theme_cardHeight') ?? _cardHeight;
    _cardBorderRadius =
        _prefs.getDouble('theme_cardBorderRadius') ?? _cardBorderRadius;
    _buttonWidth = _prefs.getDouble('theme_buttonWidth') ?? _buttonWidth;
    _buttonHeight = _prefs.getDouble('theme_buttonHeight') ?? _buttonHeight;
    _buttonBottom = _prefs.getDouble('theme_buttonBottom') ?? _buttonBottom;
    _useImageButton =
        _prefs.getBool('theme_use_image_button') ?? _useImageButton;
    _buttonImagePath =
        _prefs.getString('theme_button_image_path') ?? _buttonImagePath;
    _isButtonImageAsset =
        _prefs.getBool('theme_is_button_image_asset') ?? _isButtonImageAsset;
    _showBackground =
        _prefs.getBool('theme_show_background') ?? _showBackground;
    _backgroundImagePath =
        _prefs.getString('theme_background_image_path') ?? _backgroundImagePath;
    _isBackgroundImageAsset =
        _prefs.getBool('theme_is_background_image_asset') ??
            _isBackgroundImageAsset;
    notifyListeners();
  }
}
