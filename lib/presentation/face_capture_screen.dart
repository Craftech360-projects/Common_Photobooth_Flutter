// ignore_for_file: unused_field
import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
// NEW: Import the camera_macos package
import 'package:camera_macos/camera_macos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photobooth_flutter/providers/face_capture_provider.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/providers/photobooth_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

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
  // NEW: Use a dynamic controller to hold either CameraController or CameraMacOSController
  dynamic _controller;
  bool _cameraInitialized = false;

  // Standard camera properties
  List<CameraDescription> _cameras = <CameraDescription>[];
  int _cameraIndex = 0;
  Future<void>? _initializeControllerFuture;

  // macOS-specific properties
  String? _selectedMacosCameraId;

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
    if (_isMacos) return; // macOS camera switching is handled differently if needed

    final settings = context.read<FaceCaptureProvider>();
    final selectedIndex = settings.selectedCameraIndex;

    if (_cameraInitialized &&
        selectedIndex < _cameras.length &&
        selectedIndex != _cameraIndex) {
      _switchCamera(selectedIndex);
    }
  }

  Future<void> _initializeCamera() async {
    // PLATFORM-SPECIFIC INITIALIZATION
    if (_isMacos) {
      // For macOS, we just need to get the list of devices.
      // The actual initialization happens within the CameraMacOSView widget.
      List<CameraMacOSDevice> devices =
          await CameraMacOS.instance.listDevices();
      if (devices.isNotEmpty) {
        if (mounted) {
          setState(() {
            _selectedMacosCameraId = devices.first.deviceId;
            _cameraInitialized = true; // Ready to build the widget
          });
        }
      }
    } else {
      // For other platforms (Windows, Android, iOS)
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
              top: settings.titleTop,
              left: settings.titleLeft,
              right: settings.titleRight,
              child: Text(
                settings.titleText,
                textAlign: settings.titleAlignment,
                style: TextStyle(
                  fontSize: settings.titleFontSize,
                  fontWeight: settings.titleFontWeight,
                  color: settings.titleColor,
                  height: settings.titleLineHeight,
                ).copyWith(
                  color: settings.titleColor
                      .withValues(alpha: settings.titleOpacity),
                ),
              ),
            ),
          Positioned(
            top: settings.previewTop,
            left: settings.previewLeft,
            child: _buildCameraPreview(settings),
          ),
          Positioned(
            top: settings.buttonTop,
            left: settings.buttonLeft,
            child: _buildCaptureButton(settings),
          ),
          Positioned(
            bottom: 30,
            left: 30,
            child: GestureDetector(
              onTap: () {
                _disposeCurrentCamera().then((_) {
                  context.read<PhotoboothProvider>().clearFaceImage();
                  Navigator.pop(context);
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

  Widget _buildCameraPreview(FaceCaptureProvider settings) {
    if (widget.isPreviewMode) {
      return Container(
        width: settings.previewWidth,
        height: settings.previewHeight,
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(settings.previewBorderRadius),
          border: settings.showPreviewBorder
              ? Border.all(
                  color: settings.previewBorderColor,
                  width: settings.previewBorderWidth,
                )
              : null,
        ),
        child: const Center(
          child: Icon(Icons.camera_alt, size: 50, color: Colors.white54),
        ),
      );
    }

    if (!_cameraInitialized) {
      return Container(
        width: settings.previewWidth,
        height: settings.previewHeight,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(settings.previewBorderRadius),
        ),
        child: Center(
            child:
                CircularProgressIndicator(color: settings.previewBorderColor)),
      );
    }

    Widget cameraView;

    // PLATFORM-SPECIFIC WIDGET RENDERING
    if (_isMacos) {
      cameraView = CameraMacOSView(
        // FIX: Explicitly set the camera mode to photo.
        cameraMode: CameraMacOSMode.photo,
        deviceId: _selectedMacosCameraId,
        fit: BoxFit.cover,
        onCameraInizialized: (CameraMacOSController controller) {
          if (mounted) {
            setState(() {
              _controller = controller;
            });
          }
        },
      );
    } else {
      if (_controller == null || !_controller!.value.isInitialized) {
        return const Center(child: Text("Camera not initialized"));
      }
      final cameraAspectRatio = _controller!.value.aspectRatio;
      cameraView = AspectRatio(
        aspectRatio: settings.previewWidth / settings.previewHeight,
        child: OverflowBox(
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: settings.previewWidth,
              height: settings.previewWidth / cameraAspectRatio,
              child: CameraPreview(_controller!),
            ),
          ),
        ),
      );
    }

    return Container(
      width: settings.previewWidth,
      height: settings.previewHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(settings.previewBorderRadius),
        border: settings.showPreviewBorder
            ? Border.all(
                color: settings.previewBorderColor,
                width: settings.previewBorderWidth,
              )
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(settings.previewBorderRadius),
        child: cameraView,
      ),
    );
  }

  Widget _buildCaptureButton(FaceCaptureProvider settings) {
    if (settings.useImageButton && settings.buttonImagePath != null) {
      return GestureDetector(
        onTap: _takePicture,
        child: settings.isButtonImageAsset
            ? Image.asset(
                settings.buttonImagePath!,
                fit: BoxFit.contain,
                width: 585,
                height: 150,
              )
            : Image.file(
                File(settings.buttonImagePath!),
                fit: BoxFit.contain,
                width: 585,
                height: 150,
              ),
      );
    } else {
      return ElevatedButton(
        onPressed: _takePicture,
        style: ElevatedButton.styleFrom(
          backgroundColor: settings.buttonColor,
          foregroundColor: settings.buttonTextColor,
          minimumSize: Size(settings.buttonWidth, settings.buttonHeight),
          padding: settings.buttonPadding,
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
            fontWeight: settings.buttonFontWeight,
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