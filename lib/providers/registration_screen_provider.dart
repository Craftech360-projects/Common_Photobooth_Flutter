import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool hasBorder;
  double borderWidth;
  Color borderColor;
  double width;
  double height;

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
    this.hasBorder = true,
    this.borderWidth = 1.0,
    this.borderColor = AppColors.black,
    this.width = 0.35, // Percentage of screen width
    this.height = 60.0,
  });
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
  bool _buttonHasBorder = true;
  double _buttonBorderWidth = 1.0;
  Color _buttonBorderColor = AppColors.white;
  EdgeInsets _buttonPadding =
      const EdgeInsets.symmetric(horizontal: 30, vertical: 15);
  EdgeInsets _buttonMargin = EdgeInsets.zero;

  // Image button settings
  String? _buttonImagePath;
  bool _isButtonImageAsset = true;

  // Background settings
  String? _registrationScreenBackground;
  bool _isRegistrationScreenBackgroundAsset = true;

  // Getters
  bool get showRegistrationScreen => _showRegistrationScreen;
  double get fieldSpacing => _fieldSpacing;
  double get buttonSpacing => _buttonSpacing;
  double get borderRadius => _borderRadius;
  List<CustomTextField> get textFields => _textFields;

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

    // Load text fields
    final String? fieldsJson = _prefs.getString('registration_text_fields');
    if (fieldsJson != null) {
      final List<dynamic> fields = jsonDecode(fieldsJson);
      _textFields.clear();
      _textFields.addAll(
        fields.map(
          (field) => CustomTextField(
            id: field['id'],
            label: field['label'],
            hintText: field['hintText'],
            isEnabled: field['isEnabled'] ?? true,
            isRequired: field['isRequired'] ?? true,
            fillColor: Color(field['fillColor'] ?? Colors.white.value),
            textColor: Color(field['textColor'] ?? AppColors.black.value),
            labelColor: Color(field['labelColor'] ?? AppColors.black.value),
            fontSize: field['fontSize']?.toDouble() ?? 16.0,
            hasBorder: field['hasBorder'] ?? true,
            borderWidth: field['borderWidth']?.toDouble() ?? 1.0,
            borderColor: Color(field['borderColor'] ?? AppColors.black.value),
            width: field['width']?.toDouble() ?? 0.35,
            height: field['height']?.toDouble() ?? 60.0,
          ),
        ),
      );
    } else {
      // Default text fields
      _textFields = [
        CustomTextField(
          id: 'name',
          label: 'Full Name',
          hintText: 'Enter full name',
        ),
        CustomTextField(
          id: 'email',
          label: 'Email',
          hintText: 'Enter email address',
        ),
      ];
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
    _buttonHasBorder = _prefs.getBool('registration_button_has_border') ?? true;
    _buttonBorderWidth =
        _prefs.getDouble('registration_button_border_width') ?? 1.0;
    _buttonBorderColor = Color(
        _prefs.getInt('registration_button_border_color') ??
            AppColors.white.value);

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
      label: 'Contact Number',
      hintText: 'Enter contact number',
    );
    _textFields.add(newField);
    await _saveTextFields();
    notifyListeners();
  }

  void updateTextField(String id, CustomTextField updatedField) async {
    final index = _textFields.indexWhere((field) => field.id == id);
    if (index != -1) {
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

  Future<void> _saveTextFields() async {
    final List<Map<String, dynamic>> fieldsMap = _textFields
        .map((field) => {
              'id': field.id,
              'label': field.label,
              'hintText': field.hintText,
              'isEnabled': field.isEnabled,
              'isRequired': field.isRequired,
              'fillColor': field.fillColor.value,
              'textColor': field.textColor.value,
              'labelColor': field.labelColor.value,
              'fontSize': field.fontSize,
              'hasBorder': field.hasBorder,
              'borderWidth': field.borderWidth,
              'borderColor': field.borderColor.value,
              'width': field.width,
              'height': field.height,
            })
        .toList();
    await _prefs.setString('registration_text_fields', jsonEncode(fieldsMap));
  }

  // Button settings methods
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

  void setButtonPadding(EdgeInsets padding) async {
    _buttonPadding = padding;
    final paddingMap = {
      'left': padding.left,
      'top': padding.top,
      'right': padding.right,
      'bottom': padding.bottom,
    };
    await _prefs.setString(
        'registration_button_padding', jsonEncode(paddingMap));
    notifyListeners();
  }

  void setButtonMargin(EdgeInsets margin) async {
    _buttonMargin = margin;
    final marginMap = {
      'left': margin.left,
      'top': margin.top,
      'right': margin.right,
      'bottom': margin.bottom,
    };
    await _prefs.setString('registration_button_margin', jsonEncode(marginMap));
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
