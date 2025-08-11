
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/providers/admin_watermark_provider.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/providers/output_screen_provider.dart';
import 'package:photobooth_flutter/providers/photobooth_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:photobooth_flutter/services/license_service.dart';
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
  @override
  void initState() {
    super.initState();
    if (!widget.isPreviewMode) {
      _processImage();
      _checkCreditsAndShowWatermark();
    }
  }

  Future<void> _checkCreditsAndShowWatermark() async {
    final watermarkProvider =
        Provider.of<AdminWatermarkProvider>(context, listen: false);

    // Check current credits
    final creditsLeft = await LicenseService.instance.getCreditsLeft();
    if (creditsLeft != null && creditsLeft <= 0) {
      watermarkProvider.setShowWatermark(true);
    }
  }

  Future<void> _processImage() async {
    try {
      final provider = Provider.of<PhotoboothProvider>(context, listen: false);
      if (provider.capturedImageUrl == null) {
        debugPrint('No image URL available');
      }
    } on Exception catch (e) {
      debugPrint('Error processing image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final outputSettings = context.watch<OutputScreenProvider>();
    final globalSettings = context.watch<GlobalSettingsProvider>();
    final watermarkProvider = context.watch<AdminWatermarkProvider>();
    final photoboothProvider = context.watch<PhotoboothProvider>();

    // In preview mode, use a placeholder image if no real image is available
    final displayImageUrl = widget.isPreviewMode
        ? (photoboothProvider.swappedImageUrl ?? 'assets/images/swap.png')
        : (photoboothProvider.swappedImageUrl ??
            photoboothProvider.capturedImageUrl);

    final isPlaceholder = displayImageUrl?.startsWith('assets/') ?? true;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded,
                color: Colors.transparent, size: 32),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.outputScreenSettings),
          ),
        ],
      ),
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
          child: _buildMainContent(
              outputSettings,
              displayImageUrl,
              isPlaceholder,
              globalSettings.sharingMethod,
              photoboothProvider.email),
        ),
      ),
    );
  }

  Widget _buildMainContent(OutputScreenProvider settings, String? imageUrl,
      bool isPlaceholder, String sharingMethod, String? email) {
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        if (settings.showTitle)
          Positioned(
            top: settings.titleTop * screenSize.height,
            left: (screenSize.width * (1 - settings.titleWidth)) / 2,
            width: settings.titleWidth * screenSize.width,
            child: Text(
              settings.titleText,
              textAlign: settings.titleAlignment,
              style: TextStyle(
                fontSize: settings.titleFontSize,
                fontWeight: settings.titleFontWeight,
                color: settings.titleColor
                    .withValues(alpha: settings.titleOpacity),
                fontStyle: settings.isTitleItalic
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
          ),

        // Unified Image Position
        Positioned(
          top: settings.imageTop * screenSize.height,
          left: settings.imageLeft * screenSize.width,
          width: settings.imageWidth * screenSize.width,
          height: settings.imageHeight * screenSize.height,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(settings.imageBorderRadius),
              border: settings.showImageBorder
                  ? Border.all(
                      color: settings.imageBorderColor,
                      width: settings.imageBorderWidth)
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(settings.imageBorderRadius),
              child: _buildOutputImage(imageUrl, isPlaceholder),
            ),
          ),
        ),

        // QR Code Section or Email Info
        if (sharingMethod == 'QR Code')
          Positioned(
            left: settings.qrCodeSectionLeft * screenSize.width,
            bottom: settings.qrCodeSectionBottom * screenSize.height,
            child: _buildQrCodeSection(settings, imageUrl),
          )
        else
          Positioned(
            // Email Info
            left: 0, right: 0,
            bottom: settings.qrCodeSectionBottom * screenSize.height,
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(horizontal: screenSize.width * 0.1),
              decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12)),
              child: Text(
                widget.isPreviewMode
                    ? 'Your image will be sent via email.'
                    : 'Your generated image has been sent to\n$email',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),

        // Done Button
        Positioned(
          left: settings.doneButtonLeft * screenSize.width,
          bottom: settings.doneButtonBottom * screenSize.height,
          child: _buildButton(
              settings: settings,
              onPressed: () {
                Provider.of<PhotoboothProvider>(context, listen: false)
                    .clearUserData();
                Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.welcomeScreen, (route) => false);
              }),
        ),
      ],
    );
  }

  Widget _buildQrCodeSection(OutputScreenProvider settings, String? imageUrl) {
    final qrData =
        widget.isPreviewMode ? 'https://example.com' : (imageUrl ?? 'No Image');
    final qrWidget = QrImageView(
      data: qrData,
      version: QrVersions.auto,
      size: settings.qrCodeSize,
      backgroundColor: AppColors.white,
    );

    if (!settings.showQrCodeText) {
      return qrWidget;
    }

    final textWidget = Container(
      constraints: BoxConstraints(maxWidth: settings.qrLabelWidth),
      child: Text(
        settings.qrCodeText,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: settings.qrCodeTextFontSize,
          fontWeight: settings.qrCodeTextFontWeight,
          color: settings.qrCodeTextColor,
        ),
      ),
    );

    switch (settings.qrCodeLayout) {
      case QrCodeLayout.qrLeftTextRight:
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: settings.qrCodeRowAlignment,
          children: [qrWidget, const SizedBox(width: 16), textWidget],
        );
      case QrCodeLayout.qrRightTextLeft:
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: settings.qrCodeRowAlignment,
          children: [textWidget, const SizedBox(width: 16), qrWidget],
        );
      case QrCodeLayout.qrBottomTextTop:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: settings.qrCodeColumnAlignment,
          children: [textWidget, const SizedBox(height: 8), qrWidget],
        );
      case QrCodeLayout.qrTopTextBottom:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: settings.qrCodeColumnAlignment,
          children: [qrWidget, const SizedBox(height: 8), textWidget],
        );
    }
  }

  Widget _buildButton(
      {required OutputScreenProvider settings,
      required VoidCallback onPressed}) {
    final screenSize = MediaQuery.of(context).size;
    final width = settings.doneButtonWidth * screenSize.width;
    final height = settings.doneButtonHeight * screenSize.height;

    if (settings.useDoneButtonImage && settings.doneButtonImagePath != null) {
      return GestureDetector(
          onTap: onPressed,
          child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: settings.isDoneButtonImageAsset
                          ? AssetImage(settings.doneButtonImagePath!)
                          : NetworkImage(settings.doneButtonImagePath!)
                              as ImageProvider,
                      fit: BoxFit.contain))));
    }
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(minimumSize: Size(width, height)),
        child: Text(settings.doneButtonText));
  }

  Widget _buildOutputImage(String? imageUrl, bool isPlaceholder) {
    if (imageUrl == null) {
      return const Center(
          child: Text('No image available',
              style: TextStyle(color: AppColors.white)));
    }
    if (isPlaceholder) {
      return Image.asset(imageUrl, fit: BoxFit.cover);
    }
    return Image.network(imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : const Center(child: CircularProgressIndicator()),
        errorBuilder: (context, error, stack) => const Center(
            child: Text('Error loading image',
                style: TextStyle(color: Colors.red))));
  }

  ImageProvider _getBackgroundImage(
      OutputScreenProvider settings, GlobalSettingsProvider globalSettings) {
    // ... this method remains the same
    String? path = settings.showBackground
        ? settings.backgroundImagePath
        : globalSettings.backgroundImagePath;
    bool isAsset = settings.showBackground
        ? settings.isBackgroundImageAsset
        : globalSettings.isBackgroundImageAsset;
    if (path != null) {
      return isAsset
          ? AssetImage(path)
          : NetworkImage(path) as ImageProvider;
    }
    return const AssetImage('assets/images/common_bg.png');
  }
}
