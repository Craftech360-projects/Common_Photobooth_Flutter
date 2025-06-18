import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GenderSelectionProvider extends ChangeNotifier {
  // Title settings
  String _titleText = '';
  double _titleFontSize = 22.0;
  Color _titleColor = AppColors.white;
  FontWeight _titleFontWeight = FontWeight.w500;
  double _titleLineHeight = 1.0;
  bool _titleItalic = false;
  double _titleOpacity = 1.0;
  TextAlign _titleAlignment = TextAlign.center;
  // Position properties for welcome message
  double _titleLeft = 395.0;
  double _titleTop = 795.0;
  double _titleWidth = 300.0;

  // Gender images settings
  String? _maleImagePath = 'assets/images/male_avatar.png';
  String? _femaleImagePath = 'assets/images/female_avatar.png';
  bool _isMaleImageAsset = true;
  bool _isFemaleImageAsset = true;
  double _imageWidth = 410.0;
  double _imageHeight = 495.0;
  double _imageSpacing = 40.0;
  double _imageBorderRadius = 0.0;
  bool _showImageBorder = false;
  double _imageBorderWidth = 0.0;
  Color _imageBorderColor = AppColors.yellow;
  double _genderSelectionLeft = 100.0;
  double _genderSelectionTop = 830.0;

  // Selection effect settings
  bool _useSelectionEffect = true;
  double _selectedImageScale = 1.0;
  bool _useSelectionGlow = true;
  Color _selectionGlowColor = AppColors.white;
  double _selectionGlowIntensity = 0.35;
  double _selectionGlowSpread = 20.0;

  // Button settings
  String _buttonText = 'Continue';
  double _buttonWidth = 585.0;
  double _buttonHeight = 150.0;
  double _buttonFontSize = 18.0;
  FontWeight _buttonFontWeight = FontWeight.w500;
  Color _buttonColor = AppColors.yellow;
  Color _buttonTextColor = AppColors.black;
  double _buttonBorderRadius = 0.0;
  bool _buttonHasBorder = false;
  double _buttonBorderWidth = 0.0;
  Color _buttonBorderColor = AppColors.black;
  bool _useImageButton = true;
  String _buttonImagePath = 'assets/images/next_btn.png';
  bool _isButtonImageAsset = true;
  EdgeInsets _buttonPadding =
      const EdgeInsets.symmetric(vertical: 0, horizontal: 0);

  // Position properties for button
  double _buttonLeft = 245.0;
  double _buttonBottom = 380.0;

  // Layout settings
  double _screenPadding = 0.0;
  bool _showBackground = true;
  String _backgroundImagePath = 'assets/images/gender_bg.png';
  bool _isBackgroundImageAsset = true;

  // Getters
  String get titleText => _titleText;
  double get titleFontSize => _titleFontSize;
  Color get titleColor => _titleColor;
  FontWeight get titleFontWeight => _titleFontWeight;
  double get titleLeft => _titleLeft;
  double get titleTop => _titleTop;
  double get titleWidth => _titleWidth;

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
  double get genderSelectionLeft => _genderSelectionLeft;
  double get genderSelectionTop => _genderSelectionTop;

  String get buttonText => _buttonText;
double get buttonWidth => _buttonWidth;
  double get buttonHeight => _buttonHeight;
  double get buttonFontSize => _buttonFontSize;
  FontWeight get buttonFontWeight => _buttonFontWeight;
  Color get buttonColor => _buttonColor;
  Color get buttonTextColor => _buttonTextColor;
  double get buttonBorderRadius => _buttonBorderRadius;
  bool get buttonHasBorder => _buttonHasBorder;
  double get buttonBorderWidth => _buttonBorderWidth;
  Color get buttonBorderColor => _buttonBorderColor;
  double get buttonLeft => _buttonLeft;
  double get buttonBottom => _buttonBottom;
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
    if (lineHeight != null) _titleLineHeight = lineHeight;
    if (italic != null) _titleItalic = italic;
    if (opacity != null) _titleOpacity = opacity;
    if (alignment != null) _titleAlignment = alignment;
    notifyListeners();
    _saveSettings();
  }

  void setTitlePosition(double left, double top, double width) async {
    _titleLeft = left;
    _titleTop = top;
    _titleWidth = width;
    notifyListeners();
    await _saveSettings();
  }

  void setGenderCardPosition(double left, double top) {
    _genderSelectionLeft = left;
    _genderSelectionTop = top;
    notifyListeners();
    _saveSettings();
  }

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
            'gender_${DateTime.now().millisecondsSinceEpoch}${path.extension(sourcePath)}';
        final destinationPath = path.join(appDir.path, fileName);
        await File(sourcePath).copy(destinationPath);
        updateState(destinationPath, false);
      } catch (e) {
        debugPrint('Error copying image: $e');
        return;
      }
    }
    notifyListeners();
    _saveSettings();
  }

  Future<void> setMaleImage(String? imagePath, {required bool isAsset}) async {
    await _setImage(imagePath, isAsset, (path, asset) {
      _maleImagePath = path;
      _isMaleImageAsset = asset;
    });
  }

  Future<void> setFemaleImage(String? imagePath,
      {required bool isAsset}) async {
    await _setImage(imagePath, isAsset, (path, asset) {
      _femaleImagePath = path;
      _isFemaleImageAsset = asset;
    });
  }

  Future<void> setButtonImage(String sourcePath, {bool isAsset = true}) async {
    await _setImage(sourcePath, isAsset, (path, asset) {
      _buttonImagePath = path!;
      _isButtonImageAsset = asset;
    });
  }

  Future<void> setBackgroundImage(String? sourcePath,
      {required bool isAsset}) async {
    await _setImage(sourcePath, isAsset, (path, asset) {
      _backgroundImagePath = path!;
      _isBackgroundImageAsset = asset;
    });
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
    FontWeight? fontWeight,
    Color? buttonColor,
    Color? textColor,
    double? borderRadius,
  }) {
    if (fontSize != null) _buttonFontSize = fontSize;
    if (fontWeight != null) _buttonFontWeight = fontWeight;
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

  void setUseImageButton(bool useImage) {
    _useImageButton = useImage;
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

  // Add this method to validate file paths before using them
  Future<bool> _isFileAccessible(String? filePath) async {
    if (filePath == null) return false;

    // For asset paths, we can't check directly
    if (filePath.startsWith('assets/')) return true;

    try {
      final file = File(filePath);
      return await file.exists();
    } on Exception catch (e) {
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

      _titleLineHeight = settings['titleLineHeight'] ?? _titleLineHeight;
      _titleItalic = settings['titleItalic'] ?? _titleItalic;
      _titleOpacity = settings['titleOpacity'] ?? _titleOpacity;
      _titleAlignment =
          TextAlign.values[settings['titleAlignment'] ?? _titleAlignment.index];

      // Load position properties
      _titleLeft = settings['titleLeft'] ?? _titleLeft;
      _titleTop = settings['titleTop'] ?? _titleTop;
      _titleWidth = settings['titleWidth'] ?? _titleWidth;
      // Gender selection position
      _genderSelectionLeft =
          settings['genderSelectionLeft'] ?? _genderSelectionLeft;
      _genderSelectionTop =
          settings['genderSelectionTop'] ?? _genderSelectionTop;
      // Button position
      _buttonLeft = settings['buttonLeft'] ?? _buttonLeft;
      _buttonBottom = settings['buttonBottom'] ?? _buttonBottom;

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

      if (settings.containsKey('buttonPaddingTop')) {
        _buttonPadding = EdgeInsets.fromLTRB(
          settings['buttonPaddingLeft'] ?? 0.0,
          settings['buttonPaddingTop'] ?? 0.0,
          settings['buttonPaddingRight'] ?? 0.0,
          settings['buttonPaddingBottom'] ?? 0.0,
        );
      } else if (settings.containsKey('buttonPaddingVertical')) {
        // For backward compatibility
        _buttonPadding = EdgeInsets.symmetric(
          vertical: settings['buttonPaddingVertical'] ?? 0.0,
          horizontal: settings['buttonPaddingHorizontal'] ?? 0.0,
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
        'titleLineHeight': _titleLineHeight,
        'titleItalic': _titleItalic,
        'titleOpacity': _titleOpacity,
        'titleAlignment': _titleAlignment.index,
        'titleLeft': _titleLeft,
        'titleTop': _titleTop,
        'titleWidth': _titleWidth,
        // Gender selection position
        'genderSelectionLeft': _genderSelectionLeft,
        'genderSelectionTop': _genderSelectionTop,
        // Button position
        'buttonLeft': _buttonLeft,
        'buttonBottom': _buttonBottom,

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

        // Button margin and padding

        'buttonPaddingTop': _buttonPadding.top,
        'buttonPaddingBottom': _buttonPadding.bottom,
        'buttonPaddingLeft': _buttonPadding.left,
        'buttonPaddingRight': _buttonPadding.right,

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
        'buttonFontWeight': _buttonFontWeight.index,
        'buttonColor': _buttonColor.value,
        'buttonTextColor': _buttonTextColor.value,
        'buttonBorderRadius': _buttonBorderRadius,
        'buttonHasBorder': _buttonHasBorder,
        'buttonBorderWidth': _buttonBorderWidth,
        'buttonBorderColor': _buttonBorderColor.value,

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
    } on Exception catch (e) {
      debugPrint('Error saving gender selection settings: $e');
    }
  }
}
