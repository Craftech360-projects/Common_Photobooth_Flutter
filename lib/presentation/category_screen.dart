import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photobooth_flutter/providers/category_provider.dart';
import 'package:photobooth_flutter/providers/category_settings_provider.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:provider/provider.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  bool _showSubCategories = false;
  int _currentSubCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<CategorySettingsProvider>();
    final globalSettings = context.watch<GlobalSettingsProvider>();
    final flowProvider = context.read<CategoryProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      //IF NEEDED ADD THIS
      appBar: AppBar(
        title: Text(
          settingsProvider.showTitle ? settingsProvider.titleText : '',
          style: TextStyle(
            color: settingsProvider.titleColor,
            fontSize: settingsProvider.titleFontSize,
            fontWeight: settingsProvider.titleFontWeight,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _showSubCategories
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () {
                  setState(() {
                    _showSubCategories = false;
                    _currentSubCategoryIndex = 0;
                    flowProvider.resetSelection();
                  });
                },
              )
            : null,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: _getBackgroundImage(settingsProvider, globalSettings),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _showSubCategories
                ? _buildSubCategoryView(context)
                : _buildMainCategoryView(context),
          ),
        ),
      ),
    );
  }

  DecorationImage _getBackgroundImage(CategorySettingsProvider settings,
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

    return DecorationImage(
      image: provider,
      fit: BoxFit.cover,
    );
  }

  Widget _buildMainCategoryView(BuildContext context) {
    final settingsProvider = context.read<CategorySettingsProvider>();
    final flowProvider = context.read<CategoryProvider>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCategoryCard(
          settings: settingsProvider.aiArtistryCard,
          onTap: () {
            flowProvider.selectMainCategory(MainCategory.aIArtistry);
            setState(() => _showSubCategories = true);
          },
        ),
        const SizedBox(width: 40),
        _buildCategoryCard(
          settings: settingsProvider.swaplabCard,
          onTap: () {
            flowProvider.selectMainCategory(MainCategory.swaplab);
            Navigator.pushNamed(context, AppRoutes.themeSelection);
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required CategoryCardSettings settings,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: settings.width,
        height: settings.height,
        decoration: BoxDecoration(
          border: settings.showBorder
              ? Border.all(
                  color: isSelected ? settings.borderColor : Colors.transparent,
                  width: settings.borderWidth,
                )
              : null,
          image: DecorationImage(
            image: settings.isAsset
                ? AssetImage(settings.imagePath)
                : FileImage(File(settings.imagePath)) as ImageProvider,
            fit: BoxFit.contain,
          ),
          boxShadow: isSelected && settings.useGlow
              ? [
                  BoxShadow(
                    color:
                        settings.glowColor.withOpacity(settings.glowIntensity),
                    blurRadius: settings.glowSpread,
                    spreadRadius: settings.glowSpread / 2,
                  )
                ]
              : [],
        ),
      ),
    );
  }

  Widget _buildSubCategoryView(BuildContext context) {
    final settingsProvider = context.watch<CategorySettingsProvider>();
    final flowProvider = context.read<CategoryProvider>();
    final subCategories = [
      {
        'key': 'ghibli',
        'settings': settingsProvider.ghibliCard,
        'workflow': 'ghibli.json'
      },
      {
        'key': 'pixar',
        'settings': settingsProvider.pixarCard,
        'workflow': 'pixar.json'
      },
      {
        'key': 'packaging',
        'settings': settingsProvider.packagingCard,
        'workflow': 'packaging.json'
      },
    ];

    // This list will hold the cards in the correct paint order (back to front)
    final List<Widget> orderedStackChildren = [];
    final int count = subCategories.length;

    // Define the paint order, from back-most to front-most
    // For 3 cards, the order is [2, 1, 0] where 0 is the front card's displayIndex
    final paintOrder = List.generate(count, (i) => (count - 1 - i));

    for (var z in paintOrder) {
      // Find the original card that corresponds to this position in the stack
      final cardIndex = (_currentSubCategoryIndex + z) % count;
      final card = subCategories[cardIndex];
      final settings = card['settings'] as CategoryCardSettings;

      final int displayIndex =
          z; // The display index is its position in the paint order

      double scale = 1.0;
      double yOffset = 0;
      double xOffset = 0;

      switch (displayIndex) {
        case 0: // Front card
          scale = 1.0;
          yOffset = 0;
          xOffset = 0;
          break;
        case 1: // Card peeking from left
          scale = 0.9;
          yOffset = 30;
          xOffset = -120;
          break;
        case 2: // Card peeking from right
          scale = 0.9;
          yOffset = 30;
          xOffset = 120;
          break;
        default: // Other cards hidden behind
          scale = 0.8;
          yOffset = 60;
      }

      orderedStackChildren.add(
        AnimatedContainer(
          key: ValueKey(card['key']),
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          transform: Matrix4.identity()
            ..translate(xOffset, yOffset)
            ..scale(scale),
          child: _buildCategoryCard(
            settings: settings,
            isSelected: displayIndex == 0,
            onTap: () {
              if (displayIndex == 0) {
                flowProvider.selectWorkflow(card['workflow'] as String);
                Navigator.pushNamed(context, AppRoutes.faceCapture);
              }
            },
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Arrow
        IconButton(
          icon: Image.asset('assets/images/backward_arrow.png',
              width: 50, height: 50),
          onPressed: () {
            setState(() {
              _currentSubCategoryIndex =
                  (_currentSubCategoryIndex + 1) % subCategories.length;
            });
          },
        ),
        const SizedBox(width: 120), // Increased spacing

        // Card Stack
        SizedBox(
          width: 500,
          height: 600,
          child: Stack(
            alignment: Alignment.center,
            children: orderedStackChildren,
          ),
        ),
        const SizedBox(width: 120), // Increased spacing

        // Right Arrow
        IconButton(
          icon: Image.asset('assets/images/forward_arrow.png',
              width: 50, height: 50),
          onPressed: () {
            setState(() {
              _currentSubCategoryIndex =
                  (_currentSubCategoryIndex - 1 + subCategories.length) %
                      subCategories.length;
            });
          },
        ),
      ],
    );
  }
}
