import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/providers/character_selection_provider.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/providers/photobooth_provider.dart';
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

  // Update the _buildGridSelection method to use the new grid layout settings
  Widget _buildGridSelection(
      List<CharacterModel> characters, CharacterSelectionProvider settings) {
    // Calculate total characters to display
    final totalCharacters = characters.length;

    // Get row distribution
    final rowDistribution = settings.gridRowDistribution;

    // Create a list to hold rows of characters
    final List<Widget> rows = [];

    // Track the current character index
    int characterIndex = 0;

    // For each row in the distribution
    for (int rowIndex = 0; rowIndex < settings.gridRowCount; rowIndex++) {
      // Get how many characters should be in this row
      int charactersInRow =
          rowIndex < rowDistribution.length ? rowDistribution[rowIndex] : 1;

      // Ensure we don't exceed the total number of characters
      if (characterIndex + charactersInRow > totalCharacters) {
        charactersInRow = totalCharacters - characterIndex;
      }

      // If we've used all characters, break
      if (charactersInRow <= 0) break;

      // Create a list of character widgets for this row
      final List<Widget> rowChildren = [];

      // Add characters to this row
      for (int i = 0; i < charactersInRow; i++) {
        if (characterIndex < totalCharacters) {
          final character = characters[characterIndex];
          final isSelected = character.id == _selectedCharacterId;

          rowChildren.add(
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: settings.gridHorizontalSpacing / 2,
                ),
                child: _buildCharacterOption(character, settings,
                    isCenter: isSelected),
              ),
            ),
          );

          characterIndex++;
        }
      }

      // Center the last row if needed
      if (rowIndex == settings.gridRowCount - 1 &&
          settings.gridCenterLastRow &&
          charactersInRow <
              (rowDistribution.isNotEmpty ? rowDistribution.first : 1)) {
        // Add spacers at the beginning and end to center the row
        final spacerWidth = (rowDistribution.first - charactersInRow) / 2;
        if (spacerWidth > 0) {
          rowChildren.insert(0, Spacer(flex: (spacerWidth * 100).toInt()));
          rowChildren.add(Spacer(flex: (spacerWidth * 100).toInt()));
        }
      }

      // Add the row to our list of rows
      rows.add(
        Padding(
          padding: EdgeInsets.only(
            bottom: rowIndex < settings.gridRowCount - 1
                ? settings.gridVerticalSpacing
                : 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: rowChildren,
          ),
        ),
      );
    }

    // Return the grid layout
    return Padding(
      padding: settings.gridMargin,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: rows,
      ),
    );
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
        padding: EdgeInsets.zero,
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
              padding: EdgeInsets.zero,
              child: Text(
                settings.titleText,
                style: TextStyle(
                  fontSize: settings.titleFontSize,
                  fontWeight: settings.titleFontWeight,
                  color: settings.titleColor
                      .withValues(alpha: settings.titleOpacity),
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
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Please select a character to continue',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 16,
                  ),
                ),
              ),

            // Next button
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedCharacterId != null) {
                    // Get the selected character from the list
                    final characters = appProvider.selectedGender == 'male'
                        ? context
                            .read<CharacterSelectionProvider>()
                            .maleCharacters
                        : context
                            .read<CharacterSelectionProvider>()
                            .femaleCharacters;

                    final selectedCharacter = characters.firstWhere(
                      (character) => character.id == _selectedCharacterId,
                      orElse: () => characters.first,
                    );

                    // Set the selected character in the provider with all required arguments
                    appProvider.setCharacter(
                      selectedCharacter.id,
                      selectedCharacter.imagePath,
                      selectedCharacter.isAsset,
                    );

                    // Navigate to the next screen
                    Navigator.pushNamed(context, AppRoutes.faceCapture);
                  } else {
                    setState(() {
                      _showError = true;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.yellow,
                  minimumSize: const Size(200, 50),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
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
      child: Container(
        width: settings.characterWidth,
        height: settings.characterHeight,
        margin: EdgeInsets.all(settings.characterSpacing),
        // Add padding to give space for the glow effect
        padding: isSelected && settings.useSelectionGlow
            ? EdgeInsets.all(settings.selectionGlowSpread / 2)
            : EdgeInsets.zero,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
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
                          .withValues(alpha: settings.selectionGlowIntensity),
                      blurRadius: settings.selectionGlowSpread,
                      spreadRadius: settings.selectionGlowSpread / 2,
                    )
                  ]
                : null,
          ),
          child: Transform.scale(
            scale: scale,
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(settings.characterBorderRadius),
              child: character.isAsset
                  ? Image.asset(
                      character.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Handle missing asset files
                        return Container(
                          color: AppColors.greyOffWhite,
                          child: const Center(
                            child: Icon(Icons.broken_image,
                                size: 50, color: AppColors.grey),
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
                          color: AppColors.greyOffWhite,
                          child: const Center(
                            child: Icon(Icons.broken_image,
                                size: 50, color: AppColors.grey),
                          ),
                        ),
            ),
          ),
        ),
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

  void _validateAndContinue(PhotoboothProvider appProvider) {
    if (_selectedCharacterId == null) {
      setState(() {
        _showError = true;
      });
    } else {
      _continueToNextScreen(appProvider);
    }
  }

  void _continueToNextScreen(PhotoboothProvider appProvider) {
    // Fix: Pass all three required arguments to setCharacterz
    if (_selectedCharacterId != null) {
      final characters = appProvider.selectedGender == 'male'
          ? context.read<CharacterSelectionProvider>().maleCharacters
          : context.read<CharacterSelectionProvider>().femaleCharacters;

      final selectedCharacter = characters.firstWhere(
        (character) => character.id == _selectedCharacterId,
        orElse: () => characters.first,
      );

      appProvider.setCharacter(
        selectedCharacter.id,
        selectedCharacter.imagePath,
        selectedCharacter.isAsset,
      );

      Navigator.pushNamed(context, AppRoutes.faceCapture);
    } else {
      setState(() {
        _showError = true;
      });
    }
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
