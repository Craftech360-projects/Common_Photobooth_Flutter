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
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(settings.screenPadding),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: _getBackgroundImage(settings, globalSettings),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title with updated styling
            Container(
              margin: settings.titleMargin,
              padding: EdgeInsets.only(bottom: settings.titlePadding),
              child: Text(
                settings.titleText,
                style: TextStyle(
                  fontSize: settings.titleFontSize,
                  fontWeight: settings.titleFontWeight,
                  color: settings.titleColor.withOpacity(settings.titleOpacity),
                  fontStyle: settings.titleItalic
                      ? FontStyle.italic
                      : FontStyle.normal,
                  height: settings.titleLineHeight,
                ),
                textAlign: settings.titleAlignment,
              ),
            ),

            // Character Selection
            Expanded(
              child: characters.length > 3 && settings.useCarousel
                  ? Container(
                      margin: settings.carouselMargin,
                      padding: settings.carouselPadding,
                      child: _buildCarouselSelection(characters, settings),
                    )
                  : _buildGridSelection(characters, settings),
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
            Container(
              margin: settings.buttonMargin,
              child: _buildButton(settings, appProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterOption(
      CharacterModel character, CharacterSelectionProvider settings,
      {bool isCenter = false}) {
    final isSelected = character.id == _selectedCharacterId;
    final scale = isSelected && settings.useSelectionEffect
        ? settings.selectedCharacterScale
        : 1.0;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCharacterId = character.id;
          _showError = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: settings.characterWidth,
        height: settings.characterHeight,
        margin: EdgeInsets.all(settings.characterSpacing),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(settings.characterBorderRadius),
          border: settings.showCharacterBorder
              ? Border.all(
                  color: isSelected
                      ? settings.characterBorderColor
                      : Colors.transparent,
                  width: settings.characterBorderWidth,
                )
              : null,
          boxShadow: isSelected && settings.useSelectionGlow
              ? [
                  BoxShadow(
                    color: settings.selectionGlowColor
                        .withOpacity(settings.selectionGlowIntensity),
                    blurRadius: settings.selectionGlowSpread,
                    spreadRadius: settings.selectionGlowSpread / 2,
                  )
                ]
              : null,
        ),
        child: Transform.scale(
          scale: scale,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(settings.characterBorderRadius),
            child: character.isAsset
                ? Image.asset(
                    character.imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Handle missing asset files
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.broken_image,
                              size: 50, color: Colors.grey),
                        ),
                      );
                    },
                  )
                : File(character.imagePath).existsSync()
                    ? Image.file(
                        File(character.imagePath),
                        fit: BoxFit.contain,
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.broken_image,
                              size: 50, color: Colors.grey),
                        ),
                      ),
          ),
        ),
      ),
    );
  }

  // Add the missing _buildGridSelection method
  Widget _buildGridSelection(
      List<CharacterModel> characters, CharacterSelectionProvider settings) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: settings.characterSpacing,
        runSpacing: settings.characterSpacing,
        children: characters
            .map((character) => _buildCharacterOption(character, settings))
            .toList(),
      ),
    );
  }

  Widget _buildButton(
      CharacterSelectionProvider settings, PhotoboothProvider appProvider) {
    if (settings.useImageButton && settings.buttonImagePath != null) {
      // Image Button with padding
      return GestureDetector(
        onTap: () => _validateAndContinue(appProvider),
        child: Container(
          width: settings.buttonWidth,
          height: settings.buttonHeight,
          padding: settings.buttonPadding,
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
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else {
      // Text Button with padding
      return ElevatedButton(
        onPressed: () => _validateAndContinue(appProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor: settings.buttonColor,
          foregroundColor: settings.buttonTextColor,
          minimumSize: Size(settings.buttonWidth, settings.buttonHeight),
          padding: settings.buttonPadding,
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
            fontWeight: settings.buttonFontWeight,
          ),
        ),
      );
    }
  }

// Fix the _validateAndContinue method to include the characters parameter
  void _validateAndContinue(PhotoboothProvider appProvider) {
    final characters = appProvider.selectedGender == 'male'
        ? context.read<CharacterSelectionProvider>().maleCharacters
        : context.read<CharacterSelectionProvider>().femaleCharacters;

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
