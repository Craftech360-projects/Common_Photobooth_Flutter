// ignore_for_file: unused_field
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/providers/loading_screen_provider.dart';
import 'package:photobooth_flutter/providers/photobooth_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:photobooth_flutter/services/comfy_api_service.dart';
import 'package:photobooth_flutter/services/local_storage_service.dart'; // Add this import
import 'package:photobooth_flutter/services/supabase_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      final prefs = await SharedPreferences.getInstance();
      final serviceId = prefs.getString('authenticated_service_id');

      final provider = Provider.of<PhotoboothProvider>(context, listen: false);
      final globalSettings =
          Provider.of<GlobalSettingsProvider>(context, listen: false);

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

      // For faceswap workflow, verify we have a character image
      if (serviceId == 'LjCIQ5ONsqCHIHd6Rmyu' &&
          provider.characterImagePath == null) {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'No character image selected for faceswap';
        });
        return;
      }

      // Get participant details from provider
      final name = provider.name ?? '';
      final email = provider.email ?? '';
      final gender = provider.selectedGender;

      // Initialize ComfyAPI service if not already initialized
      if (!ComfyApiService.isInitialized) {
        await ComfyApiService.initialize(
          apiUrl: globalSettings.comfyApiUrl ?? "http://127.0.0.1:8188",
          context: context,
        );
      }

      final seed = DateTime.now().millisecondsSinceEpoch;

      // Check if we're in offline mode
      if (globalSettings.isOfflineMode) {
        // Process in offline mode
        await _processOfflineMode(
            serviceId, imageFile, provider, globalSettings, seed);
      } else {
        // Process in online mode (Supabase)
        await _processOnlineMode(serviceId, imageFile, provider, globalSettings,
            name, email, gender, seed);
      }
    } on Exception catch (e) {
      debugPrint('Error processing image: $e');
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  // Handle offline mode processing
  Future<void> _processOfflineMode(
      String? serviceId,
      File imageFile,
      PhotoboothProvider provider,
      GlobalSettingsProvider globalSettings,
      int seed) async {
    try {
      // Initialize LocalStorageService if needed
      if (!LocalStorageService.instance.isInitialized) {
        // Check if input and output directories are set
        if (globalSettings.inputDirectory == null ||
            globalSettings.outputDirectory == null) {
          setState(() {
            _isProcessing = false;
            _errorMessage =
                'Input or output directories not configured. Please set them in the admin screen.';
          });
          return;
        }

        await LocalStorageService.initialize(
          inputDirectory: globalSettings.inputDirectory!,
          outputDirectory: globalSettings.outputDirectory!,
        );
      }

      // Save face image to input directory
      final faceImagePath =
          await LocalStorageService.instance.saveFaceImage(imageFile);

      // Get output path prefix
      final outputPathPrefix =
          LocalStorageService.instance.getOutputPathPrefix();

      // Send offline workflow to ComfyAPI
      if (ComfyApiService.isInitialized && serviceId != null) {
        debugPrint(
            'Sending offline workflow for serviceId: $serviceId to ComfyAPI...');

        final response = await ComfyApiService.instance.sendOfflineWorkflow(
          faceImagePath: faceImagePath,
          outputPathPrefix: outputPathPrefix,
          serviceId: serviceId,
          seed: seed,
        );

        // Store the workflow sent time in the provider
        if (response.containsKey('sentTime')) {
          final sentTimeStr = response['sentTime'] as String;
          final sentTime = DateTime.parse(sentTimeStr);
          provider.setWorkflowSentTime(sentTime);
        }

        // Start polling for the new image in the output directory
        int attempts = 0;
        const maxAttempts =
            30; // 30 attempts with 2 second delay = 1 minute max
        const pollDelay = Duration(seconds: 2);

        final outputPrefix = outputPathPrefix.split('/').last;

        while (attempts < maxAttempts) {
          // Check for new image in output directory
          final localImagePath =
              await LocalStorageService.instance.getLatestOutputImage(
            outputPrefix,
            afterTime: provider.workflowSentTime,
          );

          if (localImagePath != null) {
            debugPrint('Found new image in local storage: $localImagePath');
            // Update the provider with local file path
            provider.setSwappedImage(localImagePath);
            provider.setCapturedImageUrl(localImagePath);

            // Navigate to output screen
            if (mounted) {
              debugPrint('Navigating to output screen...');
              await Navigator.of(context)
                  .pushReplacementNamed(AppRoutes.swappedFace);
            }
            return;
          }

          // Wait before next attempt
          await Future.delayed(pollDelay);
          attempts++;
        }

        // If we get here, we've timed out waiting for the image
        setState(() {
          _isProcessing = false;
          _errorMessage = 'Timed out waiting for image processing';
        });
      } else {
        setState(() {
          _isProcessing = false;
          _errorMessage =
              'ComfyAPI service not initialized or service ID not available';
        });
      }
    } on Exception catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Error processing image in offline mode: $e';
      });
    }
  }

  // Handle online mode processing (existing Supabase flow)
  Future<void> _processOnlineMode(
      String? serviceId,
      File imageFile,
      PhotoboothProvider provider,
      GlobalSettingsProvider globalSettings,
      String name,
      String email,
      String gender,
      int seed) async {
    // Get Supabase credentials from global settings
    final supabaseUrl = globalSettings.supabaseUrl;
    final supabaseAnonKey = globalSettings.supabaseAnonKey;

    // Check if Supabase credentials are available
    if (supabaseUrl == null || supabaseAnonKey == null) {
      setState(() {
        _isProcessing = false;
        _errorMessage =
            'Supabase credentials not configured. Please set them in the admin screen.';
      });
      return;
    }

    // Initialize Supabase if not already initialized
    if (!SupabaseService.instance.isInitialized) {
      try {
        await SupabaseService.instance.initialize(
          url: supabaseUrl,
          anonKey: supabaseAnonKey,
        );
      } on Exception catch (e) {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'Failed to initialize Supabase: $e';
        });
        return;
      }
    }

    // Check if Supabase is initialized
    if (SupabaseService.instance.isInitialized) {
      // Upload face image to Supabase using the new method
      final faceImageUrl =
          await SupabaseService.instance.uploadUserFaceImage(imageFile);

      if (faceImageUrl != null) {
        // Store participant details in Supabase
        final uniqueId = await SupabaseService.instance.storeParticipantDetails(
          name: name,
          email: email,
          gender: gender,
          imageUrl: faceImageUrl,
        );

        if (uniqueId != null && serviceId != null) {
          // Send workflow based on serviceId
          if (ComfyApiService.isInitialized) {
            try {
              debugPrint(
                  'Sending workflow for serviceId: $serviceId to ComfyAPI...');
              // Send the workflow and get the response with sent time
              final response =
                  await ComfyApiService.instance.sendWorkflowByServiceId(
                serviceId,
                faceImageUrl,
                seed,
                uniqueId: uniqueId, // Pass the uniqueId from Supabase
              );

              // Store the workflow sent time in the provider
              if (response.containsKey('sentTime')) {
                final sentTimeStr = response['sentTime'] as String;
                final sentTime = DateTime.parse(sentTimeStr);
                Provider.of<PhotoboothProvider>(context, listen: false)
                    .setWorkflowSentTime(sentTime);
              }

              // Start polling Supabase for the new image
              int attempts = 0;
              const maxAttempts =
                  30; // 30 attempts with 2 second delay = 1 minute max
              const pollDelay = Duration(seconds: 2);

              while (attempts < maxAttempts) {
                // Check for new image in Supabase, passing the workflow sent time
                final supabaseImageUrl =
                    await SupabaseService.instance.getLatestOutputImage(
                  uniqueId,
                  afterTime: provider.workflowSentTime,
                );

                if (supabaseImageUrl != null) {
                  debugPrint('Found new image in Supabase: $supabaseImageUrl');
                  // Update the URLs in the provider
                  provider.setSwappedImage(supabaseImageUrl);
                  provider.setCapturedImageUrl(supabaseImageUrl);

                  // Navigate to output screen
                  if (mounted) {
                    debugPrint('Navigating to output screen...');
                    await Navigator.of(context)
                        .pushReplacementNamed(AppRoutes.swappedFace);
                  }
                  return;
                }

                // Wait before next attempt
                await Future.delayed(pollDelay);
                attempts++;
              }

              // If we get here, we've timed out waiting for the image
              setState(() {
                _isProcessing = false;
                _errorMessage = 'Timed out waiting for image processing';
              });
            } on Exception catch (e) {
              setState(() {
                _isProcessing = false;
                _errorMessage = 'Error processing image: $e';
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
          _errorMessage = 'Failed to upload face image';
        });
      }
    } else {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Supabase not initialized';
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
          // appBar: AppBar(
          //   leading: IconButton(
          //     onPressed: () =>
          //         Navigator.pushNamed(context, AppRoutes.loadingScreenSettings),
          //     icon: const Icon(Icons.star),
          //   ),
          // ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: _getBackgroundImage(loadingSettings, globalSettings),
            ),
            child: Center(
              child: Column(
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
                              .withValues(alpha: loadingSettings.titleOpacity),
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
      return const Center(
          child: CircularProgressIndicator(
        color: AppColors.white,
      ));
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
        return const Center(
            child: Center(
                child: CircularProgressIndicator(
          color: AppColors.white,
        )));
      default:
        return const Center(
            child: Center(
                child: CircularProgressIndicator(
          color: AppColors.white,
        )));
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
