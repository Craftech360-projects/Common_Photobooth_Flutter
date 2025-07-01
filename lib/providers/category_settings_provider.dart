import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A model to hold settings for each category card to reduce redundancy.
class CategoryCardSettings {
  String imagePath;
  bool isAsset;
  double width;
  double height;
  double borderRadius;
  bool showBorder;
  double borderWidth;
  double subCategoryWidth;
  double subCategoryHeight;
  Color borderColor;
  double scale;
  bool useGlow;
  Color glowColor;
  double glowIntensity;
  double glowSpread;

  CategoryCardSettings({
    required this.imagePath,
    this.isAsset = true,
    this.width = 0.38, // Default to 38%
    this.height = 0.26, // Default to 26%
    this.borderRadius = 0.0,
    this.subCategoryWidth = 0.46, // ~500px on 1080p
    this.subCategoryHeight = 0.31, // ~600px on 1920p
    this.showBorder = false,
    this.borderWidth = 0.0,
    this.borderColor = AppColors.goldenYellow,
    this.scale = 1.05,
    this.useGlow = true,
    this.glowColor = AppColors.goldenYellow,
    this.glowIntensity = 0.5,
    this.glowSpread = 10.0,
  });

  /// Creates a [CategoryCardSettings] object from a JSON map.
  factory CategoryCardSettings.fromJson(Map<String, dynamic> json) {
    const double refWidth = 1080.0;
    const double refHeight = 1920.0;

    // Helper to convert old pixel values
    double toPercent(dynamic value, double defaultValue, double reference) {
      double val = (value as num?)?.toDouble() ?? defaultValue;
      return val > 1.0 ? val / reference : val;
    }

    return CategoryCardSettings(
      imagePath: json['imagePath'],
      isAsset: json['isAsset'] ?? true,
      width: toPercent(json['width'], 0.38, refWidth),
      height: toPercent(json['height'], 0.26, refHeight),
      subCategoryWidth: toPercent(json['subCategoryWidth'], 0.46, 1080.0),
      subCategoryHeight: toPercent(json['subCategoryHeight'], 0.31, 1920.0),
      borderRadius: json['borderRadius']?.toDouble() ?? 16.0,
      showBorder: json['showBorder'] ?? true,
      borderWidth: json['borderWidth']?.toDouble() ?? 3.0,
      borderColor: Color(json['borderColor'] ?? AppColors.goldenYellow.value),
      scale: json['scale']?.toDouble() ?? 1.05,
      useGlow: json['useGlow'] ?? true,
      glowColor: Color(json['glowColor'] ?? AppColors.goldenYellow.value),
      glowIntensity: json['glowIntensity']?.toDouble() ?? 0.5,
      glowSpread: json['glowSpread']?.toDouble() ?? 10.0,
    );
  }

  /// Converts this [CategoryCardSettings] object to a JSON map.
  Map<String, dynamic> toJson() => {
        'imagePath': imagePath,
        'isAsset': isAsset,
        'width': width,
        'height': height,
        'borderRadius': borderRadius,
        'showBorder': showBorder,
        'borderWidth': borderWidth,
        'borderColor': borderColor.value,
        'scale': scale,
        'useGlow': useGlow,
        'glowColor': glowColor.value,
        'glowIntensity': glowIntensity,
        'glowSpread': glowSpread,
      };

  /// Creates a copy of this object with the given fields replaced with the new values.
  CategoryCardSettings copyWith({
    String? imagePath,
    bool? isAsset,
    double? width,
    double? height,
    double? borderRadius,
    bool? showBorder,
    double? borderWidth,
    Color? borderColor,
    double? scale,
    bool? useGlow,
    Color? glowColor,
    double? glowIntensity,
    double? glowSpread,
  }) {
    return CategoryCardSettings(
      imagePath: imagePath ?? this.imagePath,
      isAsset: isAsset ?? this.isAsset,
      width: width ?? this.width,
      height: height ?? this.height,
      borderRadius: borderRadius ?? this.borderRadius,
      showBorder: showBorder ?? this.showBorder,
      borderWidth: borderWidth ?? this.borderWidth,
      borderColor: borderColor ?? this.borderColor,
      scale: scale ?? this.scale,
      useGlow: useGlow ?? this.useGlow,
      glowColor: glowColor ?? this.glowColor,
      glowIntensity: glowIntensity ?? this.glowIntensity,
      glowSpread: glowSpread ?? this.glowSpread,
    );
  }
}

class CategorySettingsProvider extends ChangeNotifier {
  late SharedPreferences _prefs;

  // Title settings
  String _titleText = '';
  double _titleFontSize = 28.0;
  Color _titleColor = AppColors.white;
  FontWeight _titleFontWeight = FontWeight.bold;
  bool _showTitle = false;

  // Carousel and Arrow controls
  double _arrowSpacing = 0.11; // 11% of screen width
  double _carouselWidth = 0.46; // 46% of screen width
  double _carouselHeight = 0.31; // 31% of screen height

  // Button controls
  double _buttonLeft = 0.22;
  double _buttonBottom = 0.21;
  double _buttonWidth = 0.54;
  double _buttonHeight = 0.08;

  // Packaging TextField controls
  double _packagingFieldLeft = 0.22;
  double _packagingFieldBottom = 0.31;
  double _packagingFieldWidth = 0.55;
  double _packagingFieldFontSize = 24.0;
  Color _packagingFieldTextColor = Colors.white;
  Color _packagingFieldBorderColor = Colors.white54;

  // Title settings now use percentages for position and size
  double _titleLeft = 0.0;
  double _titleTop = 0.1; // Default to 10% from top
  double _titleWidth = 1.0; // Default to 100% width

  double get arrowSpacing => _arrowSpacing;
  double get carouselWidth => _carouselWidth;
  double get carouselHeight => _carouselHeight;
  double get buttonLeft => _buttonLeft;
  double get buttonBottom => _buttonBottom;
  double get buttonWidth => _buttonWidth;
  double get buttonHeight => _buttonHeight;
  double get packagingFieldLeft => _packagingFieldLeft;
  double get packagingFieldBottom => _packagingFieldBottom;
  double get packagingFieldWidth => _packagingFieldWidth;
  double get packagingFieldFontSize => _packagingFieldFontSize;
  Color get packagingFieldTextColor => _packagingFieldTextColor;
  Color get packagingFieldBorderColor => _packagingFieldBorderColor;

  // Background settings
  String _backgroundImagePath = "assets/images/categories_bg.png";
  bool _isBackgroundImageAsset = true;
  bool _showBackground = true;

  // Main Category Card Settings
  CategoryCardSettings _aiArtistryCard =
      CategoryCardSettings(imagePath: 'assets/images/ai_artistry.png');
  CategoryCardSettings _swaplabCard =
      CategoryCardSettings(imagePath: 'assets/images/swaplab.png');

  // Sub Category Card Settings
  CategoryCardSettings _ghibliCard =
      CategoryCardSettings(imagePath: 'assets/images/ghibli.png');
  CategoryCardSettings _pixarCard =
      CategoryCardSettings(imagePath: 'assets/images/pixar.png');
  CategoryCardSettings _packagingCard =
      CategoryCardSettings(imagePath: 'assets/images/packaging.png');

  // Getters
  String get titleText => _titleText;
  double get titleFontSize => _titleFontSize;
  Color get titleColor => _titleColor;
  FontWeight get titleFontWeight => _titleFontWeight;
  bool get showTitle => _showTitle;
  double get titleLeft => _titleLeft;
  double get titleTop => _titleTop;
  double get titleWidth => _titleWidth;

  String? get backgroundImagePath => _backgroundImagePath;
  bool get isBackgroundImageAsset => _isBackgroundImageAsset;
  bool get showBackground => _showBackground;

  CategoryCardSettings get aiArtistryCard => _aiArtistryCard;
  CategoryCardSettings get swaplabCard => _swaplabCard;
  CategoryCardSettings get ghibliCard => _ghibliCard;
  CategoryCardSettings get pixarCard => _pixarCard;
  CategoryCardSettings get packagingCard => _packagingCard;

  /// Initializes the provider by loading settings from SharedPreferences.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await loadSettings();
  }

  // Setters
  void setTitleText(String text) {
    _titleText = text;
    _saveSettings();
    notifyListeners();
  }

  void setShowTitle(bool show) {
    _showTitle = show;
    _saveSettings();
    notifyListeners();
  }

  void setTitleStyle({double? fontSize, Color? color, FontWeight? fontWeight}) {
    if (fontSize != null) _titleFontSize = fontSize;
    if (color != null) _titleColor = color;
    if (fontWeight != null) _titleFontWeight = fontWeight;
    _saveSettings();
    notifyListeners();
  }

  void setShowBackground(bool show) {
    _showBackground = show;
    _saveSettings();
    notifyListeners();
  }

  void setBackgroundImage(String? path, {required bool isAsset}) {
    _backgroundImagePath = path!;
    _isBackgroundImageAsset = isAsset;
    _saveSettings();
    notifyListeners();
  }

  void setTitlePosition(double left, double top, double width) {
    _titleLeft = left;
    _titleTop = top;
    _titleWidth = width;
    _saveSettings();
    notifyListeners();
  }

  void updateCardSettings(String cardKey, CategoryCardSettings newSettings) {
    switch (cardKey) {
      case 'aiArtistry':
        _aiArtistryCard = newSettings;
        break;
      case 'swaplab':
        _swaplabCard = newSettings;
        break;
      case 'ghibli':
        _ghibliCard = newSettings;
        break;
      case 'pixar':
        _pixarCard = newSettings;
        break;
      case 'packaging':
        _packagingCard = newSettings;
        break;
    }
    _saveSettings();
    notifyListeners();
  }

  /// Loads all category screen settings from SharedPreferences.
  Future<void> loadSettings() async {
    final settingsJson = _prefs.getString('category_screen_settings');
    if (settingsJson != null) {
      final settings = jsonDecode(settingsJson);

      const double refWidth = 1080.0;
      const double refHeight = 1920.0;

      // Helper to convert old pixel values to new percentage values
      double toPercent(dynamic value, double defaultValue, double reference) {
        double val = (value as num?)?.toDouble() ?? defaultValue;
        return val > 1.0 ? val / reference : val;
      }

      // Apply migration logic to title positioning
      _titleLeft = toPercent(settings['titleLeft'], _titleLeft, refWidth);
      _titleTop = toPercent(settings['titleTop'], _titleTop, refHeight);
      _titleWidth = toPercent(settings['titleWidth'], _titleWidth, refWidth);

      _arrowSpacing =
          _prefs.getDouble('category_arrow_spacing') ?? _arrowSpacing;
      _carouselWidth =
          _prefs.getDouble('category_carousel_width') ?? _carouselWidth;
      _carouselHeight =
          _prefs.getDouble('category_carousel_height') ?? _carouselHeight;
      _buttonLeft = _prefs.getDouble('category_button_left') ?? _buttonLeft;
      _buttonBottom =
          _prefs.getDouble('category_button_bottom') ?? _buttonBottom;
      _buttonWidth = _prefs.getDouble('category_button_width') ?? _buttonWidth;
      _buttonHeight =
          _prefs.getDouble('category_button_height') ?? _buttonHeight;
      _packagingFieldLeft = _prefs.getDouble('category_packaging_field_left') ??
          _packagingFieldLeft;
      _packagingFieldBottom =
          _prefs.getDouble('category_packaging_field_bottom') ??
              _packagingFieldBottom;
      _packagingFieldWidth =
          _prefs.getDouble('category_packaging_field_width') ??
              _packagingFieldWidth;
      _packagingFieldFontSize =
          _prefs.getDouble('category_packaging_field_font_size') ??
              _packagingFieldFontSize;
      _packagingFieldTextColor = Color(
          _prefs.getInt('category_packaging_field_text_color') ??
              _packagingFieldTextColor.value);
      _packagingFieldBorderColor = Color(
          _prefs.getInt('category_packaging_field_border_color') ??
              _packagingFieldBorderColor.value);

      _titleText = settings['titleText'] ?? _titleText;
      _showTitle = settings['showTitle'] ?? _showTitle;
      _titleFontSize = settings['titleFontSize'] ?? _titleFontSize;
      _titleColor = Color(settings['titleColor'] ?? _titleColor.value);
      _titleFontWeight = FontWeight
          .values[settings['titleFontWeight'] ?? _titleFontWeight.index];
      _showBackground = settings['showBackground'] ?? _showBackground;
      _backgroundImagePath = settings['backgroundImagePath'];
      _isBackgroundImageAsset =
          settings['isBackgroundImageAsset'] ?? _isBackgroundImageAsset;

      if (settings['aiArtistryCard'] != null) {
        _aiArtistryCard =
            CategoryCardSettings.fromJson(settings['aiArtistryCard']);
      }
      if (settings['swaplabCard'] != null) {
        _swaplabCard = CategoryCardSettings.fromJson(settings['swaplabCard']);
      }
      if (settings['ghibliCard'] != null) {
        _ghibliCard = CategoryCardSettings.fromJson(settings['ghibliCard']);
      }
      if (settings['pixarCard'] != null) {
        _pixarCard = CategoryCardSettings.fromJson(settings['pixarCard']);
      }
      if (settings['packagingCard'] != null) {
        _packagingCard =
            CategoryCardSettings.fromJson(settings['packagingCard']);
      }
    }
    notifyListeners();
  }

  /// Saves all category screen settings to SharedPreferences.
  Future<void> _saveSettings() async {
    final settings = {
      'titleText': _titleText,
      'showTitle': _showTitle,
      'titleFontSize': _titleFontSize,
      'titleColor': _titleColor.value,
      'titleFontWeight': _titleFontWeight.index,
      'showBackground': _showBackground,
      'backgroundImagePath': _backgroundImagePath,
      'isBackgroundImageAsset': _isBackgroundImageAsset,
      'aiArtistryCard': _aiArtistryCard.toJson(),
      'swaplabCard': _swaplabCard.toJson(),
      'ghibliCard': _ghibliCard.toJson(),
      'pixarCard': _pixarCard.toJson(),
      'packagingCard': _packagingCard.toJson(),
    };
    await _prefs.setString('category_screen_settings', jsonEncode(settings));
    await _prefs.setDouble('category_arrow_spacing', _arrowSpacing);
    await _prefs.setDouble('category_carousel_width', _carouselWidth);
    await _prefs.setDouble('category_carousel_height', _carouselHeight);
    await _prefs.setDouble('category_button_left', _buttonLeft);
    await _prefs.setDouble('category_button_bottom', _buttonBottom);
    await _prefs.setDouble('category_button_width', _buttonWidth);
    await _prefs.setDouble('category_button_height', _buttonHeight);
    await _prefs.setDouble(
        'category_packaging_field_left', _packagingFieldLeft);
    await _prefs.setDouble(
        'category_packaging_field_bottom', _packagingFieldBottom);
    await _prefs.setDouble(
        'category_packaging_field_width', _packagingFieldWidth);
    await _prefs.setDouble(
        'category_packaging_field_font_size', _packagingFieldFontSize);
    await _prefs.setInt(
        'category_packaging_field_text_color', _packagingFieldTextColor.value);
    await _prefs.setInt('category_packaging_field_border_color',
        _packagingFieldBorderColor.value);
  }

  void setArrowSpacing(double value) {
    _arrowSpacing = value;
    _saveSettings();
    notifyListeners();
  }

  void setCarouselDimensions(double width, double height) {
    _carouselWidth = width;
    _carouselHeight = height;
    _saveSettings();
    notifyListeners();
  }

  void setButtonPosition(double left, double bottom) {
    _buttonLeft = left;
    _buttonBottom = bottom;
    _saveSettings();
    notifyListeners();
  }

  void setButtonDimensions(double width, double height) {
    _buttonWidth = width;
    _buttonHeight = height;
    _saveSettings();
    notifyListeners();
  }

  void setPackagingFieldPosition(double left, double bottom) {
    _packagingFieldLeft = left;
    _packagingFieldBottom = bottom;
    _saveSettings();
    notifyListeners();
  }

  void setPackagingFieldWidth(double value) {
    _packagingFieldWidth = value;
    _saveSettings();
    notifyListeners();
  }

  void setPackagingFieldStyle(
      {double? fontSize, Color? textColor, Color? borderColor}) {
    if (fontSize != null) _packagingFieldFontSize = fontSize;
    if (textColor != null) _packagingFieldTextColor = textColor;
    if (borderColor != null) _packagingFieldBorderColor = borderColor;
    _saveSettings();
    notifyListeners();
  }
}
