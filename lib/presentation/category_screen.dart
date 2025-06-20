import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photobooth_flutter/presentation/theme_selection_screen.dart';
import 'package:photobooth_flutter/providers/category_provider.dart';
import 'package:photobooth_flutter/providers/category_settings_provider.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/providers/photobooth_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:photobooth_flutter/routes/slide_right.dart';
import 'package:photobooth_flutter/widgets/snackbar.dart';
import 'package:provider/provider.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  bool _showSubCategories = false;
  int _currentSubCategoryIndex = 0;
  final TextEditingController _accessoriesController = TextEditingController();
  final FocusNode _accessoriesFocusNode = FocusNode();

  @override
  void dispose() {
    _accessoriesController.dispose();
    _accessoriesFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<CategorySettingsProvider>();
    final globalSettings = context.watch<GlobalSettingsProvider>();
    final flowProvider = context.read<CategoryProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 170,
        leading: _showSubCategories
            ? IconButton(
                padding:
                    const EdgeInsets.only(left: 0.0, top: 20.0, bottom: 0.0),
                onPressed: () {
                  setState(() {
                    _showSubCategories = false;
                    _currentSubCategoryIndex = 0;
                    flowProvider.resetSelection();
                  });
                },
                icon: Image.asset(
                  'assets/images/back_btn.png',
                ),
                iconSize: 180,
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
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (child, animation) {
              final slideAnimation = Tween<Offset>(
                begin: const Offset(0.0, 0.4),
                end: Offset.zero,
              ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut));
              return SlideTransition(
                position: slideAnimation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: _showSubCategories
                ? _buildSubCategoryView(context, key: const ValueKey('SubView'))
                : _buildMainCategoryView(context,
                    key: const ValueKey('MainView')),
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

  Widget _buildMainCategoryView(BuildContext context, {Key? key}) {
    final settingsProvider = context.read<CategorySettingsProvider>();
    final flowProvider = context.read<CategoryProvider>();

    return Row(
      key: key,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TappableCategoryCard(
          settings: settingsProvider.aiArtistryCard,
          provideFeedback: true,
          onTap: () {
            flowProvider.selectMainCategory(MainCategory.aIArtistry);
            setState(() => _showSubCategories = true);
          },
        ),
        const SizedBox(width: 40),
        TappableCategoryCard(
          settings: settingsProvider.swaplabCard,
          provideFeedback: true,
          onTap: () {
            flowProvider.selectMainCategory(MainCategory.swaplab);
            Navigator.push(
              context,
              SlideRightPageRoute(page: const ThemeSelectionScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSubCategoryView(BuildContext context, {Key? key}) {
    final subCategories = [
      {
        'key': 'ghibli',
        'settings': context.read<CategorySettingsProvider>().ghibliCard,
        'workflow': 'ghiblionline.json'
      },
      {
        'key': 'pixar',
        'settings': context.read<CategorySettingsProvider>().pixarCard,
        'workflow': 'pixaronline.json'
      },
      {
        'key': 'packaging',
        'settings': context.read<CategorySettingsProvider>().packagingCard,
        'workflow': 'packagingonline.json'
      },
    ];

    final isPackagingSelected =
        subCategories[_currentSubCategoryIndex]['key'] == 'packaging';

    final List<Widget> orderedStackChildren = [];
    final int count = subCategories.length;
    final paintOrder = List.generate(count, (i) => (count - 1 - i));

    for (var z in paintOrder) {
      final cardIndex = (_currentSubCategoryIndex + z) % count;
      final card = subCategories[cardIndex];
      final settings = card['settings'] as CategoryCardSettings;
      final int displayIndex = z;

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
          xOffset = 140;
          break;
        default:
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
          child: TappableCategoryCard(
            settings: settings,
            isSelected: displayIndex == 0,
            onTap: () {
              if (displayIndex != 0) {
                setState(() => _currentSubCategoryIndex = cardIndex);
              }
            },
          ),
        ),
      );
    }

    return Stack(
      key: key,
      alignment: Alignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: Image.asset('assets/images/backward_arrow.png',
                      width: 50, height: 50),
                  onPressed: () => setState(() => _currentSubCategoryIndex =
                      (_currentSubCategoryIndex + 1) % subCategories.length),
                ),
                const SizedBox(width: 120),
                SizedBox(
                  width: 500,
                  height: 600,
                  child: Stack(
                      alignment: Alignment.center,
                      children: orderedStackChildren),
                ),
                const SizedBox(width: 120),
                IconButton(
                  icon: Image.asset('assets/images/forward_arrow.png',
                      width: 50, height: 50),
                  onPressed: () => setState(() => _currentSubCategoryIndex =
                      (_currentSubCategoryIndex - 1 + subCategories.length) %
                          subCategories.length),
                ),
              ],
            ),
            if (isPackagingSelected)
              SizedBox(
                width: 600,
                child: TextField(
                  controller: _accessoriesController,
                  focusNode: _accessoriesFocusNode,
                  readOnly: false, // Changed to false for physical keyboard
                  showCursor: true,
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                  decoration: InputDecoration(
                    labelText: 'Enter Accessories (e.g., shoes, helmet)',
                    labelStyle:
                        const TextStyle(color: Colors.white70, fontSize: 24),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white54),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
          ],
        ),
        Positioned(
          bottom: 400,
          child: _buildNextButton(context),
        )
      ],
    );
  }

  Widget _buildNextButton(BuildContext context) {
    final flowProvider = context.read<CategoryProvider>();
    final photoProvider = context.read<PhotoboothProvider>();

    final subCategories = [
      {'key': 'ghibli', 'workflow': 'ghibli.json'},
      {'key': 'pixar', 'workflow': 'pixar.json'},
      {'key': 'packaging', 'workflow': 'packaging.json'},
    ];

    onPressed() {
      final selectedSubCategory = subCategories[_currentSubCategoryIndex];

      if (selectedSubCategory['key'] == 'packaging') {
        if (_accessoriesController.text.trim().isEmpty) {
          showSnackBar(context, "Please enter some accessories", isError: true);
          return;
        }
        photoProvider.setAccessories(_accessoriesController.text.trim());
      }

      _accessoriesFocusNode.unfocus();
      flowProvider.selectWorkflow(selectedSubCategory['workflow'] as String);
      Navigator.pushNamed(context, AppRoutes.faceCapture);
    }

    return GestureDetector(
      onTap: onPressed,
      child: Image.asset('assets/images/next_btn.png',
          width: 585.0, height: 150.0, fit: BoxFit.contain),
    );
  }
}

class TappableCategoryCard extends StatefulWidget {
  const TappableCategoryCard({
    super.key,
    required this.settings,
    required this.onTap,
    this.isSelected = false,
    this.provideFeedback = false,
  });

  final CategoryCardSettings settings;
  final VoidCallback onTap;
  final bool isSelected;
  final bool provideFeedback;

  @override
  State<TappableCategoryCard> createState() => _TappableCategoryCardState();
}

class _TappableCategoryCardState extends State<TappableCategoryCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isInteractable = widget.provideFeedback;
    final double scale = isInteractable && _isPressed ? 0.95 : 1.0;

    return GestureDetector(
      onTapDown:
          isInteractable ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isInteractable
          ? (_) {
              setState(() => _isPressed = false);
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  widget.onTap();
                }
              });
            }
          : null,
      onTapCancel:
          isInteractable ? () => setState(() => _isPressed = false) : null,
      onTap: isInteractable ? null : widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(scale),
        transformAlignment: Alignment.center,
        width: widget.settings.width,
        height: widget.settings.height,
        decoration: BoxDecoration(
          border: widget.settings.showBorder
              ? Border.all(
                  color: widget.isSelected
                      ? widget.settings.borderColor
                      : Colors.transparent,
                  width: widget.settings.borderWidth,
                )
              : null,
          image: DecorationImage(
            image: widget.settings.isAsset
                ? AssetImage(widget.settings.imagePath)
                : FileImage(File(widget.settings.imagePath)) as ImageProvider,
            fit: BoxFit.contain,
          ),
          boxShadow: widget.isSelected && widget.settings.useGlow
              ? [
                  BoxShadow(
                    color: widget.settings.glowColor
                        .withValues(alpha: widget.settings.glowIntensity),
                    blurRadius: 80,
                    spreadRadius: 12,
                  )
                ]
              : [],
        ),
      ),
    );
  }
}
