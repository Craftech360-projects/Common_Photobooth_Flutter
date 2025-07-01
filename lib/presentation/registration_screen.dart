import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/providers/admin_watermark_provider.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/providers/photobooth_provider.dart';
import 'package:photobooth_flutter/providers/registration_screen_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:photobooth_flutter/widgets/snackbar.dart';
import 'package:photobooth_flutter/widgets/watermark_overlay.dart';
import 'package:provider/provider.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    final registrationSettings =
        Provider.of<RegistrationScreenProvider>(context, listen: false);

    for (var field in registrationSettings.textFields) {
      final controller = TextEditingController();
      _controllers[field.id] = controller;
      _focusNodes[field.id] = FocusNode();
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
    for (var focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registrationSettings = context.watch<RegistrationScreenProvider>();
    final globalSettings = context.watch<GlobalSettingsProvider>();
    final watermarkProvider = context.watch<AdminWatermarkProvider>();
    final screenSize = MediaQuery.of(context).size;

    final textScale = min(screenSize.width / 1080.0, screenSize.height / 1920.0);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_rounded,
              color: AppColors.lightWhite,
              size: 32,
            ),
            onPressed: () {
              Navigator.pushNamed(
                  context, AppRoutes.registrationScreenSettings);
            },
          ),
        ],
      ),
      body: WatermarkOverlay(
        show: watermarkProvider.showWatermark,
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
                left: registrationSettings.titleLeft * screenSize.width,
                top: registrationSettings.titleTop * screenSize.height,
                width: registrationSettings.titleWidth * screenSize.width,
                child: Text(
                  registrationSettings.titleText,
                  style: TextStyle(
                    fontSize: registrationSettings.titleFontSize * textScale,
                    fontWeight: registrationSettings.titleFontWeight,
                    color: registrationSettings.titleTextColor,
                  ),
                  textAlign: registrationSettings.titleTextAlign,
                ),
              ),
          ...registrationSettings.textFields
                .where((field) => field.isEnabled)
                .map((field) => Positioned(
                      left: field.left * screenSize.width,
                      top: field.top * screenSize.height,
                      width: field.width * screenSize.width,
                      height: field.height * screenSize.height,
                      child: TextFormField(
                        controller: _controllers[field.id],
                        focusNode: _focusNodes[field.id],
                        maxLines: 1,
                        textAlignVertical: TextAlignVertical.center, // Add this
                        showCursor: true,
                        style: TextStyle(
                          color: field.textColor,
                          fontSize: field.fontSize * textScale,
                          fontWeight: field.fontWeight,
                          fontStyle: field.isItalic
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                        decoration: InputDecoration(
                          // isDense: true, // Add this
                          contentPadding: EdgeInsets.zero, // And add this
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          labelText: field.label,
                          hintText: field.hintText,
                          labelStyle: TextStyle(
                              fontSize: field.fontSize * textScale,
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
                      ),
                    )),
            Positioned(
              left: registrationSettings.buttonLeft * screenSize.width,
              bottom: registrationSettings.buttonBottom * screenSize.height,
              child: registrationSettings.useImageButton
                  ? _buildImageButton(registrationSettings, textScale)
                  : _buildTextButton(registrationSettings, textScale),
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
            // Bottom Right Back Button
            Positioned(
              bottom: 30,
              left: 30,
              child: GestureDetector(
                onTap: () {
                  context.read<PhotoboothProvider>().clearUserDetails();
                  Navigator.pop(context);
                },
                child: Image.asset(
                  'assets/images/back_btn.png',
                  width: 120, // Set desired width
                  height: 120, // Set desired height
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextButton(RegistrationScreenProvider settings, double textScale) {
    return Opacity(
      opacity: settings.buttonOpacity,
      child: ElevatedButton(
        onPressed: _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: settings.submitButtonColor,
          foregroundColor: settings.submitButtonTextColor,
          padding: settings.buttonPadding,
          minimumSize: Size(settings.buttonWidth * MediaQuery.of(context).size.width,
                              settings.buttonHeight * MediaQuery.of(context).size.height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(settings.buttonBorderRadius * textScale),
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
            fontSize: settings.buttonFontSize * textScale,
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

  Widget _buildImageButton(RegistrationScreenProvider settings, double textScale) {
    if (settings.buttonImagePath == null) {
      return _buildTextButton(settings, textScale);
    }

    return Opacity(
      opacity: settings.buttonImageOpacity,
      child: GestureDetector(
        onTap: _handleSubmit,
        child: ClipRRect(
        borderRadius: BorderRadius.circular(settings.buttonBorderRadius * textScale),
          child: Container(
           width: settings.buttonWidth * MediaQuery.of(context).size.width,
            height: settings.buttonHeight * MediaQuery.of(context).size.height,
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
    FocusScope.of(context).unfocus();
    final registrationSettings = context.read<RegistrationScreenProvider>();
    String? firstErrorMessage;

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
          break;
        }
      }
    }

    if (firstErrorMessage != null) {
      showSnackBar(context, firstErrorMessage, isError: true);
    } else {
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
