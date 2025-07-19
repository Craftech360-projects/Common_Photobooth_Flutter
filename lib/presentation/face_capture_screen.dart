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

  // For camera plugin (Windows/other)
  List<CameraDescription> _cameras = <CameraDescription>[];
  int _cameraIndex = 0;

  // For camera_macos plugin
  List<CameraMacOSDevice> _macOsCameras = <CameraMacOSDevice>[];

  Future<void>? _initializeControllerFuture;

  // Check the platform once
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
    final settings = context.read<FaceCaptureProvider>();
    final selectedIndex = settings.selectedCameraIndex;
    final maxCameras = _isMacos ? _macOsCameras.length : _cameras.length;

    if (_cameraInitialized &&
        selectedIndex < maxCameras &&
        selectedIndex != _cameraIndex) {
      _switchCamera(selectedIndex);
    }
  }

  Future<void> _initializeCamera() async {
    if (_isMacos) {
      // ---- macOS SPECIFIC INITIALIZATION ----
      try {
        _macOsCameras = await CameraMacOS.instance.listDevices();
        if (_macOsCameras.isEmpty) {
          log('No available cameras found on macOS.');
          return;
        }
        final settings = context.read<FaceCaptureProvider>();
        _cameraIndex = settings.selectedCameraIndex < _macOsCameras.length
            ? settings.selectedCameraIndex
            : 0;

        // The controller is initialized by the CameraMacOSView widget.
        // We just need to trigger a rebuild to show the view.
        if (mounted) {
          setState(() {});
        }
      } catch (e) {
        log('Failed to list macOS cameras: $e');
      }
    } else {
      // ---- STANDARD INITIALIZATION (for Windows, etc.) ----
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
  }

  Future<void> _switchCamera(int specificIndex) async {
    await _disposeCurrentCamera();

    setState(() {
      _cameraIndex = specificIndex;
    });

    final settings = context.read<FaceCaptureProvider>();
    settings.setSelectedCameraIndex(_cameraIndex);

    // For macOS, rebuilding the widget with the new index is enough.
    // For other platforms, we need to re-initialize the controller.
    if (!_isMacos) {
      await _initializeCamera();
    }
  }

  Future<void> _disposeCurrentCamera() async {
    if (_controller != null) {
      if (_isMacos) {
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
        if (file != null && file.bytes != null) {
          final Directory tempDir = await getTemporaryDirectory();
          final String fileName =
              'photobooth_${DateTime.now().millisecondsSinceEpoch}.jpg';
          picturePath = path.join(tempDir.path, fileName);
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
    final maxCameras = _isMacos ? _macOsCameras.length : _cameras.length;

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
              width: settings.titleWidth * screenSize.width,
              child: Text(
                settings.titleText,
                textAlign: settings.titleAlignment,
                style: TextStyle(
                  fontSize: settings.titleFontSize,
                  fontWeight: settings.titleFontWeight,
                  color: settings.titleColor
                      .withValues(alpha: settings.titleOpacity),
                  height: settings.titleLineHeight,
                  fontStyle: settings.isTitleItalic
                      ? FontStyle.italic
                      : FontStyle.normal,
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
          if (maxCameras > 1)
            Positioned(
              bottom: 30,
              right: 30,
              child: GestureDetector(
                onTap: () {
                  final nextIndex = (_cameraIndex + 1) % maxCameras;
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

    if (widget.isPreviewMode) {
      return Container(
        width: finalWidth,
        height: finalHeight,
        decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(settings.previewBorderRadius)),
      );
    }

    if (_isMacos) {
      // ---- RENDER MACOS PREVIEW ----
      if (_macOsCameras.isEmpty) {
        return Container(
            width: finalWidth,
            height: finalHeight,
            decoration: BoxDecoration(
                color: AppColors.black,
                borderRadius:
                    BorderRadius.circular(settings.previewBorderRadius)),
            child: const Center(
                child: Text("No cameras found",
                    style: TextStyle(color: Colors.white))));
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
          child: CameraMacOSView(
            cameraMode: CameraMacOSMode.photo,
            deviceId: _macOsCameras[_cameraIndex].deviceId,
            onCameraInizialized: (CameraMacOSController controller) {
              setState(() {
                _controller = controller;
                _cameraInitialized = true;
              });
            },
          ),
        ),
      );
    } else {
      // ---- RENDER STANDARD PREVIEW ----
      if (_controller == null ||
          !_controller!.value.isInitialized ||
          !_cameraInitialized) {
        return Container(
          width: finalWidth,
          height: finalHeight,
          decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius:
                  BorderRadius.circular(settings.previewBorderRadius)),
          child: Center(
              child: CircularProgressIndicator(
                  color: settings.previewBorderColor)),
        );
      }

      var scale = finalWidth / finalHeight * _controller!.value.aspectRatio;
      if (scale < 1) scale = 1 / scale;

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
            child: Center(child: CameraPreview(_controller!)),
          ),
        ),
      );
    }
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
