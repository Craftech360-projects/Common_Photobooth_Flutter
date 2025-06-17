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
  Color borderColor;
  double scale;
  bool useGlow;
  Color glowColor;
  double glowIntensity;
  double glowSpread;

  CategoryCardSettings({
    required this.imagePath,
    this.isAsset = true,
    this.width = 408.0,
    this.height = 494.0,
    this.borderRadius = 0.0,
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
  factory CategoryCardSettings.fromJson(Map<String, dynamic> json) =>
      CategoryCardSettings(
        imagePath: json['imagePath'],
        isAsset: json['isAsset'] ?? true,
        width: json['width']?.toDouble() ?? 280.0,
        height: json['height']?.toDouble() ?? 420.0,
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
  }
}
