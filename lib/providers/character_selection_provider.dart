import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CharacterSelectionProvider extends ChangeNotifier {
  // Title settings
  String _titleText = 'Select Your Character';
  double _titleFontSize = 22.0;
  Color _titleColor = AppColors.white;
  FontWeight _titleFontWeight = FontWeight.w500;
  // New title properties
  double _titleLineHeight = 1.0;
  bool _titleItalic = false;
  double _titleOpacity = 1.0;
  TextAlign _titleAlignment = TextAlign.center;
  double _titleLeft = 390.0;
  double _titleTop = 685.0;
  double _titleWidth = 300.0;

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
  double _characterHeight = 375.0;
  double _characterSpacing = 0.0;
  double _characterBorderRadius = 6.0;
  bool _showCharacterBorder = false;
  double _characterBorderWidth = 2.0;
  Color _characterBorderColor = AppColors.yellow;

  // Selection effect settings
  bool _useSelectionEffect = true;
  double _selectedCharacterScale = 1.03;
  bool _useSelectionGlow = true;
  Color _selectionGlowColor = AppColors.white;
  double _selectionGlowIntensity = 0.7;
  double _selectionGlowSpread = 10.0;

  // Carousel settings
  bool _useCarousel = true;
  double _carouselVisibleWidth = 0.5;
  double _characterLeft = 112.0;
  double _characterTop = 745.0;
  double _characterRight = 112.0;

  // Grid layout settings
  int _gridRowCount = 1;
  List<int> _gridRowDistribution = [3]; // Default: all characters in one row
  double _gridHorizontalSpacing = 20.0;
  double _gridVerticalSpacing = 20.0;
  // EdgeInsets _gridMargin = const EdgeInsets.all(20.0);
  bool _gridCenterLastRow = false;

  // Button settings
  String _buttonText = 'Next';
  double _buttonWidth = 200.0;
  double _buttonHeight = 45.0;
  double _buttonFontSize = 18.0;
  Color _buttonColor = AppColors.yellow;
  Color _buttonTextColor = AppColors.black;
  double _buttonBorderRadius = 5.0;
  bool _buttonHasBorder = false;
  double _buttonBorderWidth = 1.0;
  Color _buttonBorderColor = AppColors.black;
  bool _useImageButton = false;
  String? _buttonImagePath;
  bool _isButtonImageAsset = true;
  // New button properties
  FontWeight _buttonFontWeight = FontWeight.w500;
  EdgeInsets _buttonPadding =
      const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0);

  double _buttonLeft = 444.0;
  double _buttonBottom = 590.0;

  // Layout settings
  double _screenPadding = 0.0;
  bool _showBackground = false;
  String? _backgroundImagePath;
  bool _isBackgroundImageAsset = true;

  // Getters
  String get titleText => _titleText;
  double get titleFontSize => _titleFontSize;
  Color get titleColor => _titleColor;
  FontWeight get titleFontWeight => _titleFontWeight;
  double get titleLeft => _titleLeft;
  double get titleTop => _titleTop;
  double get titleWidth => _titleWidth;
  double get titleLineHeight => _titleLineHeight;
  bool get titleItalic => _titleItalic;
  double get titleOpacity => _titleOpacity;
  TextAlign get titleAlignment => _titleAlignment;

  // New getters for carousel
  double get characterLeft => _characterLeft;
  double get characterTop => _characterTop;
  double get characterRight => _characterRight;

  // Grid layout getters
  int get gridRowCount => _gridRowCount;
  List<int> get gridRowDistribution => _gridRowDistribution;
  double get gridHorizontalSpacing => _gridHorizontalSpacing;
  double get gridVerticalSpacing => _gridVerticalSpacing;
  // EdgeInsets get gridMargin => _gridMargin;
  bool get gridCenterLastRow => _gridCenterLastRow;

  // New getters for button
  FontWeight get buttonFontWeight => _buttonFontWeight;
  double get buttonLeft => _buttonLeft;
  double get buttonBottom => _buttonBottom;
  EdgeInsets get buttonPadding => _buttonPadding;

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
    double? lineHeight,
    bool? italic,
    double? opacity,
    TextAlign? alignment,
  }) {
    if (fontSize != null) _titleFontSize = fontSize;
    if (color != null) _titleColor = color;
    if (fontWeight != null) _titleFontWeight = fontWeight;
    if (lineHeight != null) _titleLineHeight = lineHeight;
    if (italic != null) _titleItalic = italic;
    if (opacity != null) _titleOpacity = opacity;
    if (alignment != null) _titleAlignment = alignment;
    notifyListeners();
    _saveSettings();
  }

  // New setter for title margin
  void setTitlePosition(double left, double top, double width) {
    _titleLeft = left;
    _titleTop = top;
    _titleWidth = width;
    notifyListeners();
    _saveSettings();
  }

  // New setters for carousel
  void setCarouselPosition(double left, double top, double right) {
    _characterLeft = left;
    _characterTop = top;
    _characterRight = right;
    notifyListeners();
    _saveSettings();
  }

  void setUseCarousel(bool value) {
    _useCarousel = value;
    notifyListeners();
    _saveSettings();
  }

  // You might also want to add a method to set the carousel visible width
  void setCarouselVisibleWidth(double width) {
    _carouselVisibleWidth = width;
    notifyListeners();
    _saveSettings();
  }

  // Grid layout setters
  void setGridRowCount(int count) {
    if (count < 1) count = 1;
    _gridRowCount = count;

    // Reset row distribution when row count changes
    _gridRowDistribution = List.filled(count, 1);

    // If only one row, put all characters in that row
    if (count == 1) {
      _gridRowDistribution = [3]; // Minimum 3 characters
    }

    notifyListeners();
    _saveSettings();
  }

  void setGridRowDistribution(List<int> distribution) {
    if (distribution.length != _gridRowCount) {
      // Ensure distribution length matches row count
      if (distribution.length < _gridRowCount) {
        // Add missing rows with 1 character each
        distribution
            .addAll(List.filled(_gridRowCount - distribution.length, 1));
      } else {
        // Truncate extra rows
        distribution = distribution.sublist(0, _gridRowCount);
      }
    }

    _gridRowDistribution = distribution;
    notifyListeners();
    _saveSettings();
  }

  void updateRowDistributionAt(int index, int value) {
    if (index >= 0 && index < _gridRowDistribution.length) {
      if (value < 1) value = 1;
      _gridRowDistribution[index] = value;
      notifyListeners();
      _saveSettings();
    }
  }

  void setGridSpacing({double? horizontal, double? vertical}) {
    if (horizontal != null) _gridHorizontalSpacing = horizontal;
    if (vertical != null) _gridVerticalSpacing = vertical;
    notifyListeners();
    _saveSettings();
  }

  void setGridCenterLastRow(bool center) {
    _gridCenterLastRow = center;
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
    FontWeight? fontWeight,
  }) {
    if (fontSize != null) _buttonFontSize = fontSize;
    if (buttonColor != null) _buttonColor = buttonColor;
    if (textColor != null) _buttonTextColor = textColor;
    if (borderRadius != null) _buttonBorderRadius = borderRadius;
    if (fontWeight != null) _buttonFontWeight = fontWeight;
    notifyListeners();
    _saveSettings();
  }

  // New setters for button margin and padding
  void setButtonPosition(double left, double bottom) {
    _buttonLeft = left;
    _buttonBottom = bottom;
    notifyListeners();
    _saveSettings();
  }

  void setButtonPadding(EdgeInsets padding) {
    _buttonPadding = padding;
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
      _titleLeft = settings['titleLeft'] ?? _titleLeft;
      _titleTop = settings['titleTop'] ?? _titleTop;
      _titleWidth = settings['titleWidth'] ?? _titleWidth;
      _titleLineHeight = settings['titleLineHeight'] ?? _titleLineHeight;
      _titleItalic = settings['titleItalic'] ?? _titleItalic;
      _titleOpacity = settings['titleOpacity'] ?? _titleOpacity;
      _titleAlignment =
          TextAlign.values[settings['titleAlignment'] ?? _titleAlignment.index];

      // Character settings
      if (settings['maleCharacters'] != null) {
        try {
          final List<CharacterModel> loadedMaleCharacters =
              List<CharacterModel>.from(
            (settings['maleCharacters'] as List).map(
              (x) => CharacterModel.fromJson(x),
            ),
          );

          // Keep only characters that have valid assets
          _maleCharacters = loadedMaleCharacters.where((character) {
            if (!character.isAsset) {
              // For file system files, check if they exist
              return File(character.imagePath).existsSync();
            }
            // For asset files, we'll keep them as they should be in the assets folder
            return true;
          }).toList();
        } on Exception catch (e) {
          debugPrint('Error loading male characters: $e');
          // Keep default characters if there's an error
        }
      }

      if (settings['femaleCharacters'] != null) {
        try {
          final List<CharacterModel> loadedFemaleCharacters =
              List<CharacterModel>.from(
            (settings['femaleCharacters'] as List).map(
              (x) => CharacterModel.fromJson(x),
            ),
          );

          // Keep only characters that have valid assets
          _femaleCharacters = loadedFemaleCharacters.where((character) {
            if (!character.isAsset) {
              // For file system files, check if they exist
              return File(character.imagePath).existsSync();
            }
            // For asset files, we'll keep them as they should be in the assets folder
            return true;
          }).toList();
        } on Exception catch (e) {
          debugPrint('Error loading female characters: $e');
          // Keep default characters if there's an error
        }
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
      _characterLeft = settings['characterLeft'] ?? _characterLeft;
      _characterTop = settings['characterTop'] ?? _characterTop;
      _characterRight = settings['characterRight']?? _characterRight;

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
      _buttonFontWeight = FontWeight
          .values[settings['buttonFontWeight'] ?? _buttonFontWeight.index];
      _buttonColor = Color(settings['buttonColor'] ?? _buttonColor.value);
      _buttonTextColor =
          Color(settings['buttonTextColor'] ?? _buttonTextColor.value);
      _buttonBorderRadius =
          settings['buttonBorderRadius'] ?? _buttonBorderRadius;
      _buttonHasBorder = settings['buttonHasBorder'] ?? _buttonHasBorder;
      _buttonBorderWidth = settings['buttonBorderWidth'] ?? _buttonBorderWidth;
      _buttonBorderColor =
          Color(settings['buttonBorderColor'] ?? _buttonBorderColor.value);
      _buttonLeft = settings['buttonLeft'] ?? _buttonLeft;
      _buttonBottom = settings['buttonBottom'] ?? _buttonBottom;
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

      // Load button padding
      if (settings.containsKey('buttonPaddingVertical')) {
        _buttonPadding = EdgeInsets.symmetric(
          vertical: settings['buttonPaddingVertical'] ?? 10.0,
          horizontal: settings['buttonPaddingHorizontal'] ?? 20.0,
        );
      }
    }

    // Load grid layout settings
    _gridRowCount = prefs.getInt('grid_row_count') ?? 1;
    final gridRowDistStr = prefs.getString('grid_row_distribution');
    if (gridRowDistStr != null) {
      final List<dynamic> list = jsonDecode(gridRowDistStr);
      _gridRowDistribution = list.map((e) => e as int).toList();
    }
    _gridHorizontalSpacing = prefs.getDouble('grid_horizontal_spacing') ?? 20.0;
    _gridVerticalSpacing = prefs.getDouble('grid_vertical_spacing') ?? 20.0;
    _gridCenterLastRow = prefs.getBool('grid_center_last_row') ?? false;

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
      
      'titleLineHeight': _titleLineHeight,
      'titleItalic': _titleItalic,
      'titleOpacity': _titleOpacity,
      'titleAlignment': _titleAlignment.index,
      'titleLeft': _titleLeft,
      'titleTop': _titleTop,
      'titleWidth': _titleWidth,
      // Button settings
      'buttonLeft': _buttonLeft,
      'buttonBottom': _buttonBottom,
      //
      'characterLeft': _characterLeft,
      'characterTop': _characterTop,
      'characterRight': _characterRight,

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
      'buttonFontWeight': _buttonFontWeight.index,
      'buttonColor': _buttonColor.value,
      'buttonTextColor': _buttonTextColor.value,
      'buttonBorderRadius': _buttonBorderRadius,
      'buttonHasBorder': _buttonHasBorder,
      'buttonBorderWidth': _buttonBorderWidth,
      'buttonBorderColor': _buttonBorderColor.value,
      
      'buttonPaddingVertical': _buttonPadding.top,
      'buttonPaddingHorizontal': _buttonPadding.left,
      'useImageButton': _useImageButton,
      'buttonImagePath': _buttonImagePath,
      'isButtonImageAsset': _isButtonImageAsset,

      // Layout settings
      'screenPadding': _screenPadding,
      'showBackground': _showBackground,
      'backgroundImagePath': _backgroundImagePath,
      'isBackgroundImageAsset': _isBackgroundImageAsset,
    };

    // Save grid layout settings
    await prefs.setInt('grid_row_count', _gridRowCount);
    await prefs.setString(
        'grid_row_distribution', jsonEncode(_gridRowDistribution));
    await prefs.setDouble('grid_horizontal_spacing', _gridHorizontalSpacing);
    await prefs.setDouble('grid_vertical_spacing', _gridVerticalSpacing);
   
    await prefs.setBool('grid_center_last_row', _gridCenterLastRow);

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
