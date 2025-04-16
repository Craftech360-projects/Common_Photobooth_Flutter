import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- NEW ENUM ---
enum TextFieldType {
  name,
  email,
  phone, // Added phone as an example
  custom, // For generic fields
}

class CustomTextField {
  String id;
  String label;
  String hintText;
  bool isEnabled;
  bool isRequired;
  Color fillColor;
  Color textColor;
  Color labelColor;
  double fontSize;
  FontWeight fontWeight;
  bool isItalic;
  bool hasBorder;
  double borderWidth;
  Color borderColor;
  double borderRadius;
  double width;
  double height;
  EdgeInsets margin;
  EdgeInsets padding;
  TextFieldType fieldType;

  CustomTextField({
    required this.id,
    required this.label,
    required this.hintText,
    this.isEnabled = true,
    this.isRequired = true,
    this.fillColor = Colors.white,
    this.textColor = AppColors.black,
    this.labelColor = AppColors.black,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.normal,
    this.isItalic = false,
    this.hasBorder = true,
    this.borderWidth = 1.0,
    this.borderColor = AppColors.black,
    this.borderRadius = 4.0,
    this.width = 0.35, // Percentage of screen width
    this.height = 60.0,
    this.margin = EdgeInsets.zero,
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0),
    this.fieldType = TextFieldType.custom,
  });

  // Helper method for serialization (optional but good practice)
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
        'margin': {
          'left': margin.left,
          'top': margin.top,
          'right': margin.right,
          'bottom': margin.bottom,
        },
        'padding': {
          'left': padding.left,
          'top': padding.top,
          'right': padding.right,
          'bottom': padding.bottom,
        },
        'fieldType': fieldType.name, // --- SERIALIZE ENUM NAME ---
      };
// Helper method for deserialization (optional but good practice)
  factory CustomTextField.fromJson(Map<String, dynamic> json) {
    // Helper to safely get enum from name
    TextFieldType getTextFieldTypeFromName(String? name) {
      if (name == null) return TextFieldType.custom;
      return TextFieldType.values.firstWhere(
        (e) => e.name == name,
        orElse: () => TextFieldType.custom, // Default if name doesn't match
      );
    }

    return CustomTextField(
      id: json['id'],
      label: json['label'],
      hintText: json['hintText'],
      isEnabled: json['isEnabled'] ?? true,
      isRequired: json['isRequired'] ?? true,
      fillColor: Color(json['fillColor'] ?? Colors.white.value),
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
      width: json['width']?.toDouble() ?? 0.35,
      height: json['height']?.toDouble() ?? 60.0,
      margin: json['margin'] != null
          ? EdgeInsets.fromLTRB(
              json['margin']['left']?.toDouble() ?? 0.0,
              json['margin']['top']?.toDouble() ?? 0.0,
              json['margin']['right']?.toDouble() ?? 0.0,
              json['margin']['bottom']?.toDouble() ?? 0.0,
            )
          : EdgeInsets.zero,
      padding: json['padding'] != null
          ? EdgeInsets.fromLTRB(
              json['padding']['left']?.toDouble() ?? 12.0,
              json['padding']['top']?.toDouble() ?? 0.0,
              json['padding']['right']?.toDouble() ?? 12.0,
              json['padding']['bottom']?.toDouble() ?? 0.0,
            )
          : const EdgeInsets.symmetric(horizontal: 12.0),
      fieldType: getTextFieldTypeFromName(
          json['fieldType']), // --- DESERIALIZE ENUM NAME ---
    );
  }
}

class RegistrationScreenProvider extends ChangeNotifier {
  late SharedPreferences _prefs;

  // Registration screen settings
  bool _showRegistrationScreen = true;
  double _fieldSpacing = 20.0;
  double _buttonSpacing = 40.0;
  double _borderRadius = 4.0;
  List<CustomTextField> _textFields = [];

  // Button settings
  bool _useImageButton = false;
  String _submitButtonText = 'SUBMIT';
  Color _submitButtonColor = AppColors.goldenYellow;
  Color _submitButtonTextColor = AppColors.black;
  double _buttonWidth = 200.0;
  double _buttonHeight = 60.0;
  double _buttonBorderRadius = 4.0;
  double _buttonFontSize = 24.0;
  FontWeight _buttonFontWeight = FontWeight.bold;
  bool _buttonIsItalic = false;
  bool _buttonHasBorder = true;
  double _buttonBorderWidth = 1.0;
  Color _buttonBorderColor = AppColors.white;
  EdgeInsets _buttonPadding =
      const EdgeInsets.symmetric(horizontal: 30, vertical: 15);
  EdgeInsets _buttonMargin = EdgeInsets.zero;
  double _buttonOpacity = 1.0;
  double _buttonTextOpacity = 1.0;

  // Image button settings
  String? _buttonImagePath;
  bool _isButtonImageAsset = true;
  double _buttonImageOpacity = 1.0;

  // Background settings
  String? _registrationScreenBackground;
  bool _isRegistrationScreenBackgroundAsset = true;

  // Getters
  bool get showRegistrationScreen => _showRegistrationScreen;
  double get fieldSpacing => _fieldSpacing;
  double get buttonSpacing => _buttonSpacing;
  double get borderRadius => _borderRadius;
  List<CustomTextField> get textFields => _textFields;

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
  EdgeInsets get buttonMargin => _buttonMargin;

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
        _prefs.getBool('registration_show_screen') ?? true;
    _fieldSpacing = _prefs.getDouble('registration_field_spacing') ?? 20.0;
    _buttonSpacing = _prefs.getDouble('registration_button_spacing') ?? 40.0;
    _borderRadius = _prefs.getDouble('registration_border_radius') ?? 4.0;

    // Load button margins
    final double topMargin =
        _prefs.getDouble('registration_button_margin_top') ?? 0.0;
    final double bottomMargin =
        _prefs.getDouble('registration_button_margin_bottom') ?? 0.0;
    final double leftMargin =
        _prefs.getDouble('registration_button_margin_left') ?? 0.0;
    final double rightMargin =
        _prefs.getDouble('registration_button_margin_right') ?? 0.0;
    _buttonMargin =
        EdgeInsets.fromLTRB(leftMargin, topMargin, rightMargin, bottomMargin);

    // Load button padding
    final double verticalPadding =
        _prefs.getDouble('registration_button_padding_vertical') ?? 15.0;
    final double horizontalPadding =
        _prefs.getDouble('registration_button_padding_horizontal') ?? 30.0;
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
      } catch (e) {
        debugPrint("Error decoding text fields JSON: $e. Using defaults.");
        _setDefaultTextFields(); // Fallback to defaults on error
      }
    } else {
      _setDefaultTextFields(); // Use default text fields
    }

    // Load button settings
    _useImageButton = _prefs.getBool('registration_use_image_button') ?? false;
    _submitButtonText =
        _prefs.getString('registration_button_text') ?? 'SUBMIT';
    _submitButtonColor = Color(_prefs.getInt('registration_button_color') ??
        AppColors.goldenYellow.value);
    _submitButtonTextColor = Color(
        _prefs.getInt('registration_button_text_color') ??
            AppColors.black.value);
    _buttonWidth = _prefs.getDouble('registration_button_width') ?? 200.0;
    _buttonHeight = _prefs.getDouble('registration_button_height') ?? 60.0;
    _buttonBorderRadius =
        _prefs.getDouble('registration_button_border_radius') ?? 4.0;
    _buttonFontSize = _prefs.getDouble('registration_button_font_size') ?? 24.0;
    _buttonFontWeight = FontWeight.values[
        _prefs.getInt('registration_button_font_weight') ??
            3]; // Bold is index 3
    _buttonIsItalic = _prefs.getBool('registration_button_is_italic') ?? false;
    _buttonHasBorder = _prefs.getBool('registration_button_has_border') ?? true;
    _buttonBorderWidth =
        _prefs.getDouble('registration_button_border_width') ?? 1.0;
    _buttonBorderColor = Color(
        _prefs.getInt('registration_button_border_color') ??
            AppColors.white.value);
    _buttonOpacity = _prefs.getDouble('registration_button_opacity') ?? 1.0;
    _buttonTextOpacity =
        _prefs.getDouble('registration_button_text_opacity') ?? 1.0;
    _buttonImageOpacity =
        _prefs.getDouble('registration_button_image_opacity') ?? 1.0;

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

    final String? marginJson = _prefs.getString('registration_button_margin');
    if (marginJson != null) {
      final Map<String, dynamic> margin = jsonDecode(marginJson);
      _buttonMargin = EdgeInsets.fromLTRB(
        margin['left']?.toDouble() ?? 0.0,
        margin['top']?.toDouble() ?? 0.0,
        margin['right']?.toDouble() ?? 0.0,
        margin['bottom']?.toDouble() ?? 0.0,
      );
    }

    // Load image button settings
    _buttonImagePath = _prefs.getString('registration_button_image_path');
    _isButtonImageAsset =
        _prefs.getBool('registration_is_button_image_asset') ?? true;

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
        _prefs.getString('registration_screen_background');
    _isRegistrationScreenBackgroundAsset =
        _prefs.getBool('registration_is_screen_background_asset') ?? true;

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

  void _setDefaultTextFields() {
    _textFields = [
      CustomTextField(
        id: 'name', // Keep original IDs for backward compatibility if needed
        label: 'Full Name',
        hintText: 'Enter full name',
        fieldType: TextFieldType.name, // --- SET TYPE ---
      ),
      CustomTextField(
        id: 'email', // Keep original IDs
        label: 'Email',
        hintText: 'Enter email address',
        fieldType: TextFieldType.email, // --- SET TYPE ---
      ),
    ];
  }

  // Add new methods for button styling
  void setButtonFontWeight(FontWeight weight) async {
    _buttonFontWeight = weight;
    await _prefs.setInt('registration_button_font_weight', weight.index);
    notifyListeners();
  }

  void setButtonMargin(EdgeInsets margin) async {
    _buttonMargin = margin;
    await _prefs.setDouble('registration_button_margin_top', margin.top);
    await _prefs.setDouble('registration_button_margin_bottom', margin.bottom);
    await _prefs.setDouble('registration_button_margin_left', margin.left);
    await _prefs.setDouble('registration_button_margin_right', margin.right);
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
  void addTextField() async {
    if (_textFields.length >= 3) {
      return; // Maximum 3 fields allowed
    }
    final newField = CustomTextField(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: 'Contact Number', // Example label
      hintText: 'Enter contact number',
      fieldType: TextFieldType
          .phone, // --- SET TYPE FOR NEW FIELD --- (Example: phone)
    );
    _textFields.add(newField);
    await _saveTextFields();
    notifyListeners();
  }

  void updateTextField(String id, CustomTextField updatedField) async {
    final index = _textFields.indexWhere((field) => field.id == id);
    if (index != -1) {
      // Ensure the type isn't accidentally overwritten if not explicitly set
      // Or, ensure the UI passes the correct type in updatedField
      _textFields[index] = updatedField;
      await _saveTextFields();
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
      _textFields[index] = CustomTextField(
        id: currentField.id,
        label: currentField.label,
        hintText: currentField.hintText,
        isEnabled: currentField.isEnabled,
        isRequired: currentField.isRequired,
        fillColor: currentField.fillColor,
        textColor: currentField.textColor,
        labelColor: currentField.labelColor,
        fontSize: currentField.fontSize,
        hasBorder: currentField.hasBorder,
        borderWidth: currentField.borderWidth,
        borderColor: currentField.borderColor,
        width: currentField.width,
        height: currentField.height,
        fieldType: currentField.fieldType, // Preserve field type
        // Apply updates
        fontWeight: fontWeight ?? currentField.fontWeight,
        isItalic: isItalic ?? currentField.isItalic,
        borderRadius: borderRadius ?? currentField.borderRadius,
        margin: margin ?? currentField.margin,
        padding: padding ?? currentField.padding,
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
