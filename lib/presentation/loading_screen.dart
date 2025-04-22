// ignore_for_file: unused_field
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photobooth_flutter/api/faceswap_api.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/providers/loading_screen_provider.dart';
import 'package:photobooth_flutter/providers/photobooth_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:photobooth_flutter/services/comfy_api_service.dart';
import 'package:photobooth_flutter/services/supabase_service.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  VideoPlayerController? _controller; // Make it nullable
  bool _isInitialized = false;
  bool _isProcessing = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeLoader();
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
      } on Exception catch (e) {
        debugPrint('Error initializing video player: $e');
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
      final characterImagePath = provider.characterImagePath;

      // Check if Supabase is initialized
      if (SupabaseService.instance.isInitialized) {
        // Generate a unique user ID
        final userId = DateTime.now().millisecondsSinceEpoch.toString();

        // Upload face image to Supabase
        final faceImageUrl =
            await SupabaseService.instance.uploadImage(imageFile, userId);

        if (faceImageUrl != null) {
          // Store participant details in Supabase
          final participantId =
              await SupabaseService.instance.storeParticipantDetails(
            name: name,
            email: email,
            gender: gender,
            characterId: characterId,
            imageUrl: faceImageUrl,
          );

          if (participantId != null) {
            // Get character image URL
            String? characterImageUrl;
            if (provider.isCharacterAsset == true &&
                characterImagePath != null) {
              // For asset images, we need to upload them to Supabase first
              final assetBytes = await rootBundle.load(characterImagePath);
              final tempDir = await getTemporaryDirectory();
              final tempFile =
                  File('${tempDir.path}/character_$characterId.png');
              await tempFile.writeAsBytes(assetBytes.buffer.asUint8List());

              characterImageUrl = await SupabaseService.instance.uploadImage(
                tempFile,
                'character_$characterId',
              );
            } else if (characterImagePath != null) {
              // For file images, upload directly
              characterImageUrl = await SupabaseService.instance.uploadImage(
                File(characterImagePath),
                'character_$characterId',
              );
            }

            if (characterImageUrl == null) {
              setState(() {
                _isProcessing = false;
                _errorMessage = 'Failed to upload character image';
              });
              return;
            }

            // Initialize ComfyAPI service if not already initialized
            if (!ComfyApiService.isInitialized) {
              await ComfyApiService.initialize(
                apiUrl: "http://213.173.110.102:15539",
              );
            }

            // Load and prepare the workflow
            final workflow = await FaceswapWorkflow.getWorkflow();

            // Update image URLs in the workflow
            workflow.updateImageUrls(
              sourceImageUrl: characterImageUrl,
              targetImageUrl: faceImageUrl,
            );

            // Update refresh trigger with a random value
            final refreshTrigger = DateTime.now().millisecondsSinceEpoch;
            workflow.updateRefreshTrigger(refreshTrigger);

            // Send workflow to backend
            if (ComfyApiService.isInitialized) {
              try {
                final result = await ComfyApiService.instance.sendWorkflow(
                  workflow: workflow,
                );

                if (result['status'] == 'success') {
                  final promptId = result['prompt_id'];
                  debugPrint(
                      'Workflow sent successfully with prompt ID: $promptId');

                  // Here you would typically poll for results or wait for a webhook
                  // For now, we'll just update the UI
                  provider.setCapturedImageUrl(result['image_url']);

                  // Navigate to output screen
                  await Navigator.of(context)
                      .pushReplacementNamed(AppRoutes.swappedFace);
                } else {
                  setState(() {
                    _isProcessing = false;
                    _errorMessage =
                        'Failed to process image: ${result['message']}';
                  });
                }
              } on Exception catch (e) {
                setState(() {
                  _isProcessing = false;
                  _errorMessage = 'Error sending workflow: $e';
                });
              }
            } else {
              setState(() {
                _isProcessing = false;
                _errorMessage = 'ComfyAPI service not initialized';
              });
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
          await Navigator.pushReplacementNamed(context, AppRoutes.swappedFace);
        }
      }
    } on Exception catch (e) {
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
        _controller = VideoPlayerController.asset(settings.loaderFilePath!,
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
        _controller?.addListener(() {
          setState(() {});
        });
        await _controller?.setLooping(true);
        await _controller?.initialize().then((_) => setState(() {}));
        await _controller?.play();
      } else {
        // For file videos
        _controller = VideoPlayerController.file(
          File(settings.loaderFilePath!),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
      }

      await _controller?.setLooping(true);
      await _controller?.initialize().then((_) => setState(() {}));
      await _controller?.play();
    } on Exception catch (e) {
      debugPrint('Error initializing video player: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose(); // Add null check
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
                  // Update the title widget
                  if (loadingSettings.showTitle)
                    Padding(
                      padding: loadingSettings.titlePadding,
                      child: Text(
                        loadingSettings.titleText,
                        style: TextStyle(
                          fontSize: loadingSettings.titleFontSize,
                          fontWeight: loadingSettings.titleFontWeight,
                          color: loadingSettings.titleColor
                              .withOpacity(loadingSettings.titleOpacity),
                          height: loadingSettings.titleLineHeight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Update the loader container
                  Container(
                    width: loadingSettings.loaderWidth,
                    height: loadingSettings.loaderHeight,
                    margin: loadingSettings.loaderMargin,
                    child: _buildLoader(loadingSettings),
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
    if (settings.loaderFilePath == null) {
      return const CircularProgressIndicator();
    }

    switch (settings.loaderFileType) {
      case 'gif':
        if (settings.isLoaderFileAsset) {
          return Image.asset(
            settings.loaderFilePath!,
            fit: BoxFit.contain,
          );
        } else {
          return Image.file(
            File(settings.loaderFilePath!),
            fit: BoxFit.contain,
          );
        }
      case 'mp4':
      case 'mov':
        if (_controller != null && _controller!.value.isInitialized) {
          return AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          );
        }
        return const CircularProgressIndicator();
      default:
        return const CircularProgressIndicator();
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
