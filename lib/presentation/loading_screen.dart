// ignore_for_file: unused_field
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:photobooth_flutter/api/workflow.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/providers/loading_screen_provider.dart';
import 'package:photobooth_flutter/providers/photobooth_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:photobooth_flutter/services/comfy_api_service.dart';
import 'package:photobooth_flutter/services/local_storage_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool _isProcessing = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processImage();
    });
  }

  // Future<void> _initializeLoader() async {
  //   final settings = Provider.of<LoadingScreenProvider>(context, listen: false);
  //   // Initialize video controller if needed
  //   if ((settings.loaderFileType == 'mp4' ||
  //           settings.loaderFileType == 'mov') &&
  //       settings.loaderFilePath != null) {
  //     try {
  //       await _initializeVideoPlayer(settings);
  //     } on Exception catch (e) {
  //       debugPrint('Error initializing video player: $e');
  //     }
  //   }
  //   setState(() {
  //     _isInitialized = true;
  //   });
  // }

 Future<void> _processImage() async {
    try {
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

      // Get participant details from provider
      final name = provider.name ?? '';
      final email = provider.email ?? '';
      final gender = provider.selectedGender;

      // Initialize ComfyAPI service if not already initialized
      if (!ComfyApiService.isInitialized) {
        await ComfyApiService.initialize(
          apiUrl: globalSettings.comfyApiUrl ?? "http://127.0.0.1:8188",
        );
      }

      final seed = DateTime.now().millisecondsSinceEpoch;

      if (provider.selectedTheme != null) {
        await _processSwaplab(imageFile, provider, globalSettings, seed);
      } else {
        await _processOfflineMode(imageFile, provider, globalSettings, seed);
      }
    } on Exception catch (e) {
      debugPrint('Error processing image: $e');
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> _processSwaplab(File imageFile, PhotoboothProvider provider,
      GlobalSettingsProvider globalSettings, int seed) async {
    try {
      if (!LocalStorageService.isServiceInitialized) {
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

      final faceImagePath =
          await LocalStorageService.instance.saveFaceImage(imageFile);

      final themeName =
          provider.selectedTheme!.name.toLowerCase().replaceAll(' ', '_');
      final gender = provider.selectedGender;
      final characterNumber = Random().nextInt(4) + 1;
      final characterImageName =
          '${gender == 'male' ? 'm' : 'f'}$characterNumber.png';
      
      // MODIFIED: Construct a relative path for the theme character image.
      final characterImagePath =
          'themes/$gender/$themeName/$characterImageName';

      final outputPathPrefix =
          LocalStorageService.instance.getOutputPathPrefix();

      if (ComfyApiService.isInitialized) {
        try {
          final workflow = await Workflow.getWorkflow('swaplab.json');
          
          // These methods now receive relative paths
          workflow.updateInputImagePath(faceImagePath, nodeId: '35');
          workflow.updateSwaplabCharacterImage(characterImagePath);
          workflow.updateOutputImagePath(outputPathPrefix, nodeId: '37');

          final response = await ComfyApiService.instance.sendOfflineWorkflow(
            workflow: workflow.toMap(),
          );

          if (response.containsKey('sentTime')) {
            final sentTimeStr = response['sentTime'] as String;
            final sentTime = DateTime.parse(sentTimeStr);
            provider.setWorkflowSentTime(sentTime);
          }

          int attempts = 0;
          const maxAttempts = 90;
          const pollDelay = Duration(seconds: 2);

          final outputPrefix = path.basename(outputPathPrefix);

          while (attempts < maxAttempts) {
            final localImagePath =
                await LocalStorageService.instance.getLatestOutputImage(
              outputPrefix,
              afterTime: provider.workflowSentTime,
            );

            if (localImagePath != null) {
              provider.setSwappedImage(localImagePath);
              provider.setCapturedImageUrl(localImagePath);

              if (mounted) {
                await Navigator.of(context)
                    .pushReplacementNamed(AppRoutes.swappedFace);
              }
              return;
            }

            await Future.delayed(pollDelay);
            attempts++;
          }

          setState(() {
            _isProcessing = false;
            _errorMessage = 'Timed out waiting for image processing';
          });
        } catch (e) {
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
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Error processing image in Swaplab mode: $e';
      });
    }
  }

  // Handle offline mode processing
  Future<void> _processOfflineMode(File imageFile, PhotoboothProvider provider,
      GlobalSettingsProvider globalSettings, int seed) async {
    try {
      // Check if LocalStorageService is initialized using the static method
      if (!LocalStorageService.isServiceInitialized) {
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

      // Now it's safe to use the instance
      // Save face image to input directory
      final faceImagePath =
          await LocalStorageService.instance.saveFaceImage(imageFile);

      // Get output path prefix
      final outputPathPrefix =
          LocalStorageService.instance.getOutputPathPrefix();

      // Send offline workflow to ComfyAPI
      if (ComfyApiService.isInitialized) {
        try {
          // ADDED: Read the selected workflow from SharedPreferences.
          final prefs = await SharedPreferences.getInstance();
          final workflowFileName = prefs.getString('selected_workflow');
          // REASON: Ensure a workflow was selected during authentication.
          if (workflowFileName == null) {
            setState(() {
              _isProcessing = false;
              _errorMessage =
                  'Error: No workflow selected. Please re-authenticate.';
            });
            return;
          }

          final workflow = await Workflow.getWorkflow(workflowFileName);
          workflow.updateInputImagePath(faceImagePath);
          workflow.updateNoiseSeed(seed);
          workflow.updateOutputImagePath(outputPathPrefix);

          debugPrint('  workflow: $workflowFileName');
          debugPrint('  faceImagePath: $faceImagePath');
          debugPrint('  outputPathPrefix: $outputPathPrefix');
          debugPrint('  seed: $seed');

          // Send the workflow and get the response with sent time
          final response = await ComfyApiService.instance.sendOfflineWorkflow(
            workflow: workflow.toMap(),
          );

          // Store the workflow sent time in the provider
          if (response.containsKey('sentTime')) {
            final sentTimeStr = response['sentTime'] as String;
            final sentTime = DateTime.parse(sentTimeStr);
            provider.setWorkflowSentTime(sentTime);
          }

          // Start polling for the new image in the output directory
          int attempts = 0;
          const maxAttempts = 90;
          const pollDelay = Duration(seconds: 2);

          final outputPrefix = path.basename(outputPathPrefix);

          while (attempts < maxAttempts) {
            // Check for new image in output directory
            final localImagePath =
                await LocalStorageService.instance.getLatestOutputImage(
              outputPrefix,
              afterTime: provider.workflowSentTime,
            );

            if (localImagePath != null) {
              // Update the provider with local file path
              provider.setSwappedImage(localImagePath);
              provider.setCapturedImageUrl(localImagePath);

              // Navigate to output screen
              if (mounted) {
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
        } catch (e) {
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
    } on Exception catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Error processing image in offline mode: $e';
      });
    }
  }
  // Future<void> _initializeVideoPlayer(LoadingScreenProvider settings) async {
  //   if (settings.loaderFilePath == null) return;

  //   try {
  //     if (settings.isLoaderFileAsset) {
  //       // For asset videos
  //       _controller = VideoPlayerController.asset(settings.loaderFilePath!,
  //           videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
  //       _controller?.addListener(() {
  //         setState(() {});
  //       });
  //       await _controller?.setLooping(true);
  //       await _controller?.initialize().then((_) => setState(() {}));
  //       await _controller?.play();
  //     } else {
  //       // For file videos
  //       _controller = VideoPlayerController.file(
  //         File(settings.loaderFilePath!),
  //         videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
  //       );
  //     }

  //     await _controller?.setLooping(true);
  //     await _controller?.initialize().then((_) => setState(() {}));
  //     await _controller?.play();
  //   } on Exception catch (e) {
  //     debugPrint('Error initializing video player: $e');
  //   }
  // }

  // @override
  // void dispose() {
  //   _controller?.dispose(); // Add null check
  //   super.dispose();
  // }

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
            child: Stack(
              alignment: Alignment.center,
              children: [
                // The main content is now always the new animated text loader.
                _buildLoader(loadingSettings),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoader(LoadingScreenProvider settings) {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'An Error Occurred',
              style: TextStyle(
                  color: settings.titleColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: settings.titleColor, fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }

    // The new text-based loader
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                  fontSize: 70,
                  color: settings.titleColor,
                  fontWeight: FontWeight.w500,
                  fontFamily: "PolySans"),
              children: const <TextSpan>[
                TextSpan(text: 'Processing the\n'),
              ],
            ),
          ),
          const _PulsatingText(),
        ],
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
        image: AssetImage('assets/images/common_bg.png'),
        fit: BoxFit.cover,
      );
    }
  }
}

class _PulsatingText extends StatefulWidget {
  const _PulsatingText();

  @override
  State<_PulsatingText> createState() => _PulsatingTextState();
}

class _PulsatingTextState extends State<_PulsatingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _animation = Tween(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: const Text(
        'Magic',
        style: TextStyle(
          fontSize: 90,
          color: AppColors.yellow,
          fontWeight: FontWeight.bold,
          fontFamily: "PolySans",
          // shadows: [
          //   Shadow(
          //     blurRadius: 20.0,
          //     color: AppColors.yellow,
          //     offset: Offset(0, 0),
          //   ),
          // ],
        ),
      ),
    );
  }
}
