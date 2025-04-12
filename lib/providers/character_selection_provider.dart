import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CharacterSelectionProvider extends ChangeNotifier {
  // Title settings
  String _titleText = 'Select Your Character';
  double _titleFontSize = 40.0;
  Color _titleColor = Colors.white;
  FontWeight _titleFontWeight = FontWeight.bold;
  double _titlePadding = 20.0;

  // Character settings
  List<CharacterModel> _maleCharacters = [
    CharacterModel(
      id: 'm1',
      imagePath: 'assets/characters/m1.png',
      isAsset: true,
    ),
    CharacterModel(
      id: 'm2',
      imagePath: 'assets/characters/m2.png',
      isAsset: true,
    ),
    CharacterModel(
      id: 'm3',
      imagePath: 'assets/characters/m3.png',
      isAsset: true,
    ),
    CharacterModel(
      id: 'm4',
      imagePath: 'assets/characters/m4.png',
      isAsset: true,
    ),
  ];

  List<CharacterModel> _femaleCharacters = [
    CharacterModel(
      id: 'f1',
      imagePath: 'assets/characters/f1.png',
      isAsset: true,
    ),
    CharacterModel(
      id: 'f2',
      imagePath: 'assets/characters/f2.png',
      isAsset: true,
    ),
    CharacterModel(
      id: 'f3',
      imagePath: 'assets/characters/f3.png',
      isAsset: true,
    ),
    CharacterModel(
      id: 'f4',
      imagePath: 'assets/characters/f4.png',
      isAsset: true,
    ),
  ];

  // Character display settings
  double _characterWidth = 250.0;
  double _characterHeight = 300.0;
  double _characterSpacing = 20.0;
  double _characterBorderRadius = 20.0;
  bool _showCharacterBorder = true;
  double _characterBorderWidth = 3.0;
  Color _characterBorderColor = const Color(0xFFFFD700); // Golden yellow

  // Selection effect settings
  bool _useSelectionEffect = true;
  double _selectedCharacterScale = 1.1;
  bool _useSelectionGlow = true;
  Color _selectionGlowColor = Colors.white;
  double _selectionGlowIntensity = 0.7;
  double _selectionGlowSpread = 10.0;

  // Carousel settings
  bool _useCarousel = true;
  double _carouselVisibleWidth = 0.5; // Percentage of side character visible

  // Button settings
  String _buttonText = 'Next';
  double _buttonWidth = 200.0;
  double _buttonHeight = 50.0;
  double _buttonFontSize = 18.0;
  Color _buttonColor = const Color(0xFFFFD700);
  Color _buttonTextColor = Colors.black;
  double _buttonBorderRadius = 10.0;
  bool _buttonHasBorder = false;
  double _buttonBorderWidth = 1.0;
  Color _buttonBorderColor = Colors.black;
  double _buttonMarginTop = 30.0;
  bool _useImageButton = false;
  String? _buttonImagePath;
  bool _isButtonImageAsset = true;

  // Layout settings
  double _screenPadding = 20.0;
  bool _showBackground = true;
  String? _backgroundImagePath;
  bool _isBackgroundImageAsset = true;

  // Getters
  String get titleText => _titleText;
  double get titleFontSize => _titleFontSize;
  Color get titleColor => _titleColor;
  FontWeight get titleFontWeight => _titleFontWeight;
  double get titlePadding => _titlePadding;

  List<CharacterModel> get maleCharacters => _maleCharacters;
  List<CharacterModel> get femaleCharacters => _femaleCharacters;
  double get characterWidth => _characterWidth;
  double get characterHeight => _characterHeight;
  double get characterSpacing => _characterSpacing;
  double get characterBorderRadius => _characterBorderRadius;
  double get characterBorderWidth => _characterBorderWidth;
  Color get characterBorderColor => _characterBorderColor;
  bool get showCharacterBorder => _showCharacterBorder;

  bool get useSelectionEffect => _useSelectionEffect;
  double get selectedCharacterScale => _selectedCharacterScale;
  bool get useSelectionGlow => _useSelectionGlow;
  Color get selectionGlowColor => _selectionGlowColor;
  double get selectionGlowIntensity => _selectionGlowIntensity;
  double get selectionGlowSpread => _selectionGlowSpread;

  bool get useCarousel => _useCarousel;
  double get carouselVisibleWidth => _carouselVisibleWidth;

  String get buttonText => _buttonText;
  double get buttonWidth => _buttonWidth;
  double get buttonHeight => _buttonHeight;
  double get buttonFontSize => _buttonFontSize;
  Color get buttonColor => _buttonColor;
  Color get buttonTextColor => _buttonTextColor;
  double get buttonBorderRadius => _buttonBorderRadius;
  bool get buttonHasBorder => _buttonHasBorder;
  double get buttonBorderWidth => _buttonBorderWidth;
  Color get buttonBorderColor => _buttonBorderColor;
  double get buttonMarginTop => _buttonMarginTop;
  bool get useImageButton => _useImageButton;
  String? get buttonImagePath => _buttonImagePath;
  bool get isButtonImageAsset => _isButtonImageAsset;

  double get screenPadding => _screenPadding;
  bool get showBackground => _showBackground;
  String? get backgroundImagePath => _backgroundImagePath;
  bool get isBackgroundImageAsset => _isBackgroundImageAsset;

  // Setters
  void setTitleText(String text) {
    _titleText = text;
    notifyListeners();
    _saveSettings();
  }

  void setTitleStyle({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? padding,
  }) {
    if (fontSize != null) _titleFontSize = fontSize;
    if (color != null) _titleColor = color;
    if (fontWeight != null) _titleFontWeight = fontWeight;
    if (padding != null) _titlePadding = padding;
    notifyListeners();
    _saveSettings();
  }

  void addMaleCharacter(String imagePath, {required bool isAsset}) {
    final id = 'm${_maleCharacters.length + 1}';
    _maleCharacters.add(CharacterModel(
      id: id,
      imagePath: imagePath,
      isAsset: isAsset,
    ));
    notifyListeners();
    _saveSettings();
  }

  void addFemaleCharacter(String imagePath, {required bool isAsset}) {
    final id = 'f${_femaleCharacters.length + 1}';
    _femaleCharacters.add(CharacterModel(
      id: id,
      imagePath: imagePath,
      isAsset: isAsset,
    ));
    notifyListeners();
    _saveSettings();
  }

  void removeMaleCharacter(String id) {
    _maleCharacters.removeWhere((character) => character.id == id);
    notifyListeners();
    _saveSettings();
  }

  void removeFemaleCharacter(String id) {
    _femaleCharacters.removeWhere((character) => character.id == id);
    notifyListeners();
    _saveSettings();
  }

  void updateMaleCharacter(String id, String imagePath,
      {required bool isAsset}) {
    final index = _maleCharacters.indexWhere((character) => character.id == id);
    if (index != -1) {
      _maleCharacters[index] = CharacterModel(
        id: id,
        imagePath: imagePath,
        isAsset: isAsset,
      );
      notifyListeners();
      _saveSettings();
    }
  }

  void updateFemaleCharacter(String id, String imagePath,
      {required bool isAsset}) {
    final index =
        _femaleCharacters.indexWhere((character) => character.id == id);
    if (index != -1) {
      _femaleCharacters[index] = CharacterModel(
        id: id,
        imagePath: imagePath,
        isAsset: isAsset,
      );
      notifyListeners();
      _saveSettings();
    }
  }

  void setCharacterDimensions(double width, double height) {
    _characterWidth = width;
    _characterHeight = height;
    notifyListeners();
    _saveSettings();
  }

  void setCharacterSpacing(double spacing) {
    _characterSpacing = spacing;
    notifyListeners();
    _saveSettings();
  }

  void setCharacterBorder({
    double? borderRadius,
    bool? showBorder,
    double? borderWidth,
    Color? borderColor,
  }) {
    if (borderRadius != null) _characterBorderRadius = borderRadius;
    if (showBorder != null) _showCharacterBorder = showBorder;
    if (borderWidth != null) _characterBorderWidth = borderWidth;
    if (borderColor != null) _characterBorderColor = borderColor;
    notifyListeners();
    _saveSettings();
  }

  void setSelectionEffect({
    bool? useEffect,
    double? scale,
    bool? useGlow,
    Color? glowColor,
    double? glowIntensity,
    double? glowSpread,
  }) {
    if (useEffect != null) _useSelectionEffect = useEffect;
    if (scale != null) _selectedCharacterScale = scale;
    if (useGlow != null) _useSelectionGlow = useGlow;
    if (glowColor != null) _selectionGlowColor = glowColor;
    if (glowIntensity != null) _selectionGlowIntensity = glowIntensity;
    if (glowSpread != null) _selectionGlowSpread = glowSpread;
    notifyListeners();
    _saveSettings();
  }

  void setCarouselSettings({
    bool? useCarousel,
    double? visibleWidth,
  }) {
    if (useCarousel != null) _useCarousel = useCarousel;
    if (visibleWidth != null) _carouselVisibleWidth = visibleWidth;
    notifyListeners();
    _saveSettings();
  }

  void setButtonText(String text) {
    _buttonText = text;
    notifyListeners();
    _saveSettings();
  }

  void setButtonDimensions(double width, double height) {
    _buttonWidth = width;
    _buttonHeight = height;
    notifyListeners();
    _saveSettings();
  }

  void setButtonStyle({
    double? fontSize,
    Color? buttonColor,
    Color? textColor,
    double? borderRadius,
  }) {
    if (fontSize != null) _buttonFontSize = fontSize;
    if (buttonColor != null) _buttonColor = buttonColor;
    if (textColor != null) _buttonTextColor = textColor;
    if (borderRadius != null) _buttonBorderRadius = borderRadius;
    notifyListeners();
    _saveSettings();
  }

  void setButtonBorder({
    bool? hasBorder,
    double? borderWidth,
    Color? borderColor,
  }) {
    if (hasBorder != null) _buttonHasBorder = hasBorder;
    if (borderWidth != null) _buttonBorderWidth = borderWidth;
    if (borderColor != null) _buttonBorderColor = borderColor;
    notifyListeners();
    _saveSettings();
  }

  void setButtonMarginTop(double margin) {
    _buttonMarginTop = margin;
    notifyListeners();
    _saveSettings();
  }

  void setUseImageButton(bool useImage) {
    _useImageButton = useImage;
    notifyListeners();
    _saveSettings();
  }

  void setButtonImage(String? path, {bool isAsset = true}) {
    _buttonImagePath = path;
    _isButtonImageAsset = isAsset;
    notifyListeners();
    _saveSettings();
  }

  void setScreenPadding(double padding) {
    _screenPadding = padding;
    notifyListeners();
    _saveSettings();
  }

  void setShowBackground(bool show) {
    _showBackground = show;
    notifyListeners();
    _saveSettings();
  }

  void setBackgroundImage(String? path, {required bool isAsset}) {
    _backgroundImagePath = path;
    _isBackgroundImageAsset = isAsset;
    notifyListeners();
    _saveSettings();
  }

  // Initialize provider from SharedPreferences
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('character_selection_settings');

    if (settingsJson != null) {
      final Map<String, dynamic> settings = jsonDecode(settingsJson);

      // Title settings
      _titleText = settings['titleText'] ?? _titleText;
      _titleFontSize = settings['titleFontSize'] ?? _titleFontSize;
      _titleColor = Color(settings['titleColor'] ?? _titleColor.value);
      _titleFontWeight = FontWeight
          .values[settings['titleFontWeight'] ?? _titleFontWeight.index];
      _titlePadding = settings['titlePadding'] ?? _titlePadding;

      // Character settings
      if (settings['maleCharacters'] != null) {
        _maleCharacters = List<CharacterModel>.from(
          (settings['maleCharacters'] as List).map(
            (x) => CharacterModel.fromJson(x),
          ),
        );
      }

      if (settings['femaleCharacters'] != null) {
        _femaleCharacters = List<CharacterModel>.from(
          (settings['femaleCharacters'] as List).map(
            (x) => CharacterModel.fromJson(x),
          ),
        );
      }

      // Character display settings
      _characterWidth = settings['characterWidth'] ?? _characterWidth;
      _characterHeight = settings['characterHeight'] ?? _characterHeight;
      _characterSpacing = settings['characterSpacing'] ?? _characterSpacing;
      _characterBorderRadius =
          settings['characterBorderRadius'] ?? _characterBorderRadius;
      _showCharacterBorder =
          settings['showCharacterBorder'] ?? _showCharacterBorder;
      _characterBorderWidth =
          settings['characterBorderWidth'] ?? _characterBorderWidth;
      _characterBorderColor = Color(
          settings['characterBorderColor'] ?? _characterBorderColor.value);

      // Selection effect settings
      _useSelectionEffect =
          settings['useSelectionEffect'] ?? _useSelectionEffect;
      _selectedCharacterScale =
          settings['selectedCharacterScale'] ?? _selectedCharacterScale;
      _useSelectionGlow = settings['useSelectionGlow'] ?? _useSelectionGlow;
      _selectionGlowColor =
          Color(settings['selectionGlowColor'] ?? _selectionGlowColor.value);
      _selectionGlowIntensity =
          settings['selectionGlowIntensity'] ?? _selectionGlowIntensity;
      _selectionGlowSpread =
          settings['selectionGlowSpread'] ?? _selectionGlowSpread;

      // Carousel settings
      _useCarousel = settings['useCarousel'] ?? _useCarousel;
      _carouselVisibleWidth =
          settings['carouselVisibleWidth'] ?? _carouselVisibleWidth;

      // Button settings
      _buttonText = settings['buttonText'] ?? _buttonText;
      _buttonWidth = settings['buttonWidth'] ?? _buttonWidth;
      _buttonHeight = settings['buttonHeight'] ?? _buttonHeight;
      _buttonFontSize = settings['buttonFontSize'] ?? _buttonFontSize;
      _buttonColor = Color(settings['buttonColor'] ?? _buttonColor.value);
      _buttonTextColor =
          Color(settings['buttonTextColor'] ?? _buttonTextColor.value);
      _buttonBorderRadius =
          settings['buttonBorderRadius'] ?? _buttonBorderRadius;
      _buttonHasBorder = settings['buttonHasBorder'] ?? _buttonHasBorder;
      _buttonBorderWidth = settings['buttonBorderWidth'] ?? _buttonBorderWidth;
      _buttonBorderColor =
          Color(settings['buttonBorderColor'] ?? _buttonBorderColor.value);
      _buttonMarginTop = settings['buttonMarginTop'] ?? _buttonMarginTop;
      _useImageButton = settings['useImageButton'] ?? _useImageButton;
      _buttonImagePath = settings['buttonImagePath'];
      _isButtonImageAsset =
          settings['isButtonImageAsset'] ?? _isButtonImageAsset;

      // Layout settings
      _screenPadding = settings['screenPadding'] ?? _screenPadding;
      _showBackground = settings['showBackground'] ?? _showBackground;
      _backgroundImagePath = settings['backgroundImagePath'];
      _isBackgroundImageAsset =
          settings['isBackgroundImageAsset'] ?? _isBackgroundImageAsset;
    }

    notifyListeners();
  }

  // Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final Map<String, dynamic> settings = {
      // Title settings
      'titleText': _titleText,
      'titleFontSize': _titleFontSize,
      'titleColor': _titleColor.value,
      'titleFontWeight': _titleFontWeight.index,
      'titlePadding': _titlePadding,

      // Character settings
      'maleCharacters': _maleCharacters.map((e) => e.toJson()).toList(),
      'femaleCharacters': _femaleCharacters.map((e) => e.toJson()).toList(),

      // Character display settings
      'characterWidth': _characterWidth,
      'characterHeight': _characterHeight,
      'characterSpacing': _characterSpacing,
      'characterBorderRadius': _characterBorderRadius,
      'showCharacterBorder': _showCharacterBorder,
      'characterBorderWidth': _characterBorderWidth,
      'characterBorderColor': _characterBorderColor.value,

      // Selection effect settings
      'useSelectionEffect': _useSelectionEffect,
      'selectedCharacterScale': _selectedCharacterScale,
      'useSelectionGlow': _useSelectionGlow,
      'selectionGlowColor': _selectionGlowColor.value,
      'selectionGlowIntensity': _selectionGlowIntensity,
      'selectionGlowSpread': _selectionGlowSpread,

      // Carousel settings
      'useCarousel': _useCarousel,
      'carouselVisibleWidth': _carouselVisibleWidth,

      // Button settings
      'buttonText': _buttonText,
      'buttonWidth': _buttonWidth,
      'buttonHeight': _buttonHeight,
      'buttonFontSize': _buttonFontSize,
      'buttonColor': _buttonColor.value,
      'buttonTextColor': _buttonTextColor.value,
      'buttonBorderRadius': _buttonBorderRadius,
      'buttonHasBorder': _buttonHasBorder,
      'buttonBorderWidth': _buttonBorderWidth,
      'buttonBorderColor': _buttonBorderColor.value,
      'buttonMarginTop': _buttonMarginTop,
      'useImageButton': _useImageButton,
      'buttonImagePath': _buttonImagePath,
      'isButtonImageAsset': _isButtonImageAsset,

      // Layout settings
      'screenPadding': _screenPadding,
      'showBackground': _showBackground,
      'backgroundImagePath': _backgroundImagePath,
      'isBackgroundImageAsset': _isBackgroundImageAsset,
    };

    await prefs.setString('character_selection_settings', jsonEncode(settings));
  }
}

class CharacterModel {
  final String id;
  final String imagePath;
  final bool isAsset;

  CharacterModel({
    required this.id,
    required this.imagePath,
    required this.isAsset,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    return CharacterModel(
      id: json['id'],
      imagePath: json['imagePath'],
      isAsset: json['isAsset'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'isAsset': isAsset,
    };
  }
}
