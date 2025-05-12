// ignore_for_file: unused_field
import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_macos/camera_macos.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photobooth_flutter/providers/admin_watermark_provider.dart';
import 'package:photobooth_flutter/providers/face_capture_provider.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/providers/photobooth_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:photobooth_flutter/widgets/watermark_overlay.dart';
import 'package:provider/provider.dart';

/// Example app for Camera Windows plugin.
class FaceCaptureScreen extends StatefulWidget {
  const FaceCaptureScreen({
    super.key,
  });

  @override
  State<FaceCaptureScreen> createState() => _FaceCaptureScreenState();
}

class _FaceCaptureScreenState extends State<FaceCaptureScreen> {
  String _cameraInfo = 'Unknown';
  List<CameraDescription> _cameras = <CameraDescription>[];
  int _cameraIndex = 0;
  int _cameraId = -1;
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _cameraInitialized = false;

  StreamSubscription<CameraErrorEvent>? _errorStreamSubscription;
  StreamSubscription<CameraClosingEvent>? _cameraClosingStreamSubscription;

  // macOS camera variables
  final GlobalKey _cameraKey = GlobalKey();
  CameraMacOSController? _macOSController;
  List<CameraMacOSDevice> _macOSVideoDevices = [];
  String? _selectedVideoDeviceId;
  bool _isMacOS = false;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();

    // Check platform
    _isMacOS = Platform.isMacOS;

    // Only initialize camera if not in preview mode

    // Initialize camera after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isMacOS) {
        _initializeMacOSCamera();
      } else {
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

  // macOS camera initialization
  Future<void> _initializeMacOSCamera() async {
    try {
      // List available video devices
      _macOSVideoDevices = await CameraMacOS.instance.listDevices(
        deviceType: CameraMacOSDeviceType.video,
      );

      if (_macOSVideoDevices.isNotEmpty) {
        _selectedVideoDeviceId = _macOSVideoDevices.first.deviceId;
      }

      setState(() {
        _cameraInitialized = true;
      });
    } on Exception catch (e) {
      debugPrint('Error initializing macOS camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera error: $e')),
        );
      }
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

    int cameraId = -1;
    try {
      final int cameraIndex = _cameraIndex % _cameras.length;
      final CameraDescription camera = _cameras[cameraIndex];

      // cameraId = await CameraPlatform.instance.createCameraWithSettings(
      //   camera,
      //   _mediaSettings,
      // );

      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.bgra8888,
        enableAudio: false,
      );

      _initializeControllerFuture = _controller?.initialize();
      await _initializeControllerFuture;

      unawaited(_errorStreamSubscription?.cancel());
      _errorStreamSubscription = CameraPlatform.instance
          .onCameraError(cameraId)
          .listen(_onCameraError);

      unawaited(_cameraClosingStreamSubscription?.cancel());
      _cameraClosingStreamSubscription = CameraPlatform.instance
          .onCameraClosing(cameraId)
          .listen(_onCameraClosing);

      // final Future<CameraInitializedEvent> initialized =
      //     CameraPlatform.instance.onCameraInitialized(cameraId).first;

      // await CameraPlatform.instance.initializeCamera(
      //   cameraId,
      // );

      // final CameraInitializedEvent event = await initialized;
      // _previewSize = Size(
      //   event.previewWidth,
      //   event.previewHeight,
      // );

      if (mounted) {
        setState(() {
          _cameraInitialized = true;
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
          _cameraInitialized = false;
          _cameraId = -1;
          _cameraIndex = 0;
          _cameraInfo =
              'Failed to initialize camera: ${e.code}: ${e.description}';
        });
      }
    }
  }

  Future<void> _disposeCurrentCamera() async {
    if (_cameraId >= 0 && _cameraInitialized) {
      try {
        await CameraPlatform.instance.dispose(_cameraId);
        await _controller?.dispose();
        _controller = null;

        if (mounted) {
          setState(() {
            _cameraInitialized = false;
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

  Future<void> _takePicture() async {
    // Determine which platform logic to use
    final isMacOS = Platform.isMacOS;
    XFile? file; // Define file here so it's accessible after the if/else

    // Use try-finally to ensure potential camera re-init happens even on success path if needed
    try {
      if (isMacOS) {
        // --- macOS Picture Taking Logic ---
        if (_macOSController == null) {
          throw Exception("macOS controller is not initialized");
        }

        // Correctly expect CameraMacOSPicture?
        final CameraMacOSFile? macOSPicture =
            await _macOSController!.takePicture(); // Renamed for clarity

        if (macOSPicture == null) {
          // Check the picture object itself
          throw Exception(
              "macOS controller failed to take picture (returned null picture object)");
        }
        if (macOSPicture.bytes == null) {
          // Also check if bytes are present
          throw Exception(
              "macOS controller failed to take picture (returned null bytes)");
        }

        // --- Convert Bitmap to File ---
        // Get temporary directory
        final Directory tempDir = await getTemporaryDirectory();
        final String filePath =
            '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.png';

        // Create image directly from the bytes
        // The CameraMacOSFile doesn't have width/height properties
        // We need to save the bytes directly
        await File(filePath).writeAsBytes(macOSPicture.bytes!);

        // Create an XFile object from the saved path
        file = XFile(filePath);
        // --- End Bitmap to File ---

        // --- End macOS Logic ---
      } else {
        // --- Windows/Other Platform Picture Taking Logic ---
        if (!_cameraInitialized || _controller == null || _cameraId < 0) {
          throw Exception("Camera not ready or controller not initialized.");
        }
        file = await CameraPlatform.instance.takePicture(_cameraId);

        // --- End Windows/Other Logic ---
      }

      // Verify file exists (important!)
      final imageFile = File(file.path); // Use file! (null check above)
      if (!await imageFile.exists()) {
        // Use await for async check
        debugPrint('File does not exist at path: ${file.path}');
        throw Exception("Captured image file does not exist at ${file.path}.");
      } else {
        debugPrint('File verified, exists at path: ${file.path}');
      }

      // --- Consider removing this disposal ---
      // await _disposeCurrentCamera(); // Removed as discussed before

      // --- Update Provider ---
      // Use context safely
      if (!mounted) return; // Check if widget is still in the tree
      final provider = context.read<PhotoboothProvider>();
      provider.setFaceImage(file.path); // Use file!

      // --- Navigate ---
      if (mounted) {
        // Check again before async gap
        await Navigator.pushNamed(context, AppRoutes.loadingScreen);
      }
      // --- End Common Logic ---
    } on Exception catch (e) {
      // --- Error Handling ---
      debugPrint("Error during _takePicture: $e"); // Log the specific error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to take picture: $e')),
        );

        // Ensure camera is disposed *before* trying to re-initialize (only non-macOS here)
        if (_cameraInitialized && !isMacOS) {
          debugPrint("Disposing non-macOS camera due to error...");
          await _disposeCurrentCamera();
        }

        // Attempt re-initialization
        if (!isMacOS) {
          debugPrint("Re-initializing non-macOS camera...");
          await _initializeCamera();
        } else {
          debugPrint("Re-initializing macOS camera...");
          // Handle macOS re-initialization
          await _initializeMacOSCamera();
        }
      }
      // --- End Error Handling ---
    }
  }

  void _onCameraError(CameraErrorEvent event) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera error'),
          duration: Duration(seconds: 5),
        ),
      );

      // Dispose camera on camera error as it can not be used anymore.
      _disposeCurrentCamera();
      _fetchCameras();
    }
  }

  void _onCameraClosing(CameraClosingEvent event) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera closing'),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<FaceCaptureProvider>();
    final globalSettings = context.watch<GlobalSettingsProvider>();
    final watermarkProvider = context.watch<AdminWatermarkProvider>();

    return Scaffold(
      // appBar: AppBar(
      //   leading: IconButton(
      //     onPressed: () =>
      //         Navigator.pushNamed(context, AppRoutes.faceCaptureSettings),
      //     icon: const Icon(Icons.star),
      //   ),
      // ),

      //   // actions: [
      //   //   // Add camera switch button if there are multiple cameras
      //   //   if (_cameras.length > 1)
      //   //     IconButton(
      //   //       onPressed: _switchCamera,
      //   //       icon: const Icon(Icons.switch_camera),
      //   //       tooltip: 'Switch Camera',
      //   //     ),
      //   //   IconButton(
      //   //     onPressed: () => Navigator.pop(context),
      //   //     icon: const Icon(Icons.arrow_back),
      //   //   ),
      //   // ],
      // ),
      body: WatermarkOverlay(
        show: watermarkProvider.showWatermark,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: _getBackgroundImage(settings, globalSettings),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              // Title
              if (settings.showTitle)
                Padding(
                  padding: settings.titlePadding,
                  child: Text(
                    textAlign: settings.titleAlignment,
                    settings.titleText,
                    style: TextStyle(
                      height: settings.titleLineHeight,
                      fontSize: settings.titleFontSize,
                      fontWeight: settings.titleFontWeight,
                      color: settings.titleColor
                          .withValues(alpha: settings.titleOpacity),
                    ),
                  ),
                ),

              // Camera Preview
              _buildCameraPreview(settings),

              // Capture Button
              _buildCaptureButton(settings),
            ],
          ),
        ),
      ),
    );
  }

  // Add placeholder widgets for preview mode

  Widget _buildCameraPreview(FaceCaptureProvider settings) {
    if (!_cameraInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_isMacOS) {
      return Container(
        margin: settings.previewMargin,
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
              ? AspectRatio(
                  aspectRatio: 2 / 6, child: CameraPreview(_controller!))
              : const Center(child: Text('Camera not available')),
        ),
      );
    }
  }

  Widget _buildCaptureButton(FaceCaptureProvider settings) {
    if (settings.useImageButton && settings.buttonImagePath != null) {
      return GestureDetector(
        onTap: _takePicture,
        child: Container(
          margin: settings.buttonMargin,
          padding: settings.buttonPadding,
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
      return Container(
        margin: settings.buttonMargin,
        padding: settings.buttonPadding,
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
              fontWeight: settings.buttonFontWeight,
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
