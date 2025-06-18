// ignore_for_file: unused_field
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:photobooth_flutter/api/workflow.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/models/user_model.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/providers/loading_screen_provider.dart';
import 'package:photobooth_flutter/providers/photobooth_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:photobooth_flutter/services/comfy_api_service.dart';
import 'package:photobooth_flutter/services/local_storage_service.dart';
import 'package:photobooth_flutter/services/sqflite_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late VideoPlayerController _videoController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _videoController =
        VideoPlayerController.asset('assets/videos/loading_bg.mp4')
          ..initialize().then((_) {
            _videoController.setLooping(true);
            _videoController.play();
            if (mounted) {
              setState(() {});
            }
          });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processImage();
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  // MODIFIED: This function now stops the video when an error is set.
  void _setErrorMessage(String message) {
    if (mounted) {
      setState(() {
        _errorMessage = message;
        if (_videoController.value.isPlaying) {
          _videoController.pause();
        }
      });
    }
  }

  Future<void> _processImage() async {
    try {
      final provider = Provider.of<PhotoboothProvider>(context, listen: false);
      final globalSettings =
          Provider.of<GlobalSettingsProvider>(context, listen: false);

      if (provider.faceImagePath == null) {
        _setErrorMessage('No face image captured');
        return;
      }

      final imageFile = File(provider.faceImagePath!);

      if (!imageFile.existsSync()) {
        debugPrint(
            'Image file does not exist at path: ${provider.faceImagePath}');
        _setErrorMessage('Image file not found');
        return;
      }

      final name = provider.name ?? '';
      final email = provider.email ?? '';
      final gender = provider.selectedGender;

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
      _setErrorMessage('Error: $e');
    }
  }

  Future<void> _processSwaplab(File imageFile, PhotoboothProvider provider,
      GlobalSettingsProvider globalSettings, int seed) async {
    try {
      if (!LocalStorageService.isServiceInitialized) {
        if (globalSettings.inputDirectory == null ||
            globalSettings.outputDirectory == null) {
          _setErrorMessage(
              'Input or output directories not configured. Please set them in the admin screen.');
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

      final characterImagePath =
          'themes/$gender/$themeName/$characterImageName';

      final outputPathPrefix =
          LocalStorageService.instance.getOutputPathPrefix();

      if (ComfyApiService.isInitialized) {
        try {
          final workflow = await Workflow.getWorkflow('swaplab.json');

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

              await DatabaseService.instance.insertUser(UserData(
                name: provider.name ?? 'N/A',
                email: provider.email ?? 'N/A',
                outputImageFilename: path.basename(localImagePath),
              ));

              if (mounted) {
                await Navigator.of(context)
                    .pushReplacementNamed(AppRoutes.swappedFace);
              }
              return;
            }

            await Future.delayed(pollDelay);
            attempts++;
          }

          _setErrorMessage('Timed out waiting for image processing');
        } catch (e) {
          _setErrorMessage('Error sending workflow: $e');
        }
      } else {
        _setErrorMessage('ComfyAPI service not initialized');
      }
    } catch (e) {
      _setErrorMessage('Error processing image in Swaplab mode: $e');
    }
  }

  Future<void> _processOfflineMode(File imageFile, PhotoboothProvider provider,
      GlobalSettingsProvider globalSettings, int seed) async {
    try {
      if (!LocalStorageService.isServiceInitialized) {
        if (globalSettings.inputDirectory == null ||
            globalSettings.outputDirectory == null) {
          _setErrorMessage(
              'Input or output directories not configured. Please set them in the admin screen.');
          return;
        }

        await LocalStorageService.initialize(
          inputDirectory: globalSettings.inputDirectory!,
          outputDirectory: globalSettings.outputDirectory!,
        );
      }

      final faceImagePath =
          await LocalStorageService.instance.saveFaceImage(imageFile);

      final outputPathPrefix =
          LocalStorageService.instance.getOutputPathPrefix();

      if (ComfyApiService.isInitialized) {
        try {
          final prefs = await SharedPreferences.getInstance();
          final workflowFileName = prefs.getString('selected_workflow');
          if (workflowFileName == null) {
            _setErrorMessage(
                'Error: No workflow selected. Please re-authenticate.');
            return;
          }

          final workflow = await Workflow.getWorkflow(workflowFileName);

          if (workflowFileName == 'packaging.json') {
            final gender = provider.gender ?? 'person';
            final accessories = provider.accessories ??
                'shoes, sunglasses, helmet, motorbikes';
            workflow.updatePackagingPrompt(gender, accessories);
          }

          workflow.updateInputImagePath(faceImagePath);
          workflow.updateNoiseSeed(seed);
          workflow.updateOutputImagePath(outputPathPrefix);

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

              await DatabaseService.instance.insertUser(UserData(
                name: provider.name ?? 'N/A',
                email: provider.email ?? 'N/A',
                outputImageFilename: path.basename(localImagePath),
              ));

              if (mounted) {
                await Navigator.of(context)
                    .pushReplacementNamed(AppRoutes.swappedFace);
              }
              return;
            }

            await Future.delayed(pollDelay);
            attempts++;
          }

          _setErrorMessage('Timed out waiting for image processing');
        } catch (e) {
          _setErrorMessage('Error sending workflow: $e');
        }
      } else {
        _setErrorMessage('ComfyAPI service not initialized');
      }
    } on Exception catch (e) {
      _setErrorMessage('Error processing image in offline mode: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // MODIFIED: The body's background color is black to avoid flashes
      backgroundColor: Colors.black,
      body: Center(
        child: _errorMessage != null
            // If there's an error, show the error message UI
            ? _buildErrorDisplay()
            // Otherwise, show the video player
            : _videoController.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _videoController.value.aspectRatio,
                    child: VideoPlayer(_videoController),
                  )
                // Before video is initialized, show a blank container
                : Container(),
      ),
    );
  }

  // NEW: A dedicated widget to display the error message.
  Widget _buildErrorDisplay() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 60),
          const SizedBox(height: 20),
          const Text(
            'An Error Occurred',
            style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ],
      ),
    );
  }
}