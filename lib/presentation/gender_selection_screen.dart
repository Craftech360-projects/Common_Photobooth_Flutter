import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/providers/admin_watermark_provider.dart';
import 'package:photobooth_flutter/providers/gender_selection_provider.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/providers/photobooth_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:photobooth_flutter/widgets/watermark_overlay.dart';
import 'package:provider/provider.dart';

class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({super.key});

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String? _selectedGender;
  bool _showError = false;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<GenderSelectionProvider>();
    final globalSettings = context.watch<GlobalSettingsProvider>();
    final appProvider = context.watch<PhotoboothProvider>();
    final watermarkProvider = context.watch<AdminWatermarkProvider>();

    return Scaffold(
      body: WatermarkOverlay(
        show: watermarkProvider.showWatermark,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: _getBackgroundImage(settings, globalSettings),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Title with updated styling
            Positioned(
              left: settings.titleLeft,
              top: settings.titleTop,
              width: settings.titleWidth,
              child: Text(
                settings.titleText,
                style: TextStyle(
                  fontSize: settings.titleFontSize,
                  fontWeight: settings.titleFontWeight,
                  color: settings.titleColor
                      .withValues(alpha: settings.titleOpacity),
                  fontStyle: settings.titleItalic
                      ? FontStyle.italic
                      : FontStyle.normal,
                  height: settings.titleLineHeight,
                ),
                textAlign: settings.titleAlignment,
              ),
            ),

            // Gender Selection with margins and padding
            Positioned(
              left: settings.genderSelectionLeft,
              top: settings.genderSelectionTop,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Male Option
                  _buildGenderOption('male', settings),

                  // Female Option
                  _buildGenderOption('female', settings),
                ],
              ),
            ),

            // Error message
            if (_showError)
              const Text(
                'Please select a gender to continue',
                style: TextStyle(
                  color: AppColors.red,
                  fontSize: 16,
                ),
              ),

            // Continue Button with margins
            Positioned(
              left: settings.buttonLeft,
              bottom: settings.buttonBottom,
              child: settings.useImageButton
                  ? _buildImageButton(settings, appProvider)
                  : _buildButton(settings, appProvider),
            ),

            // _buildButton(settings, appProvider)),

            Positioned(
              right: 0,
              top: 0,
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(
                    context, AppRoutes.genderScreenSettings),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderOption(String gender, GenderSelectionProvider settings) {
    final bool isSelected = _selectedGender == gender;
    final bool isMale = gender == 'male';

    final imagePath =
        isMale ? settings.maleImagePath : settings.femaleImagePath;
    final isAsset =
        isMale ? settings.isMaleImageAsset : settings.isFemaleImageAsset;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
          _showError = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isSelected && settings.useSelectionEffect
            ? settings.imageWidth * settings.selectedImageScale
            : settings.imageWidth,
        height: isSelected && settings.useSelectionEffect
            ? settings.imageHeight * settings.selectedImageScale
            : settings.imageHeight,
        margin: EdgeInsets.symmetric(horizontal: settings.imageSpacing / 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(settings.imageBorderRadius),
          border: settings.showImageBorder
              ? Border.all(
                  color: settings.imageBorderColor,
                  width: settings.imageBorderWidth,
                )
              : null,
          image: DecorationImage(
            image: isAsset
                ? AssetImage(imagePath!)
                : FileImage(File(imagePath!)) as ImageProvider,
            fit: BoxFit.contain,
          ),
          boxShadow: isSelected &&
                  settings.useSelectionEffect &&
                  settings.useSelectionGlow
              ? [
                  BoxShadow(
                    color: settings.selectionGlowColor
                        .withValues(alpha: settings.selectionGlowIntensity),
                    blurRadius: settings.selectionGlowSpread,
                    spreadRadius: settings.selectionGlowSpread / 2,
                  )
                ]
              : null,
        ),
      ),
    );
  }

  Widget _buildImageButton(
      GenderSelectionProvider settings, PhotoboothProvider appProvider) {
    if (settings.buttonImagePath == null) {
      // Fallback to text button if no image is selected
      return _buildButton(settings, appProvider);
    }

    return Opacity(
      opacity: 1.0,
      child: GestureDetector(
        onTap: () {
          if (_selectedGender == null) {
            setState(() {
              _showError = true;
            });
            return;
          }

          // Set the gender in the provider
          appProvider.setGender(_selectedGender!);

          // Navigate directly to face capture screen instead of character selection
          Navigator.pushNamed(context, AppRoutes.faceCapture);
        },
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

  Widget _buildButton(
      GenderSelectionProvider settings, PhotoboothProvider appProvider) {
    return SizedBox(
      width: settings.buttonWidth,
      height: settings.buttonHeight,
      child: ElevatedButton(
        onPressed: () {
          if (_selectedGender == null) {
            setState(() {
              _showError = true;
            });
            return;
          }

          // Set the gender in the provider
          appProvider.setGender(_selectedGender!);

          // Navigate directly to face capture screen instead of character selection
          Navigator.pushNamed(context, AppRoutes.faceCapture);
        },
        style: ElevatedButton.styleFrom(
          // padding: settings.buttonPadding,
          backgroundColor: settings.buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(settings.buttonBorderRadius),
          ),
        ),
        child: settings.useImageButton && settings.buttonImagePath != null
            ? Image.file(
                File(settings.buttonImagePath!),
                fit: BoxFit.cover,
              )
            : Text(
                settings.buttonText,
                style: TextStyle(
                  color: settings.buttonTextColor,
                  fontSize: settings.buttonFontSize,
                  fontWeight: settings.buttonFontWeight,
                ),
              ),
      ),
    );
  }

  ImageProvider _getBackgroundImage(
      GenderSelectionProvider settings, GlobalSettingsProvider globalSettings) {
    // First try to use gender screen specific background
    if (settings.showBackground && settings.backgroundImagePath != null) {
      if (settings.isBackgroundImageAsset) {
        return AssetImage(settings.backgroundImagePath!);
      } else {
        return FileImage(File(settings.backgroundImagePath!));
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
