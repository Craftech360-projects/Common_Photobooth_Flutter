import 'dart:io';

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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          toolbarHeight: 70,
          leadingWidth: 170,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            // Add padding here for horizontal and vertical spacing
            padding: const EdgeInsets.only(left: 0.0, top: 20.0, bottom: 0.0),
            onPressed: () {
              // Clear selected theme when going back
              context.read<PhotoboothProvider>().clearTheme();
              Navigator.pop(context);
            },
            icon: Image.asset(
              'assets/images/back_btn.png',
            ),
            iconSize: 180,
          )),
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
                top: settings.titleTop,
                child: Text(
                  settings.titleText,
                  style: TextStyle(
                    fontSize: settings.titleFontSize,
                    color: settings.titleColor,
                    fontWeight: settings.titleFontWeight,
                  ),
                ),
              ),
            Positioned(
              top: settings.carouselTop,
              height: settings.carouselHeight,
              left: 0,
              right: 0,
              child: _buildThemeCarousel(context, settings),
            ),
            Positioned(
              bottom: settings.buttonBottom,
              child: _buildSelectButton(context, settings, photoboothProvider),
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

  Widget _buildThemeCarousel(
      BuildContext context, theme_provider.ThemeSelectionProvider settings) {
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
          scale = 1.0;
          yOffset = 0;
          xOffset = 0;
          break;
        case 1:
          scale = 0.9;
          yOffset = 30;
          xOffset = -100;
          break;
        case 2:
          scale = 0.9;
          yOffset = 30;
          xOffset = 150;
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
              theme: theme,
              isSelected: displayIndex == 0,
              onTap: () => setState(() => _currentIndex = cardIndex),
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
        const SizedBox(width: 150),
        SizedBox(
            width: 500,
            height: settings.carouselHeight,
            child: Stack(
                alignment: Alignment.center, children: orderedStackChildren)),
        const SizedBox(width: 150),
        IconButton(
          icon: Image.asset('assets/images/forward_arrow.png',
              width: 50, height: 50),
          onPressed: () => setState(
              () => _currentIndex = (_currentIndex + 1) % themes.length),
        ),
      ],
    );
  }

  Widget _buildThemeCard(
      {required theme_provider.Theme theme,
      required bool isSelected,
      required VoidCallback onTap,
      required theme_provider.ThemeSelectionProvider settings}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: settings.cardWidth,
        height: settings.cardHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(settings.cardBorderRadius),
          image: DecorationImage(
              image: AssetImage(theme.imagePath), fit: BoxFit.contain),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.goldenYellow.withValues(alpha: 0.6),
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
      PhotoboothProvider photoboothProvider) {
    onPressed() {
      final selectedTheme = settings.themes[_currentIndex];
      photoboothProvider.setTheme(selectedTheme);
      Navigator.pushNamed(context, AppRoutes.faceCapture);
    }

    if (settings.useImageButton && settings.buttonImagePath != null) {
      return GestureDetector(
        onTap: onPressed,
        child: Image.asset(settings.buttonImagePath!,
            width: settings.buttonWidth,
            height: settings.buttonHeight,
            fit: BoxFit.contain),
      );
    } else {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.goldenYellow,
          foregroundColor: AppColors.black,
          minimumSize: Size(settings.buttonWidth, settings.buttonHeight),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        child: const Text('Select'),
      );
    }
  }
}
