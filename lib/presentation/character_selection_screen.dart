import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photobooth_flutter/providers/app_provider.dart';
import 'package:photobooth_flutter/providers/character_selection_provider.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:provider/provider.dart';

class CharacterSelectionScreen extends StatefulWidget {
  const CharacterSelectionScreen({super.key});

  @override
  State<CharacterSelectionScreen> createState() =>
      _CharacterSelectionScreenState();
}

class _CharacterSelectionScreenState extends State<CharacterSelectionScreen> {
  String? _selectedCharacterId;
  int _currentIndex = 0;
  bool _showError = false;
  // In the class declaration, update the PageController initialization
  final PageController _pageController = PageController(viewportFraction: 0.5);

  // Then update the _buildCarouselSelection method
  Widget _buildCarouselSelection(
      List<CharacterModel> characters, CharacterSelectionProvider settings) {
    return Stack(
      children: [
        // Main carousel
        Column(
          children: [
            Expanded(
              child: Center(
                child: SizedBox(
                  height: settings.characterHeight + 20,
                  // Make the width take the full available width
                  width: double.infinity,
                  child: PageView.builder(
                    controller: _pageController,
                    // Reduce the spacing by increasing the viewportFraction
                    itemCount: characters.length * 2000,
                    itemBuilder: (context, index) {
                      final actualIndex = index % characters.length;
                      final character = characters[actualIndex];
                      final isCenter = actualIndex == _currentIndex;

                      // Apply scale based on position - center items are larger
                      final scale = isCenter ? 1.0 : 0.8;

                      return Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                          // Reduce horizontal margin to bring images closer
                          margin: EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: isCenter ? 0 : 20,
                          ),
                          child: Transform.scale(
                            scale: scale,
                            child: _buildCharacterOption(character, settings,
                                isCenter: isCenter),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),

        // Left navigation arrow
        Positioned(
          left: 10,
          top: 0,
          bottom: 0,
          child: Center(
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  color: Colors.white, size: 30),
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
        ),

        // Right navigation arrow
        Positioned(
          right: 10,
          top: 0,
          bottom: 0,
          child: Center(
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios,
                  color: Colors.white, size: 30),
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set initial page to a large number to enable infinite scrolling
      if (_pageController.hasClients) {
        // Get the actual number of characters
        final characterCount =
            context.read<PhotoboothProvider>().selectedGender == 'male'
                ? context
                    .read<CharacterSelectionProvider>()
                    .maleCharacters
                    .length
                : context
                    .read<CharacterSelectionProvider>()
                    .femaleCharacters
                    .length;

        if (characterCount > 0) {
          // Start at index 0 but with proper positioning
          _pageController.jumpToPage(characterCount * 1000);
          _currentIndex = 0;
        }
      }

      _pageController.addListener(() {
        if (_pageController.page != null) {
          final characterCount =
              context.read<PhotoboothProvider>().selectedGender == 'male'
                  ? context
                      .read<CharacterSelectionProvider>()
                      .maleCharacters
                      .length
                  : context
                      .read<CharacterSelectionProvider>()
                      .femaleCharacters
                      .length;

          if (characterCount > 0) {
            final page = _pageController.page!.round() % characterCount;
            if (page != _currentIndex) {
              setState(() {
                _currentIndex = page;
              });
            }
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<CharacterSelectionProvider>();
    final globalSettings = context.watch<GlobalSettingsProvider>();
    final appProvider = context.watch<PhotoboothProvider>();

    // Get the appropriate character list based on selected gender
    final characters = appProvider.selectedGender == 'male'
        ? settings.maleCharacters
        : settings.femaleCharacters;

    // Ensure we have at least 3 characters
    if (characters.length < 3) {
      return Scaffold(
        body: Center(
          child: Text(
            'Please add at least 3 ${appProvider.selectedGender} characters in settings',
            style: const TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.characterScreenSettings),
          icon: const Icon(Icons.star),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: _getBackgroundImage(settings, globalSettings),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            Padding(
              padding: EdgeInsets.only(bottom: settings.titlePadding),
              child: Text(
                settings.titleText,
                style: TextStyle(
                  fontSize: settings.titleFontSize,
                  fontWeight: settings.titleFontWeight,
                  color: settings.titleColor,
                ),
              ),
            ),

            // Character Selection
            Expanded(
              child: characters.length <= 3 || !settings.useCarousel
                  ? _buildRowSelection(characters, settings)
                  : _buildCarouselSelection(characters, settings),
            ),

            // Error message
            if (_showError)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  'Please select a character to continue',
                  style: TextStyle(
                    color: Colors.red[400],
                    fontSize: 16,
                  ),
                ),
              ),

            // Continue Button
            SizedBox(height: settings.buttonMarginTop),
            _buildButton(settings, appProvider, characters),
          ],
        ),
      ),
    );
  }

  Widget _buildRowSelection(
      List<CharacterModel> characters, CharacterSelectionProvider settings) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: characters.take(3).map((character) {
        return _buildCharacterOption(character, settings);
      }).toList(),
    );
  }

  Widget _buildCharacterOption(
      CharacterModel character, CharacterSelectionProvider settings,
      {bool isCenter = true}) {
    final bool isSelected = _selectedCharacterId == character.id;

    // For carousel, apply fade effect to non-center items
    final opacity = isCenter ? 1.0 : settings.carouselVisibleWidth;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCharacterId = character.id;
          _showError = false;
        });
      },
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: settings.characterWidth,
          height: settings.characterHeight,

          // margin:
          //     EdgeInsets.symmetric(horizontal: settings.characterSpacing / 1),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(settings.characterBorderRadius + 4),
            border: settings.showCharacterBorder
                ? Border.all(
                    color: settings.characterBorderColor,
                    width: settings.characterBorderWidth + 0.5,
                  )
                : null,
            boxShadow: isSelected &&
                    settings.useSelectionEffect &&
                    settings.useSelectionGlow
                ? [
                    BoxShadow(
                      color: settings.selectionGlowColor
                          .withValues(alpha: settings.selectionGlowIntensity),
                      blurRadius: settings.selectionGlowSpread,
                      spreadRadius: settings.selectionGlowSpread / 2,
                    )
                  ]
                : null,
          ),
          // Use ClipRRect to ensure the image respects the border radius
          child: ClipRRect(
            borderRadius: BorderRadius.circular(settings.characterBorderRadius),
            child: Image(
              image: character.isAsset
                  ? AssetImage(character.imagePath)
                  : FileImage(File(character.imagePath)) as ImageProvider,
              fit: BoxFit.cover,
              width: settings.characterWidth,
              height: settings.characterHeight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(CharacterSelectionProvider settings,
      PhotoboothProvider appProvider, List<CharacterModel> characters) {
    if (settings.useImageButton && settings.buttonImagePath != null) {
      // Image Button
      return GestureDetector(
        onTap: () => _validateAndContinue(appProvider, characters),
        child: Container(
          width: settings.buttonWidth,
          height: settings.buttonHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(settings.buttonBorderRadius),
            border: settings.buttonHasBorder
                ? Border.all(
                    color: settings.buttonBorderColor,
                    width: settings.buttonBorderWidth,
                  )
                : null,
            image: DecorationImage(
              image: settings.isButtonImageAsset
                  ? AssetImage(settings.buttonImagePath!)
                  : FileImage(File(settings.buttonImagePath!)) as ImageProvider,
              fit: BoxFit.fitHeight,
            ),
          ),
        ),
      );
    } else {
      // Text Button
      return ElevatedButton(
        onPressed: () => _validateAndContinue(appProvider, characters),
        style: ElevatedButton.styleFrom(
          backgroundColor: settings.buttonColor,
          foregroundColor: settings.buttonTextColor,
          minimumSize: Size(settings.buttonWidth, settings.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(settings.buttonBorderRadius),
            side: settings.buttonHasBorder
                ? BorderSide(
                    color: settings.buttonBorderColor,
                    width: settings.buttonBorderWidth,
                  )
                : BorderSide.none,
          ),
        ),
        child: Text(
          settings.buttonText,
          style: TextStyle(
            fontSize: settings.buttonFontSize,
          ),
        ),
      );
    }
  }

  void _validateAndContinue(
      PhotoboothProvider appProvider, List<CharacterModel> characters) {
    if (_selectedCharacterId == null) {
      setState(() {
        _showError = true;
      });
    } else {
      _continueToNextScreen(appProvider, characters);
    }
  }

  void _continueToNextScreen(
      PhotoboothProvider appProvider, List<CharacterModel> characters) {
    final selectedCharacter =
        characters.firstWhere((c) => c.id == _selectedCharacterId);
    appProvider.setCharacter(selectedCharacter.id, selectedCharacter.imagePath,
        selectedCharacter.isAsset);
    Navigator.pushNamed(context, AppRoutes.faceCapture);
  }

  ImageProvider _getBackgroundImage(CharacterSelectionProvider settings,
      GlobalSettingsProvider globalSettings) {
    // First try to use character screen specific background
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
