import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photobooth_flutter/providers/admin_watermark_provider.dart';
import 'package:photobooth_flutter/providers/app_flow_provider.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/providers/photobooth_provider.dart';
import 'package:photobooth_flutter/providers/registration_screen_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:photobooth_flutter/widgets/watermark_overlay.dart';
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

  @override
  void initState() {
    super.initState();
    // --- FIX: Initialize controllers here, before the first build ---
    final registrationSettings =
        Provider.of<RegistrationScreenProvider>(context, listen: false);

    for (var field in registrationSettings.textFields) {
      _controllers[field.id] = TextEditingController();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // If registration screen is disabled, navigate directly to gender selection
      if (!registrationSettings.showRegistrationScreen) {
        Navigator.pushReplacementNamed(context, AppRoutes.genderSelection);
      }
    });
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
    final watermarkProvider = context.watch<AdminWatermarkProvider>();

    return Scaffold(
      body: WatermarkOverlay(
        show: watermarkProvider.showWatermark,
        child: Stack(
          children: [
            // Background container
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image:
                      _getBackgroundImage(registrationSettings, globalSettings),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Title widget with positioning
            if (registrationSettings.showTitle)
              Positioned(
                left: registrationSettings.titleLeft,
                top: registrationSettings.titleTop,
                width: registrationSettings.titleWidth,
                child: Text(
                  registrationSettings.titleText,
                  style: TextStyle(
                    fontSize: registrationSettings.titleFontSize,
                    fontWeight: registrationSettings.titleFontWeight,
                    color: registrationSettings.titleTextColor,
                    height: registrationSettings.titleLineHeight,
                  ),
                  textAlign: registrationSettings.titleTextAlign,
                ),
              ),

            // Text fields with positioning
            ...registrationSettings.textFields
                .where((field) => field.isEnabled)
                .map((field) => Positioned(
                      left: field.left,
                      top: field.top,
                      width: MediaQuery.of(context).size.width * field.width,
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
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              field.borderRadius,
                            ),
                            borderSide: field.hasBorder
                                ? BorderSide(
                                    color: field.borderColor,
                                    width: field.borderWidth,
                                  )
                                : BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              field.borderRadius,
                            ),
                            borderSide: field.hasBorder
                                ? BorderSide(
                                    color: field.borderColor,
                                    width: field.borderWidth,
                                  )
                                : BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              field.borderRadius,
                            ),
                            borderSide: field.hasBorder
                                ? BorderSide(
                                    color: field.borderColor,
                                    width: field.borderWidth,
                                  )
                                : BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (field.isRequired && (value?.isEmpty ?? true)) {
                            return 'Please enter ${field.label.toLowerCase()}';
                          }

                          // Add type-specific validations
                          if (value != null && value.isNotEmpty) {
                            switch (field.fieldType) {
                              case TextFieldType.email:
                                // Email validation using regex
                                final emailRegex =
                                    RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                if (!emailRegex.hasMatch(value)) {
                                  return 'Please enter a valid email address';
                                }
                                break;
                              case TextFieldType.phone:
                                // Phone validation - allow digits, spaces, and some special chars
                                final phoneRegex = RegExp(
                                    r'^[+]?[(]?[0-9]{1,4}[)]?[-\s\.]?[0-9]{1,4}[-\s\.]?[0-9]{1,9}$');
                                if (!phoneRegex.hasMatch(value)) {
                                  return 'Please enter a valid phone number';
                                }
                                break;
                              case TextFieldType.name:
                                // Name validation - minimum 2 characters
                                if (value.length < 2) {
                                  return 'Name must be at least 2 characters';
                                }
                                break;
                              default:
                                // No additional validation for custom fields
                                break;
                            }
                          }
                          return null;
                        },
                      ),
                    )),

            // Button with positioning
            Positioned(
              left: registrationSettings.buttonLeft,
              bottom: registrationSettings.buttonBottom,
              child: registrationSettings.useImageButton
                  ? _buildImageButton(registrationSettings)
                  : _buildTextButton(registrationSettings),
            ),

            // Admin settings access
            Positioned(
              right: 0,
              top: 0,
              child: GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.adminScreen),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),

            // Hidden form for validation
            Opacity(
              opacity: 0,
              child: Form(
                key: _formKey,
                child: Container(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextButton(RegistrationScreenProvider settings) {
    return Opacity(
      opacity: settings.buttonOpacity,
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
                .withValues(alpha: settings.buttonTextOpacity),
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(settings.buttonBorderRadius),
          child: Container(
            width: settings.buttonWidth,
            height: settings.buttonHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(settings.buttonBorderRadius),
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
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<PhotoboothProvider>(context, listen: false);
      final registrationSettings = context.read<RegistrationScreenProvider>();
      final appFlowProvider = context.read<AppFlowProvider>();

      // Log controllers (optional debugging)
      _controllers.forEach((key, controller) {});

      // --- MODIFICATION START ---
      // Find field IDs based on their type
      String? nameFieldId = registrationSettings.textFields
          .firstWhere((f) => f.isEnabled && f.fieldType == TextFieldType.name,
              orElse: () => CustomTextField(
                  id: '', label: '', hintText: '')) // Provide a dummy default
          .id;
      String? emailFieldId = registrationSettings.textFields
          .firstWhere((f) => f.isEnabled && f.fieldType == TextFieldType.email,
              orElse: () => CustomTextField(id: '', label: '', hintText: ''))
          .id;

      // // Example for phone:
      String? phoneFieldId = registrationSettings.textFields
          .firstWhere((f) => f.isEnabled && f.fieldType == TextFieldType.phone,
              orElse: () => CustomTextField(id: '', label: '', hintText: ''))
          .id;

      // Retrieve text using the found IDs
      String name = '';
      if (nameFieldId.isNotEmpty && _controllers.containsKey(nameFieldId)) {
        name = _controllers[nameFieldId]!.text;
      } else {
        debugPrint('Could not find enabled Name field or its controller.');
      }

      String email = '';
      if (emailFieldId.isNotEmpty && _controllers.containsKey(emailFieldId)) {
        email = _controllers[emailFieldId]!.text;
      } else {
        debugPrint('Could not find enabled Email field or its controller.');
      }

      String phone = '';
      if (_controllers.containsKey(phoneFieldId)) {
        phone = _controllers[phoneFieldId]!.text;
      } else {
        debugPrint('Could not find enabled Phone field or its controller.');
      }
      // --- MODIFICATION END ---

      // Set user details in provider
      provider.setUserDetails(name, email);

      Navigator.pushNamed(context, AppRoutes.categoriesScreen);
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
