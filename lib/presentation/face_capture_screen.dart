import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_macos/camera_macos.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/providers/face_capture_provider.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/providers/photobooth_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:provider/provider.dart';

class FaceCaptureScreen extends StatefulWidget {
  final bool isPreviewMode;

  const FaceCaptureScreen({
    super.key,
    this.isPreviewMode = false,
  });

  @override
  State<FaceCaptureScreen> createState() => _FaceCaptureScreenState();
}

class _FaceCaptureScreenState extends State<FaceCaptureScreen> {
  dynamic _controller;
  bool _cameraInitialized = false;

  // Standard camera properties
  List<CameraDescription> _cameras = <CameraDescription>[];
  int _cameraIndex = 0;
  Future<void>? _initializeControllerFuture;

  // NEW: Check the platform once
  final bool _isMacos = Platform.isMacOS;

  @override
  void initState() {
    super.initState();
    if (widget.isPreviewMode) {
      log("preview mode on");
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCamera();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isMacos) {
      return; // macOS camera switching is handled differently if needed
    }

    final settings = context.read<FaceCaptureProvider>();
    final selectedIndex = settings.selectedCameraIndex;

    if (_cameraInitialized &&
        selectedIndex < _cameras.length &&
        selectedIndex != _cameraIndex) {
      _switchCamera(selectedIndex);
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        log('No available cameras found.');
        return;
      }
      final settings = context.read<FaceCaptureProvider>();
      _cameraIndex = settings.selectedCameraIndex < _cameras.length
          ? settings.selectedCameraIndex
          : 0;

      _controller = CameraController(
        _cameras[_cameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );

      _initializeControllerFuture = _controller?.initialize();
      await _initializeControllerFuture;

      if (mounted) {
        setState(() {
          _cameraInitialized = true;
        });
      }
    } on CameraException catch (e) {
      log('Failed to initialize camera: ${e.code}: ${e.description}');
    }
  }

  Future<void> _switchCamera(int specificIndex) async {
    if (_isMacos || _cameras.isEmpty) return;
    await _disposeCurrentCamera();
    setState(() {
      _cameraIndex = specificIndex;
    });
    final settings = context.read<FaceCaptureProvider>();
    settings.setSelectedCameraIndex(_cameraIndex);
    await _initializeCamera();
  }

  Future<void> _disposeCurrentCamera() async {
    if (_controller != null) {
      if (_isMacos) {
        // macOS controller has a different lifecycle managed by its widget
        await (_controller as CameraMacOSController?)?.destroy();
      } else {
        await (_controller as CameraController?)?.dispose();
      }
      if (mounted) {
        setState(() {
          _controller = null;
        });
      }
    }
    _cameraInitialized = false;
  }

  Future<void> _takePicture() async {
    if (!_cameraInitialized || _controller == null) {
      log("Camera not ready or controller not initialized.");
      return;
    }

    try {
      String? picturePath;
      // PLATFORM-SPECIFIC PICTURE TAKING
      if (_isMacos) {
        CameraMacOSFile? file =
            await (_controller as CameraMacOSController).takePicture();
        // FIX: Add a null check for file.bytes before using it.
        if (file != null && file.bytes != null) {
          final Directory tempDir = await getTemporaryDirectory();
          final String fileName =
              'photobooth_${DateTime.now().millisecondsSinceEpoch}.jpg';
          picturePath = path.join(tempDir.path, fileName);
          // Use the non-nullable `file.bytes!` after the check.
          await File(picturePath).writeAsBytes(file.bytes!);
        }
      } else {
        final XFile file =
            await (_controller as CameraController).takePicture();
        picturePath = file.path;
      }

      if (picturePath != null) {
        if (!mounted) return;
        context.read<PhotoboothProvider>().setFaceImage(picturePath);
        await Navigator.pushNamed(context, AppRoutes.loadingScreen);
      }
    } catch (e) {
      log("Error during _takePicture: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to take picture: $e')));
      }
    }
  }

  @override
  void dispose() {
    _disposeCurrentCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<FaceCaptureProvider>();
    final globalSettings = context.watch<GlobalSettingsProvider>();
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: _getBackgroundImage(settings, globalSettings),
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (settings.showTitle)
            Positioned(
              top: settings.titleTop * screenSize.height,
              left: settings.titleLeft * screenSize.width,
              width: settings.titleWidth *
                  screenSize.width, // Use width from provider
              child: Text(
                settings.titleText,
                textAlign: settings.titleAlignment,
                style: TextStyle(
                  fontSize: settings.titleFontSize,
                  fontWeight: settings.titleFontWeight,
                  color: settings.titleColor.withOpacity(settings.titleOpacity),
                  height: settings.titleLineHeight,
                  fontStyle: settings.isTitleItalic
                      ? FontStyle.italic
                      : FontStyle.normal, // Use italic style
                ),
              ),
            ),
          Positioned(
            top: settings.previewTop * screenSize.height,
            left: settings.previewLeft * screenSize.width,
            child: _buildCameraPreview(settings, screenSize),
          ),
          Positioned(
            top: settings.buttonTop * screenSize.height,
            left: settings.buttonLeft * screenSize.width,
            child: _buildCaptureButton(settings, screenSize),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.faceCaptureSettings);
                },
                child: const Icon(
                  Icons.star,
                  color: Colors.transparent,
                )),
          ),

          // Camera switch button (only show if multiple cameras available)
          if (!_isMacos && _cameras.length > 1)
            Positioned(
              bottom: 30,
              right: 30,
              child: GestureDetector(
                onTap: () {
                  final nextIndex = (_cameraIndex + 1) % _cameras.length;
                  _switchCamera(nextIndex);
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cameraswitch,
                    color: AppColors.white,
                    size: 30,
                  ),
                ),
              ),
            ),

          Positioned(
            bottom: 30,
            left: 30,
            child: GestureDetector(
              onTap: () {
                _disposeCurrentCamera().then((_) {
                  if (mounted) {
                    context.read<PhotoboothProvider>().clearFaceImage();
                    Navigator.pop(context);
                  }
                });
              },
              child: Image.asset(
                'assets/images/back_btn.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(FaceCaptureProvider settings, Size screenSize) {
    final double finalWidth = settings.previewWidth * screenSize.width;
    final double finalHeight = settings.previewHeight * screenSize.height;

    if (widget.isPreviewMode ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return Container(
        width: finalWidth,
        height: finalHeight,
        decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(settings.previewBorderRadius)),
        child: Center(
            child:
                CircularProgressIndicator(color: settings.previewBorderColor)),
      );
    }

    // Get the size of the container
    final Size containerSize = Size(finalWidth, finalHeight);

    // Get the camera's aspect ratio
    final double cameraAspectRatio = _controller!.value.aspectRatio;

    // Calculate the scale factor to cover the container
    // This is the core of the fix
    var scale = containerSize.aspectRatio * cameraAspectRatio;

    // We need to inverse the scale if the camera is "taller" than the container
    if (scale < 1) {
      scale = 1 / scale;
    }

    return Container(
      width: finalWidth,
      height: finalHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(settings.previewBorderRadius),
        border: settings.showPreviewBorder
            ? Border.all(
                color: settings.previewBorderColor,
                width: settings.previewBorderWidth)
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(settings.previewBorderRadius),
        child: Transform.scale(
          scale: scale,
          child: Center(
            child: CameraPreview(_controller!),
          ),
        ),
      ),
    );
  }

  Widget _buildCaptureButton(FaceCaptureProvider settings, Size screenSize) {
    final double finalWidth = settings.buttonWidth * screenSize.width;
    final double finalHeight = settings.buttonHeight * screenSize.height;

    if (settings.useImageButton) {
      if (settings.buttonImagePath == null) return const SizedBox();
      return Opacity(
        opacity: settings.buttonImageOpacity,
        child: GestureDetector(
          onTap: _takePicture,
          child: settings.isButtonImageAsset
              ? Image.asset(settings.buttonImagePath!,
                  fit: BoxFit.contain, width: finalWidth, height: finalHeight)
              : Image.file(File(settings.buttonImagePath!),
                  fit: BoxFit.contain, width: finalWidth, height: finalHeight),
        ),
      );
    } else {
      return SizedBox(
        width: finalWidth,
        height: finalHeight,
        child: ElevatedButton(
          onPressed: _takePicture,
          style: ElevatedButton.styleFrom(
            backgroundColor: settings.buttonBackgroundColor,
            foregroundColor: settings.buttonForegroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(settings.buttonBorderRadius),
            ),
          ),
          child: Text(
            settings.buttonText,
            style: TextStyle(
              fontSize: settings.buttonFontSize,
              fontWeight: settings.buttonFontWeight,
            ),
          ),
        ),
      );
    }
  }

  ImageProvider _getBackgroundImage(
      FaceCaptureProvider settings, GlobalSettingsProvider globalSettings) {
    if (settings.showBackground && settings.backgroundImagePath != null) {
      if (settings.isBackgroundImageAsset) {
        return AssetImage(settings.backgroundImagePath!);
      } else {
        return FileImage(File(settings.backgroundImagePath!));
      }
    } else {
      if (globalSettings.backgroundImagePath != null) {
        if (globalSettings.isBackgroundImageAsset) {
          return AssetImage(globalSettings.backgroundImagePath!);
        } else {
          return FileImage(File(globalSettings.backgroundImagePath!));
        }
      } else {
        return const AssetImage('assets/images/common_bg.png');
      }
    }
  }
}
