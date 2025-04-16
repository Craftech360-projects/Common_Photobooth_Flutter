import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GenderSelectionProvider extends ChangeNotifier {
  // Title settings
  String _titleText = 'Select Gender';
  double _titleFontSize = 32.0;
  Color _titleColor = Colors.white;
  FontWeight _titleFontWeight = FontWeight.bold;
  double _titlePadding = 20.0;
  double _titleLineHeight = 1.2;
  bool _titleItalic = false;
  double _titleOpacity = 1.0;
  TextAlign _titleAlignment = TextAlign.center;
  EdgeInsets _titleMargin = const EdgeInsets.all(0);

  // Gender images settings
  String? _maleImagePath = 'assets/images/male_avatar.png';
  String? _femaleImagePath = 'assets/images/female_avatar.png';
  bool _isMaleImageAsset = true;
  bool _isFemaleImageAsset = true;
  double _imageWidth = 150.0;
  double _imageHeight = 150.0;
  double _imageSpacing = 40.0;
  double _imageBorderRadius = 20.0;
  bool _showImageBorder = true;
  double _imageBorderWidth = 2.0;
  Color _imageBorderColor = const Color(0xFFFFD700);
  EdgeInsets _imagesRowMargin = const EdgeInsets.all(0);
  EdgeInsets _imagesRowPadding = const EdgeInsets.all(0);

  // Selection effect settings
  bool _useSelectionEffect = true;
  double _selectedImageScale = 1.1;
  bool _useSelectionGlow = true;
  Color _selectionGlowColor = Colors.blue;
  double _selectionGlowIntensity = 0.7;
  double _selectionGlowSpread = 10.0;

  // Button settings
  String _buttonText = 'Continue';
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
  EdgeInsets _buttonMargin = const EdgeInsets.all(0);
  EdgeInsets _buttonPadding =
      const EdgeInsets.symmetric(vertical: 10, horizontal: 20);

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

  String? get maleImagePath => _maleImagePath;
  String? get femaleImagePath => _femaleImagePath;
  bool get isMaleImageAsset => _isMaleImageAsset;
  bool get isFemaleImageAsset => _isFemaleImageAsset;
  double get imageWidth => _imageWidth;
  double get imageHeight => _imageHeight;
  double get imageSpacing => _imageSpacing;
  double get imageBorderRadius => _imageBorderRadius;
  double get imageBorderWidth => _imageBorderWidth;
  Color get imageBorderColor => _imageBorderColor;
  bool get showImageBorder => _showImageBorder;
  bool get useSelectionEffect => _useSelectionEffect;
  double get selectedImageScale => _selectedImageScale;
  bool get useSelectionGlow => _useSelectionGlow;
  Color get selectionGlowColor => _selectionGlowColor;
  double get selectionGlowIntensity => _selectionGlowIntensity;
  double get selectionGlowSpread => _selectionGlowSpread;

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

  double get titleLineHeight => _titleLineHeight;
  bool get titleItalic => _titleItalic;
  double get titleOpacity => _titleOpacity;
  TextAlign get titleAlignment => _titleAlignment;
  EdgeInsets get titleMargin => _titleMargin;

  EdgeInsets get imagesRowMargin => _imagesRowMargin;
  EdgeInsets get imagesRowPadding => _imagesRowPadding;

  EdgeInsets get buttonMargin => _buttonMargin;
  EdgeInsets get buttonPadding => _buttonPadding;

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
    if (padding != null) _titlePadding = padding;
    if (lineHeight != null) _titleLineHeight = lineHeight;
    if (italic != null) _titleItalic = italic;
    if (opacity != null) _titleOpacity = opacity;
    if (alignment != null) _titleAlignment = alignment;
    notifyListeners();
    _saveSettings();
  }

  // New setters for margins and paddings
  void setTitleMargin(EdgeInsets margin) {
    _titleMargin = margin;
    notifyListeners();
    _saveSettings();
  }

  void setImagesRowMargin(EdgeInsets margin) {
    _imagesRowMargin = margin;
    notifyListeners();
    _saveSettings();
  }

  void setImagesRowPadding(EdgeInsets padding) {
    _imagesRowPadding = padding;
    notifyListeners();
    _saveSettings();
  }

  void setButtonMargin(EdgeInsets margin) {
    _buttonMargin = margin;
    notifyListeners();
    _saveSettings();
  }

  void setButtonPadding(EdgeInsets padding) {
    _buttonPadding = padding;
    notifyListeners();
    _saveSettings();
  }

  void setMaleImage(String? imagePath, {required bool isAsset}) {
    _maleImagePath = imagePath;
    _isMaleImageAsset = isAsset;
    notifyListeners();
    _saveSettings();
  }

  void setFemaleImage(String? imagePath, {required bool isAsset}) {
    _femaleImagePath = imagePath;
    _isFemaleImageAsset = isAsset;
    notifyListeners();
    _saveSettings();
  }

  void setImageDimensions(double width, double height) {
    _imageWidth = width;
    _imageHeight = height;
    notifyListeners();
    _saveSettings();
  }

  void setImageSpacing(double spacing) {
    _imageSpacing = spacing;
    notifyListeners();
    _saveSettings();
  }

  void setImageBorder({
    double? borderRadius,
    bool? showBorder,
    double? borderWidth,
    Color? borderColor,
  }) {
    if (borderRadius != null) _imageBorderRadius = borderRadius;
    if (showBorder != null) _showImageBorder = showBorder;
    if (borderWidth != null) _imageBorderWidth = borderWidth;
    if (borderColor != null) _imageBorderColor = borderColor;
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
    if (scale != null) _selectedImageScale = scale;
    if (useGlow != null) _useSelectionGlow = useGlow;
    if (glowColor != null) _selectionGlowColor = glowColor;
    if (glowIntensity != null) _selectionGlowIntensity = glowIntensity;
    if (glowSpread != null) _selectionGlowSpread = glowSpread;
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

  // Add this method to validate file paths before using them
  Future<bool> _isFileAccessible(String? filePath) async {
    if (filePath == null) return false;

    // For asset paths, we can't check directly
    if (filePath.startsWith('assets/')) return true;

    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      debugPrint('Error checking file accessibility: $e');
      return false;
    }
  }

  // Initialize provider from SharedPreferences
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('gender_selection_settings');

    if (settingsJson != null) {
      final Map<String, dynamic> settings = jsonDecode(settingsJson);

      // Title settings
      _titleText = settings['titleText'] ?? _titleText;
      _titleFontSize = settings['titleFontSize'] ?? _titleFontSize;
      _titleColor = Color(settings['titleColor'] ?? _titleColor.value);
      _titleFontWeight = FontWeight
          .values[settings['titleFontWeight'] ?? _titleFontWeight.index];
      _titlePadding = settings['titlePadding'] ?? _titlePadding;
      _titleLineHeight = settings['titleLineHeight'] ?? _titleLineHeight;
      _titleItalic = settings['titleItalic'] ?? _titleItalic;
      _titleOpacity = settings['titleOpacity'] ?? _titleOpacity;
      _titleAlignment =
          TextAlign.values[settings['titleAlignment'] ?? _titleAlignment.index];

      // Load title margin
      if (settings.containsKey('titleMarginTop')) {
        _titleMargin = EdgeInsets.fromLTRB(
          settings['titleMarginLeft'] ?? 0.0,
          settings['titleMarginTop'] ?? 0.0,
          settings['titleMarginRight'] ?? 0.0,
          settings['titleMarginBottom'] ?? 0.0,
        );
      }

      // Gender images settings - with validation
      if (settings.containsKey('maleImagePath')) {
        final path = settings['maleImagePath'] as String?;
        final isAsset = settings['isMaleImageAsset'] ?? true;

        if (isAsset || await _isFileAccessible(path)) {
          _maleImagePath = path;
          _isMaleImageAsset = isAsset;
        } else {
          // Fallback to default if file not accessible
          _maleImagePath = 'assets/images/male_avatar.png';
          _isMaleImageAsset = true;
          debugPrint('Male image file not accessible, using default: $path');
        }
      }

      if (settings.containsKey('femaleImagePath')) {
        final path = settings['femaleImagePath'] as String?;
        final isAsset = settings['isFemaleImageAsset'] ?? true;

        if (isAsset || await _isFileAccessible(path)) {
          _femaleImagePath = path;
          _isFemaleImageAsset = isAsset;
        } else {
          // Fallback to default if file not accessible
          _femaleImagePath = 'assets/images/female_avatar.png';
          _isFemaleImageAsset = true;
          debugPrint('Female image file not accessible, using default: $path');
        }
      }

      _imageWidth = settings['imageWidth'] ?? _imageWidth;
      _imageHeight = settings['imageHeight'] ?? _imageHeight;
      _imageSpacing = settings['imageSpacing'] ?? _imageSpacing;
      _imageBorderRadius = settings['imageBorderRadius'] ?? _imageBorderRadius;
      _showImageBorder = settings['showImageBorder'] ?? _showImageBorder;
      _imageBorderWidth = settings['imageBorderWidth'] ?? _imageBorderWidth;
      _imageBorderColor =
          Color(settings['imageBorderColor'] ?? _imageBorderColor.value);

      // Selection effect settings
      _useSelectionEffect =
          settings['useSelectionEffect'] ?? _useSelectionEffect;
      _selectedImageScale =
          settings['selectedImageScale'] ?? _selectedImageScale;
      _useSelectionGlow = settings['useSelectionGlow'] ?? _useSelectionGlow;
      _selectionGlowColor =
          Color(settings['selectionGlowColor'] ?? _selectionGlowColor.value);
      _selectionGlowIntensity =
          settings['selectionGlowIntensity'] ?? _selectionGlowIntensity;
      _selectionGlowSpread =
          settings['selectionGlowSpread'] ?? _selectionGlowSpread;

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

      if (settings.containsKey('imagesRowMarginTop')) {
        _imagesRowMargin = EdgeInsets.fromLTRB(
          settings['imagesRowMarginLeft'] ?? 0.0,
          settings['imagesRowMarginTop'] ?? 0.0,
          settings['imagesRowMarginRight'] ?? 0.0,
          settings['imagesRowMarginBottom'] ?? 0.0,
        );
      }

      if (settings.containsKey('imagesRowPaddingTop')) {
        _imagesRowPadding = EdgeInsets.fromLTRB(
          settings['imagesRowPaddingLeft'] ?? 0.0,
          settings['imagesRowPaddingTop'] ?? 0.0,
          settings['imagesRowPaddingRight'] ?? 0.0,
          settings['imagesRowPaddingBottom'] ?? 0.0,
        );
      }

      // Load button margin and padding
      if (settings.containsKey('buttonMarginTop')) {
        _buttonMargin = EdgeInsets.fromLTRB(
          settings['buttonMarginLeft'] ?? 0.0,
          settings['buttonMarginTop'] ?? 0.0,
          settings['buttonMarginRight'] ?? 0.0,
          settings['buttonMarginBottom'] ?? 0.0,
        );
      }

      if (settings.containsKey('buttonPaddingVertical')) {
        _buttonPadding = EdgeInsets.symmetric(
          vertical: settings['buttonPaddingVertical'] ?? 10.0,
          horizontal: settings['buttonPaddingHorizontal'] ?? 20.0,
        );
      }
    }

    notifyListeners();
  }

  // Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final Map<String, dynamic> settings = {
        // Title settings
        'titleText': _titleText,
        'titleFontSize': _titleFontSize,
        'titleColor': _titleColor.value,
        'titleFontWeight': _titleFontWeight.index,
        'titlePadding': _titlePadding,
        'titleLineHeight': _titleLineHeight,
        'titleItalic': _titleItalic,
        'titleOpacity': _titleOpacity,
        'titleAlignment': _titleAlignment.index,
        'titleMarginTop': _titleMargin.top,
        'titleMarginBottom': _titleMargin.bottom,
        'titleMarginLeft': _titleMargin.left,
        'titleMarginRight': _titleMargin.right,

        // Gender images settings
        'maleImagePath': _maleImagePath,
        'femaleImagePath': _femaleImagePath,
        'isMaleImageAsset': _isMaleImageAsset,
        'isFemaleImageAsset': _isFemaleImageAsset,
        'imageWidth': _imageWidth,
        'imageHeight': _imageHeight,
        'imageSpacing': _imageSpacing,
        'imageBorderRadius': _imageBorderRadius,
        'showImageBorder': _showImageBorder,
        'imageBorderWidth': _imageBorderWidth,
        'imageBorderColor': _imageBorderColor.value,

        // Images row margin and padding
        'imagesRowMarginTop': _imagesRowMargin.top,
        'imagesRowMarginBottom': _imagesRowMargin.bottom,
        'imagesRowMarginLeft': _imagesRowMargin.left,
        'imagesRowMarginRight': _imagesRowMargin.right,
        'imagesRowPaddingTop': _imagesRowPadding.top,
        'imagesRowPaddingBottom': _imagesRowPadding.bottom,
        'imagesRowPaddingLeft': _imagesRowPadding.left,
        'imagesRowPaddingRight': _imagesRowPadding.right,

        // Button margin and padding
        'buttonMarginBottom': _buttonMargin.bottom,
        'buttonMarginLeft': _buttonMargin.left,
        'buttonMarginRight': _buttonMargin.right,
        'buttonPaddingVertical': _buttonPadding.top,
        'buttonPaddingHorizontal': _buttonPadding.left,

        // Selection effect settings
        'useSelectionEffect': _useSelectionEffect,
        'selectedImageScale': _selectedImageScale,
        'useSelectionGlow': _useSelectionGlow,
        'selectionGlowColor': _selectionGlowColor.value,
        'selectionGlowIntensity': _selectionGlowIntensity,
        'selectionGlowSpread': _selectionGlowSpread,

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

      await prefs.setString('gender_selection_settings', jsonEncode(settings));
    } catch (e) {
      debugPrint('Error saving gender selection settings: $e');
    }
  }
}
