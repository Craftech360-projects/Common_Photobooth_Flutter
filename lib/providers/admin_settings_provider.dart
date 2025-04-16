import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
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

  // GLOBAL SETTINGS
  Size _selectedResolution = const Size(1920, 1080);
  String? _backgroundImage;
  bool _isAssetImage = true;
  double _fieldSpacing = 20.0;
  double _buttonSpacing = 40.0;
  double _borderRadius = 4.0;

  // WELCOME SCREEN SETTINGS
  bool _showWelcomeScreen = true;
  String _welcomeMessage = 'Welcome to the AI Photobooth!';
  String _welcomeButtonText = 'Get Started';
  Color _welcomeButtonColor = AppColors.goldenYellow;
  Color _welcomeButtonTextColor = AppColors.black;
  String? _welcomeScreenBackground;
  bool _isWelcomeScreenBackgroundAsset = true;

  // PARTICIPANT DETAILS SCREEN SETTINGS
  final String _submitButtonText = 'SUBMIT';
  final TextStyle _buttonTextStyle = const TextStyle(
    letterSpacing: 0.5,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );
  final List<CustomFormField> _formFields = [];

  // GETTERS
  // Global settings
  Size get selectedResolution => _selectedResolution;
  String? get backgroundImage => _backgroundImage;
  bool get isAssetImage => _isAssetImage;
  double get fieldSpacing => _fieldSpacing;
  double get buttonSpacing => _buttonSpacing;
  double get borderRadius => _borderRadius;

  // Welcome screen settings
  bool get showWelcomeScreen => _showWelcomeScreen;
  String get welcomeMessage => _welcomeMessage;
  String get welcomeButtonText => _welcomeButtonText;
  Color get welcomeButtonColor => _welcomeButtonColor;
  Color get welcomeButtonTextColor => _welcomeButtonTextColor;
  String? get welcomeScreenBackground => _welcomeScreenBackground;
  bool get isWelcomeScreenBackgroundAsset => _isWelcomeScreenBackgroundAsset;

  // Participant details screen settings
  String get submitButtonText => _submitButtonText;
  TextStyle get buttonTextStyle => _buttonTextStyle;
  List<CustomFormField> get formFields => _formFields;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await loadSettings();
  }

  Future<void> loadSettings() async {
    // LOAD GLOBAL SETTINGS
    _selectedResolution = Size(
      _prefs.getDouble('resolution_width') ?? 1920,
      _prefs.getDouble('resolution_height') ?? 1080,
    );

    _backgroundImage = _prefs.getString('background_image');
    _isAssetImage = _prefs.getBool('is_asset_image') ?? true;

    // Verify background image file exists if it's not an asset
    if (_backgroundImage != null && !_isAssetImage) {
      final file = File(_backgroundImage!);
      if (!file.existsSync()) {
        _backgroundImage = null;
        await _prefs.remove('background_image');
      }
    }

    _fieldSpacing = _prefs.getDouble('field_spacing') ?? 20.0;
    _buttonSpacing = _prefs.getDouble('button_spacing') ?? 40.0;
    _borderRadius = _prefs.getDouble('border_radius') ?? 4.0;

    // LOAD WELCOME SCREEN SETTINGS
    _showWelcomeScreen = _prefs.getBool('show_welcome_screen') ?? true;
    _welcomeMessage =
        _prefs.getString('welcome_message') ?? 'Welcome to the AI Photobooth!';
    _welcomeButtonText =
        _prefs.getString('welcome_button_text') ?? 'Get Started';
    _welcomeButtonColor = Color(
        _prefs.getInt('welcome_button_color') ?? AppColors.goldenYellow.value);
    _welcomeButtonTextColor = Color(
        _prefs.getInt('welcome_button_text_color') ?? AppColors.black.value);
    _welcomeScreenBackground = _prefs.getString('welcome_screen_background');
    _isWelcomeScreenBackgroundAsset =
        _prefs.getBool('is_welcome_screen_background_asset') ?? true;

    // Verify welcome screen background image file exists if it's not an asset
    if (_welcomeScreenBackground != null && !_isWelcomeScreenBackgroundAsset) {
      final file = File(_welcomeScreenBackground!);
      if (!file.existsSync()) {
        _welcomeScreenBackground = null;
        await _prefs.remove('welcome_screen_background');
      }
    }

    //   // LOAD PARTICIPANT DETAILS SCREEN SETTINGS
    //   _submitButtonText = _prefs.getString('submit_button_text') ?? 'SUBMIT';

    //   // LOAD FORM FIELDS
    //   final String? fieldsJson = _prefs.getString('form_fields');
    //   if (fieldsJson != null) {
    //     final List<dynamic> fields = jsonDecode(fieldsJson);
    //     _formFields.clear();
    //     _formFields.addAll(
    //       fields.map(
    //         (field) => CustomFormField(
    //           id: field['id'],
    //           label: field['label'],
    //           hintText: field['hintText'],
    //           fillColor: Color(field['fillColor']),
    //           isRequired: field['isRequired'] ?? true,
    //           textColor: Color(field['textColor'] ?? 0xFF000000),
    //         ),
    //       ),
    //     );
    //   } else {
    //     // Default form fields
    //     _formFields = [
    //       CustomFormField(
    //         id: 'name',
    //         label: 'Full Name',
    //         hintText: 'Enter full name',
    //         fillColor: Colors.white,
    //       ),
    //       CustomFormField(
    //         id: 'email',
    //         label: 'Email',
    //         hintText: 'Enter email address',
    //         fillColor: Colors.white,
    //       ),
    //     ];
    //   }

    //   // LOAD BUTTON TEXT STYLE
    //   final String? styleJson = _prefs.getString('button_text_style');
    //   if (styleJson != null) {
    //     final style = jsonDecode(styleJson);
    //     _buttonTextStyle = TextStyle(
    //       letterSpacing: style['letterSpacing']?.toDouble() ?? 0.5,
    //       fontSize: style['fontSize']?.toDouble() ?? 24,
    //       fontWeight: FontWeight.values[style['fontWeight'] ?? 6],
    //       color: Color(style['color'] ?? 0xFF000000),
    //     );
    //   }

    //   notifyListeners();
  }

  // GLOBAL SETTINGS METHODS
  void setResolution(Size size) async {
    _selectedResolution = size;
    await _prefs.setDouble('resolution_width', size.width);
    await _prefs.setDouble('resolution_height', size.height);
    notifyListeners();
  }

  Future<void> setBackgroundImage(String sourcePath,
      {required bool isAsset}) async {
    if (isAsset) {
      // For asset images, just store the path
      _backgroundImage = sourcePath;
      _isAssetImage = true;
    } else {
      // For file images, copy to app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName =
          'global_background_${DateTime.now().millisecondsSinceEpoch}${path.extension(sourcePath)}';
      final destinationPath = path.join(appDir.path, fileName);

      try {
        final sourceFile = File(sourcePath);
        await sourceFile.copy(destinationPath);
        _backgroundImage = destinationPath;
        _isAssetImage = false;
      } on Exception catch (e) {
        debugPrint('Error copying background image: $e');
        return;
      }
    }

    await _prefs.setString('background_image', _backgroundImage!);
    await _prefs.setBool('is_asset_image', _isAssetImage);
    notifyListeners();
  }

  void setFieldSpacing(double spacing) async {
    _fieldSpacing = spacing;
    await _prefs.setDouble('field_spacing', spacing);
    notifyListeners();
  }

  void setButtonSpacing(double spacing) async {
    _buttonSpacing = spacing;
    await _prefs.setDouble('button_spacing', spacing);
    notifyListeners();
  }

  void setBorderRadius(double radius) async {
    _borderRadius = radius;
    await _prefs.setDouble('border_radius', radius);
    notifyListeners();
  }

  // WELCOME SCREEN METHODS
  void setShowWelcomeScreen(bool show) async {
    _showWelcomeScreen = show;
    await _prefs.setBool('show_welcome_screen', show);
    notifyListeners();
  }

  void setWelcomeMessage(String message) async {
    _welcomeMessage = message;
    await _prefs.setString('welcome_message', message);
    notifyListeners();
  }

  void setWelcomeButtonText(String text) async {
    _welcomeButtonText = text;
    await _prefs.setString('welcome_button_text', text);
    notifyListeners();
  }

  void setWelcomeButtonColor(Color color) async {
    _welcomeButtonColor = color;
    await _prefs.setInt('welcome_button_color', color.value);
    notifyListeners();
  }

  void setWelcomeButtonTextColor(Color color) async {
    _welcomeButtonTextColor = color;
    await _prefs.setInt('welcome_button_text_color', color.value);
    notifyListeners();
  }

  Future<void> setWelcomeScreenBackground(String? sourcePath,
      {bool isAsset = true}) async {
    if (sourcePath == null) {
      _welcomeScreenBackground = null;
      _isWelcomeScreenBackgroundAsset = true;
      await _prefs.remove('welcome_screen_background');
      await _prefs.setBool('is_welcome_screen_background_asset', true);
      notifyListeners();
      return;
    }

    if (isAsset) {
      // For asset images, just store the path
      _welcomeScreenBackground = sourcePath;
      _isWelcomeScreenBackgroundAsset = true;
    } else {
      // For file images, copy to app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName =
          'welcome_background_${DateTime.now().millisecondsSinceEpoch}${path.extension(sourcePath)}';
      final destinationPath = path.join(appDir.path, fileName);

      try {
        final sourceFile = File(sourcePath);
        await sourceFile.copy(destinationPath);
        _welcomeScreenBackground = destinationPath;
        _isWelcomeScreenBackgroundAsset = false;
      } on Exception catch (e) {
        debugPrint('Error copying background image: $e');
        return;
      }
    }

    await _prefs.setString(
        'welcome_screen_background', _welcomeScreenBackground!);
    await _prefs.setBool(
        'is_welcome_screen_background_asset', _isWelcomeScreenBackgroundAsset);
    notifyListeners();
  }

  // // PARTICIPANT DETAILS SCREEN METHODS
  // void setSubmitButtonText(String text) async {
  //   _submitButtonText = text;
  //   await _prefs.setString('submit_button_text', text);
  //   notifyListeners();
  // }

  // void setButtonTextStyle(TextStyle style) async {
  //   _buttonTextStyle = style;
  //   final styleMap = {
  //     'letterSpacing': style.letterSpacing,
  //     'fontSize': style.fontSize,
  //     'fontWeight': style.fontWeight?.index,
  //     'color': style.color?.value,
  //   };
  //   await _prefs.setString('button_text_style', jsonEncode(styleMap));
  //   notifyListeners();
  // }

  // void addFormField() async {
  //   final newField = CustomFormField(
  //     id: DateTime.now().millisecondsSinceEpoch.toString(),
  //     label: 'New Field',
  //     hintText: 'Enter value',
  //     fillColor: Colors.white,
  //   );
  //   _formFields.add(newField);
  //   await _saveFormFields();
  //   notifyListeners();
  // }

  // void updateFormField(String id, CustomFormField updatedField) async {
  //   final index = _formFields.indexWhere((field) => field.id == id);
  //   if (index != -1) {
  //     _formFields[index] = updatedField;
  //     await _saveFormFields();
  //     notifyListeners();
  //   }
  // }

  // void removeFormField(String id) async {
  //   _formFields.removeWhere((field) => field.id == id);
  //   await _saveFormFields();
  //   notifyListeners();
  // }

  // Future<void> _saveFormFields() async {
  //   final List<Map<String, dynamic>> fieldsMap = _formFields
  //       .map((field) => {
  //             'id': field.id,
  //             'label': field.label,
  //             'hintText': field.hintText,
  //             'fillColor': field.fillColor.value,
  //             'isRequired': field.isRequired,
  //             'textColor': field.textColor.value,
  //           })
  //       .toList();
  //   await _prefs.setString('form_fields', jsonEncode(fieldsMap));
  // }
}
