// lib/providers/registration_screen_provider.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TextFieldType { name, email, phone, custom }

class CustomTextField {
  final String id;
  final String label;
  final String hintText;
  bool isEnabled;
  final bool isRequired;
  final Color fillColor;
  final Color textColor;
  final Color labelColor;
  final double fontSize;
  final FontWeight fontWeight;
  final bool isItalic;
  final bool hasBorder;
  final double borderWidth;
  final Color borderColor;
  final double borderRadius;
  final double width;
  final double height;
  final TextFieldType fieldType;
  final double left;
  final double top;

  CustomTextField({
    required this.id,
    required this.label,
    required this.hintText,
    this.isEnabled = true,
    this.isRequired = true,
    this.fillColor = AppColors.white,
    this.textColor = AppColors.black,
    this.labelColor = AppColors.black,
    this.fontSize = 46.0,
    this.fontWeight = FontWeight.w500,
    this.isItalic = false,
    this.hasBorder = true,
    this.borderWidth = 1.0,
    this.borderColor = AppColors.black,
    this.borderRadius = 0.0,
    this.width = 650.0, // Default absolute width
    this.height = 100.0,
    this.left = 180.0,
    this.top = 880.0,
    this.fieldType = TextFieldType.custom,
  });

  CustomTextField copyWith({
    String? id,
    String? label,
    String? hintText,
    bool? isEnabled,
    bool? isRequired,
    Color? fillColor,
    Color? textColor,
    Color? labelColor,
    double? fontSize,
    FontWeight? fontWeight,
    bool? isItalic,
    bool? hasBorder,
    double? borderWidth,
    Color? borderColor,
    double? borderRadius,
    double? width,
    double? height,
    TextFieldType? fieldType,
    double? left,
    double? top,
  }) {
    return CustomTextField(
      id: id ?? this.id,
      label: label ?? this.label,
      hintText: hintText ?? this.hintText,
      isEnabled: isEnabled ?? this.isEnabled,
      isRequired: isRequired ?? this.isRequired,
      fillColor: fillColor ?? this.fillColor,
      textColor: textColor ?? this.textColor,
      labelColor: labelColor ?? this.labelColor,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      isItalic: isItalic ?? this.isItalic,
      hasBorder: hasBorder ?? this.hasBorder,
      borderWidth: borderWidth ?? this.borderWidth,
      borderColor: borderColor ?? this.borderColor,
      borderRadius: borderRadius ?? this.borderRadius,
      width: width ?? this.width,
      height: height ?? this.height,
      fieldType: fieldType ?? this.fieldType,
      left: left ?? this.left,
      top: top ?? this.top,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'hintText': hintText,
        'isEnabled': isEnabled,
        'isRequired': isRequired,
        'fillColor': fillColor.value,
        'textColor': textColor.value,
        'labelColor': labelColor.value,
        'fontSize': fontSize,
        'fontWeight': fontWeight.index,
        'isItalic': isItalic,
        'hasBorder': hasBorder,
        'borderWidth': borderWidth,
        'borderColor': borderColor.value,
        'borderRadius': borderRadius,
        'width': width,
        'height': height,
        'left': left,
        'top': top,
        'fieldType': fieldType.name,
      };

  factory CustomTextField.fromJson(Map<String, dynamic> json) {
    TextFieldType getTextFieldTypeFromName(String? name) {
      if (name == null) return TextFieldType.custom;
      return TextFieldType.values.firstWhere((e) => e.name == name,
          orElse: () => TextFieldType.custom);
    }

    return CustomTextField(
      id: json['id'],
      label: json['label'],
      hintText: json['hintText'],
      isEnabled: json['isEnabled'] ?? true,
      isRequired: json['isRequired'] ?? true,
      fillColor: Color(json['fillColor'] ?? AppColors.white.value),
      textColor: Color(json['textColor'] ?? AppColors.black.value),
      labelColor: Color(json['labelColor'] ?? AppColors.black.value),
      fontSize: json['fontSize']?.toDouble() ?? 16.0,
      fontWeight:
          FontWeight.values[json['fontWeight'] ?? FontWeight.normal.index],
      isItalic: json['isItalic'] ?? false,
      hasBorder: json['hasBorder'] ?? true,
      borderWidth: json['borderWidth']?.toDouble() ?? 1.0,
      borderColor: Color(json['borderColor'] ?? AppColors.black.value),
      borderRadius: json['borderRadius']?.toDouble() ?? 4.0,
      // *** FIX: Use a consistent absolute pixel default value ***
      width: json['width']?.toDouble() ?? 650.0, // Was 0.55
      height: json['height']?.toDouble() ?? 100.0, // Increased default height
      left: json['left']?.toDouble() ?? 180.0, // Adjusted default position
      top: json['top']?.toDouble() ?? 880.0, // Adjusted default position
      fieldType: getTextFieldTypeFromName(json['fieldType']),
    );
  }
}

class RegistrationScreenProvider extends ChangeNotifier {
  late SharedPreferences _prefs;

  // Registration screen settings
  bool _showRegistrationScreen = true;
  double _fieldSpacing = 0.0;
  double _buttonSpacing = 0.0;
  double _borderRadius = 4.0;
  List<CustomTextField> _textFields = [];

  // Title settings
  bool _showTitle = false;
  String _titleText = "";
  double _titleFontSize = 22.0;
  FontWeight _titleFontWeight = FontWeight.w500;
  double _titleLineHeight = 1.0;
  TextAlign _titleTextAlign = TextAlign.center;
  Color _titleTextColor = AppColors.white;
  double _titleLeft = 395.0;
  double _titleTop = 900.0;
  double _titleWidth = 300.0;

  // Button settings
  bool _useImageButton = true;
  String _submitButtonText = 'SUBMIT';
  Color _submitButtonColor = AppColors.goldenYellow;
  Color _submitButtonTextColor = AppColors.black;
  double _buttonWidth = 585.0;
  double _buttonHeight = 150.0;
  double _buttonBorderRadius = 0.0;
  double _buttonFontSize = 18.0;
  FontWeight _buttonFontWeight = FontWeight.w500;
  bool _buttonIsItalic = false;
  bool _buttonHasBorder = false;
  double _buttonBorderWidth = 0.0;
  Color _buttonBorderColor = AppColors.white;
  EdgeInsets _buttonPadding =
      const EdgeInsets.symmetric(horizontal: 30, vertical: 15);
  double _buttonOpacity = 1.0;
  double _buttonTextOpacity = 1.0;
  double _buttonLeft = 246.0;
  double _buttonBottom = 530.0;

  // Image button settings
  String? _buttonImagePath = 'assets/images/submit_btn.png';
  bool _isButtonImageAsset = true;
  double _buttonImageOpacity = 1.0;

  // Background settings
  String? _registrationScreenBackground = 'assets/images/registration_bg.png';
  bool _isRegistrationScreenBackgroundAsset = true;

  // Getters
  bool get showRegistrationScreen => _showRegistrationScreen;
  double get fieldSpacing => _fieldSpacing;
  double get buttonSpacing => _buttonSpacing;
  double get borderRadius => _borderRadius;
  List<CustomTextField> get textFields => _textFields;

  // Title getters
  bool get showTitle => _showTitle;
  String get titleText => _titleText;
  double get titleFontSize => _titleFontSize;
  FontWeight get titleFontWeight => _titleFontWeight;
  double get titleLineHeight => _titleLineHeight;
  TextAlign get titleTextAlign => _titleTextAlign;
  Color get titleTextColor => _titleTextColor;
  double get titleLeft => _titleLeft;
  double get titleTop => _titleTop;
  double get titleWidth => _titleWidth;

  FontWeight get buttonFontWeight => _buttonFontWeight;
  bool get buttonIsItalic => _buttonIsItalic;
  double get buttonOpacity => _buttonOpacity;
  double get buttonTextOpacity => _buttonTextOpacity;
  double get buttonImageOpacity => _buttonImageOpacity;

  bool get useImageButton => _useImageButton;
  String get submitButtonText => _submitButtonText;
  Color get submitButtonColor => _submitButtonColor;
  Color get submitButtonTextColor => _submitButtonTextColor;
  double get buttonWidth => _buttonWidth;
  double get buttonHeight => _buttonHeight;
  double get buttonBorderRadius => _buttonBorderRadius;
  double get buttonFontSize => _buttonFontSize;
  bool get buttonHasBorder => _buttonHasBorder;
  double get buttonBorderWidth => _buttonBorderWidth;
  Color get buttonBorderColor => _buttonBorderColor;
  EdgeInsets get buttonPadding => _buttonPadding;
  double get buttonLeft => _buttonLeft;
  double get buttonBottom => _buttonBottom;

  String? get buttonImagePath => _buttonImagePath;
  bool get isButtonImageAsset => _isButtonImageAsset;
  String? get registrationScreenBackground => _registrationScreenBackground;
  bool get isRegistrationScreenBackgroundAsset =>
      _isRegistrationScreenBackgroundAsset;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await loadSettings();
  }

  Future<void> loadSettings() async {
    // Load registration screen settings
    _showRegistrationScreen =
        _prefs.getBool('registration_show_screen') ?? _showRegistrationScreen;
    _fieldSpacing =
        _prefs.getDouble('registration_field_spacing') ?? _fieldSpacing;
    _buttonSpacing =
        _prefs.getDouble('registration_button_spacing') ?? _buttonSpacing;
    _borderRadius =
        _prefs.getDouble('registration_border_radius') ?? _borderRadius;

    // Load title settings
    _showTitle = _prefs.getBool('registration_show_title') ?? _showTitle;
    _titleText = _prefs.getString('registration_title_text') ?? _titleText;
    _titleFontSize =
        _prefs.getDouble('registration_title_font_size') ?? _titleFontSize;
    _titleFontWeight = FontWeight.values[
        _prefs.getInt('registration_title_font_weight') ??
            _titleFontWeight.index];
    _titleLineHeight =
        _prefs.getDouble('registration_title_line_height') ?? _titleLineHeight;
    _titleTextAlign = TextAlign.values[
        _prefs.getInt('registration_title_text_align') ??
            _titleTextAlign.index];
    _titleTextColor = Color(_prefs.getInt('registration_title_text_color') ??
        _titleTextColor.value);

    _titleLeft = _prefs.getDouble('registration_title_left') ?? _titleLeft;
    _titleTop = _prefs.getDouble('registration_title_top') ?? _titleTop;
    _titleWidth = _prefs.getDouble('registration_title_width') ?? _titleWidth;

// Load button position
    _buttonLeft = _prefs.getDouble('registration_button_left') ?? _buttonLeft;
    _buttonBottom =
        _prefs.getDouble('registration_button_bottom') ?? _buttonBottom;

    // Load button padding
    final double verticalPadding =
        _prefs.getDouble('registration_button_padding_vertical') ?? 12.0;
    final double horizontalPadding =
        _prefs.getDouble('registration_button_padding_horizontal') ?? 18.0;
    _buttonPadding = EdgeInsets.symmetric(
        vertical: verticalPadding, horizontal: horizontalPadding);

    // Load text fields
    final String? fieldsJson = _prefs.getString('registration_text_fields');
    if (fieldsJson != null) {
      try {
        // Add try-catch for robust parsing
        final List<dynamic> fields = jsonDecode(fieldsJson);
        _textFields.clear();
        _textFields.addAll(
          fields.map((field) =>
              CustomTextField.fromJson(field)), // Use factory constructor
        );
      } on Exception catch (e) {
        debugPrint("Error decoding text fields JSON: $e. Using defaults.");
        _setDefaultTextFields(); // Fallback to defaults on error
      }
    } else {
      _setDefaultTextFields(); // Use default text fields
    }

    // Load button settings
    _useImageButton =
        _prefs.getBool('registration_use_image_button') ?? _useImageButton;
    _buttonImagePath =
        _prefs.getString('registration_button_image_path') ?? _buttonImagePath;
    _isButtonImageAsset =
        _prefs.getBool('registration_is_button_image_asset') ??
            _isButtonImageAsset;

    _submitButtonText =
        _prefs.getString('registration_button_text') ?? _submitButtonText;
    _submitButtonColor = Color(
        _prefs.getInt('registration_button_color') ?? _submitButtonColor.value);
    _submitButtonTextColor = Color(
        _prefs.getInt('registration_button_text_color') ??
            _submitButtonTextColor.value);
    _buttonWidth =
        _prefs.getDouble('registration_button_width') ?? _buttonWidth;
    _buttonHeight =
        _prefs.getDouble('registration_button_height') ?? _buttonHeight;
    _buttonBorderRadius =
        _prefs.getDouble('registration_button_border_radius') ??
            _buttonBorderRadius;
    _buttonFontSize =
        _prefs.getDouble('registration_button_font_size') ?? _buttonFontSize;
    _buttonFontWeight = FontWeight.values[
        _prefs.getInt('registration_button_font_weight') ??
            _buttonFontWeight.index];
    _buttonIsItalic =
        _prefs.getBool('registration_button_is_italic') ?? _buttonIsItalic;
    _buttonHasBorder =
        _prefs.getBool('registration_button_has_border') ?? _buttonHasBorder;
    _buttonBorderWidth = _prefs.getDouble('registration_button_border_width') ??
        _buttonBorderWidth;
    _buttonBorderColor = Color(
        _prefs.getInt('registration_button_border_color') ??
            _buttonBorderColor.value);
    _buttonOpacity =
        _prefs.getDouble('registration_button_opacity') ?? _buttonOpacity;
    _buttonTextOpacity = _prefs.getDouble('registration_button_text_opacity') ??
        _buttonTextOpacity;
    _buttonImageOpacity =
        _prefs.getDouble('registration_button_image_opacity') ??
            _buttonImageOpacity;

    // Load padding and margin
    final String? paddingJson = _prefs.getString('registration_button_padding');
    if (paddingJson != null) {
      final Map<String, dynamic> padding = jsonDecode(paddingJson);
      _buttonPadding = EdgeInsets.fromLTRB(
        padding['left']?.toDouble() ?? 30.0,
        padding['top']?.toDouble() ?? 15.0,
        padding['right']?.toDouble() ?? 30.0,
        padding['bottom']?.toDouble() ?? 15.0,
      );
    }

    // Verify button image file exists if it's not an asset
    if (_buttonImagePath != null && !_isButtonImageAsset) {
      final file = File(_buttonImagePath!);
      if (!file.existsSync()) {
        _buttonImagePath = null;
        await _prefs.remove('registration_button_image_path');
      }
    }

    // Load background settings
    _registrationScreenBackground =
        _prefs.getString('registration_screen_background') ??
            _registrationScreenBackground;
    _isRegistrationScreenBackgroundAsset =
        _prefs.getBool('registration_is_screen_background_asset') ??
            _isRegistrationScreenBackgroundAsset;

    // Verify background image file exists if it's not an asset
    if (_registrationScreenBackground != null &&
        !_isRegistrationScreenBackgroundAsset) {
      final file = File(_registrationScreenBackground!);
      if (!file.existsSync()) {
        _registrationScreenBackground = null;
        await _prefs.remove('registration_screen_background');
      }
    }

    notifyListeners();
  }

  // Title setters
  void setShowTitle(bool show) {
    _showTitle = show;
    _prefs.setBool('registration_show_title', show);
    notifyListeners();
  }

  void setTitleText(String text) {
    _titleText = text;
    _prefs.setString('registration_title_text', text);
    notifyListeners();
  }

  void setTitleFontSize(double size) {
    _titleFontSize = size;
    _prefs.setDouble('registration_title_font_size', size);
    notifyListeners();
  }

  void setTitleFontWeight(FontWeight weight) {
    _titleFontWeight = weight;
    _prefs.setInt('registration_title_font_weight', weight.index);
    notifyListeners();
  }

  void setTitleLineHeight(double height) {
    _titleLineHeight = height;
    _prefs.setDouble('registration_title_line_height', height);
    notifyListeners();
  }

  void setTitleTextAlign(TextAlign align) {
    _titleTextAlign = align;
    _prefs.setInt('registration_title_text_align', align.index);
    notifyListeners();
  }

  void setTitleTextColor(Color color) {
    _titleTextColor = color;
    _prefs.setInt('registration_title_text_color', color.value);
    notifyListeners();
  }

  void setTitlePosition(double left, double top, double width) {
    _titleLeft = left;
    _titleTop = top;
    _titleWidth = width;
    _prefs.setDouble('registration_title_left', left);
    _prefs.setDouble('registration_title_top', top);
    _prefs.setDouble('registration_title_width', width);
    notifyListeners();
  }

  void setButtonPosition(double left, double bottom) {
    _buttonLeft = left;
    _buttonBottom = bottom;
    _prefs.setDouble('registration_button_left', left);
    _prefs.setDouble('registration_button_bottom', bottom);
    notifyListeners();
  }

  void _setDefaultTextFields() {
    _textFields = [
      CustomTextField(
          id: 'name',
          label: 'Full Name',
          hintText: '',
          fieldType: TextFieldType.name,
          hasBorder: false,
          left: 180,
          top: 880.0),
      CustomTextField(
          id: 'email',
          label: 'Email Address',
          hintText: '',
          fieldType: TextFieldType.email,
          hasBorder: false,
          left: 180,
          top: 1066.0),
    ];
  }

  // Add new methods for button styling
  void setButtonFontWeight(FontWeight weight) async {
    _buttonFontWeight = weight;
    await _prefs.setInt('registration_button_font_weight', weight.index);
    notifyListeners();
  }

  void setButtonPadding(EdgeInsets padding) async {
    _buttonPadding = padding;
    await _prefs.setDouble('registration_button_padding_vertical', padding.top);
    await _prefs.setDouble(
        'registration_button_padding_horizontal', padding.left);
    notifyListeners();
  }

  void setButtonIsItalic(bool isItalic) async {
    _buttonIsItalic = isItalic;
    await _prefs.setBool('registration_button_is_italic', isItalic);
    notifyListeners();
  }

  void setButtonOpacity(double opacity) async {
    _buttonOpacity = opacity;
    await _prefs.setDouble('registration_button_opacity', opacity);
    notifyListeners();
  }

  void setButtonTextOpacity(double opacity) async {
    _buttonTextOpacity = opacity;
    await _prefs.setDouble('registration_button_text_opacity', opacity);
    notifyListeners();
  }

  void setButtonImageOpacity(double opacity) async {
    _buttonImageOpacity = opacity;
    await _prefs.setDouble('registration_button_image_opacity', opacity);
    notifyListeners();
  }

  // Screen settings methods
  void setShowRegistrationScreen(bool show) async {
    _showRegistrationScreen = show;
    await _prefs.setBool('registration_show_screen', show);
    notifyListeners();
  }

  void setFieldSpacing(double spacing) async {
    _fieldSpacing = spacing;
    await _prefs.setDouble('registration_field_spacing', spacing);
    notifyListeners();
  }

  void setButtonSpacing(double spacing) async {
    _buttonSpacing = spacing;
    await _prefs.setDouble('registration_button_spacing', spacing);
    notifyListeners();
  }

  void setBorderRadius(double radius) async {
    _borderRadius = radius;
    await _prefs.setDouble('registration_border_radius', radius);
    notifyListeners();
  }

  // Text field methods
  void addTextField() {
    if (_textFields.length >= 3) return;
    final newField = CustomTextField(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: 'New Field',
      hintText: 'Enter value',
      fieldType: TextFieldType.custom,
      top: 1060.0,
    );
    _textFields.add(newField);
    _saveTextFields();
    notifyListeners();
  }

  void updateTextFieldPosition(String id, double left, double top) {
    final index = _textFields.indexWhere((field) => field.id == id);
    if (index != -1) {
      final field = _textFields[index];
      final updatedField = field.copyWith(left: left, top: top);
      _textFields[index] = updatedField;
      _saveTextFields();
      notifyListeners();
    }
  }

  void updateTextField(String id, CustomTextField updatedField) {
    final index = _textFields.indexWhere((field) => field.id == id);
    if (index != -1) {
      _textFields[index] = updatedField;
      _saveTextFields();
      notifyListeners();
    }
  }

  void removeTextField(String id) async {
    // Ensure at least one field remains
    if (_textFields.length <= 1) {
      return;
    }

    _textFields.removeWhere((field) => field.id == id);
    await _saveTextFields();
    notifyListeners();
  }

  void toggleTextFieldEnabled(String id, bool enabled) async {
    // Count enabled fields
    int enabledCount = _textFields.where((field) => field.isEnabled).length;

    // If trying to disable and only one is enabled, prevent it
    if (!enabled && enabledCount <= 1) {
      return;
    }

    final index = _textFields.indexWhere((field) => field.id == id);
    if (index != -1) {
      _textFields[index].isEnabled = enabled;
      await _saveTextFields();
      notifyListeners();
    }
  }

  // Update the _saveTextFields method to include new properties
  Future<void> _saveTextFields() async {
    // Use the toJson helper method from CustomTextField
    final List<Map<String, dynamic>> fieldsMap =
        _textFields.map((field) => field.toJson()).toList();
    await _prefs.setString('registration_text_fields', jsonEncode(fieldsMap));
  }

  // Add method to update text field with new properties
  void updateTextFieldStyle({
    required String id,
    FontWeight? fontWeight,
    bool? isItalic,
    double? borderRadius,
    EdgeInsets? margin,
    EdgeInsets? padding,
    // Add other style properties if needed
  }) async {
    final index = _textFields.indexWhere((field) => field.id == id);
    if (index != -1) {
      // Create a copy with updated styles, preserving other properties like fieldType
      final currentField = _textFields[index];
      _textFields[index] = currentField.copyWith(
        fontWeight: fontWeight,
        isItalic: isItalic,
        borderRadius: borderRadius,
      );

      await _saveTextFields();
      notifyListeners();
    }
  }

  void setUseImageButton(bool use) async {
    _useImageButton = use;
    await _prefs.setBool('registration_use_image_button', use);
    notifyListeners();
  }

  void setSubmitButtonText(String text) async {
    _submitButtonText = text;
    await _prefs.setString('registration_button_text', text);
    notifyListeners();
  }

  void setSubmitButtonColor(Color color) async {
    _submitButtonColor = color;
    await _prefs.setInt('registration_button_color', color.value);
    notifyListeners();
  }

  void setSubmitButtonTextColor(Color color) async {
    _submitButtonTextColor = color;
    await _prefs.setInt('registration_button_text_color', color.value);
    notifyListeners();
  }

  void setButtonDimensions(double width, double height) async {
    _buttonWidth = width;
    _buttonHeight = height;
    await _prefs.setDouble('registration_button_width', width);
    await _prefs.setDouble('registration_button_height', height);
    notifyListeners();
  }

  void setButtonBorderRadius(double radius) async {
    _buttonBorderRadius = radius;
    await _prefs.setDouble('registration_button_border_radius', radius);
    notifyListeners();
  }

  void setButtonFontSize(double size) async {
    _buttonFontSize = size;
    await _prefs.setDouble('registration_button_font_size', size);
    notifyListeners();
  }

  void setButtonBorder(bool hasBorder, double width, Color color) async {
    _buttonHasBorder = hasBorder;
    _buttonBorderWidth = width;
    _buttonBorderColor = color;
    await _prefs.setBool('registration_button_has_border', hasBorder);
    await _prefs.setDouble('registration_button_border_width', width);
    await _prefs.setInt('registration_button_border_color', color.value);
    notifyListeners();
  }

  // Image button methods
  Future<void> setButtonImage(String? sourcePath, {bool isAsset = true}) async {
    if (sourcePath == null) {
      _buttonImagePath = null;
      _isButtonImageAsset = true;
      await _prefs.remove('registration_button_image_path');
      await _prefs.setBool('registration_is_button_image_asset', true);
      notifyListeners();
      return;
    }

    if (isAsset) {
      // For asset images, just store the path
      _buttonImagePath = sourcePath;
      _isButtonImageAsset = true;
    } else {
      // For file images, copy to app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName =
          'registration_button_${DateTime.now().millisecondsSinceEpoch}${path.extension(sourcePath)}';
      final destinationPath = path.join(appDir.path, fileName);

      try {
        final sourceFile = File(sourcePath);
        await sourceFile.copy(destinationPath);
        _buttonImagePath = destinationPath;
        _isButtonImageAsset = false;
      } on Exception catch (e) {
        debugPrint('Error copying button image: $e');
        return;
      }
    }

    await _prefs.setString('registration_button_image_path', _buttonImagePath!);
    await _prefs.setBool(
        'registration_is_button_image_asset', _isButtonImageAsset);
    notifyListeners();
  }

  // Background methods
  Future<void> setRegistrationScreenBackground(String? sourcePath,
      {bool isAsset = true}) async {
    if (sourcePath == null) {
      _registrationScreenBackground = null;
      _isRegistrationScreenBackgroundAsset = true;
      await _prefs.remove('registration_screen_background');
      await _prefs.setBool('registration_is_screen_background_asset', true);
      notifyListeners();
      return;
    }

    if (isAsset) {
      // For asset images, just store the path
      _registrationScreenBackground = sourcePath;
      _isRegistrationScreenBackgroundAsset = true;
    } else {
      // For file images, copy to app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName =
          'registration_background_${DateTime.now().millisecondsSinceEpoch}${path.extension(sourcePath)}';
      final destinationPath = path.join(appDir.path, fileName);

      try {
        final sourceFile = File(sourcePath);
        await sourceFile.copy(destinationPath);
        _registrationScreenBackground = destinationPath;
        _isRegistrationScreenBackgroundAsset = false;
      } on Exception catch (e) {
        debugPrint('Error copying background image: $e');
        return;
      }
    }

    await _prefs.setString(
        'registration_screen_background', _registrationScreenBackground!);
    await _prefs.setBool('registration_is_screen_background_asset',
        _isRegistrationScreenBackgroundAsset);
    notifyListeners();
  }
}
