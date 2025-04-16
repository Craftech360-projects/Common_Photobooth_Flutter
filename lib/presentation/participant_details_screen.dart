import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photobooth_flutter/providers/app_provider.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/providers/registration_screen_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:provider/provider.dart';

class ParticipantDetailsScreen extends StatefulWidget {
  const ParticipantDetailsScreen({super.key});

  @override
  State<ParticipantDetailsScreen> createState() =>
      _ParticipantDetailsScreenState();
}

class _ParticipantDetailsScreenState extends State<ParticipantDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final List<int> _secretPattern = [];
  final List<int> _correctPattern = [1, 2];
  DateTime? _lastTapTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final registrationSettings = context.read<RegistrationScreenProvider>();

      // If registration screen is disabled, navigate directly to gender selection
      if (!registrationSettings.showRegistrationScreen) {
        Navigator.pushReplacementNamed(context, AppRoutes.genderSelection);
      }

      // Initialize controllers for each field
      for (var field in registrationSettings.textFields) {
        _controllers[field.id] = TextEditingController();
        debugPrint('Created controller for field: ${field.id}');
      }
    });
  }

  // FOR NAVIGATING TO ADMIN SCREEN
  void _handleSecretTap(int position) {
    final now = DateTime.now();
    if (_lastTapTime != null && now.difference(_lastTapTime!).inSeconds > 5) {
      _secretPattern.clear();
    }
    _lastTapTime = now;

    _secretPattern.add(position);
    if (_secretPattern.length == _correctPattern.length) {
      bool isCorrect = true;
      for (int i = 0; i < _correctPattern.length; i++) {
        if (_secretPattern[i] != _correctPattern[i]) {
          isCorrect = false;
          break;
        }
      }
      if (isCorrect) {
        Navigator.pushNamed(context, AppRoutes.adminScreen);
      }
      _secretPattern.clear();
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registrationSettings = context.watch<RegistrationScreenProvider>();
    final globalSettings = context.watch<GlobalSettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pushNamed(
              context, AppRoutes.registrationScreenSettings),
          icon: const Icon(Icons.star),
        ),
      ),
      body: Stack(children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: _getBackgroundImage(registrationSettings, globalSettings),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...registrationSettings.textFields
                      .where((field) => field.isEnabled)
                      .map((field) => Column(
                            children: [
                              Container(
                                margin: field.margin,
                                width: MediaQuery.of(context).size.width *
                                    field.width,
                                height: field.height,
                                child: TextFormField(
                                  controller: _controllers[field.id],
                                  style: TextStyle(
                                    color: field.textColor,
                                    fontSize: field.fontSize,
                                    fontWeight: field.fontWeight,
                                    fontStyle: field.isItalic
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: field.label,
                                    labelStyle: TextStyle(
                                      color: field.labelColor,
                                    ),
                                    hintText: field.hintText,
                                    filled: true,
                                    fillColor: field.fillColor,
                                    contentPadding: field.padding,
                                    border: field.hasBorder
                                        ? OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              field.borderRadius,
                                            ),
                                            borderSide: BorderSide(
                                              color: field.borderColor,
                                              width: field.borderWidth,
                                            ),
                                          )
                                        : InputBorder.none,
                                    enabledBorder: field.hasBorder
                                        ? OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              field.borderRadius,
                                            ),
                                            borderSide: BorderSide(
                                              color: field.borderColor,
                                              width: field.borderWidth,
                                            ),
                                          )
                                        : InputBorder.none,
                                    focusedBorder: field.hasBorder
                                        ? OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              field.borderRadius,
                                            ),
                                            borderSide: BorderSide(
                                              color: field.borderColor,
                                              width: field.borderWidth,
                                            ),
                                          )
                                        : InputBorder.none,
                                  ),
                                  validator: (value) {
                                    if (field.isRequired &&
                                        (value?.isEmpty ?? true)) {
                                      return 'Please enter ${field.label.toLowerCase()}';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(
                                  height: registrationSettings.fieldSpacing),
                            ],
                          )),
                  SizedBox(height: registrationSettings.buttonSpacing),
                  registrationSettings.useImageButton
                      ? _buildImageButton(registrationSettings)
                      : _buildTextButton(registrationSettings),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          child: GestureDetector(
            onTap: () => _handleSecretTap(1),
            child: Container(
              width: 100,
              height: 100,
              color: Colors.transparent,
            ),
          ),
        ),
        Positioned(
          left: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: () => _handleSecretTap(2),
            child: Container(
              width: 100,
              height: 100,
              color: Colors.transparent,
            ),
          ),
        )
      ]),
    );
  }

  Widget _buildTextButton(RegistrationScreenProvider settings) {
    return Opacity(
      opacity: settings.buttonOpacity,
      child: Container(
        margin: settings.buttonMargin,
        child: ElevatedButton(
          onPressed: _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: settings.submitButtonColor,
            foregroundColor: settings.submitButtonTextColor,
            padding: settings.buttonPadding,
            minimumSize: Size(settings.buttonWidth, settings.buttonHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(settings.buttonBorderRadius),
              side: settings.buttonHasBorder
                  ? BorderSide(
                      color: settings.buttonBorderColor,
                      width: settings.buttonBorderWidth,
                    )
                  : BorderSide.none,
            ),
          ),
          child: Text(
            settings.submitButtonText,
            style: TextStyle(
              fontSize: settings.buttonFontSize,
              fontWeight: settings.buttonFontWeight,
              fontStyle:
                  settings.buttonIsItalic ? FontStyle.italic : FontStyle.normal,
              color: settings.submitButtonTextColor
                  .withOpacity(settings.buttonTextOpacity),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageButton(RegistrationScreenProvider settings) {
    if (settings.buttonImagePath == null) {
      // Fallback to text button if no image is selected
      return _buildTextButton(settings);
    }

    return Opacity(
      opacity: settings.buttonImageOpacity,
      child: GestureDetector(
        onTap: _handleSubmit,
        child: Container(
          margin: settings.buttonMargin,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(settings.buttonBorderRadius),
            child: Container(
              width: settings.buttonWidth,
              height: settings.buttonHeight,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(settings.buttonBorderRadius),
                image: DecorationImage(
                  image: settings.isButtonImageAsset
                      ? AssetImage(settings.buttonImagePath!)
                      : FileImage(File(settings.buttonImagePath!))
                          as ImageProvider,
                  fit: BoxFit.cover,
                ),
                border: settings.buttonHasBorder
                    ? Border.all(
                        color: settings.buttonBorderColor,
                        width: settings.buttonBorderWidth,
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<PhotoboothProvider>(context, listen: false);
    
      // Get values from controllers and log all controllers for debugging
      _controllers.forEach((key, controller) {
        debugPrint('Controller $key has value: ${controller.text}');
      });
      
      // Make sure we're using the correct field IDs
      final name = _controllers['name']?.text ?? '';
      final email = _controllers['email']?.text ?? '';
      
      debugPrint('Submitting - Name: "$name", Email: "$email"');
      
      // Set user details in provider
      provider.setUserDetails(name, email);
      
      // Navigate to gender selection screen
      Navigator.pushNamed(context, AppRoutes.genderSelection);
    }
  }

  ImageProvider _getBackgroundImage(
      RegistrationScreenProvider registrationSettings,
      GlobalSettingsProvider globalSettings) {
    // First try to use registration screen specific background
    if (registrationSettings.registrationScreenBackground != null) {
      if (registrationSettings.isRegistrationScreenBackgroundAsset) {
        return AssetImage(registrationSettings.registrationScreenBackground!);
      } else {
        return FileImage(
            File(registrationSettings.registrationScreenBackground!));
      }
    }

    // Fall back to global background if available
    if (globalSettings.backgroundImage != null) {
      if (globalSettings.isAssetImage) {
        return AssetImage(globalSettings.backgroundImage!);
      } else {
        return FileImage(File(globalSettings.backgroundImage!));
      }
    }

    // Default background
    return const AssetImage('assets/images/background.jpg');
  }
}
