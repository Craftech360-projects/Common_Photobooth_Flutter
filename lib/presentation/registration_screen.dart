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
import 'package:virtual_keyboard_multi_language/virtual_keyboard_multi_language.dart';

class ParticipantDetailsScreen extends StatefulWidget {
  const ParticipantDetailsScreen({super.key});

  @override
  State<ParticipantDetailsScreen> createState() =>
      _ParticipantDetailsScreenState();
}

class _ParticipantDetailsScreenState extends State<ParticipantDetailsScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  bool _isKeyboardVisible = false;
  TextEditingController? _currentController;
  // Use a mutable keyboard type
  VirtualKeyboardType _keyboardType = VirtualKeyboardType.Alphanumeric;

  @override
  void initState() {
    super.initState();
    final registrationSettings =
        Provider.of<RegistrationScreenProvider>(context, listen: false);

    for (var field in registrationSettings.textFields) {
      final controller = TextEditingController();
      _controllers[field.id] = controller;

      _focusNodes[field.id] = FocusNode()
        ..addListener(() {
          if (_focusNodes[field.id]!.hasFocus) {
            setState(() {
              _currentController = _controllers[field.id];
              // Set keyboard type based on the focused field
              _keyboardType = (field.fieldType == TextFieldType.email)
                  ? VirtualKeyboardType.Alphanumeric
                  : VirtualKeyboardType.Alphanumeric;
              _isKeyboardVisible = true;
            });
          }
        });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!registrationSettings.showRegistrationScreen) {
        Navigator.pushReplacementNamed(context, AppRoutes.genderSelection);
      }
    });
  }

  /// Correctly handles key presses from the virtual keyboard.
  void _onKeyPress(VirtualKeyboardKey key) {
    if (_currentController == null) return;

    final text = _currentController!.text;
    final selection = _currentController!.selection;

    // --- FIX STARTS HERE ---
    // Check for the backspace action.
    if (key.action == VirtualKeyboardKeyAction.Backspace) {
      if (selection.baseOffset > 0) {
        final newText = text.replaceRange(
          selection.start - 1,
          selection.end,
          '',
        );
        _currentController!.text = newText;
        // Move the cursor back
        _currentController!.selection = TextSelection.fromPosition(
            TextPosition(offset: selection.start - 1));
      }
    } else if (key.action == VirtualKeyboardKeyAction.Return) {
      // Optional: Handle the enter key, e.g., by submitting the form.
      _handleSubmit();
    } else {
      // Handle all other keys (letters, numbers, symbols).
      final newText = text.replaceRange(
        selection.start,
        selection.end,
        key.text ?? '',
      );
      _currentController!.text = newText;
      // Move the cursor forward
      _currentController!.selection = TextSelection.fromPosition(
          TextPosition(offset: selection.start + (key.text?.length ?? 0)));
    }
    // --- FIX ENDS HERE ---
  }

  /// Hides the virtual keyboard and unfocuses the text fields.
  void _hideKeyboard() {
    setState(() {
      _isKeyboardVisible = false;
    });
    FocusScope.of(context).unfocus();
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

    return Scaffold(
      body: WatermarkOverlay(
        show: watermarkProvider.showWatermark,
        child: Stack(
          children: [
            GestureDetector(
              onTap: _hideKeyboard,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: _getBackgroundImage(
                        registrationSettings, globalSettings),
                    fit: BoxFit.cover,
                  ),
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
                        focusNode: _focusNodes[field.id],
                        readOnly: true,
                        showCursor: true,
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
            if (_isKeyboardVisible)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: VirtualKeyboard(
                    height: MediaQuery.of(context).size.height * 0.25,
                    postKeyPress: _onKeyPress,
                    type: _keyboardType,
                    textColor: Colors.white,
                    fontSize: 30,
                    // You can optionally set a height
                    // height: 350,
                  ),
                ),
              )
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
    _hideKeyboard();
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
