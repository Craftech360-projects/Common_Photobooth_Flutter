import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/providers/app_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SwappedFaceScreen extends StatefulWidget {
  const SwappedFaceScreen({super.key});

  @override
  State<SwappedFaceScreen> createState() => _SwappedFaceScreenState();
}

class _SwappedFaceScreenState extends State<SwappedFaceScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  Future<void> _processImage() async {
    try {
      final provider = Provider.of<PhotoboothProvider>(context, listen: false);
      final capturedImagePath = provider.capturedImage;

      if (capturedImagePath == null) {
        throw Exception('No captured image found');
      }

      // TODO: Implement API call to face swap service
      // const apiUrl = 'YOUR_FACE_SWAP_API_URL';
      // final response = await processFaceSwap(capturedImagePath, provider.selectedCharacter);
      // provider.setSwappedImage(response.imageUrl);

      // Temporary mock delay
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _isLoading = false);
    } on Exception {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to process image';
      });
    }
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
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.goldenYellow,
                ),
              )
            : _errorMessage != null
                ? _buildErrorWidget()
                : _buildResultWidget(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _errorMessage!,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Provider.of<PhotoboothProvider>(context, listen: false).reset();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldenYellow,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultWidget() {
    return Consumer<PhotoboothProvider>(
      builder: (context, provider, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 400,
              height: 500,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.goldenYellow,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(17),
                child: Image.file(
                  File(provider.capturedImage!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (provider.swappedImageUrl != null)
              QrImageView(
                data: provider.swappedImageUrl!,
                size: 150,
                backgroundColor: AppColors.white,
              ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                provider.reset();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldenYellow,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              child: const Text(
                'START OVER',
                style: TextStyle(
                  fontSize: 24,
                  color: AppColors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
