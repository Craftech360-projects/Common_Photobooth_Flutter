import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/providers/admin_watermark_provider.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/providers/output_screen_provider.dart';
import 'package:photobooth_flutter/providers/photobooth_provider.dart';
import 'package:photobooth_flutter/widgets/watermark_overlay.dart';
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

      // If we already have a captured image URL, use it
      if (provider.capturedImageUrl != null) {
        setState(() => _isLoading = false);
        return;
      }

      // Otherwise, this is a fallback for testing
      setState(() {
        _isLoading = false;
        _errorMessage = 'No image URL available';
      });
    } on Exception catch (e) {
      debugPrint('Error processing image: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to process image: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final outputSettings = Provider.of<OutputScreenProvider>(context);
    final globalSettings = Provider.of<GlobalSettingsProvider>(context);
    final watermarkProvider = context.watch<AdminWatermarkProvider>();
    return Scaffold(
      // appBar: AppBar(
      //   leading: IconButton(
      //     onPressed: () =>
      //         Navigator.pushNamed(context, AppRoutes.outputScreenSettings),
      //     icon: const Icon(Icons.star),
      //   ),
      // ),
      body: WatermarkOverlay(
        show: watermarkProvider.showWatermark,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: _getBackgroundImage(outputSettings, globalSettings),
              fit: BoxFit.cover,
            ),
          ),
          child: _isLoading
              ? const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.goldenYellow))
              : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                                color: AppColors.red, fontSize: 18),
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
    final provider = Provider.of<PhotoboothProvider>(context, listen: false);

    // First try to use swappedImageUrl, then fall back to capturedImageUrl if needed
    final imageUrl = provider.swappedImageUrl;
    debugPrint('Attempting to load image from URL: $imageUrl');

    if (imageUrl != null) {
      return Image.network(
        imageUrl,
        fit: BoxFit.fill,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          debugPrint(
              'Loading progress: ${loadingProgress.cumulativeBytesLoaded}/${loadingProgress.expectedTotalBytes}');
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading image: $error');
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, color: AppColors.red, size: 50),
              const SizedBox(height: 10),
              Text('Error: $error',
                  style: const TextStyle(color: Colors.white)),
            ],
          );
        },
      );
    } else {
      return const Center(
        child:
            Text('No image available', style: TextStyle(color: Colors.white)),
      );
    }
  }

  Widget _buildQrCodeWithText(OutputScreenProvider settings) {
    final provider = Provider.of<PhotoboothProvider>(context);
    final swappedImage = provider.swappedImageUrl;

    final qrCode = QrImageView(
      data: swappedImage ?? 'https://example.com/download-image',
      version: QrVersions.auto,
      size: settings.qrCodeSize,
      backgroundColor: settings.qrCodeBackgroundColor,
      eyeStyle: QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: settings.qrCodeForegroundColor,
      ),
      dataModuleStyle: QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: settings.qrCodeForegroundColor,
      ),
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

  ImageProvider _getBackgroundImage(
      OutputScreenProvider settings, GlobalSettingsProvider globalSettings) {
    // First try to use gender screen specific background
    if (settings.showBackground && settings.backgroundImagePath != null) {
      if (settings.isBackgroundImageAsset) {
        return AssetImage(settings.backgroundImagePath!);
      } else {
        return FileImage(File(settings.backgroundImagePath!));
      }
    }

    // Fall back to global background if available
    if (globalSettings.backgroundImage != null) {
      if (globalSettings.isAssetImage) {
        return AssetImage(globalSettings.backgroundImage!);
      } else {
        return FileImage(File(globalSettings.backgroundImage!));
      }
    }

    // Default background
    return const AssetImage('assets/images/background.jpg');
  }
}
