import 'dart:io';

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

    // If welcome screen is disabled, navigate directly to participant details
    if (!welcomeSettings.showWelcomeScreen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.participantDetails);
      });
      return const SizedBox.shrink(); // Return empty widget while redirecting
    }

    return Scaffold(
      // appBar: AppBar(
      //   leading: IconButton(
      //     onPressed: () =>
      //         Navigator.pushNamed(context, AppRoutes.welcomeScreenSettings),
      //     icon: const Icon(Icons.star),
      //   ),
      // ),
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

            // Content
            Positioned(
              left: welcomeSettings.welcomeMessageLeft,
              top: welcomeSettings.welcomeMessageTop,
              width: welcomeSettings.welcomeMessageWidth,
             
              child: Text(
                welcomeSettings.welcomeMessage,
                style: TextStyle(
                  fontSize: welcomeSettings.welcomeMessageFontSize,
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
              left: welcomeSettings.buttonLeft,
              top: welcomeSettings.buttonTop,
              child: welcomeSettings.useImageButton
                  ? _buildImageButton(welcomeSettings)
                  : _buildTextButton(welcomeSettings),
            ),

            // Admin access button (hidden at bottom)
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
          ],
        ),
      ),
    );
  }

  Widget _buildTextButton(WelcomeScreenProvider settings) {
    return Opacity(
      opacity: settings.buttonOpacity,
      child: ElevatedButton(
        onPressed: () =>
            Navigator.pushNamed(context, AppRoutes.participantDetails),
        style: ElevatedButton.styleFrom(
          backgroundColor: settings.welcomeButtonColor,
          foregroundColor: settings.welcomeButtonTextColor,
          minimumSize: Size(settings.buttonWidth, settings.buttonHeight),
          padding: EdgeInsets.symmetric(
            vertical: settings.buttonPaddingVertical,
            horizontal: settings.buttonPaddingHorizontal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(settings.buttonBorderRadius),
          ),
        ),
        child: Text(
          settings.welcomeButtonText,
          style: TextStyle(
            fontSize: settings.buttonTextFontSize,
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

  Widget _buildImageButton(WelcomeScreenProvider settings) {
    if (settings.buttonImagePath == null) {
      // Fallback to text button if no image is selected
      return _buildTextButton(settings);
    }

    return Opacity(
      opacity: settings.buttonOpacity,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRoutes.participantDetails),
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
                opacity: settings.buttonImageOpacity,
              ),
            ),
          ),
        ),
      ),
    );
  }

  ImageProvider _getBackgroundImage(WelcomeScreenProvider welcomeSettings,
      GlobalSettingsProvider globalSettings) {
    // First try to use welcome screen specific background
    if (welcomeSettings.welcomeScreenBackground != null) {
      if (welcomeSettings.isWelcomeScreenBackgroundAsset) {
        return AssetImage(welcomeSettings.welcomeScreenBackground!);
      } else {
        return FileImage(File(welcomeSettings.welcomeScreenBackground!));
      }
    }

    // Fall back to global background
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
