import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryCardSettings {
  String imagePath;
  bool isAsset;
  double width;
  double height;
  double subCategoryWidth;
  double subCategoryHeight;
  bool useGlow;
  Color glowColor;
  double glowIntensity;
  double glowSpread;
  double glowBlurRadius;

  CategoryCardSettings({
    required this.imagePath,
    this.isAsset = true,
    this.width = 0.30,
    this.height = 0.26,
    this.subCategoryWidth = 0.46,
    this.subCategoryHeight = 0.31,
    this.useGlow = true,
    this.glowColor = AppColors.goldenYellow,
    this.glowIntensity = 0.5,
    this.glowSpread = 10.0,
    this.glowBlurRadius = 80.0,
  });

  factory CategoryCardSettings.fromJson(Map<String, dynamic> json) {
    const double refWidth = 1080.0;
    const double refHeight = 1920.0;

    double toPercent(dynamic value, double defaultValue, double reference) {
      double val = (value as num?)?.toDouble() ?? defaultValue;
      return val > 1.0 ? val / reference : val;
    }

    return CategoryCardSettings(
      imagePath: json['imagePath'],
      isAsset: json['isAsset'] ?? true,
      width: toPercent(json['width'], 0.30, refWidth),
      height: toPercent(json['height'], 0.26, refHeight),
      subCategoryWidth: toPercent(json['subCategoryWidth'], 0.46, refWidth),
      subCategoryHeight: toPercent(json['subCategoryHeight'], 0.31, refHeight),
      useGlow: json['useGlow'] ?? true,
      glowColor: Color(json['glowColor'] ?? AppColors.goldenYellow.value),
      glowIntensity: json['glowIntensity']?.toDouble() ?? 0.5,
      glowSpread: json['glowSpread']?.toDouble() ?? 10.0,
      glowBlurRadius: json['glowBlurRadius']?.toDouble() ?? 80.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'imagePath': imagePath,
        'isAsset': isAsset,
        'width': width,
        'height': height,
        'subCategoryWidth': subCategoryWidth,
        'subCategoryHeight': subCategoryHeight,
        'useGlow': useGlow,
        'glowColor': glowColor.value,
        'glowIntensity': glowIntensity,
        'glowSpread': glowSpread,
        'glowBlurRadius': glowBlurRadius,
      };

  CategoryCardSettings copyWith({
    String? imagePath,
    bool? isAsset,
    double? width,
    double? height,
    double? subCategoryWidth,
    double? subCategoryHeight,
    bool? useGlow,
    Color? glowColor,
    double? glowIntensity,
    double? glowSpread,
    double? glowBlurRadius,
  }) {
    return CategoryCardSettings(
      imagePath: imagePath ?? this.imagePath,
      isAsset: isAsset ?? this.isAsset,
      width: width ?? this.width,
      height: height ?? this.height,
      subCategoryWidth: subCategoryWidth ?? this.subCategoryWidth,
      subCategoryHeight: subCategoryHeight ?? this.subCategoryHeight,
      useGlow: useGlow ?? this.useGlow,
      glowColor: glowColor ?? this.glowColor,
      glowIntensity: glowIntensity ?? this.glowIntensity,
      glowSpread: glowSpread ?? this.glowSpread,
      glowBlurRadius: glowBlurRadius ?? this.glowBlurRadius,
    );
  }
}

class CategorySettingsProvider extends ChangeNotifier {
  late SharedPreferences _prefs;

  String _titleText = '';
  double _titleFontSize = 28.0;
  Color _titleColor = AppColors.white;
  FontWeight _titleFontWeight = FontWeight.bold;
  bool _showTitle = false;

  double _arrowSpacing = 0.11;
  double _carouselWidth = 0.46;
  double _carouselHeight = 0.31;

  double _buttonLeft = 0.22;
  double _buttonBottom = 0.19;
  double _buttonWidth = 0.54;
  double _buttonHeight = 0.08;

  double _packagingFieldLeft = 0.22;
  double _packagingFieldBottom = 0.31;
  double _packagingFieldWidth = 0.55;
  double _packagingFieldFontSize = 19.0;
  Color _packagingFieldTextColor = AppColors.white;
  Color _packagingFieldBorderColor = Colors.white54;
  double _packagingFieldHeight = 0.05;
  double _packagingFieldBorderRadius = 8.0;
  String _packagingFieldLabelText = 'Enter Accessories (e.g., shoes, helmet)';
  Color _packagingFieldLabelColor = Colors.white70;
  double _packagingFieldLabelSize = 19.0;
  Color _packagingFieldFocusedBorderColor = AppColors.white;

  double _mainCategorySpacing = 0.01;

  double _carouselTopSpacing = 0.0;
  double _carouselScale1 = 0.9;
  double _carouselYOffset1 = 0.016;
  double _carouselXOffset1 = -0.093;
  double _carouselScale2 = 0.9;
  double _carouselYOffset2 = 0.016;
  double _carouselXOffset2 = 0.130;
  double _carouselScale3 = 0.8;
  double _carouselYOffset3 = 0.031;

  double _arrowWidth = 0.046;
  double _arrowHeight = 0.026;

  String _nextButtonAsset = 'assets/images/next_btn.png';
  bool _nextButtonIsAsset = true;

  double _titleLeft = 0.0;
  double _titleTop = 0.1;
  double _titleWidth = 1.0;

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
  double get packagingFieldHeight => _packagingFieldHeight;
  double get packagingFieldBorderRadius => _packagingFieldBorderRadius;
  String get packagingFieldLabelText => _packagingFieldLabelText;
  Color get packagingFieldLabelColor => _packagingFieldLabelColor;
  double get packagingFieldLabelSize => _packagingFieldLabelSize;
  Color get packagingFieldFocusedBorderColor =>
      _packagingFieldFocusedBorderColor;

  double get mainCategorySpacing => _mainCategorySpacing;
  double get carouselTopSpacing => _carouselTopSpacing;
  double get carouselScale1 => _carouselScale1;
  double get carouselYOffset1 => _carouselYOffset1;
  double get carouselXOffset1 => _carouselXOffset1;
  double get carouselScale2 => _carouselScale2;
  double get carouselYOffset2 => _carouselYOffset2;
  double get carouselXOffset2 => _carouselXOffset2;
  double get carouselScale3 => _carouselScale3;
  double get carouselYOffset3 => _carouselYOffset3;
  double get arrowWidth => _arrowWidth;
  double get arrowHeight => _arrowHeight;
  String get nextButtonAsset => _nextButtonAsset;
  bool get nextButtonIsAsset => _nextButtonIsAsset;

  String _backgroundImagePath = "assets/images/categories_bg.png";
  bool _isBackgroundImageAsset = true;
  bool _showBackground = true;

  CategoryCardSettings _aiArtistryCard =
      CategoryCardSettings(imagePath: 'assets/images/ai_artistry.png');
  CategoryCardSettings _swaplabCard =
      CategoryCardSettings(imagePath: 'assets/images/swaplab.png');

  CategoryCardSettings _ghibliCard =
      CategoryCardSettings(imagePath: 'assets/images/ghibli.png');
  CategoryCardSettings _pixarCard =
      CategoryCardSettings(imagePath: 'assets/images/pixar.png');
  CategoryCardSettings _packagingCard =
      CategoryCardSettings(imagePath: 'assets/images/packaging.png');

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

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await loadSettings();
  }

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

  Future<void> loadSettings() async {
    final settingsJson = _prefs.getString('category_screen_settings');
    if (settingsJson != null) {
      final settings = jsonDecode(settingsJson);

      const double refWidth = 1080.0;
      const double refHeight = 1920.0;

      double toPercent(dynamic value, double defaultValue, double reference) {
        double val = (value as num?)?.toDouble() ?? defaultValue;
        return val > 1.0 ? val / reference : val;
      }

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
      _packagingFieldHeight =
          _prefs.getDouble('category_packaging_field_height') ??
              _packagingFieldHeight;
      _packagingFieldBorderRadius =
          _prefs.getDouble('category_packaging_field_border_radius') ??
              _packagingFieldBorderRadius;
      _packagingFieldLabelText =
          _prefs.getString('category_packaging_field_label_text') ??
              _packagingFieldLabelText;
      _packagingFieldLabelColor = Color(
          _prefs.getInt('category_packaging_field_label_color') ??
              _packagingFieldLabelColor.value);
      _packagingFieldLabelSize =
          _prefs.getDouble('category_packaging_field_label_size') ??
              _packagingFieldLabelSize;
      _packagingFieldFocusedBorderColor = Color(
          _prefs.getInt('category_packaging_field_focused_border_color') ??
              _packagingFieldFocusedBorderColor.value);
      _mainCategorySpacing =
          _prefs.getDouble('category_main_category_spacing') ??
              _mainCategorySpacing;
      _carouselTopSpacing = _prefs.getDouble('category_carousel_top_spacing') ??
          _carouselTopSpacing;
      _carouselScale1 =
          _prefs.getDouble('category_carousel_scale1') ?? _carouselScale1;
      _carouselYOffset1 =
          _prefs.getDouble('category_carousel_y_offset1') ?? _carouselYOffset1;
      _carouselXOffset1 =
          _prefs.getDouble('category_carousel_x_offset1') ?? _carouselXOffset1;
      _carouselScale2 =
          _prefs.getDouble('category_carousel_scale2') ?? _carouselScale2;
      _carouselYOffset2 =
          _prefs.getDouble('category_carousel_y_offset2') ?? _carouselYOffset2;
      _carouselXOffset2 =
          _prefs.getDouble('category_carousel_x_offset2') ?? _carouselXOffset2;
      _carouselScale3 =
          _prefs.getDouble('category_carousel_scale3') ?? _carouselScale3;
      _carouselYOffset3 =
          _prefs.getDouble('category_carousel_y_offset3') ?? _carouselYOffset3;
      _arrowWidth = _prefs.getDouble('category_arrow_width') ?? _arrowWidth;
      _arrowHeight = _prefs.getDouble('category_arrow_height') ?? _arrowHeight;
      _nextButtonAsset =
          _prefs.getString('category_next_button_asset') ?? _nextButtonAsset;
      _nextButtonIsAsset =
          _prefs.getBool('category_next_button_is_asset') ?? _nextButtonIsAsset;

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
    await _prefs.setDouble(
        'category_packaging_field_height', _packagingFieldHeight);
    await _prefs.setDouble(
        'category_packaging_field_border_radius', _packagingFieldBorderRadius);
    await _prefs.setString(
        'category_packaging_field_label_text', _packagingFieldLabelText);
    await _prefs.setInt('category_packaging_field_label_color',
        _packagingFieldLabelColor.value);
    await _prefs.setDouble(
        'category_packaging_field_label_size', _packagingFieldLabelSize);
    await _prefs.setInt('category_packaging_field_focused_border_color',
        _packagingFieldFocusedBorderColor.value);
    await _prefs.setDouble(
        'category_main_category_spacing', _mainCategorySpacing);
    await _prefs.setDouble(
        'category_carousel_top_spacing', _carouselTopSpacing);
    await _prefs.setDouble('category_carousel_scale1', _carouselScale1);
    await _prefs.setDouble('category_carousel_y_offset1', _carouselYOffset1);
    await _prefs.setDouble('category_carousel_x_offset1', _carouselXOffset1);
    await _prefs.setDouble('category_carousel_scale2', _carouselScale2);
    await _prefs.setDouble('category_carousel_y_offset2', _carouselYOffset2);
    await _prefs.setDouble('category_carousel_x_offset2', _carouselXOffset2);
    await _prefs.setDouble('category_carousel_scale3', _carouselScale3);
    await _prefs.setDouble('category_carousel_y_offset3', _carouselYOffset3);
    await _prefs.setDouble('category_arrow_width', _arrowWidth);
    await _prefs.setDouble('category_arrow_height', _arrowHeight);
    await _prefs.setString('category_next_button_asset', _nextButtonAsset);
    await _prefs.setBool('category_next_button_is_asset', _nextButtonIsAsset);
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
      {double? fontSize,
      Color? textColor,
      Color? borderColor,
      double? height,
      double? borderRadius,
      String? labelText,
      Color? labelColor,
      double? labelSize,
      Color? focusedBorderColor}) {
    if (fontSize != null) _packagingFieldFontSize = fontSize;
    if (textColor != null) _packagingFieldTextColor = textColor;
    if (borderColor != null) _packagingFieldBorderColor = borderColor;
    if (height != null) _packagingFieldHeight = height;
    if (borderRadius != null) _packagingFieldBorderRadius = borderRadius;
    if (labelText != null) _packagingFieldLabelText = labelText;
    if (labelColor != null) _packagingFieldLabelColor = labelColor;
    if (labelSize != null) _packagingFieldLabelSize = labelSize;
    if (focusedBorderColor != null)
      _packagingFieldFocusedBorderColor = focusedBorderColor;
    _saveSettings();
    notifyListeners();
  }

  void setMainCategorySpacing(double spacing) {
    _mainCategorySpacing = spacing;
    _saveSettings();
    notifyListeners();
  }

  void setCarouselPositioning(
      {double? topSpacing,
      double? scale1,
      double? yOffset1,
      double? xOffset1,
      double? scale2,
      double? yOffset2,
      double? xOffset2,
      double? scale3,
      double? yOffset3}) {
    if (topSpacing != null) _carouselTopSpacing = topSpacing;
    if (scale1 != null) _carouselScale1 = scale1;
    if (yOffset1 != null) _carouselYOffset1 = yOffset1;
    if (xOffset1 != null) _carouselXOffset1 = xOffset1;
    if (scale2 != null) _carouselScale2 = scale2;
    if (yOffset2 != null) _carouselYOffset2 = yOffset2;
    if (xOffset2 != null) _carouselXOffset2 = xOffset2;
    if (scale3 != null) _carouselScale3 = scale3;
    if (yOffset3 != null) _carouselYOffset3 = yOffset3;
    _saveSettings();
    notifyListeners();
  }

  void setArrowDimensions(double width, double height) {
    _arrowWidth = width;
    _arrowHeight = height;
    _saveSettings();
    notifyListeners();
  }

  void setNextButtonAsset(String asset, {required bool isAsset}) {
    _nextButtonAsset = asset;
    _nextButtonIsAsset = isAsset;
    _saveSettings();
    notifyListeners();
  }
}
