import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/constants/constants.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/providers/admin_watermark_provider.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/providers/output_screen_provider.dart';
import 'package:photobooth_flutter/providers/photobooth_provider.dart';
import 'package:photobooth_flutter/widgets/watermark_overlay.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SwappedFaceScreen extends StatefulWidget {
  final bool isPreviewMode;

  const SwappedFaceScreen({
    super.key,
    this.isPreviewMode = false,
  });

  @override
  State<SwappedFaceScreen> createState() => _SwappedFaceScreenState();
}

class _SwappedFaceScreenState extends State<SwappedFaceScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (!widget.isPreviewMode) {
      _processImage();
    } else {
      setState(() => _isLoading = false);
    }
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
          child: widget.isPreviewMode
              ? _buildPreviewContent(outputSettings)
              : _buildMainContent(),
        ),
      ),
    );
  }

  Widget _buildPreviewContent(OutputScreenProvider settings) {
    return Stack(
      children: [
        if (settings.showTitle)
          Positioned(
            left: settings.titleLeft,
            top: settings.titleTop,
            width: settings.titleWidth,
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
        Positioned(
          left: settings.imageLeft,
          top: settings.imageTop,
          child: Container(
            width: settings.imageWidth,
            height: settings.imageHeight,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(settings.imageBorderRadius),
              border: Border.all(
                color: settings.imageBorderColor,
                width: settings.imageBorderWidth,
              ),
            ),
            child: const Center(
              child: Icon(Icons.image, size: 48, color: AppColors.grey),
            ),
          ),
        ),
        // QR code placeholder
        Positioned(
            left: settings.qrCodeLeft,
            bottom: settings.qrCodeBottom,
            child: _buildQrCodeWithText(settings)),
        // Button placeholder
        Positioned(
          left: settings.buttonLeft,
          bottom: settings.buttonBottom,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(settings.buttonBorderRadius),
              ),
              backgroundColor: settings.buttonColor,
              foregroundColor: settings.buttonTextColor,
              padding: EdgeInsets.symmetric(
                horizontal: settings.buttonPaddingHorizontal,
                vertical: settings.buttonPaddingVertical,
              ),
            ),
            child: Text(
              settings.buttonText,
              style: TextStyle(fontSize: settings.buttonFontSize),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(color: AppColors.goldenYellow))
        : _errorMessage != null
            ? const Center(/* existing error content */)
            : _buildSuccessContent(
                context, Provider.of<OutputScreenProvider>(context));
  }

  Widget _buildSuccessContent(
      BuildContext context, OutputScreenProvider settings) {
    return Stack(
      children: [
        // Title
        if (settings.showTitle)
          Positioned(
            left: settings.titleLeft,
            top: settings.titleTop,
            width: settings.titleWidth,
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

        // Output Image
        Positioned(
          left: settings.imageLeft,
          top: settings.imageTop,
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

        // QR Code and Text
        Positioned(
          left: settings.qrCodeLeft,
          bottom: settings.qrCodeBottom,
          child: _buildQrCodeWithText(settings),
        ),

        // Start Over Button
        Positioned(
          left: settings.buttonLeft,
          bottom: settings.buttonBottom,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
            style: ElevatedButton.styleFrom(
              backgroundColor: settings.buttonColor,
              foregroundColor: settings.buttonTextColor,
              padding: EdgeInsets.symmetric(
                horizontal: settings.buttonPaddingHorizontal,
                vertical: settings.buttonPaddingVertical,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(settings.buttonBorderRadius),
              ),
              textStyle: TextStyle(
                fontSize: settings.buttonFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: Text(settings.buttonText),
          ),
        ),
      ],
    );
  }

  Widget _buildOutputImage() {
    final provider = Provider.of<PhotoboothProvider>(context, listen: false);
    final globalSettings =
        Provider.of<GlobalSettingsProvider>(context, listen: false);

    // First try to use swappedImageUrl, then fall back to capturedImageUrl if needed
    final imageUrl = provider.swappedImageUrl;
    debugPrint('Attempting to load image from URL: $imageUrl');

    if (imageUrl != null) {
      // Check if we're in offline mode and if the image is a local file path
      if (globalSettings.isOfflineMode && !imageUrl.startsWith('http')) {
        // Display local file image
        return Image.file(
          File(imageUrl),
          fit: BoxFit.fill,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading local image: $error');
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error, color: AppColors.red, size: 50),
                Constants.h8,
                Text('Error: $error',
                    style: const TextStyle(color: AppColors.white)),
              ],
            );
          },
        );
      } else {
        // Display online image from URL
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
                Constants.h8,
                Text('Error: $error',
                    style: const TextStyle(color: AppColors.white)),
              ],
            );
          },
        );
      }
    } else {
      return const Center(
        child: Text('No image available',
            style: TextStyle(color: AppColors.white)),
      );
    }
  }

  Widget _buildQrCodeWithText(OutputScreenProvider settings) {
    final provider = Provider.of<PhotoboothProvider>(context);
    final globalSettings = Provider.of<GlobalSettingsProvider>(context);
    final swappedImage = provider.swappedImageUrl;

    // For QR code data, use the image URL directly for online mode
    // For offline mode, use a placeholder or local file path
    final qrData = globalSettings.isOfflineMode
        ? 'Image saved locally at: ${swappedImage ?? "unknown location"}'
        : swappedImage ?? 'https://example.com/download-image';

    final qrCode = QrImageView(
      data: qrData,
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

    // Adjust QR code text based on mode
    final qrText = Text(
      globalSettings.isOfflineMode
          ? 'Image saved locally'
          : settings.qrCodeText,
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
            Constants.h8,
            qrText,
          ],
        );
      case QrCodeLayout.above:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            qrText,
            Constants.h8,
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
