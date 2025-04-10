import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomFormField {
  String id;
  String label;
  String hintText;
  Color fillColor;
  bool isRequired;
  Color textColor;

  CustomFormField({
    required this.id,
    required this.label,
    required this.hintText,
    required this.fillColor,
    this.isRequired = true,
    this.textColor = AppColors.black,
  });
}

class AdminSettingsProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  // RESOLUTION SETTINGS
  Size _selectedResolution = const Size(1920, 1080);
  String? _backgroundImage;
  bool _isAssetImage = true;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await loadSettings();
  }

  Future<void> loadSettings() async {
    _selectedResolution = Size(
      _prefs.getDouble('resolution_width') ?? 1920,
      _prefs.getDouble('resolution_height') ?? 1080,
    );

    _backgroundImage = _prefs.getString('background_image');
    _isAssetImage = _prefs.getBool('is_asset_image') ?? true;

    _fieldSpacing = _prefs.getDouble('field_spacing') ?? 20.0;
    _buttonSpacing = _prefs.getDouble('button_spacing') ?? 40.0;
    _borderRadius = _prefs.getDouble('border_radius') ?? 4.0;
    _submitButtonText = _prefs.getString('submit_button_text') ?? 'SUBMIT';

    // LOAD FORM FIELDS
    //1. FETCHING FORMS FROM PREFERENCES
    final String? fieldsJson = _prefs.getString('form_fields');

    //2. DECODING JSON TO LIST OF CUSTOM FORM FIELDS
    if (fieldsJson != null) {
      final List<dynamic> fields = jsonDecode(fieldsJson);
      //
      _formFields.clear();
      //
      _formFields.addAll(
        fields.map(
          (field) => CustomFormField(
            id: field['id'],
            label: field['label'],
            hintText: field['hintText'],
            fillColor: Color(field['fillColor']),
            isRequired: field['isRequired'] ?? true,
            textColor: Color(field['textColor'] ?? 0xFF000000),
            // WE ALSO HAVE TO ADD CONTROLLER FOR EACH FIELD
          ),
        ),
      );
    }

    // LOAD BUTTON TEXT STYLE
    //1. FETCHING FROM PREFERENCES
    final String? styleJson = _prefs.getString('button_text_style');
    if (styleJson != null) {
      final style = jsonDecode(styleJson);
      _buttonTextStyle = TextStyle(
        letterSpacing: style['letterSpacing']?.toDouble() ?? 0.5,
        fontSize: style['fontSize']?.toDouble() ?? 24,
        fontWeight: FontWeight.values[style['fontWeight'] ?? 6],
        color: Color(style['color'] ?? 0xFF000000).withValues(alpha: 1.0),
      );
    }

    notifyListeners();
  }

  // SAVE SETTINGS
  Future<void> _saveSettings() async {
    await _prefs.setDouble('resolution_width', _selectedResolution.width);
    await _prefs.setDouble('resolution_height', _selectedResolution.height);

    if (_backgroundImage != null) {
      await _prefs.setString('background_image', _backgroundImage!);
      await _prefs.setBool('is_asset_image', _isAssetImage);
    }

    await _prefs.setDouble('field_spacing', _fieldSpacing);
    await _prefs.setDouble('button_spacing', _buttonSpacing);
    await _prefs.setDouble('border_radius', _borderRadius);
    await _prefs.setString('submit_button_text', _submitButtonText);

    // Save form fields
    final fieldsJson = jsonEncode(_formFields
        .map((field) => {
              'id': field.id,
              'label': field.label,
              'hintText': field.hintText,
              'fillColor': field.fillColor.value,
              'isRequired': field.isRequired,
              'textColor': field.textColor.value,
              // WE ALSO HAVE TO ADD CONTROLLER FOR EACH FIELD
            })
        .toList());
    //
    await _prefs.setString('form_fields', fieldsJson);

    // SAVE BUTTON TEXT STYLE
    final styleJson = jsonEncode({
      'letterSpacing': _buttonTextStyle.letterSpacing,
      'fontSize': _buttonTextStyle.fontSize,
      'fontWeight': _buttonTextStyle.fontWeight?.index,
      'color': _buttonTextStyle.color?.value ?? 0xFF000000,
    });
    //
    await _prefs.setString('button_text_style', styleJson);
  }

  // I. PARTICIPANT DETAILS SCREEN SETTINGS
  final List<CustomFormField> _formFields = [
    CustomFormField(
      id: 'name',
      label: 'Full Name',
      hintText: 'Enter full name',
      fillColor: AppColors.goldenYellow,
      textColor: AppColors.black,
    ),
    CustomFormField(
      id: 'email',
      label: 'Email',
      hintText: 'Enter email address',
      fillColor: AppColors.goldenYellow,
      textColor: AppColors.black,
    ),
  ];

  double _fieldSpacing = 20.0;
  double _buttonSpacing = 40.0;
  double _borderRadius = 4.0;
  String _submitButtonText = 'SUBMIT';
  TextStyle _buttonTextStyle = const TextStyle(
    letterSpacing: 0.5,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );

  // GETTERS
  Size get selectedResolution => _selectedResolution;
  String? get backgroundImage => _backgroundImage;
  bool get isAssetImage => _isAssetImage;
  List<CustomFormField> get formFields => _formFields;
  double get fieldSpacing => _fieldSpacing;
  double get buttonSpacing => _buttonSpacing;
  double get borderRadius => _borderRadius;
  String get submitButtonText => _submitButtonText;
  TextStyle get buttonTextStyle => _buttonTextStyle;

  // SETTERS
  void setResolution(Size resolution) {
    _selectedResolution = resolution;
    _saveSettings();
    notifyListeners();
  }

  void setBackgroundImage(String path, {bool isAsset = false}) {
    _backgroundImage = path;
    _isAssetImage = isAsset;
    _saveSettings();
    notifyListeners();
  }

  void setFieldSpacing(double spacing) {
    _fieldSpacing = spacing;
    _saveSettings();
    notifyListeners();
  }

  void setButtonSpacing(double spacing) {
    _buttonSpacing = spacing;
    _saveSettings();
    notifyListeners();
  }

  void setBorderRadius(double radius) {
    _borderRadius = radius;
    _saveSettings();
    notifyListeners();
  }

  void setSubmitButtonText(String text) {
    _submitButtonText = text;
    _saveSettings();
    notifyListeners();
  }

  void setButtonTextStyle(TextStyle style) {
    _buttonTextStyle = style;
    _saveSettings();
    notifyListeners();
  }

  void addFormField() {
    _formFields.add(
      CustomFormField(
        id: 'field_${_formFields.length}',
        label: 'New Field',
        hintText: 'Enter value',
        fillColor: AppColors.goldenYellow,
        textColor: AppColors.black,
      ),
    );
    _saveSettings();
    notifyListeners();
  }

  void removeFormField(String id) {
    _formFields.removeWhere((field) => field.id == id);
    _saveSettings();
    notifyListeners();
  }

  void updateFormField(String id, CustomFormField updatedField) {
    final index = _formFields.indexWhere((field) => field.id == id);
    if (index != -1) {
      _formFields[index] = updatedField;
      _saveSettings();
      notifyListeners();
    }
  }
}
