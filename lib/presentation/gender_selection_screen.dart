import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photobooth_flutter/providers/photobooth_provider.dart';
import 'package:photobooth_flutter/providers/gender_selection_provider.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
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

    return Scaffold(
      // appBar: AppBar(
      //   leading: IconButton(
      //       onPressed: () =>
      //           Navigator.pushNamed(context, AppRoutes.genderScreenSettings),
      //       icon: const Icon(Icons.star)),
      // ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(settings.screenPadding),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: _getBackgroundImage(settings, globalSettings),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title with updated styling
            Container(
              margin: settings.titleMargin,
              padding: EdgeInsets.only(bottom: settings.titlePadding),
              child: Text(
                settings.titleText,
                style: TextStyle(
                  fontSize: settings.titleFontSize,
                  fontWeight: settings.titleFontWeight,
                  color: settings.titleColor.withOpacity(settings.titleOpacity),
                  fontStyle: settings.titleItalic
                      ? FontStyle.italic
                      : FontStyle.normal,
                  height: settings.titleLineHeight,
                ),
                textAlign: settings.titleAlignment,
              ),
            ),

            // Gender Selection with margins and padding
            Container(
              margin: settings.imagesRowMargin,
              padding: settings.imagesRowPadding,
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
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  'Please select a gender to continue',
                  style: TextStyle(
                    color: Colors.red[400],
                    fontSize: 16,
                  ),
                ),
              ),

            // Continue Button with margins
            Container(
              margin: settings.buttonMargin,
              child: _buildButton(settings, appProvider),
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
            fit: BoxFit.cover,
          ),
          boxShadow: isSelected &&
                  settings.useSelectionEffect &&
                  settings.useSelectionGlow
              ? [
                  BoxShadow(
                    color: settings.selectionGlowColor
                        .withOpacity(settings.selectionGlowIntensity),
                    blurRadius: settings.selectionGlowSpread,
                    spreadRadius: settings.selectionGlowSpread / 2,
                  )
                ]
              : null,
        ),
      ),
    );
  }

  Widget _buildButton(
      GenderSelectionProvider settings, PhotoboothProvider appProvider) {
    if (settings.useImageButton && settings.buttonImagePath != null) {
      // Image Button with padding
      return GestureDetector(
        onTap: () => _validateAndContinue(appProvider),
        child: Container(
          width: settings.buttonWidth,
          height: settings.buttonHeight,
          padding: settings.buttonPadding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(settings.buttonBorderRadius),
            border: settings.buttonHasBorder
                ? Border.all(
                    color: settings.buttonBorderColor,
                    width: settings.buttonBorderWidth,
                  )
                : null,
            image: DecorationImage(
              image: settings.isButtonImageAsset
                  ? AssetImage(settings.buttonImagePath!)
                  : FileImage(File(settings.buttonImagePath!)) as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else {
      // Text Button with padding
      return ElevatedButton(
        onPressed: () => _validateAndContinue(appProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor: settings.buttonColor,
          foregroundColor: settings.buttonTextColor,
          minimumSize: Size(settings.buttonWidth, settings.buttonHeight),
          padding: settings.buttonPadding,
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
          settings.buttonText,
          style: TextStyle(
            fontSize: settings.buttonFontSize,
          ),
        ),
      );
    }
  }

  void _validateAndContinue(PhotoboothProvider appProvider) {
    if (_selectedGender == null) {
      setState(() {
        _showError = true;
      });
    } else {
      _continueToNextScreen(appProvider);
    }
  }

  void _continueToNextScreen(PhotoboothProvider appProvider) {
    appProvider.setGender(_selectedGender!);
    Navigator.pushNamed(context, AppRoutes.characterSelection);
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
