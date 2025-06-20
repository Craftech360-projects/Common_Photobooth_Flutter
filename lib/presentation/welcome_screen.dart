import 'dart:io';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:photobooth_flutter/providers/admin_watermark_provider.dart';
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
  late final Player _player;
  late final VideoController _controller;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _controller = VideoController(_player);
    _player.open(Media('asset://assets/videos/welcome_bg.mp4'), play: true);
    // Correct: Use setPlaylistMode for looping
    _player.setPlaylistMode(PlaylistMode.single);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final welcomeSettings = context.watch<WelcomeScreenProvider>();
    final watermarkProvider = context.watch<AdminWatermarkProvider>();

    if (!welcomeSettings.showWelcomeScreen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.participantDetails);
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      body: WatermarkOverlay(
        show: watermarkProvider.showWatermark,
        child: Stack(
          children: [
            // CORRECTED WIDGET STRUCTURE
            SizedBox.expand(
              child: Video(
                controller: _controller,
                controls: NoVideoControls,
                fit: BoxFit.cover, // Apply the fit property directly here
              ),
            ),
            Positioned(
              left: welcomeSettings.buttonLeft,
              bottom: welcomeSettings.buttonBottom,
              child: welcomeSettings.useImageButton
                  ? _buildImageButton(welcomeSettings)
                  : _buildTextButton(welcomeSettings),
            ),
            Positioned(
              left: 0,
              bottom: 0,
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
}
