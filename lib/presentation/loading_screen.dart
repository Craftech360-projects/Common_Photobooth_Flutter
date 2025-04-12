import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/providers/loading_screen_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_media_kit/video_player_media_kit.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  VideoPlayerController? _videoController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    VideoPlayerMediaKit.ensureInitialized(
      macOS: true,
      windows: true,
    );
    _startLoading();
  }

  Future<void> _startLoading() async {
    final settings = Provider.of<LoadingScreenProvider>(context, listen: false);

    // Initialize video controller if needed
    if (settings.loaderFileType == 'mp4' || settings.loaderFileType == 'mov') {
      await _initializeVideoPlayer(settings);
    }

    setState(() {
      _isInitialized = true;
    });

    // Navigate to the swapped face screen after the specified duration
    Future.delayed(Duration(seconds: settings.loaderDurationSeconds), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.swappedFace);
      }
    });
  }

  Future<void> _initializeVideoPlayer(LoadingScreenProvider settings) async {
    if (settings.loaderFilePath == null) return;

    if (settings.isLoaderFileAsset) {
      // For asset videos
      _videoController = VideoPlayerController.asset(
        settings.loaderFilePath!,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
    } else {
      // For file videos
      _videoController = VideoPlayerController.file(
        File(settings.loaderFilePath!),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
    }

    try {
      await _videoController!.initialize();
      await _videoController!.setLooping(true);
      await _videoController!.play();
    } on Exception catch (e) {
      debugPrint('Error initializing video player: $e');
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LoadingScreenProvider, GlobalSettingsProvider>(
      builder: (context, loadingSettings, globalSettings, child) {
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: _getBackgroundImage(loadingSettings, globalSettings),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  if (loadingSettings.showTitle)
                    Padding(
                      padding:
                          EdgeInsets.only(bottom: loadingSettings.titlePadding),
                      child: Text(
                        loadingSettings.titleText,
                        style: TextStyle(
                          fontSize: loadingSettings.titleFontSize,
                          fontWeight: loadingSettings.titleFontWeight,
                          color: loadingSettings.titleColor,
                        ),
                      ),
                    ),

                  // Loader
                  Container(
                    width: loadingSettings.loaderWidth,
                    height: loadingSettings.loaderHeight,
                    decoration: loadingSettings.showLoaderBorder
                        ? BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                loadingSettings.loaderBorderRadius),
                            border: Border.all(
                              color: loadingSettings.loaderBorderColor,
                              width: loadingSettings.loaderBorderWidth,
                            ),
                          )
                        : null,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                          loadingSettings.loaderBorderRadius),
                      child: _buildLoader(loadingSettings),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoader(LoadingScreenProvider settings) {
    // If no loader file is specified, show a default circular progress indicator
    if (settings.loaderFilePath == null || !_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.goldenYellow,
        ),
      );
    }

    // Based on the file type, show the appropriate loader
    switch (settings.loaderFileType) {
      case 'gif':
        return settings.isLoaderFileAsset
            ? Image.asset(
                settings.loaderFilePath!,
                fit: BoxFit.contain,
              )
            : Image.file(
                File(settings.loaderFilePath!),
                fit: BoxFit.contain,
              );

      case 'json':
        return Lottie.asset(
          settings.loaderFilePath!,
          fit: BoxFit.contain,
        );

      case 'mp4':
      case 'mov':
        if (_videoController != null && _videoController!.value.isInitialized) {
          return AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          );
        }
        return const Center(
          child: CircularProgressIndicator(
            color: AppColors.goldenYellow,
          ),
        );

      default:
        return const Center(
          child: CircularProgressIndicator(
            color: AppColors.goldenYellow,
          ),
        );
    }
  }

  DecorationImage? _getBackgroundImage(
      LoadingScreenProvider settings, GlobalSettingsProvider globalSettings) {
    // First try to use the screen-specific background if it's enabled and available
    if (settings.showBackground && settings.backgroundImagePath != null) {
      return DecorationImage(
        image: settings.isBackgroundImageAsset
            ? AssetImage(settings.backgroundImagePath!)
            : FileImage(File(settings.backgroundImagePath!)) as ImageProvider,
        fit: BoxFit.cover,
      );
    }
    // Fall back to global background if available
    else if (globalSettings.backgroundImagePath != null) {
      return DecorationImage(
        image: globalSettings.isBackgroundImageAsset
            ? AssetImage(globalSettings.backgroundImagePath!)
            : FileImage(File(globalSettings.backgroundImagePath!))
                as ImageProvider,
        fit: BoxFit.cover,
      );
    }
    // Use default background as last resort
    else {
      return const DecorationImage(
        image: AssetImage('assets/images/background.jpg'),
        fit: BoxFit.cover,
      );
    }
  }
}
