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
  bool _isInitialized = false;

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

  bool _showTitle = true;
  String _titleText = 'Set the scene';
  double _titleFontSize = 80.0;
  FontWeight _titleFontWeight = FontWeight.w700;
  Color _titleColor = AppColors.yellow;
  double _titleTop = 0.26;

  double _carouselTop = 0.3;
  double _carouselHeight = 0.41;
  double _arrowSpacing = 0.08;

  double _cardWidth = 0.25;
  double _cardHeight = 0.33;
  double _cardBorderRadius = 0.0;

  double _card1Scale = 0.9;
  double _card1YOffset = 30;
  double _card1XOffset = -80;

  double _card2Scale = 0.9;
  double _card2YOffset = 30;
  double _card2XOffset = 120;

  bool _useImageButton = true;
  String? _buttonImagePath = 'assets/images/next_btn.png';
  bool _isButtonImageAsset = true;
  double _buttonWidth = 0.45;
  double _buttonHeight = 0.08;
  double _buttonBottom = 0.17;

  bool _showBackground = true;
  String? _backgroundImagePath = 'assets/images/common_bg.png';
  bool _isBackgroundImageAsset = true;

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
  double get card1Scale => _card1Scale;
  double get card1YOffset => _card1YOffset;
  double get card1XOffset => _card1XOffset;
  double get card2Scale => _card2Scale;
  double get card2YOffset => _card2YOffset;
  double get card2XOffset => _card2XOffset;
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

  void setCarouselCardTransforms({
    double? card1Scale,
    double? card1YOffset,
    double? card1XOffset,
    double? card2Scale,
    double? card2YOffset,
    double? card2XOffset,
  }) {
    if (card1Scale != null) _card1Scale = card1Scale;
    if (card1YOffset != null) _card1YOffset = card1YOffset;
    if (card1XOffset != null) _card1XOffset = card1XOffset;
    if (card2Scale != null) _card2Scale = card2Scale;
    if (card2YOffset != null) _card2YOffset = card2YOffset;
    if (card2XOffset != null) _card2XOffset = card2XOffset;
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

  void _saveAndNotify() {
    _saveSettings();
    notifyListeners();
  }

  Future<void> _saveSettings() async {
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

    await _prefs.setDouble('theme_card1Scale', _card1Scale);
    await _prefs.setDouble('theme_card1YOffset', _card1YOffset);
    await _prefs.setDouble('theme_card1XOffset', _card1XOffset);
    await _prefs.setDouble('theme_card2Scale', _card2Scale);
    await _prefs.setDouble('theme_card2YOffset', _card2YOffset);
    await _prefs.setDouble('theme_card2XOffset', _card2XOffset);

    await _prefs.setBool('theme_use_image_button', _useImageButton);
    if (_buttonImagePath != null) {
      await _prefs.setString('theme_button_image_path', _buttonImagePath!);
    }
    await _prefs.setBool('theme_is_button_image_asset', _isButtonImageAsset);
    await _prefs.setDouble('theme_buttonWidth', _buttonWidth);
    await _prefs.setDouble('theme_buttonHeight', _buttonHeight);
    await _prefs.setDouble('theme_buttonBottom', _buttonBottom);

    await _prefs.setBool('theme_show_background', _showBackground);
    if (_backgroundImagePath != null) {
      await _prefs.setString(
          'theme_background_image_path', _backgroundImagePath!);
    }
    await _prefs.setBool(
        'theme_is_background_image_asset', _isBackgroundImageAsset);
  }

  Future<void> _loadSettings() async {
    const double refWidth = 1080.0;
    const double refHeight = 1920.0;

    double toPercent(String key, double defaultValue, double reference) {
      double val = _prefs.getDouble(key) ?? defaultValue;
      return val > 1.0 ? val / reference : val;
    }

    _showTitle = _prefs.getBool('theme_showTitle') ?? _showTitle;
    _titleText = _prefs.getString('theme_titleText') ?? _titleText;
    _titleFontSize = _prefs.getDouble('theme_titleFontSize') ?? _titleFontSize;
    _titleFontWeight = FontWeight.values[
        _prefs.getInt('theme_titleFontWeight') ?? _titleFontWeight.index];
    _titleColor = Color(_prefs.getInt('theme_titleColor') ?? _titleColor.value);

    _titleTop = toPercent('theme_titleTop', _titleTop, refHeight);
    _carouselTop = toPercent('theme_carouselTop', _carouselTop, refHeight);
    _carouselHeight =
        toPercent('theme_carouselHeight', _carouselHeight, refHeight);
    _arrowSpacing = toPercent('theme_arrowSpacing', _arrowSpacing, refWidth);
    _cardWidth = toPercent('theme_cardWidth', _cardWidth, refWidth);
    _cardHeight = toPercent('theme_cardHeight', _cardHeight, refHeight);
    _buttonWidth = toPercent('theme_buttonWidth', _buttonWidth, refWidth);
    _buttonHeight = toPercent('theme_buttonHeight', _buttonHeight, refHeight);
    _buttonBottom = toPercent('theme_buttonBottom', _buttonBottom, refHeight);
    _cardBorderRadius =
        _prefs.getDouble('theme_cardBorderRadius') ?? _cardBorderRadius;

    _card1Scale = _prefs.getDouble('theme_card1Scale') ?? _card1Scale;
    _card1YOffset = _prefs.getDouble('theme_card1YOffset') ?? _card1YOffset;
    _card1XOffset = _prefs.getDouble('theme_card1XOffset') ?? _card1XOffset;
    _card2Scale = _prefs.getDouble('theme_card2Scale') ?? _card2Scale;
    _card2YOffset = _prefs.getDouble('theme_card2YOffset') ?? _card2YOffset;
    _card2XOffset = _prefs.getDouble('theme_card2XOffset') ?? _card2XOffset;

    _useImageButton =
        _prefs.getBool('theme_use_image_button') ?? _useImageButton;
    _buttonImagePath =
        _prefs.getString('theme_button_image_path') ?? _buttonImagePath;
    _isButtonImageAsset =
        _prefs.getBool('theme_is_button_image_asset') ?? _isButtonImageAsset;
    _showBackground =
        _prefs.getBool('theme_show_background') ?? _showBackground;
    _backgroundImagePath = _prefs.getString('theme_background_image_path');
    _isBackgroundImageAsset =
        _prefs.getBool('theme_is_background_image_asset') ??
            _isBackgroundImageAsset;

    notifyListeners();
  }
}
