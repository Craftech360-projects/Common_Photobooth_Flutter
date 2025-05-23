// ignore_for_file: unused_field
import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photobooth_flutter/providers/face_capture_provider.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/providers/photobooth_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:provider/provider.dart';

/// Example app for Camera Windows plugin.
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
  String _cameraInfo = 'Unknown';
  List<CameraDescription> _cameras = <CameraDescription>[];
  int _cameraIndex = 0;
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _cameraInitialized = false;

  StreamSubscription<CameraErrorEvent>? _errorStreamSubscription;
  StreamSubscription<CameraClosingEvent>? _cameraClosingStreamSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();

    // Skip camera initialization in preview mode
    if (widget.isPreviewMode) {
      print("preview mode ${widget.isPreviewMode}");
      return;
    }

    // Initialize camera after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCameras() // Fetch available cameras on init.
          .then((_) => _initializeCamera()) // Initialize first camera.
          .catchError((dynamic error) {
        if (mounted) {
          setState(() {
            _cameraInfo = 'Failed to get cameras: $error';
          });
        }
      });
    });
  }

  // Add a didUpdateWidget lifecycle method to detect camera changes from settings
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check if the selected camera index has changed
    final settings = context.read<FaceCaptureProvider>();
    final selectedIndex = settings.selectedCameraIndex;

    // If camera is initialized and the selected index is different from current index
    if (_cameraInitialized &&
        selectedIndex < _cameras.length &&
        selectedIndex != _cameraIndex) {
      // Switch to the new camera
      _switchCamera(selectedIndex);
    }
  }

  /// Fetches list of available cameras from camera_windows plugin.
  Future<void> _fetchCameras() async {
    String cameraInfo;
    List<CameraDescription> cameras = <CameraDescription>[];

    int cameraIndex = 0;
    try {
      cameras = await CameraPlatform.instance.availableCameras();
      if (cameras.isEmpty) {
        cameraInfo = 'No available cameras';
      } else {
        // Get the selected camera index from provider
        final settings = context.read<FaceCaptureProvider>();
        cameraIndex = settings.selectedCameraIndex < cameras.length
            ? settings.selectedCameraIndex
            : 0;

        cameraInfo = 'Found camera: ${cameras[cameraIndex].name}';
      }
    } on PlatformException catch (e) {
      cameraInfo = 'Failed to get cameras: ${e.code}: ${e.message}';
    }

    if (mounted) {
      setState(() {
        _cameraIndex = cameraIndex;
        _cameras = cameras;
        _cameraInfo = cameraInfo;
      });
    }
  }

  // Update the _switchCamera method to accept a specific index
  Future<void> _switchCamera([int? specificIndex]) async {
    if (_cameras.isEmpty) {
      return;
    }

    // Dispose current camera first
    await _disposeCurrentCamera();

    // Update camera index
    setState(() {
      if (specificIndex != null && specificIndex < _cameras.length) {
        _cameraIndex = specificIndex;
      } else {
        _cameraIndex = (_cameraIndex + 1) % _cameras.length;
      }
    });

    // Update the selected camera index in provider
    final settings = context.read<FaceCaptureProvider>();
    settings.setSelectedCameraIndex(_cameraIndex);

    // Initialize the new camera
    await _initializeCamera();
  }

  @override
  void dispose() {
    // Make sure to properly dispose camera resources
    _disposeCurrentCamera();
    _controller?.dispose();
    _errorStreamSubscription?.cancel();
    _errorStreamSubscription = null;
    _cameraClosingStreamSubscription?.cancel();
    _cameraClosingStreamSubscription = null;
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    assert(!_cameraInitialized);

    if (_cameras.isEmpty) {
      return;
    }

    try {
      final int cameraIndex = _cameraIndex % _cameras.length;
      final CameraDescription camera = _cameras[cameraIndex];

      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.bgra8888,
        enableAudio: false,
      );

      _initializeControllerFuture = _controller?.initialize();
      await _initializeControllerFuture;

      if (mounted) {
        setState(() {
          _cameraInitialized = true;
          _cameraIndex = cameraIndex;
          _cameraInfo = 'Capturing camera: ${camera.name}';
        });
      }
    } on CameraException catch (e) {
      // Reset state.
      if (mounted) {
        setState(() {
          _cameraInitialized = false;
          _cameraIndex = 0;
          _controller = null; // Ensure controller is null on failure
          _cameraInfo =
              'Failed to initialize camera: ${e.code}: ${e.description}';
        });
      }
    }
  }

  Future<void> _disposeCurrentCamera() async {
    if (_controller != null && _cameraInitialized) {
      final currentController = _controller; // Store controller

      // Immediately mark as not initialized
      if (mounted) {
        setState(() {
          _cameraInitialized = false;
          _controller = null;
          _cameraInfo = 'Disposing camera...';
        });
      } else {
        _cameraInitialized = false;
        _controller = null;
      }

      try {
        // Dispose the controller
        await currentController?.dispose();

        // Update info on successful disposal if mounted
        if (mounted) {
          setState(() {
            _cameraInfo = 'Camera disposed';
          });
        }
      } on CameraException catch (e) {
        debugPrint(
            'Failed to dispose camera controller: ${e.code}: ${e.description}');
        // Update info on failed disposal if mounted
        if (mounted) {
          setState(() {
            _cameraInfo =
                'Failed to dispose camera: ${e.code}: ${e.description}';
          });
        }
      }
    } else {
      // Ensure state reflects camera not being initialized/controller null
      // IMPORTANT: Don't use setState here, just update the fields directly
      _cameraInitialized = false;
      _controller = null;
    }
  }

  Future<void> _takePicture() async {
    XFile? file;

    try {
      // Update check: rely only on _cameraInitialized and _controller
      if (!_cameraInitialized || _controller == null) {
        throw Exception("Camera not ready or controller not initialized.");
      }
      // Use controller's takePicture method
      file = await _controller!.takePicture();

      // Verify file exists (important!)
      final imageFile = File(file.path);
      if (!await imageFile.exists()) {
        // Use await for async check
        debugPrint('File does not exist at path: ${file.path}');
        throw Exception("Captured image file does not exist at ${file.path}.");
      } else {
        debugPrint('File verified, exists at path: ${file.path}');
      }

      // --- Dispose the camera AFTER successful capture and BEFORE navigation ---
      await _disposeCurrentCamera();

      // --- Update Provider ---
      // Use context safely
      if (!mounted) return; // Check if widget is still in the tree
      final provider = context.read<PhotoboothProvider>();
      provider.setFaceImage(file.path);

      // --- Navigate ---
      if (!mounted) return; // Add another mounted check before navigation
      await Navigator.pushNamed(context, AppRoutes.loadingScreen);
    } on Exception catch (e) {
      // --- Error Handling ---
      debugPrint("Error during _takePicture: $e"); // Log the specific error
      if (!mounted) return; // Add mounted check here too

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to take picture: $e')),
      );

      // Ensure camera controller is disposed *before* trying to re-initialize
      if (_controller != null) {
        debugPrint("Disposing camera controller due to error...");
        await _disposeCurrentCamera();
      }

      // Attempt re-initialization only if the controller is null
      if (!mounted) return; // Add mounted check before re-initialization

      debugPrint("Re-initializing camera...");
      // Ensure controller is null before re-initializing
      if (_controller == null) {
        await _initializeCamera();
      } else {
        debugPrint("Controller not null, skipping re-initialization attempt.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<FaceCaptureProvider>();
    final globalSettings = context.watch<GlobalSettingsProvider>();

    // Show loading indicator if camera is not initialized
    // if (!_cameraInitialized ||
    //     _controller == null ||
    //     !_controller!.value.isInitialized) {
    //   return Scaffold(
    //     body: Container(
    //       width: double.infinity,
    //       height: double.infinity,
    //       decoration: BoxDecoration(
    //         image: DecorationImage(
    //           image: _getBackgroundImage(settings, globalSettings),
    //           fit: BoxFit.cover,
    //         ),
    //       ),
    //       child: Center(
    //         child: CircularProgressIndicator(
    //           color: settings.previewBorderColor,
    //         ),
    //       ),
    //     ),
    //   );
    // }

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
                  color: settings.titleColor.withOpacity(settings.titleOpacity),
                ),
              ),
            ),

          Positioned(
            top: settings.previewTop,
            left: settings.previewLeft,
            child: _buildCameraPreview(settings),
          ),

          // Capture Button
          Positioned(
            top: settings.buttonTop,
            left: settings.buttonLeft,
            child: _buildCaptureButton(settings),
          ),

          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.faceCaptureSettings),
              child: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(FaceCaptureProvider settings) {
    // In preview mode, just show a placeholder
    if (widget.isPreviewMode) {
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
                color: Colors.white, // Add a background color for visibility
              )
            : BoxDecoration(
                borderRadius:
                    BorderRadius.circular(settings.previewBorderRadius),
                color: Colors.black38, // Add a background color for visibility
              ),
        child: const Center(
          child: Icon(
            Icons.camera_alt,
            size: 50,
            color: Colors.white54,
          ),
        ),
      );
    }

    if (!_cameraInitialized || _controller == null) {
      return Center(
        child: CircularProgressIndicator(
          color: settings.previewBorderColor,
        ),
      );
    }

    // Ensure controller and its value are ready
    if (!_controller!.value.isInitialized) {
      return Center(
        child: CircularProgressIndicator(
          color: settings.previewBorderColor,
        ),
      );
    }

    // Calculate aspect ratio
    final cameraAspectRatio = _controller!.value.aspectRatio;

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
        child: AspectRatio(
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
        ),
      ),
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
          ),
          child: settings.isButtonImageAsset
              ? Image.asset(
                  settings.buttonImagePath!,
                  fit: BoxFit.contain,
                )
              : Image.file(
                  File(settings.buttonImagePath!),
                  fit: BoxFit.contain,
                ),
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
      // Use the global background if available
      if (globalSettings.backgroundImagePath != null) {
        if (globalSettings.isBackgroundImageAsset) {
          return AssetImage(globalSettings.backgroundImagePath!);
        } else {
          return FileImage(File(globalSettings.backgroundImagePath!));
        }
      } else {
        // Default background
        return const AssetImage('assets/images/background.jpg');
      }
    }
  }
}
