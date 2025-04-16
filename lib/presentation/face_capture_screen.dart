import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/providers/app_provider.dart';
import 'package:photobooth_flutter/providers/face_capture_provider.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:photobooth_flutter/services/supabase_service.dart';
import 'package:provider/provider.dart';

class FaceCaptureScreen extends StatefulWidget {
  const FaceCaptureScreen({super.key});

  @override
  State<FaceCaptureScreen> createState() => _FaceCaptureScreenState();
}

class _FaceCaptureScreenState extends State<FaceCaptureScreen> {
  // For Windows camera
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  List<CameraDescription> _cameras = [];
  bool _cameraInitialized = false;
  bool _isDisposingCamera = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      // First, dispose of any existing controller
      if (_controller != null) {
        _isDisposingCamera = true;
        await _controller!.dispose();
        _controller = null;
        _isDisposingCamera = false;
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        debugPrint('No cameras available');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No cameras available')),
          );
        }
        return;
      }

      final settings = context.read<FaceCaptureProvider>();
      final selectedIndex = settings.selectedCameraIndex < _cameras.length
          ? settings.selectedCameraIndex
          : 0;

      _controller = CameraController(
        _cameras[selectedIndex],
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.bgra8888,
      );

      _initializeControllerFuture = _controller?.initialize();
      await _initializeControllerFuture;

      setState(() {
        _cameraInitialized = true;
      });
    } on Exception catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera error: $e')),
        );
      }
    }
  }

  Future<void> _takePicture() async {
    try {
      if (_controller == null || !_cameraInitialized) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera not initialized')),
        );
        return;
      }

      final image = await _controller!.takePicture();

      // Dispose the camera controller after taking the picture
      if (_controller != null) {
        _isDisposingCamera = true;
        await _controller!.dispose();
        _controller = null;
        _isDisposingCamera = false;
      }
      _cameraInitialized = false;

      final provider = context.read<PhotoboothProvider>();

      // Set the face image path in the provider
      provider.setFaceImage(image.path);

      // Navigate to loading screen
      Navigator.pushNamed(context, AppRoutes.loadingScreen);

      // Get participant details from provider
      final name = provider.name ?? '';
      final email = provider.email ?? '';

      // Debug log to check values
      debugPrint('User details from provider - Name: "$name", Email: "$email"');

      final gender = provider.selectedGender;
      final characterId = provider.selectedCharacterId;

      // Check if Supabase is initialized
      if (SupabaseService.instance.isInitialized) {
        try {
          // Upload image to Supabase
          final imageFile = File(image.path);
          final userId = DateTime.now().millisecondsSinceEpoch.toString();
          final imageUrl =
              await SupabaseService.instance.uploadImage(imageFile, userId);

          if (imageUrl != null) {
            // Store participant details with image URL
            final participantId =
                await SupabaseService.instance.storeParticipantDetails(
              name: name,
              email: email,
              gender: gender,
              characterId: characterId,
              imageUrl: imageUrl,
            );

            // Store the captured image URL in the provider
            provider.setCapturedImageUrl(imageUrl);

            // Navigate to the output screen
            if (mounted) {
              Navigator.pushReplacementNamed(context, AppRoutes.swappedFace);
            }
          } else {
            debugPrint('Failed to upload image to Supabase');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to upload image')),
              );
              Navigator.pop(context); // Go back from loading screen
            }
          }
        } catch (e) {
          debugPrint('Error during Supabase operations: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
            Navigator.pop(context); // Go back from loading screen
          }
        }
      } else {
        debugPrint('Supabase not initialized, skipping upload');
        // For testing without Supabase, set a dummy URL
        provider.setCapturedImageUrl('https://example.com/dummy-image.jpg');

        // Navigate to the output screen after a short delay
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.swappedFace);
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to take picture: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    // Make sure to dispose of the controller when the widget is disposed
    if (_controller != null) {
      _controller!.dispose();
      _controller = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<FaceCaptureProvider>();
    final globalSettings = context.watch<GlobalSettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.faceCaptureSettings),
          icon: const Icon(Icons.star),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: _getBackgroundImage(settings, globalSettings),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            if (settings.showTitle)
              Padding(
                padding: EdgeInsets.only(bottom: settings.titlePadding),
                child: Text(
                  settings.titleText,
                  style: TextStyle(
                    fontSize: settings.titleFontSize,
                    fontWeight: settings.titleFontWeight,
                    color: settings.titleColor,
                  ),
                ),
              ),

            // Camera Preview
            _buildCameraPreview(settings),

            // Capture Button
            SizedBox(height: settings.buttonMarginTop),
            _buildCaptureButton(settings),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview(FaceCaptureProvider settings) {
    if (!_cameraInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Container(
            width: settings.previewWidth,
            height: settings.previewHeight,
            decoration: settings.showPreviewBorder
                ? BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(settings.previewBorderRadius),
                    border: Border.all(
                      color: settings.previewBorderColor,
                      width: settings.previewBorderWidth,
                    ),
                  )
                : null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(settings.previewBorderRadius),
              child: _controller != null
                  ? CameraPreview(_controller!)
                  : const Center(child: Text('Camera not available')),
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _buildCaptureButton(FaceCaptureProvider settings) {
    if (settings.useImageButton && settings.buttonImagePath != null) {
      return GestureDetector(
        onTap: _takePicture,
        child: Container(
          width: settings.buttonWidth,
          height: settings.buttonHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(settings.buttonBorderRadius),
            border: settings.buttonHasBorder
                ? Border.all(
                    color: settings.buttonBorderColor,
                    width: settings.buttonBorderWidth,
                  )
                : null,
            image: DecorationImage(
              image: settings.isButtonImageAsset
                  ? AssetImage(settings.buttonImagePath!)
                  : FileImage(File(settings.buttonImagePath!)) as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else {
      return SizedBox(
        width: settings.buttonWidth,
        height: settings.buttonHeight,
        child: ElevatedButton(
          onPressed: _takePicture,
          style: ElevatedButton.styleFrom(
            backgroundColor: settings.buttonColor,
            foregroundColor: settings.buttonTextColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(settings.buttonBorderRadius),
              side: settings.buttonHasBorder
                  ? BorderSide(
                      color: settings.buttonBorderColor,
                      width: settings.buttonBorderWidth,
                    )
                  : BorderSide.none,
            ),
          ),
          child: Text(
            settings.buttonText,
            style: TextStyle(
              fontSize: settings.buttonFontSize,
            ),
          ),
        ),
      );
    }
  }

  ImageProvider _getBackgroundImage(
      FaceCaptureProvider settings, GlobalSettingsProvider globalSettings) {
    // First try to use the screen-specific background if it's enabled and available
    if (settings.showBackground && settings.backgroundImagePath != null) {
      return settings.isBackgroundImageAsset
          ? AssetImage(settings.backgroundImagePath!)
          : FileImage(File(settings.backgroundImagePath!)) as ImageProvider;
    }

    // Fall back to global background if available
    else if (globalSettings.backgroundImage != null) {
      if (globalSettings.isAssetImage) {
        return AssetImage(globalSettings.backgroundImage!);
      } else {
        final file = File(globalSettings.backgroundImage!);
        if (file.existsSync()) {
          return FileImage(file);
        } else {
          debugPrint(
              'Global background image file does not exist: ${globalSettings.backgroundImage}');
          return const AssetImage('assets/images/background.jpg');
        }
      }
    }

    // Use default background as last resort
    else {
      return const AssetImage('assets/images/background.jpg');
    }
  }
}
