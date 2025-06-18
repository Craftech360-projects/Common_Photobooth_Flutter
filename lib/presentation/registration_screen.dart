import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photobooth_flutter/providers/admin_watermark_provider.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/providers/photobooth_provider.dart';
import 'package:photobooth_flutter/providers/registration_screen_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:photobooth_flutter/widgets/snackbar.dart';
import 'package:photobooth_flutter/widgets/watermark_overlay.dart';
import 'package:provider/provider.dart';

class ParticipantDetailsScreen extends StatefulWidget {
  const ParticipantDetailsScreen({super.key});

  @override
  State<ParticipantDetailsScreen> createState() =>
      _ParticipantDetailsScreenState();
}

class _ParticipantDetailsScreenState extends State<ParticipantDetailsScreen> {
  // The Form key is no longer needed as validation is handled manually.
  // final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    final registrationSettings =
        Provider.of<RegistrationScreenProvider>(context, listen: false);

    for (var field in registrationSettings.textFields) {
      _controllers[field.id] = TextEditingController();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!registrationSettings.showRegistrationScreen) {
        Navigator.pushReplacementNamed(context, AppRoutes.genderSelection);
      }
    });
  }

  @override
  void dispose() {
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
        // The Form widget is removed as we are now handling validation manually.
        child: Stack(
          children: [
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
                  ),
                  textAlign: registrationSettings.titleTextAlign,
                ),
              ),
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
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          labelText: field.label,
                          hintText: field.hintText,
                          labelStyle: TextStyle(
                              fontSize: field.fontSize,
                              color: field.labelColor),
                          filled: false,
                          fillColor: field.fillColor,
                          border: field.hasBorder
                              ? OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(field.borderRadius),
                                  borderSide: BorderSide(
                                      color: field.borderColor,
                                      width: field.borderWidth))
                              : InputBorder.none,
                          enabledBorder: field.hasBorder
                              ? OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(field.borderRadius),
                                  borderSide: BorderSide(
                                      color: field.borderColor,
                                      width: field.borderWidth))
                              : InputBorder.none,
                          focusedBorder: field.hasBorder
                              ? OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(field.borderRadius),
                                  borderSide: BorderSide(
                                      color: field.borderColor,
                                      width: field.borderWidth))
                              : InputBorder.none,
                        ),
                        // The validator property is removed to prevent in-field errors.
                      ),
                    )),
            Positioned(
              left: registrationSettings.buttonLeft,
              bottom: registrationSettings.buttonBottom,
              child: registrationSettings.useImageButton
                  ? _buildImageButton(registrationSettings)
                  : _buildTextButton(registrationSettings),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(
                    context, AppRoutes.registrationScreenSettings),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(color: Colors.transparent),
                ),
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
                .withOpacity(settings.buttonTextOpacity),
          ),
        ),
      ),
    );
  }

  Widget _buildImageButton(RegistrationScreenProvider settings) {
    if (settings.buttonImagePath == null) {
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
    FocusScope.of(context).unfocus(); // Hide keyboard
    final registrationSettings = context.read<RegistrationScreenProvider>();
    String? firstErrorMessage;

    // Manually validate each enabled field
    for (var field in registrationSettings.textFields) {
      if (field.isEnabled) {
        final value = _controllers[field.id]?.text;
        String? error;

        if (field.isRequired && (value == null || value.isEmpty)) {
          error = 'Please fill in the ${field.label} field';
        } else if (value != null && value.isNotEmpty) {
          switch (field.fieldType) {
            case TextFieldType.email:
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value)) {
                error = 'Please enter a valid email address';
              }
              break;
            case TextFieldType.phone:
              final phoneRegex = RegExp(
                  r'^[+]?[(]?[0-9]{1,4}[)]?[-\s\.]?[0-9]{1,4}[-\s\.]?[0-9]{1,9}$');
              if (!phoneRegex.hasMatch(value)) {
                error = 'Please enter a valid phone number';
              }
              break;
            case TextFieldType.name:
              if (value.length < 2) {
                error = 'Name must be at least 2 characters';
              }
              break;
            default:
              break;
          }
        }

        if (error != null) {
          firstErrorMessage = error;
          break; // Stop at the first error
        }
      }
    }

    if (firstErrorMessage != null) {
      // If there's an error, show it in a SnackBar and do not proceed.
      showSnackBar(context, firstErrorMessage, isError: true);
    } else {
      // If all fields are valid, proceed.
      final provider = Provider.of<PhotoboothProvider>(context, listen: false);
      String name = '';
      String email = '';

      for (var field in registrationSettings.textFields) {
        if (field.isEnabled) {
          if (field.fieldType == TextFieldType.name) {
            name = _controllers[field.id]?.text ?? '';
          } else if (field.fieldType == TextFieldType.email) {
            email = _controllers[field.id]?.text ?? '';
          }
        }
      }

      provider.setUserDetails(name, email);
      Navigator.pushNamed(context, AppRoutes.genderSelection);
    }
  }

  ImageProvider _getBackgroundImage(
      RegistrationScreenProvider registrationSettings,
      GlobalSettingsProvider globalSettings) {
    if (registrationSettings.registrationScreenBackground != null) {
      if (registrationSettings.isRegistrationScreenBackgroundAsset) {
        return AssetImage(registrationSettings.registrationScreenBackground!);
      } else {
        return FileImage(
            File(registrationSettings.registrationScreenBackground!));
      }
    }
    if (globalSettings.backgroundImage != null) {
      if (globalSettings.isAssetImage) {
        return AssetImage(globalSettings.backgroundImage!);
      } else {
        return FileImage(File(globalSettings.backgroundImage!));
      }
    }
    return const AssetImage('assets/images/common_bg.png');
  }
}
