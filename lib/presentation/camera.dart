import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photobooth_flutter/providers/face_capture_provider.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:provider/provider.dart';

/// Example app for Camera Windows plugin.
class FaceCaptureScreen extends StatefulWidget {
  const FaceCaptureScreen({super.key});

  @override
  State<FaceCaptureScreen> createState() => _FaceCaptureScreenState();
}

class _FaceCaptureScreenState extends State<FaceCaptureScreen> {
  String _cameraInfo = 'Unknown';
  Future<void>? _initializeControllerFuture;
  CameraController? _controller;
  List<CameraDescription> _cameras = <CameraDescription>[];
  int _cameraIndex = 0;
  int _cameraId = -1;
  bool _initialized = false;
  final MediaSettings _mediaSettings = const MediaSettings(
    resolutionPreset: ResolutionPreset.high,
    fps: 15,
    videoBitrate: 200000,
    audioBitrate: 32000,
    enableAudio: true,
  );
  StreamSubscription<CameraErrorEvent>? _errorStreamSubscription;
  StreamSubscription<CameraClosingEvent>? _cameraClosingStreamSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    _fetchCameras() // Fetch available cameras on init.
        .then((_) => _initializeCamera()) // Initialize first camera.
        .catchError((dynamic error) {
      if (mounted) {
        setState(() {
          _cameraInfo = 'Failed to get cameras: $error';
        });
      }
    });
  }

  @override
  void dispose() {
    _disposeCurrentCamera();
    _errorStreamSubscription?.cancel();
    _errorStreamSubscription = null;
    _cameraClosingStreamSubscription?.cancel();
    _cameraClosingStreamSubscription = null;
    super.dispose();
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
        cameraIndex = _cameraIndex % cameras.length;
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

  /// Initializes the camera on the device.
  Future<void> _initializeCamera() async {
    assert(!_initialized);

    if (_cameras.isEmpty) {
      return;
    }

    int cameraId = -1;
    try {
      final int cameraIndex = _cameraIndex % _cameras.length;
      final CameraDescription camera = _cameras[cameraIndex];

      cameraId = await CameraPlatform.instance.createCameraWithSettings(
        camera,
        _mediaSettings,
      );

      unawaited(_errorStreamSubscription?.cancel());
      _errorStreamSubscription = CameraPlatform.instance
          .onCameraError(cameraId)
          .listen(_onCameraError);

      unawaited(_cameraClosingStreamSubscription?.cancel());
      _cameraClosingStreamSubscription = CameraPlatform.instance
          .onCameraClosing(cameraId)
          .listen(_onCameraClosing);

      final Future<CameraInitializedEvent> initialized =
          CameraPlatform.instance.onCameraInitialized(cameraId).first;

      await CameraPlatform.instance.initializeCamera(
        cameraId,
      );

      _initializeControllerFuture = _controller?.initialize();
      await _initializeControllerFuture;

      if (mounted) {
        setState(() {
          _initialized = true;
          _cameraId = cameraId;
          _cameraIndex = cameraIndex;
          _cameraInfo = 'Capturing camera: ${camera.name}';
        });
      }
    } on CameraException catch (e) {
      try {
        if (cameraId >= 0) {
          await CameraPlatform.instance.dispose(cameraId);
        }
      } on CameraException catch (e) {
        debugPrint('Failed to dispose camera: ${e.code}: ${e.description}');
      }

      // Reset state.
      if (mounted) {
        setState(() {
          _initialized = false;
          _cameraId = -1;
          _cameraIndex = 0;
          _cameraInfo =
              'Failed to initialize camera: ${e.code}: ${e.description}';
        });
      }
    }
  }

  Future<void> _disposeCurrentCamera() async {
    if (_cameraId >= 0 && _initialized) {
      try {
        await CameraPlatform.instance.dispose(_cameraId);

        if (mounted) {
          setState(() {
            _initialized = false;
            _cameraId = -1;
            _cameraInfo = 'Camera disposed';
          });
        }
      } on CameraException catch (e) {
        if (mounted) {
          setState(() {
            _cameraInfo =
                'Failed to dispose camera: ${e.code}: ${e.description}';
          });
        }
      }
    }
  }

  Widget _buildPreview(FaceCaptureProvider settings) {
    if (!_initialized) {
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
                borderRadius:
                    BorderRadius.circular(settings.previewBorderRadius),
                child: CameraPreview(_controller!)),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Future<void> _takePicture() async {
    final XFile file = await CameraPlatform.instance.takePicture(_cameraId);
    _showInSnackBar('Picture captured to: ${file.path}');
  }

  // Future<void> _switchCamera() async {
  //   if (_cameras.isNotEmpty) {
  //     // select next index;
  //     _cameraIndex = (_cameraIndex + 1) % _cameras.length;
  //     if (_initialized && _cameraId >= 0) {
  //       await _disposeCurrentCamera();
  //       await _fetchCameras();
  //       if (_cameras.isNotEmpty) {
  //         await _initializeCamera();
  //       }
  //     } else {
  //       await _fetchCameras();
  //     }
  //   }
  // }

  void _onCameraError(CameraErrorEvent event) {
    if (mounted) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('Error: ${event.description}')));

      // Dispose camera on camera error as it can not be used anymore.
      _disposeCurrentCamera();
      _fetchCameras();
    }
  }

  void _onCameraClosing(CameraClosingEvent event) {
    if (mounted) {
      _showInSnackBar('Camera is closing');
    }
  }

  void _showInSnackBar(String message) {
    _scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 1),
    ));
  }

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

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
            _buildPreview(settings),
            // _buildCameraPreview(settings),

            // Capture Button
            SizedBox(height: settings.buttonMarginTop),
            _buildCaptureButton(settings),
          ],
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
