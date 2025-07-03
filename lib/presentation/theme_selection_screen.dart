import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/providers/photobooth_provider.dart';
import 'package:photobooth_flutter/providers/theme_selection_provider.dart'
    as theme_provider;
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:provider/provider.dart';

class ThemeSelectionScreen extends StatefulWidget {
  const ThemeSelectionScreen({super.key});

  @override
  State<ThemeSelectionScreen> createState() => _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState extends State<ThemeSelectionScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<theme_provider.ThemeSelectionProvider>();
    final photoboothProvider = context.read<PhotoboothProvider>();
    final globalSettings = context.read<GlobalSettingsProvider>();
    final screenSize = MediaQuery.of(context).size;

    final textScale =
        min(screenSize.width / 1080.0, screenSize.height / 1920.0);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: _getBackgroundImage(settings, globalSettings),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (settings.showTitle)
              Positioned(
                top: settings.titleTop * screenSize.height,
                child: Text(
                  settings.titleText,
                  style: TextStyle(
                    fontSize: settings.titleFontSize * textScale,
                    color: settings.titleColor,
                    fontWeight: settings.titleFontWeight,
                  ),
                ),
              ),
            Positioned(
              top: settings.carouselTop * screenSize.height,
              height: settings.carouselHeight * screenSize.height,
              left: 0,
              right: 0,
              child:
                  _buildThemeCarousel(context, settings, screenSize, textScale),
            ),
            Positioned(
              bottom: settings.buttonBottom * screenSize.height,
              child: _buildSelectButton(
                  context, settings, photoboothProvider, screenSize),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(
                    context, AppRoutes.themeSelectionSettings),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(color: Colors.transparent),
                ),
              ),
            ),
            // Bottom Right Back Button
            Positioned(
              bottom: 30,
              left: 30,
              child: GestureDetector(
                onTap: () {
                  context.read<PhotoboothProvider>().clearTheme();
                  Navigator.pop(context);
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
      ),
    );
  }

  DecorationImage _getBackgroundImage(
      theme_provider.ThemeSelectionProvider settings,
      GlobalSettingsProvider globalSettings) {
    ImageProvider provider;
    String? path;
    bool isAsset = true;

    if (settings.showBackground && settings.backgroundImagePath != null) {
      path = settings.backgroundImagePath;
      isAsset = settings.isBackgroundImageAsset;
    } else if (globalSettings.backgroundImage != null) {
      path = globalSettings.backgroundImage;
      isAsset = globalSettings.isAssetImage;
    }

    if (path != null && path.isNotEmpty) {
      provider = isAsset ? AssetImage(path) : FileImage(File(path));
    } else {
      provider = const AssetImage('assets/images/common_bg.png');
    }

    return DecorationImage(image: provider, fit: BoxFit.cover);
  }

  // lib/presentation/theme_selection_screen.dart

  Widget _buildThemeCarousel(
      BuildContext context,
      theme_provider.ThemeSelectionProvider settings,
      Size screenSize,
      double textScale) {
    final themes = settings.themes;
    final orderedStackChildren = <Widget>[];
    final count = themes.length;
    final paintOrder = List.generate(count, (i) => (count - 1 - i));

    for (var z in paintOrder) {
      final cardIndex = (_currentIndex + z) % count;
      final theme = themes[cardIndex];
      final displayIndex = z;
      double scale = 1.0, yOffset = 0, xOffset = 0;

      switch (displayIndex) {
        case 0:
          scale = 1.05;
          yOffset = 0;
          xOffset = 0;
          break;
        case 1:
          scale = settings.card1Scale;
          yOffset = settings.card1YOffset;
          xOffset = settings.card1XOffset;
          break;
        case 2:
          scale = settings.card2Scale;
          yOffset = settings.card2YOffset;
          xOffset = settings.card2XOffset;
          break;
        default:
          scale = 0.8;
          yOffset = 60;
      }

      orderedStackChildren.add(
        AnimatedContainer(
          key: ValueKey(theme.name),
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          transform: Matrix4.identity()
            ..translate(xOffset, yOffset)
            ..scale(scale),
          child: _buildThemeCard(
              textScale: textScale,
              screenSize: screenSize,
              theme: theme,
              isSelected: displayIndex == 0,
              onTap: () => setState(
                    () => _currentIndex = cardIndex,
                  ),
              settings: settings),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          icon: Image.asset('assets/images/backward_arrow.png',
              width: 50, height: 50),
          onPressed: () => setState(() => _currentIndex =
              (_currentIndex - 1 + themes.length) % themes.length),
        ),
        SizedBox(width: settings.arrowSpacing * screenSize.width),
        SizedBox(
            width: settings.cardWidth * screenSize.width * 1.8,
            height: settings.carouselHeight * screenSize.height,
            child: Stack(
                alignment: Alignment.center, children: orderedStackChildren)),
        SizedBox(width: settings.arrowSpacing * screenSize.width),
        IconButton(
          icon: Image.asset('assets/images/forward_arrow.png',
              width: 50, height: 50),
          onPressed: () => setState(
              () => _currentIndex = (_currentIndex + 1) % themes.length),
        ),
      ],
    );
  }

  Widget _buildThemeCard({
    required theme_provider.Theme theme,
    required bool isSelected,
    required VoidCallback onTap,
    required theme_provider.ThemeSelectionProvider settings,
    required Size screenSize,
    required double textScale,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        // FIX: Multiply by screen dimensions to get the correct pixel size
        width: settings.cardWidth * screenSize.width,
        height: settings.cardHeight * screenSize.height,
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(settings.cardBorderRadius * textScale),
          image: DecorationImage(
              image: AssetImage(theme.imagePath), fit: BoxFit.contain),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.goldenYellow.withOpacity(0.6),
                    blurRadius: 80,
                    spreadRadius: 12,
                  )
                ]
              : [],
        ),
      ),
    );
  }

  Widget _buildSelectButton(
    BuildContext context,
    theme_provider.ThemeSelectionProvider settings,
    PhotoboothProvider photoboothProvider,
    Size screenSize,
  ) {
    onPressed() {
      final selectedTheme = settings.themes[_currentIndex];
      photoboothProvider.setTheme(selectedTheme);
      Navigator.pushNamed(context, AppRoutes.faceCapture);
    }

    if (settings.useImageButton && settings.buttonImagePath != null) {
      return GestureDetector(
        onTap: onPressed,
        child: Image.asset(settings.buttonImagePath!,
            width: settings.buttonWidth * screenSize.width,
            height: settings.buttonHeight * screenSize.height,
            fit: BoxFit.contain),
      );
    } else {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.goldenYellow,
          foregroundColor: AppColors.black,
          minimumSize: Size(settings.buttonWidth * screenSize.width,
              settings.buttonHeight * screenSize.height),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        child: const Text('Select'),
      );
    }
  }
}
