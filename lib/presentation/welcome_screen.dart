import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:photobooth_flutter/providers/admin_watermark_provider.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/providers/welcome_screen_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:photobooth_flutter/widgets/watermark_overlay.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    final welcomeSettings = context.watch<WelcomeScreenProvider>();
    final globalSettings = context.watch<GlobalSettingsProvider>();
    final watermarkProvider = context.watch<AdminWatermarkProvider>();
    final screenSize = MediaQuery.of(context).size;

    if (!welcomeSettings.showWelcomeScreen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.participantDetails);
      });
      return const SizedBox.shrink();
    }

    // --- Responsive Scaling Logic ---
    // This is used for font sizes and non-stretching elements
    const refWidth = 1080.0;
    const refHeight = 1920.0;
    final textScale =
        min(screenSize.width / refWidth, screenSize.height / refHeight);

    return Scaffold(
      body: WatermarkOverlay(
        show: watermarkProvider.showWatermark,
        child: Stack(
          children: [
            // Background
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: _getBackgroundImage(welcomeSettings, globalSettings),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // --- CORRECTED POSITIONING ---
            Positioned(
              left: welcomeSettings.welcomeMessageLeft * screenSize.width,
              top: welcomeSettings.welcomeMessageTop * screenSize.height,
              width: welcomeSettings.welcomeMessageWidth * screenSize.width,
              child: Text(
                welcomeSettings.welcomeMessage,
                style: TextStyle(
                  fontSize: welcomeSettings.welcomeMessageFontSize * textScale,
                  fontWeight: welcomeSettings.welcomeMessageFontWeight,
                  color: welcomeSettings.welcomeMessageColor
                      .withValues(alpha: welcomeSettings.welcomeMessageOpacity),
                  fontStyle: welcomeSettings.welcomeMessageItalic
                      ? FontStyle.italic
                      : FontStyle.normal,
                  height: welcomeSettings.welcomeMessageLineHeight,
                ),
                textAlign: welcomeSettings.welcomeMessageTextAlign,
              ),
            ),
            Positioned(
              left: welcomeSettings.buttonLeft * screenSize.width,
              bottom: welcomeSettings.buttonBottom * screenSize.height,
              child: welcomeSettings.useImageButton
                  ? _buildImageButton(welcomeSettings, textScale)
                  : _buildTextButton(welcomeSettings, textScale),
            ),
            // --- END OF CORRECTION ---

            // Admin access button
            Positioned(
              right: 0,
              top: 0,
              child: GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.adminScreen),
                child: Container(
                  width: 50,
                  height: 50,
                  color: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Button build methods now only need textScale for fonts and border radius
  Widget _buildTextButton(WelcomeScreenProvider settings, double textScale) {
    return Opacity(
      opacity: settings.buttonOpacity,
      child: ElevatedButton(
        onPressed: () =>
            Navigator.pushNamed(context, AppRoutes.genderSelection),
        style: ElevatedButton.styleFrom(
          backgroundColor: settings.welcomeButtonColor,
          foregroundColor: settings.welcomeButtonTextColor,
          minimumSize: Size(settings.buttonWidth, settings.buttonHeight),
          padding: EdgeInsets.symmetric(
            vertical: settings.buttonPaddingVertical,
            horizontal: settings.buttonPaddingHorizontal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(settings.buttonBorderRadius * textScale),
          ),
        ),
        child: Text(
          settings.welcomeButtonText,
          style: TextStyle(
            fontSize: settings.buttonTextFontSize * textScale,
            fontWeight: settings.buttonTextFontWeight,
            color: settings.welcomeButtonTextColor
                .withValues(alpha: settings.buttonTextOpacity),
            fontStyle:
                settings.buttonTextItalic ? FontStyle.italic : FontStyle.normal,
            height: settings.buttonTextLineHeight,
          ),
        ),
      ),
    );
  }

  Widget _buildImageButton(WelcomeScreenProvider settings, double textScale) {
    if (settings.buttonImagePath == null) {
      return _buildTextButton(settings, textScale);
    }
    return Opacity(
      opacity: settings.buttonOpacity,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRoutes.genderSelection),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(settings.buttonBorderRadius * textScale),
          child: SizedBox(
            width: settings.buttonWidth,
            height: settings.buttonHeight,
            child: Image(
              image: settings.isButtonImageAsset
                  ? AssetImage(settings.buttonImagePath!)
                  : FileImage(File(settings.buttonImagePath!)) as ImageProvider,
              fit: BoxFit.contain,
              opacity: AlwaysStoppedAnimation(settings.buttonImageOpacity),
            ),
          ),
        ),
      ),
    );
  }

  ImageProvider _getBackgroundImage(WelcomeScreenProvider welcomeSettings,
      GlobalSettingsProvider globalSettings) {
    if (welcomeSettings.welcomeScreenBackground != null) {
      return welcomeSettings.isWelcomeScreenBackgroundAsset
          ? AssetImage(welcomeSettings.welcomeScreenBackground!)
          : FileImage(File(welcomeSettings.welcomeScreenBackground!));
    }
    if (globalSettings.backgroundImage != null) {
      return globalSettings.isAssetImage
          ? AssetImage(globalSettings.backgroundImage!)
          : FileImage(File(globalSettings.backgroundImage!));
    }
    return const AssetImage('assets/images/background.jpg');
  }
}
