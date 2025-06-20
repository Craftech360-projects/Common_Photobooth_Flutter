// ignore_for_file: unused_field
import 'dart:async';
import 'dart:developer';
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

    if (widget.isPreviewMode) {
      log("preview mode ${widget.isPreviewMode}");
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCameras()
          .then((_) => _initializeCamera())
          .catchError((dynamic error) {
        if (mounted) {
          setState(() {
            _cameraInfo = 'Failed to get cameras: $error';
          });
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = context.read<FaceCaptureProvider>();
    final selectedIndex = settings.selectedCameraIndex;

    if (_cameraInitialized &&
        selectedIndex < _cameras.length &&
        selectedIndex != _cameraIndex) {
      _switchCamera(selectedIndex);
    }
  }

  Future<void> _fetchCameras() async {
    String cameraInfo;
    List<CameraDescription> cameras = <CameraDescription>[];
    int cameraIndex = 0;
    try {
      cameras = await CameraPlatform.instance.availableCameras();
      if (cameras.isEmpty) {
        cameraInfo = 'No available cameras';
      } else {
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

  Future<void> _switchCamera([int? specificIndex]) async {
    if (_cameras.isEmpty) return;
    await _disposeCurrentCamera();
    setState(() {
      if (specificIndex != null && specificIndex < _cameras.length) {
        _cameraIndex = specificIndex;
      } else {
        _cameraIndex = (_cameraIndex + 1) % _cameras.length;
      }
    });
    final settings = context.read<FaceCaptureProvider>();
    settings.setSelectedCameraIndex(_cameraIndex);
    await _initializeCamera();
  }

  @override
  void dispose() {
    _disposeCurrentCamera();
    _controller?.dispose();
    _errorStreamSubscription?.cancel();
    _cameraClosingStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    assert(!_cameraInitialized);
    if (_cameras.isEmpty) return;
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
      if (mounted) {
        setState(() {
          _cameraInitialized = false;
          _cameraIndex = 0;
          _controller = null;
          _cameraInfo =
              'Failed to initialize camera: ${e.code}: ${e.description}';
        });
      }
    }
  }

  Future<void> _disposeCurrentCamera() async {
    if (_controller != null && _cameraInitialized) {
      final currentController = _controller;
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
        await currentController?.dispose();
        if (mounted) setState(() => _cameraInfo = 'Camera disposed');
      } on CameraException catch (e) {
        debugPrint(
            'Failed to dispose camera controller: ${e.code}: ${e.description}');
        if (mounted) {
          setState(() => _cameraInfo =
              'Failed to dispose camera: ${e.code}: ${e.description}');
        }
      }
    } else {
      _cameraInitialized = false;
      _controller = null;
    }
  }

  Future<void> _takePicture() async {
    XFile? file;
    try {
      if (!_cameraInitialized || _controller == null) {
        throw Exception("Camera not ready or controller not initialized.");
      }
      file = await _controller!.takePicture();
      final imageFile = File(file.path);
      if (!await imageFile.exists()) {
        throw Exception("Captured image file does not exist at ${file.path}.");
      }
      await _disposeCurrentCamera();
      if (!mounted) return;
      context.read<PhotoboothProvider>().setFaceImage(file.path);
      await Navigator.pushNamed(context, AppRoutes.loadingScreen);
    } on Exception catch (e) {
      debugPrint("Error during _takePicture: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to take picture: $e')));
      if (_controller != null) await _disposeCurrentCamera();
      if (!mounted) return;
      if (_controller == null) await _initializeCamera();
    }
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
                  color: settings.titleColor.withOpacity(settings.titleOpacity),
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
          // Bottom Right Back Button
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
        decoration: settings.showPreviewBorder
            ? BoxDecoration(
                borderRadius:
                    BorderRadius.circular(settings.previewBorderRadius),
                border: Border.all(
                  color: settings.previewBorderColor,
                  width: settings.previewBorderWidth,
                ),
                color: Colors.white,
              )
            : BoxDecoration(
                borderRadius:
                    BorderRadius.circular(settings.previewBorderRadius),
                color: Colors.black38,
              ),
        child: const Center(
          child: Icon(Icons.camera_alt, size: 50, color: Colors.white54),
        ),
      );
    }
    if (!_cameraInitialized || _controller == null) {
      return const Center(child: SizedBox());
    }
    if (!_controller!.value.isInitialized) {
      return Center(
          child: CircularProgressIndicator(color: settings.previewBorderColor));
    }
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
