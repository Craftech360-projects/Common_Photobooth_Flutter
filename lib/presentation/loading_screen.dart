import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/providers/loading_screen_provider.dart';
import 'package:photobooth_flutter/providers/photobooth_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:photobooth_flutter/services/supabase_service.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  VideoPlayerController? _videoController;
  bool _isInitialized = false;
  bool _isProcessing = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeLoader();
    // Start processing the image after the loader is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processImage();
    });
  }

  Future<void> _initializeLoader() async {
    final settings = Provider.of<LoadingScreenProvider>(context, listen: false);

    // Initialize video controller if needed
    if ((settings.loaderFileType == 'mp4' ||
            settings.loaderFileType == 'mov') &&
        settings.loaderFilePath != null) {
      try {
        await _initializeVideoPlayer(settings);
      } catch (e) {
        debugPrint('Error initializing video player: $e');
        // Continue without video if initialization fails
      }
    }

    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _processImage() async {
    try {
      final provider = Provider.of<PhotoboothProvider>(context, listen: false);

      // Check if we have a face image path
      if (provider.faceImagePath == null) {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'No face image captured';
        });
        return;
      }

      // Get the image file
      final imageFile = File(provider.faceImagePath!);

      // Verify file exists
      if (!imageFile.existsSync()) {
        debugPrint(
            'Image file does not exist at path: ${provider.faceImagePath}');
        setState(() {
          _isProcessing = false;
          _errorMessage = 'Image file not found';
        });
        return;
      }

      // Get participant details from provider
      final name = provider.name ?? '';
      final email = provider.email ?? '';
      final gender = provider.selectedGender;
      final characterId = provider.selectedCharacterId;

      // Check if Supabase is initialized
      if (SupabaseService.instance.isInitialized) {
        // Generate a unique user ID
        final userId = DateTime.now().millisecondsSinceEpoch.toString();

        // Upload image to Supabase
        final imageUrl =
            await SupabaseService.instance.uploadImage(imageFile, userId);

        if (imageUrl != null) {
          final participantId =
              await SupabaseService.instance.storeParticipantDetails(
            name: name,
            email: email,
            gender: gender,
            characterId: characterId,
            imageUrl: imageUrl,
          );

          if (participantId != null) {
            // Store the captured image URL in the provider
            provider.setCapturedImageUrl(imageUrl);

            // Navigate to the output screen
            if (mounted) {
              Navigator.pushReplacementNamed(context, AppRoutes.swappedFace);
            }
          } else {
            setState(() {
              _isProcessing = false;
              _errorMessage = 'Failed to store participant details';
            });
          }
        } else {
          setState(() {
            _isProcessing = false;
            _errorMessage = 'Failed to upload image';
          });
        }
      } else {
        debugPrint('Supabase not initialized, using dummy URL');
        // For testing without Supabase, set a dummy URL
        provider.setCapturedImageUrl('https://example.com/dummy-image.jpg');

        // Add a short delay to simulate processing
        await Future.delayed(const Duration(seconds: 2));

        // Navigate to the output screen
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.swappedFace);
        }
      }
    } catch (e) {
      debugPrint('Error processing image: $e');
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> _initializeVideoPlayer(LoadingScreenProvider settings) async {
    if (settings.loaderFilePath == null) return;

    try {
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

      await _videoController!.initialize();
      await _videoController!.setLooping(true);
      await _videoController!.play();
    } catch (e) {
      debugPrint('Error initializing video player: $e');
      _videoController = null; // Set to null so we can show fallback
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
          appBar: AppBar(
            leading: IconButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.loadingScreenSettings),
              icon: const Icon(Icons.star),
            ),
          ),
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
                      child: _errorMessage != null
                          ? _buildErrorWidget()
                          : _buildLoader(loadingSettings),
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

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
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
    try {
      switch (settings.loaderFileType) {
        case 'gif':
          return settings.isLoaderFileAsset
              ? Image.asset(
                  settings.loaderFilePath!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('Error loading GIF: $error');
                    return _buildFallbackLoader();
                  },
                )
              : Image.file(
                  File(settings.loaderFilePath!),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('Error loading GIF file: $error');
                    return _buildFallbackLoader();
                  },
                );

        case 'json':
          return Lottie.asset(
            settings.loaderFilePath!,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Error loading Lottie animation: $error');
              return _buildFallbackLoader();
            },
          );

        case 'mp4':
        case 'mov':
          if (_videoController != null &&
              _videoController!.value.isInitialized) {
            return AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            );
          }
          return _buildFallbackLoader();

        default:
          return _buildFallbackLoader();
      }
    } catch (e) {
      debugPrint('Error building loader: $e');
      return _buildFallbackLoader();
    }
  }

  Widget _buildFallbackLoader() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.goldenYellow,
      ),
    );
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
    else if (globalSettings.backgroundImage != null) {
      return DecorationImage(
        image: globalSettings.isAssetImage
            ? AssetImage(globalSettings.backgroundImage!)
            : FileImage(File(globalSettings.backgroundImage!)) as ImageProvider,
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
