import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/providers/app_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:provider/provider.dart';

class FaceCaptureScreen extends StatefulWidget {
  const FaceCaptureScreen({super.key});

  @override
  State<FaceCaptureScreen> createState() => _FaceCaptureScreenState();
}

class _FaceCaptureScreenState extends State<FaceCaptureScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    _initializeControllerFuture = _controller?.initialize();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Container(
                    width: 350,
                    height: 500,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.goldenYellow,
                        width: 5,
                      ),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(21),
                      child: CameraPreview(_controller!),
                    ),
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _initializeControllerFuture;
                  final image = await _controller?.takePicture();
                  if (image != null) {
                    context
                        .read<PhotoboothProvider>()
                        .setCapturedImage(image.path);
                    await Navigator.pushNamed(context, AppRoutes.swappedFace);
                  }
                } on Exception catch (e) {
                  debugPrint(e.toString());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              child: const Text(
                'CAPTURE',
                style: TextStyle(
                  fontSize: 30,
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
