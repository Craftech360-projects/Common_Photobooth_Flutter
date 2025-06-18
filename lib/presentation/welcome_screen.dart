import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photobooth_flutter/providers/admin_watermark_provider.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/providers/welcome_screen_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:photobooth_flutter/widgets/watermark_overlay.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/welcome_bg.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
      body: WatermarkOverlay(
        show: watermarkProvider.showWatermark,
        child: Stack(
          children: [
            // Background Video
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),

            // Your existing content on top of the video
            Positioned(
              left: welcomeSettings.buttonLeft,
              bottom: welcomeSettings.buttonBottom,
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
}
