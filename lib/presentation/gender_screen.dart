import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/providers/admin_watermark_provider.dart';
import 'package:photobooth_flutter/providers/gender_screen_provider.dart';
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

  void _handleContinue() {
    if (_selectedGender == null) {
      setState(() {
        _showError = true;
      });
      return;
    }
    final appProvider = context.read<PhotoboothProvider>();
    appProvider.setGender(_selectedGender!);

    Navigator.pushNamed(context, AppRoutes.categoriesScreen);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<GenderSelectionProvider>();
    final globalSettings = context.watch<GlobalSettingsProvider>();
    final watermarkProvider = context.watch<AdminWatermarkProvider>();
    final screenSize = MediaQuery.of(context).size;

    // Scaling for fonts and other non-stretching elements
    final textScale =
        min(screenSize.width / 1080.0, screenSize.height / 1920.0);

    return Scaffold(
      body: WatermarkOverlay(
        show: watermarkProvider.showWatermark,
        child: Stack(
          alignment: Alignment.center,
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
            Positioned(
              left: settings.titleLeft * screenSize.width,
              top: settings.titleTop * screenSize.height,
              width: settings.titleWidth * screenSize.width,
              child: Text(
                settings.titleText,
                style: TextStyle(
                  fontSize: settings.titleFontSize * textScale,
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

            Positioned(
              left: settings.genderSelectionLeft * screenSize.width,
              top: settings.genderSelectionTop * screenSize.height,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildGenderOption('male', settings, screenSize),
                  SizedBox(
                      width: settings
                          .imageSpacing), // Spacing is fine in logical pixels
                  _buildGenderOption('female', settings, screenSize),
                ],
              ),
            ),

            if (_showError)
              Positioned(
                bottom: settings.buttonBottom + 80,
                child: const Text(
                  'Please select a gender to continue',
                  style: TextStyle(
                    color: AppColors.red,
                    fontSize: 16,
                  ),
                ),
              ),

            Positioned(
              left: settings.buttonLeft * screenSize.width,
              bottom: settings.buttonBottom * screenSize.height,
              child: settings.useImageButton
                  ? _buildImageButton(settings, screenSize)
                  : _buildTextButton(settings, screenSize),
            ),

            Positioned(
              right: 0,
              top: 0,
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(
                    context, AppRoutes.genderScreenSettings),
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
                  context.read<PhotoboothProvider>().clearGender();
                  Navigator.pop(context);
                },
                child: Image.asset(
                  'assets/images/back_btn.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderOption(
      String gender, GenderSelectionProvider settings, Size screenSize) {
    final imageWidth = settings.imageWidth * screenSize.width;
    final imageHeight = settings.imageHeight * screenSize.height;

    final isSelected = _selectedGender == gender;
    final isMale = gender == 'male';

    final imagePath =
        isMale ? settings.maleImagePath : settings.femaleImagePath;
    final isAsset =
        isMale ? settings.isMaleImageAsset : settings.isFemaleImageAsset;

    if (imagePath == null) {
      return Container(
          width: settings.imageWidth,
          height: settings.imageHeight,
          color: Colors.grey[200]);
    }

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
            ? imageWidth * settings.selectedImageScale
            : imageWidth,
        height: isSelected && settings.useSelectionEffect
            ? imageHeight * settings.selectedImageScale
            : imageHeight,
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
                ? AssetImage(imagePath)
                : FileImage(File(imagePath)) as ImageProvider,
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

  Widget _buildImageButton(GenderSelectionProvider settings, Size screenSize) {
    if (settings.buttonImagePath == null) {
      return _buildTextButton(settings, screenSize);
    }

    return Opacity(
      opacity: 1.0,
      child: GestureDetector(
        onTap: _handleContinue,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(settings.buttonBorderRadius),
          child: Container(
            width: settings.buttonWidth * screenSize.width,
            height: settings.buttonHeight * screenSize.height,
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

  Widget _buildTextButton(GenderSelectionProvider settings, Size screenSize) {
    return SizedBox(
      width: settings.buttonWidth * screenSize.width,
      height: settings.buttonHeight * screenSize.height,
      child: ElevatedButton(
        onPressed: _handleContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: settings.buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(settings.buttonBorderRadius),
          ),
        ),
        child: Text(
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
    if (settings.showBackground && settings.backgroundImagePath != null) {
      if (settings.isBackgroundImageAsset) {
        return AssetImage(settings.backgroundImagePath!);
      } else {
        return FileImage(File(settings.backgroundImagePath!));
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
