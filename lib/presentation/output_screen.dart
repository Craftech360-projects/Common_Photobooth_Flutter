// lib/presentation/output_screen.dart

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
  final bool isPreviewMode;
  const SwappedFaceScreen({super.key, this.isPreviewMode = false});

  @override
  State<SwappedFaceScreen> createState() => _SwappedFaceScreenState();
}

class _SwappedFaceScreenState extends State<SwappedFaceScreen> {
  // ... (initState and _processImage methods remain the same)
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
      if (provider.capturedImageUrl != null) {
        setState(() => _isLoading = false);
        return;
      }
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
    final outputSettings = context.watch<OutputScreenProvider>();
    final globalSettings = context.watch<GlobalSettingsProvider>();
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
    // This preview can be simplified as it's just for layout guidance
    return Stack(
      children: [
        if (settings.showTitle)
          Positioned(
            left: settings.titleLeft,
            top: settings.titleTop,
            width: settings.titleWidth,
            child: Text(
              settings.titleText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: settings.titleFontSize,
                color: settings.titleColor,
                fontWeight: settings.titleFontWeight,
              ),
            ),
          ),
        Positioned(
          left: settings.swaplabLeft,
          top: settings.swaplabTop,
          child: Container(
            width: settings.swaplabImageWidth,
            height: settings.swaplabImageHeight,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              border: Border.all(color: Colors.grey.shade600),
            ),
            child: const Center(child: Text('Swaplab Image')),
          ),
        ),
        Positioned(
          left: settings.aiArtistryLeft,
          top: settings.aiArtistryTop,
          child: Container(
            width: 400, // Example fixed size for preview
            height: 400,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              border: Border.all(color: Colors.grey.shade600),
            ),
            child: const Center(child: Text('AI Artistry Image')),
          ),
        ),
        Positioned(
          left: settings.qrCodeLeft,
          bottom: settings.qrCodeBottom,
          child: QrImageView(
              data: 'PREVIEW',
              size: settings.qrCodeSize,
              backgroundColor: Colors.white),
        ),
        // Preview for Done Button
        Positioned(
          left: settings.doneButtonLeft,
          bottom: settings.doneButtonBottom,
          child: _buildButton(
            isDone: true,
            settings: settings,
            onPressed: () {},
          ),
        ),
        // Preview for Download Button
        Positioned(
          left: settings.downloadButtonLeft,
          bottom: settings.downloadButtonBottom,
          child: _buildButton(
            isDone: false,
            settings: settings,
            onPressed: () {},
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
            ? Center(
                child: Text(_errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 18)))
            : _buildSuccessContent(
                context, context.watch<OutputScreenProvider>());
  }

  Widget _buildSuccessContent(
      BuildContext context, OutputScreenProvider settings) {
    final photoboothProvider = context.read<PhotoboothProvider>();
    final globalSettings = context.read<GlobalSettingsProvider>();

    final isSwaplabFlow = photoboothProvider.selectedTheme != null;
    final imageUrl = photoboothProvider.swappedImageUrl ??
        photoboothProvider.capturedImageUrl;

    return Stack(
      children: [
        if (settings.showTitle)
          Positioned(
            left: settings.titleLeft,
            top: settings.titleTop,
            width: settings.titleWidth,
            child: Text(
              settings.titleText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: settings.titleFontSize,
                fontWeight: settings.titleFontWeight,
                color: settings.titleColor,
              ),
            ),
          ),
        Positioned(
          left: isSwaplabFlow ? settings.swaplabLeft : settings.aiArtistryLeft,
          top: isSwaplabFlow ? settings.swaplabTop : settings.aiArtistryTop,
          width: isSwaplabFlow ? settings.swaplabImageWidth : null,
          height: isSwaplabFlow ? settings.swaplabImageHeight : null,
          child: _buildOutputImage(imageUrl),
        ),
        if (globalSettings.sharingMethod == 'QR Code')
          Positioned(
            left: settings.qrCodeLeft,
            bottom: settings.qrCodeBottom,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: QrImageView(
                data: imageUrl ?? 'No Image',
                version: QrVersions.auto,
                size: settings.qrCodeSize,
              ),
            ),
          )
        else
          Positioned(
            left: settings.qrCodeLeft,
            right: settings.qrCodeLeft,
            bottom: settings.qrCodeBottom,
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 200),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Your generated image has been sent to\n${photoboothProvider.email}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        Positioned(
          left: settings.doneButtonLeft,
          bottom: settings.doneButtonBottom,
          child: _buildButton(
            isDone: true,
            settings: settings,
            onPressed: () {
              Provider.of<PhotoboothProvider>(context, listen: false)
                  .clearUserData();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/', (route) => false);
            },
          ),
        ),
        Positioned(
          left: settings.downloadButtonLeft,
          bottom: settings.downloadButtonBottom,
          child: _buildButton(
            isDone: false,
            settings: settings,
            onPressed: () {
              // TODO: Implement Download Logic
            },
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required bool isDone,
    required OutputScreenProvider settings,
    required VoidCallback onPressed,
  }) {
    final useImage =
        isDone ? settings.useDoneButtonImage : settings.useDownloadButtonImage;
    final imagePath = isDone
        ? settings.doneButtonImagePath
        : settings.downloadButtonImagePath;
    final isAsset = isDone
        ? settings.isDoneButtonImageAsset
        : settings.isDownloadButtonImageAsset;
    final text = isDone ? settings.doneButtonText : settings.downloadButtonText;
    final width =
        isDone ? settings.doneButtonWidth : settings.downloadButtonWidth;
    final height =
        isDone ? settings.doneButtonHeight : settings.downloadButtonHeight;

    if (useImage && imagePath != null) {
      return GestureDetector(
        onTap: onPressed,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: isAsset
                  ? AssetImage(imagePath)
                  : FileImage(File(imagePath)) as ImageProvider,
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
    }

    // Fallback to text button
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(width, height),
        // Add more styling from provider if needed for text buttons
      ),
      child: Text(text),
    );
  }

  Widget _buildOutputImage(String? imageUrl) {
    if (imageUrl == null) {
      return const Center(
          child: Text('No image available',
              style: TextStyle(color: Colors.white)));
    }
    if (!imageUrl.startsWith('http')) {
      return Image.file(File.fromUri(Uri.file(imageUrl)), fit: BoxFit.cover);
    } else {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : const Center(child: CircularProgressIndicator()),
        errorBuilder: (context, error, stack) => const Center(
            child: Text('Error loading image',
                style: TextStyle(color: Colors.red))),
      );
    }
  }

  ImageProvider _getBackgroundImage(
      OutputScreenProvider settings, GlobalSettingsProvider globalSettings) {
    String? path = settings.showBackground
        ? settings.backgroundImagePath
        : globalSettings.backgroundImage;
    bool isAsset = settings.showBackground
        ? settings.isBackgroundImageAsset
        : globalSettings.isAssetImage;

    if (path != null) {
      return isAsset
          ? AssetImage(path)
          : FileImage(File(path)) as ImageProvider;
    }

    return const AssetImage('assets/images/common_bg.png');
  }
}
