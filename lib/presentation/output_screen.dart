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
    // This preview doesn't need to be flow-aware, it's just a placeholder
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
        Center(
          child: Container(
            width: settings.swaplabImageWidth,
            height: settings.swaplabImageHeight,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(settings.imageBorderRadius),
              border: Border.all(
                color: settings.imageBorderColor,
                width: settings.imageBorderWidth,
              ),
            ),
            child: Image.asset(
              "assets/images/swap.png",
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          left: settings.buttonLeft,
          bottom: settings.buttonBottom,
          child: settings.useImageButton
              ? _buildImageButton(settings)
              : _buildTextButton(settings),
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
                context, Provider.of<OutputScreenProvider>(context));
  }

  Widget _buildSuccessContent(
      BuildContext context, OutputScreenProvider settings) {
    final photoboothProvider = context.read<PhotoboothProvider>();
    // Determine which flow is active to apply the correct layout
    final isSwaplabFlow = photoboothProvider.selectedTheme != null;

    // final double imageWidth =
    //     isSwaplabFlow ? settings.swaplabImageWidth : settings.imageWidth;
    // final double imageHeight =
    //     isSwaplabFlow ? settings.swaplabImageHeight : settings.imageHeight;

    return Stack(
      alignment: Alignment.center,
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
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 100),
          width: isSwaplabFlow ? 700 : 900,
          // height: 1000,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(settings.imageBorderRadius),
            border: Border.all(
              color: settings.imageBorderColor,
              width: settings.imageBorderWidth,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              _buildOutputImage(),
              Positioned(
                top: 10,
                right: 10,
                child: Image.asset(
                  'assets/images/cft_logo.png',
                  width: 120,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: settings.buttonLeft,
          bottom: isSwaplabFlow ? 100 : 350,
          child: Column(
            children: [
              const Text(
                textAlign: TextAlign.center,
                "Thanks for participating.\nYour image will be sent via email.",
                style: TextStyle(
                    height: 1.4,
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: AppColors.white),
              ),
              // Constants.h32,
              settings.useImageButton
                  ? _buildImageButton(settings)
                  : _buildTextButton(settings),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextButton(OutputScreenProvider settings) {
    return ElevatedButton(
      onPressed: () {
        Provider.of<PhotoboothProvider>(context, listen: false).clearUserData();
        Navigator.of(context).pushReplacementNamed('/');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: settings.buttonColor,
        foregroundColor: settings.buttonTextColor,
        minimumSize: Size(settings.buttonWidth, settings.buttonHeight),
        padding: EdgeInsets.symmetric(
          horizontal: settings.buttonPaddingHorizontal,
          vertical: settings.buttonPaddingVertical,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(settings.buttonBorderRadius),
        ),
        textStyle: TextStyle(
          fontSize: settings.buttonFontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: Text(settings.buttonText),
    );
  }

  Widget _buildImageButton(OutputScreenProvider settings) {
    if (settings.buttonImagePath == null) {
      return _buildTextButton(settings);
    }
    return GestureDetector(
      onTap: () {
        Provider.of<PhotoboothProvider>(context, listen: false).clearUserData();
        Navigator.of(context).pushReplacementNamed('/');
      },
      child: Container(
        width: 370,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(settings.buttonBorderRadius),
          image: DecorationImage(
            image: settings.isButtonImageAsset
                ? AssetImage(settings.buttonImagePath!)
                : FileImage(File(settings.buttonImagePath!)) as ImageProvider,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildOutputImage() {
    final provider = Provider.of<PhotoboothProvider>(context, listen: false);
    final globalSettings =
        Provider.of<GlobalSettingsProvider>(context, listen: false);

    final imageUrl = provider.swappedImageUrl ?? provider.capturedImageUrl;
    debugPrint('Attempting to load image from URL: $imageUrl');

    if (imageUrl != null) {
      if (globalSettings.isOfflineMode && !imageUrl.startsWith('http')) {
        return Image.file(
          File.fromUri(Uri.file(imageUrl)),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading local image: $error');
            return const Center(
                child: Text('Error loading image',
                    style: TextStyle(color: Colors.red)));
          },
        );
      } else {
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading image: $error');
            return const Center(
                child: Text('Error loading image',
                    style: TextStyle(color: Colors.red)));
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

  ImageProvider _getBackgroundImage(
      OutputScreenProvider settings, GlobalSettingsProvider globalSettings) {
    if (settings.showBackground && settings.backgroundImagePath != null) {
      if (settings.isBackgroundImageAsset) {
        return AssetImage(settings.backgroundImagePath!);
      } else {
        return FileImage(File(settings.backgroundImagePath!));
      }
    }

    if (globalSettings.backgroundImage != null) {
      if (globalSettings.isAssetImage) {
        return AssetImage(globalSettings.backgroundImage!);
      } else {
        return FileImage(File(globalSettings.backgroundImage!));
      }
    }
    return const AssetImage('assets/images/common_bg.png');
  }
}
