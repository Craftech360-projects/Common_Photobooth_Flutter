import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_macos/camera_macos.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/providers/app_provider.dart';
import 'package:photobooth_flutter/providers/face_capture_provider.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:provider/provider.dart';

class FaceCaptureScreen extends StatefulWidget {
  const FaceCaptureScreen({super.key});

  @override
  State<FaceCaptureScreen> createState() => _FaceCaptureScreenState();
}

class _FaceCaptureScreenState extends State<FaceCaptureScreen> {
  // For macOS camera
  final GlobalKey _cameraKey = GlobalKey();
  CameraMacOSController? _macOSController;
  List<CameraMacOSDevice> _macOSVideoDevices = [];
  final List<CameraMacOSDevice> _macOSAudioDevices = [];
  String? _selectedVideoDeviceId;
  String? _selectedAudioDeviceId;

  // For other platforms
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  List<CameraDescription> _cameras = [];

  bool _isMacOS = false;
  bool _cameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _isMacOS = Platform.isMacOS;
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      if (_isMacOS) {
        await _initializeMacOSCamera();
      } else {
        await _initializeOtherPlatformCamera();
      }
    } on Exception catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera error: $e')),
        );
      }
    }
  }

  Future<void> _initializeMacOSCamera() async {
    try {
      // List available video devices
      _macOSVideoDevices = await CameraMacOS.instance.listDevices(
        deviceType: CameraMacOSDeviceType.video,
      );

      if (_macOSVideoDevices.isNotEmpty) {
        _selectedVideoDeviceId = _macOSVideoDevices.first.deviceId;
      }

      if (_macOSAudioDevices.isNotEmpty) {
        _selectedAudioDeviceId = _macOSAudioDevices.first.deviceId;
      }

      setState(() {
        _cameraInitialized = true;
      });
    } on Exception catch (e) {
      debugPrint('Error initializing macOS camera: $e');
    }
  }

  Future<void> _initializeOtherPlatformCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        debugPrint('No cameras available');
        return;
      }

      final settings = context.read<FaceCaptureProvider>();
      final selectedIndex = settings.selectedCameraIndex < _cameras.length
          ? settings.selectedCameraIndex
          : 0;

      _controller = CameraController(
        _cameras[selectedIndex],
        ResolutionPreset.medium,
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
    }
  }

  Future<void> _takePicture() async {
    try {
      late final String imagePath;

      if (_isMacOS) {
        if (_macOSController == null) {
          debugPrint('macOS controller is null');
          return;
        }

        // Fix the takePicture method call
        final image = await _macOSController!.takePicture();

        if (image == null) {
          debugPrint('Failed to take picture on macOS');
          return;
        }

        // Fix the path access
        imagePath = image.url ?? '';
      } else {
        if (_controller == null || !_controller!.value.isInitialized) {
          debugPrint('Camera controller not initialized');
          return;
        }

        final image = await _controller!.takePicture();
        imagePath = image.path;
      }

      if (mounted) {
        final appProvider = context.read<PhotoboothProvider>();
        appProvider.setFaceImagePath(imagePath);

        await Navigator.pushNamed(context, AppRoutes.loadingScreen);
      }
    } on Exception catch (e) {
      debugPrint('Error taking picture: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to take picture: $e')),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
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
          image: settings.showBackground && settings.backgroundImagePath != null
              ? DecorationImage(
                  image: _getBackgroundImage(settings, globalSettings),
                  fit: BoxFit.cover,
                )
              : null,
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

    if (_isMacOS) {
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
          child: CameraMacOSView(
            key: _cameraKey,
            deviceId: _selectedVideoDeviceId,
            audioDeviceId: _selectedAudioDeviceId,
            cameraMode: CameraMacOSMode.photo,
            fit: BoxFit.cover,
            onCameraInizialized: (controller) {
              setState(() {
                _macOSController = controller;
              });
            },
          ),
        ),
      );
    } else {
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
                borderRadius:
                    BorderRadius.circular(settings.previewBorderRadius),
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
    else if (globalSettings.backgroundImagePath != null) {
      return globalSettings.isBackgroundImageAsset
          ? AssetImage(globalSettings.backgroundImagePath!)
          : FileImage(File(globalSettings.backgroundImagePath!))
              as ImageProvider;
    }
    // Use default background as last resort
    else {
      return const AssetImage('assets/images/default_background.jpg');
    }
  }
}
