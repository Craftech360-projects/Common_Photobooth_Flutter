import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/providers/character_selection_provider.dart';
import 'package:photobooth_flutter/widgets/color_picker.dart';
import 'package:provider/provider.dart';

class CharacterScreenSettings extends StatefulWidget {
  const CharacterScreenSettings({super.key});

  @override
  State<CharacterScreenSettings> createState() =>
      _CharacterScreenSettingsState();
}

class _CharacterScreenSettingsState extends State<CharacterScreenSettings> {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<CharacterSelectionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Character Selection Screen Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Settings
            _buildSectionTitle('Title Settings'),
            TextFormField(
              initialValue: settings.titleText,
              decoration: const InputDecoration(
                labelText: 'Title Text',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                settings.setTitleText(value);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: settings.titleFontSize.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Font Size',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final size = double.tryParse(value);
                      if (size != null) {
                        settings.setTitleStyle(fontSize: size);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: settings.titlePadding.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Padding',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final padding = double.tryParse(value);
                      if (padding != null) {
                        settings.setTitleStyle(padding: padding);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Title Color'),
              trailing: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: settings.titleColor,
                  border: Border.all(color: Colors.grey),
                ),
              ),
              onTap: () async {
                final color =
                    await _showColorPicker(context, settings.titleColor);
                if (color != null) {
                  settings.setTitleStyle(color: color);
                }
              },
            ),

            const Divider(height: 32),

            // Background Settings
            _buildSectionTitle('Background Settings'),
            SwitchListTile(
              title: const Text('Show Background'),
              value: settings.showBackground,
              onChanged: (value) {
                settings.setShowBackground(value);
              },
            ),
            if (settings.showBackground) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.image,
                        allowMultiple: false,
                      );
                      if (result != null && result.files.isNotEmpty) {
                        settings.setBackgroundImage(
                          result.files.first.path,
                          isAsset: false,
                        );
                      }
                    },
                    child: const Text('Select Background Image'),
                  ),
                  const SizedBox(width: 16),
                  if (settings.backgroundImagePath != null)
                    ElevatedButton(
                      onPressed: () {
                        settings.setBackgroundImage(null, isAsset: true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Remove Background'),
                    ),
                ],
              ),
              if (settings.backgroundImagePath != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    width: 200,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      image: DecorationImage(
                        image: settings.isBackgroundImageAsset
                            ? AssetImage(settings.backgroundImagePath!)
                            : FileImage(File(settings.backgroundImagePath!))
                                as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
            ],

            const Divider(height: 32),

            // Character Settings
            _buildSectionTitle('Male Characters'),
            _buildCharacterList(context, settings, true),

            const Divider(height: 32),

            _buildSectionTitle('Female Characters'),
            _buildCharacterList(context, settings, false),

            const Divider(height: 32),

            // Character Display Settings
            _buildSectionTitle('Character Display Settings'),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: settings.characterWidth.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Character Width',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final width = double.tryParse(value);
                      if (width != null) {
                        settings.setCharacterDimensions(
                            width, settings.characterHeight);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: settings.characterHeight.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Character Height',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final height = double.tryParse(value);
                      if (height != null) {
                        settings.setCharacterDimensions(
                            settings.characterWidth, height);
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            TextFormField(
              initialValue: settings.characterSpacing.toString(),
              decoration: const InputDecoration(
                labelText: 'Spacing Between Characters',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final spacing = double.tryParse(value);
                if (spacing != null) {
                  settings.setCharacterSpacing(spacing);
                }
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              initialValue: settings.characterBorderRadius.toString(),
              decoration: const InputDecoration(
                labelText: 'Character Border Radius',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final radius = double.tryParse(value);
                if (radius != null) {
                  settings.setCharacterBorder(borderRadius: radius);
                }
              },
            ),

            const SizedBox(height: 16),

            // Character Border Settings
            SwitchListTile(
              title: const Text('Show Character Border'),
              value: settings.showCharacterBorder,
              onChanged: (value) {
                settings.setCharacterBorder(showBorder: value);
              },
            ),

            if (settings.showCharacterBorder) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: settings.characterBorderWidth.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Border Width',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final width = double.tryParse(value);
                        if (width != null) {
                          settings.setCharacterBorder(borderWidth: width);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ListTile(
                      title: const Text('Border Color'),
                      trailing: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: settings.characterBorderColor,
                          border: Border.all(color: Colors.grey),
                        ),
                      ),
                      onTap: () async {
                        final color = await _showColorPicker(
                            context, settings.characterBorderColor);
                        if (color != null) {
                          settings.setCharacterBorder(borderColor: color);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],

            const Divider(height: 32),

            // Selection Effect Settings
            _buildSectionTitle('Selection Effect Settings'),
            SwitchListTile(
              title: const Text('Use Selection Effect'),
              subtitle: const Text('Scale up selected character'),
              value: settings.useSelectionEffect,
              onChanged: (value) {
                settings.setSelectionEffect(useEffect: value);
              },
            ),

            if (settings.useSelectionEffect) ...[
              const SizedBox(height: 16),
              Slider(
                value: settings.selectedCharacterScale,
                min: 1.0,
                max: 1.3,
                divisions: 6,
                label: settings.selectedCharacterScale.toStringAsFixed(2),
                onChanged: (value) {
                  settings.setSelectionEffect(scale: value);
                },
              ),
              const Text('Selected Character Scale Factor',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Use Selection Glow'),
                subtitle: const Text('Add glow effect to selected character'),
                value: settings.useSelectionGlow,
                onChanged: (value) {
                  settings.setSelectionEffect(useGlow: value);
                },
              ),
              if (settings.useSelectionGlow) ...[
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Glow Color'),
                  trailing: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: settings.selectionGlowColor,
                      border: Border.all(color: Colors.grey),
                    ),
                  ),
                  onTap: () async {
                    final color = await _showColorPicker(
                        context, settings.selectionGlowColor);
                    if (color != null) {
                      settings.setSelectionEffect(glowColor: color);
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text('Glow Intensity',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Slider(
                  value: settings.selectionGlowIntensity,
                  min: 0.1,
                  max: 1.0,
                  divisions: 9,
                  label: settings.selectionGlowIntensity.toStringAsFixed(1),
                  onChanged: (value) {
                    settings.setSelectionEffect(glowIntensity: value);
                  },
                ),
                const SizedBox(height: 16),
                const Text('Glow Spread',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Slider(
                  value: settings.selectionGlowSpread,
                  min: 1.0,
                  max: 20.0,
                  divisions: 19,
                  label: settings.selectionGlowSpread.toStringAsFixed(1),
                  onChanged: (value) {
                    settings.setSelectionEffect(glowSpread: value);
                  },
                ),
              ],
            ],

            const Divider(height: 32),

            // Carousel Settings
            _buildSectionTitle('Carousel Settings'),
            SwitchListTile(
              title: const Text('Use Carousel for 4+ Characters'),
              subtitle: const Text(
                  'Display characters in a carousel when more than 3'),
              value: settings.useCarousel,
              onChanged: (value) {
                settings.setCarouselSettings(useCarousel: value);
              },
            ),

            if (settings.useCarousel) ...[
              const SizedBox(height: 16),
              const Text('Side Character Visibility',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Slider(
                value: settings.carouselVisibleWidth,
                min: 0.1,
                max: 0.9,
                divisions: 8,
                label: '${(settings.carouselVisibleWidth * 100).toInt()}%',
                onChanged: (value) {
                  settings.setCarouselSettings(visibleWidth: value);
                },
              ),
              const Text('Percentage of side character visible',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
            ],

            const Divider(height: 32),

            // Button Settings
            _buildSectionTitle('Button Settings'),
            TextFormField(
              initialValue: settings.buttonText,
              decoration: const InputDecoration(
                labelText: 'Button Text',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                settings.setButtonText(value);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: settings.buttonWidth.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Button Width',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final width = double.tryParse(value);
                      if (width != null) {
                        settings.setButtonDimensions(
                            width, settings.buttonHeight);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: settings.buttonHeight.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Button Height',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final height = double.tryParse(value);
                      if (height != null) {
                        settings.setButtonDimensions(
                            settings.buttonWidth, height);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: settings.buttonFontSize.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Font Size',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final size = double.tryParse(value);
                      if (size != null) {
                        settings.setButtonStyle(fontSize: size);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: settings.buttonBorderRadius.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Border Radius',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final radius = double.tryParse(value);
                      if (radius != null) {
                        settings.setButtonStyle(borderRadius: radius);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Button Color'),
                    trailing: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: settings.buttonColor,
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                    onTap: () async {
                      final color =
                          await _showColorPicker(context, settings.buttonColor);
                      if (color != null) {
                        settings.setButtonStyle(buttonColor: color);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('Text Color'),
                    trailing: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: settings.buttonTextColor,
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                    onTap: () async {
                      final color = await _showColorPicker(
                          context, settings.buttonTextColor);
                      if (color != null) {
                        settings.setButtonStyle(textColor: color);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Button Has Border'),
              value: settings.buttonHasBorder,
              onChanged: (value) {
                settings.setButtonBorder(hasBorder: value);
              },
            ),
            if (settings.buttonHasBorder) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: settings.buttonBorderWidth.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Border Width',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final width = double.tryParse(value);
                        if (width != null) {
                          settings.setButtonBorder(borderWidth: width);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ListTile(
                      title: const Text('Border Color'),
                      trailing: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: settings.buttonBorderColor,
                          border: Border.all(color: Colors.grey),
                        ),
                      ),
                      onTap: () async {
                        final color = await _showColorPicker(
                            context, settings.buttonBorderColor);
                        if (color != null) {
                          settings.setButtonBorder(borderColor: color);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              initialValue: settings.buttonMarginTop.toString(),
              decoration: const InputDecoration(
                labelText: 'Button Top Margin',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final margin = double.tryParse(value);
                if (margin != null) {
                  settings.setButtonMarginTop(margin);
                }
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Use Image Button'),
              value: settings.useImageButton,
              onChanged: (value) {
                settings.setUseImageButton(value);
              },
            ),
            if (settings.useImageButton) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.image,
                        allowMultiple: false,
                      );
                      if (result != null && result.files.isNotEmpty) {
                        settings.setButtonImage(
                          result.files.first.path,
                          isAsset: false,
                        );
                      }
                    },
                    child: const Text('Select Button Image'),
                  ),
                  const SizedBox(width: 16),
                  if (settings.buttonImagePath != null)
                    ElevatedButton(
                      onPressed: () {
                        settings.setButtonImage(null);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Remove Image'),
                    ),
                ],
              ),
              if (settings.buttonImagePath != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius:
                          BorderRadius.circular(settings.buttonBorderRadius),
                      image: DecorationImage(
                        image: settings.isButtonImageAsset
                            ? AssetImage(settings.buttonImagePath!)
                            : FileImage(File(settings.buttonImagePath!))
                                as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCharacterList(
      BuildContext context, CharacterSelectionProvider settings, bool isMale) {
    final characters =
        isMale ? settings.maleCharacters : settings.femaleCharacters;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${characters.length} Characters',
                style: const TextStyle(fontStyle: FontStyle.italic)),
            ElevatedButton(
              onPressed: characters.length < 6
                  ? () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.image,
                        allowMultiple: false,
                      );
                      if (result != null && result.files.isNotEmpty) {
                        if (isMale) {
                          settings.addMaleCharacter(
                            result.files.first.path!,
                            isAsset: false,
                          );
                        } else {
                          settings.addFemaleCharacter(
                            result.files.first.path!,
                            isAsset: false,
                          );
                        }
                      }
                    }
                  : null,
              child: const Text('Add Character'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (characters.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No characters added yet.'),
          )
        else
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: characters.length,
              itemBuilder: (context, index) {
                final character = characters[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(
                              settings.characterBorderRadius),
                          image: DecorationImage(
                            image: character.isAsset
                                ? AssetImage(character.imagePath)
                                : FileImage(File(character.imagePath))
                                    as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: characters.length > 3
                              ? () {
                                  if (isMale) {
                                    settings.removeMaleCharacter(character.id);
                                  } else {
                                    settings
                                        .removeFemaleCharacter(character.id);
                                  }
                                }
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.image,
                              allowMultiple: false,
                            );
                            if (result != null && result.files.isNotEmpty) {
                              if (isMale) {
                                settings.updateMaleCharacter(
                                  character.id,
                                  result.files.first.path!,
                                  isAsset: false,
                                );
                              } else {
                                settings.updateFemaleCharacter(
                                  character.id,
                                  result.files.first.path!,
                                  isAsset: false,
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Future<Color?> _showColorPicker(
      BuildContext context, Color initialColor) async {
    Color selectedColor = initialColor;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: initialColor,
              onColorChanged: (Color color) {
                selectedColor = color;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                selectedColor = initialColor;
              },
            ),
            TextButton(
              child: const Text('Select'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    return selectedColor != initialColor ? selectedColor : null;
  }
}
