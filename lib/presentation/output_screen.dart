import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/providers/app_provider.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/providers/output_screen_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../routes/routes.dart';

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
      final capturedImagePath = provider.faceImagePath;

      if (capturedImagePath == null) {
        throw Exception('No captured image found');
      }

      // TODO: Implement API call to face swap service
      // const apiUrl = 'YOUR_FACE_SWAP_API_URL';
      // final response = await processFaceSwap(capturedImagePath, provider.selectedCharacter);
      // provider.setSwappedImage(response.imageUrl);

      // Temporary mock delay
      await Future.delayed(const Duration(seconds: 2));

      // Set a dummy swapped image URL if not set
      if (provider.swappedImageUrl == null) {
        provider.setSwappedImage('https://example.com/swapped-image.jpg');
      }

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
    final outputSettings = Provider.of<OutputScreenProvider>(context);
    final globalSettings = Provider.of<GlobalSettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.outputScreenSettings),
          icon: const Icon(Icons.star),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: outputSettings.showBackground &&
                  outputSettings.backgroundImagePath != null
              ? DecorationImage(
                  image: outputSettings.isBackgroundImageAsset
                      ? AssetImage(outputSettings.backgroundImagePath!)
                      : FileImage(File(outputSettings.backgroundImagePath!))
                          as ImageProvider,
                  fit: BoxFit.cover,
                )
              : globalSettings.backgroundImage != null
                  ? DecorationImage(
                      image: globalSettings.isAssetImage
                          ? AssetImage(globalSettings.backgroundImage!)
                          : FileImage(File(globalSettings.backgroundImage!))
                              as ImageProvider,
                      fit: BoxFit.cover,
                    )
                  : null,
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.goldenYellow))
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _errorMessage!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 18),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () =>
                              Navigator.of(context).pushReplacementNamed('/'),
                          child: const Text('Start Over'),
                        ),
                      ],
                    ),
                  )
                : _buildSuccessContent(context, outputSettings),
      ),
    );
  }

  Widget _buildSuccessContent(
      BuildContext context, OutputScreenProvider settings) {
    final screenSize = MediaQuery.of(context).size;

    // Use Stack for all layouts to allow for fine-tuning with offsets
    return Stack(
      children: [
        // Title
        if (settings.showTitle)
          Positioned(
            left: screenSize.width / 2 -
                150 +
                settings.titleOffsetX, // Center horizontally by default
            top: 50 + settings.titleOffsetY, // Position from top by default
            child: SizedBox(
              width: 300, // Fixed width for title
              child: Text(
                settings.titleText,
                style: TextStyle(
                  fontSize: settings.titleFontSize,
                  fontWeight: settings.titleFontWeight,
                  color: settings.titleColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

        // Output Image
        Positioned(
          left: screenSize.width / 2 -
              settings.imageWidth / 2 +
              settings.imageOffsetX, // Center horizontally
          top: screenSize.height / 2 -
              settings.imageHeight / 2 +
              settings.imageOffsetY, // Center vertically
          child: Container(
            width: settings.imageWidth,
            height: settings.imageHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(settings.imageBorderRadius),
              border: Border.all(
                color: settings.imageBorderColor,
                width: settings.imageBorderWidth,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildOutputImage(),
          ),
        ),

        // QR Code and Text - Use Align widget for better centering
        Positioned(
          left: 0,
          right: 0,
          bottom: 150 + settings.qrCodeOffsetY,
          child: Container(
            alignment: Alignment.center,
            transform: Matrix4.translationValues(settings.qrCodeOffsetX, 0, 0),
            child: _buildQrCodeWithText(settings),
          ),
        ),

        // Start Over Button
        Positioned(
          left: (screenSize.width / 2) - 100 + settings.buttonOffsetX,
          bottom: 50 + settings.buttonOffsetY,
          child: SizedBox(
            child: Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed('/'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: settings.buttonColor,
                  foregroundColor: settings.buttonTextColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: settings.buttonPaddingHorizontal,
                    vertical: settings.buttonPaddingVertical,
                  ),
                  textStyle: TextStyle(
                    fontSize: settings.buttonFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Text(settings.buttonText),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOutputImage() {
    final provider = Provider.of<PhotoboothProvider>(context);
    final swappedImageUrl = provider.swappedImageUrl;

    if (swappedImageUrl == null) {
      return const Center(
        child: Text(
          'No image available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    // For now, just show a placeholder
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Text('Swapped Image Placeholder'),
      ),
    );

    // TODO: Implement actual image loading
    // return Image.network(
    //   swappedImageUrl,
    //   fit: BoxFit.cover,
    //   loadingBuilder: (context, child, loadingProgress) {
    //     if (loadingProgress == null) return child;
    //     return Center(
    //       child: CircularProgressIndicator(
    //         value: loadingProgress.expectedTotalBytes != null
    //             ? loadingProgress.cumulativeBytesLoaded /
    //                 loadingProgress.expectedTotalBytes!
    //             : null,
    //         color: AppColors.goldenYellow,
    //       ),
    //     );
    //   },
    //   errorBuilder: (context, error, stackTrace) {
    //     return const Center(
    //       child: Text(
    //         'Failed to load image',
    //         style: TextStyle(color: Colors.white),
    //       ),
    //     );
    //   },
    // );
  }

  Widget _buildQrCodeWithText(OutputScreenProvider settings) {
    final qrCode = QrImageView(
      data: 'https://example.com/download-image',
      version: QrVersions.auto,
      size: settings.qrCodeSize,
      backgroundColor: settings.qrCodeBackgroundColor,
      foregroundColor: settings.qrCodeForegroundColor,
    );

    final qrText = Text(
      settings.qrCodeText,
      style: TextStyle(
        fontSize: settings.qrCodeTextFontSize,
        color: settings.qrCodeTextColor,
      ),
      textAlign: TextAlign.center,
    );

    switch (settings.qrCodeLayout) {
      case QrCodeLayout.below:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            qrCode,
            const SizedBox(height: 10),
            qrText,
          ],
        );
      case QrCodeLayout.above:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            qrText,
            const SizedBox(height: 10),
            qrCode,
          ],
        );
      case QrCodeLayout.leftOfQr:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 150,
              child: qrText,
            ),
            const SizedBox(width: 10),
            qrCode,
          ],
        );
      case QrCodeLayout.rightOfQr:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            qrCode,
            const SizedBox(width: 10),
            SizedBox(
              width: 150,
              child: qrText,
            ),
          ],
        );
      case QrCodeLayout.sideBySide:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                qrCode,
                const SizedBox(width: 20),
                SizedBox(
                  width: 150,
                  child: qrText,
                ),
              ],
            ),
          ],
        );
    }
  }
}
