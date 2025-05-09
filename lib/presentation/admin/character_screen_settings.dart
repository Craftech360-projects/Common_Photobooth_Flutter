import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/constants/constants.dart';
import 'package:photobooth_flutter/presentation/character_selection_screen.dart';
import 'package:photobooth_flutter/providers/character_selection_provider.dart';
import 'package:photobooth_flutter/widgets/improved_color_picker.dart';
import 'package:photobooth_flutter/widgets/settings_preview.dart';
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
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SettingsPreview(
              width: 1080,
              height: 1920,
              scale: 0.45,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.transparent),
                borderRadius: BorderRadius.circular(0),
              ),
              child: const CharacterSelectionScreen(),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Settings
                  _buildSectionTitle('Title Settings'),

                  // Title Text
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

                  Constants.h16,

                  // Title Font Size
                  _buildSliderWithLabel(
                    label: 'Font Size',
                    value: settings.titleFontSize,
                    min: 16.0,
                    max: 48.0,
                    divisions: 32,
                    onChanged: (value) {
                      settings.setTitleStyle(fontSize: value);
                    },
                  ),

                  // Title Line Height
                  _buildSliderWithLabel(
                    label: 'Line Height',
                    value: settings.titleLineHeight,
                    min: 0.8,
                    max: 2.0,
                    divisions: 24,
                    onChanged: (value) {
                      settings.setTitleStyle(lineHeight: value);
                    },
                  ),

                  // Title Opacity
                  _buildSliderWithLabel(
                    label: 'Text Opacity',
                    value: settings.titleOpacity,
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                    onChanged: (value) {
                      settings.setTitleStyle(opacity: value);
                    },
                  ),

                  // Title Font Weight
                  _buildSectionSubtitle('Font Style'),

                  DropdownButtonFormField<FontWeight>(
                    decoration: const InputDecoration(
                      labelText: 'Font Weight',
                      border: OutlineInputBorder(),
                    ),
                    value: settings.titleFontWeight,
                    items: [
                      const DropdownMenuItem(
                          value: FontWeight.w300, child: Text('Light')),
                      const DropdownMenuItem(
                          value: FontWeight.w400, child: Text('Regular')),
                      const DropdownMenuItem(
                          value: FontWeight.w500, child: Text('Medium')),
                      const DropdownMenuItem(
                          value: FontWeight.w600, child: Text('SemiBold')),
                      const DropdownMenuItem(
                          value: FontWeight.w700, child: Text('Bold')),
                      const DropdownMenuItem(
                          value: FontWeight.w800, child: Text('ExtraBold')),
                      const DropdownMenuItem(
                          value: FontWeight.w900, child: Text('Black')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        settings.setTitleStyle(fontWeight: value);
                      }
                    },
                  ),

                  Constants.h16,

                  // Title Text Style (Italic)
                  SwitchListTile(
                    title: const Text('Italic Text'),
                    value: settings.titleItalic,
                    onChanged: (value) {
                      settings.setTitleStyle(italic: value);
                    },
                  ),

                  // Title Text Alignment
                  _buildSectionSubtitle('Text Alignment'),

                  SegmentedButton<TextAlign>(
                    segments: const [
                      ButtonSegment(
                          value: TextAlign.left,
                          icon: Icon(Icons.format_align_left)),
                      ButtonSegment(
                          value: TextAlign.center,
                          icon: Icon(Icons.format_align_center)),
                      ButtonSegment(
                          value: TextAlign.right,
                          icon: Icon(Icons.format_align_right)),
                    ],
                    selected: {settings.titleAlignment},
                    onSelectionChanged: (Set<TextAlign> selection) {
                      if (selection.isNotEmpty) {
                        settings.setTitleStyle(alignment: selection.first);
                      }
                    },
                  ),

                  Constants.h16,

                  // Title Margin
                  _buildSectionSubtitle('Title Margins'),

                  _buildSliderWithLabel(
                    label: 'Top Margin',
                    value: settings.titleMargin.top,
                    min: 0.0,
                    max: 50.0,
                    divisions: 50,
                    onChanged: (value) {
                      settings.setTitleMargin(EdgeInsets.fromLTRB(
                        settings.titleMargin.left,
                        value,
                        settings.titleMargin.right,
                        settings.titleMargin.bottom,
                      ));
                    },
                  ),

                  _buildSliderWithLabel(
                    label: 'Bottom Margin',
                    value: settings.titleMargin.bottom,
                    min: 0.0,
                    max: 50.0,
                    divisions: 50,
                    onChanged: (value) {
                      settings.setTitleMargin(EdgeInsets.fromLTRB(
                        settings.titleMargin.left,
                        settings.titleMargin.top,
                        settings.titleMargin.right,
                        value,
                      ));
                    },
                  ),

                  _buildSliderWithLabel(
                    label: 'Left Margin',
                    value: settings.titleMargin.left,
                    min: 0.0,
                    max: 50.0,
                    divisions: 50,
                    onChanged: (value) {
                      settings.setTitleMargin(EdgeInsets.fromLTRB(
                        value,
                        settings.titleMargin.top,
                        settings.titleMargin.right,
                        settings.titleMargin.bottom,
                      ));
                    },
                  ),

                  _buildSliderWithLabel(
                    label: 'Right Margin',
                    value: settings.titleMargin.right,
                    min: 0.0,
                    max: 50.0,
                    divisions: 50,
                    onChanged: (value) {
                      settings.setTitleMargin(EdgeInsets.fromLTRB(
                        settings.titleMargin.left,
                        settings.titleMargin.top,
                        value,
                        settings.titleMargin.bottom,
                      ));
                    },
                  ),

                  // Title Color
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
                      final color = await _showImprovedColorPicker(
                        context: context,
                        color: settings.titleColor,
                        title: 'Select Title Color',
                      );
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
                    Constants.h8,
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
                        Constants.w16,
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
                                  : FileImage(
                                          File(settings.backgroundImagePath!))
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
                      Constants.w16,
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

                  Constants.h16,

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

                  Constants.h16,

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

                  Constants.h16,

                  // Character Border Settings
                  SwitchListTile(
                    title: const Text('Show Character Border'),
                    value: settings.showCharacterBorder,
                    onChanged: (value) {
                      settings.setCharacterBorder(showBorder: value);
                    },
                  ),

                  if (settings.showCharacterBorder) ...[
                    Constants.h16,
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue:
                                settings.characterBorderWidth.toString(),
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
                        Constants.w16,
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
                    Constants.h16,
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
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14)),
                    Constants.h16,
                    SwitchListTile(
                      title: const Text('Use Selection Glow'),
                      subtitle:
                          const Text('Add glow effect to selected character'),
                      value: settings.useSelectionGlow,
                      onChanged: (value) {
                        settings.setSelectionEffect(useGlow: value);
                      },
                    ),
                    if (settings.useSelectionGlow) ...[
                      Constants.h16,
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
                      Constants.h16,
                      const Text('Glow Intensity',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Slider(
                        value: settings.selectionGlowIntensity,
                        min: 0.1,
                        max: 1.0,
                        divisions: 9,
                        label:
                            settings.selectionGlowIntensity.toStringAsFixed(1),
                        onChanged: (value) {
                          settings.setSelectionEffect(glowIntensity: value);
                        },
                      ),
                      Constants.h16,
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

                  // Carousel or Grid View
                  SwitchListTile(
                    title: const Text('Use Carousel View'),
                    subtitle:
                        const Text('Toggle between carousel and grid layout'),
                    value: settings.useCarousel,
                    onChanged: (value) {
                      settings.setUseCarousel(value);
                    },
                  ),

                  // Grid Layout Settings (only show when carousel is disabled)
                  if (!settings.useCarousel) ...[
                    _buildSectionSubtitle('Grid Layout Settings'),

                    // Row Count
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Number of Rows',
                        border: OutlineInputBorder(),
                      ),
                      value: settings.gridRowCount,
                      items: List.generate(3, (index) => index + 1)
                          .map((count) => DropdownMenuItem(
                                value: count,
                                child: Text(
                                    '$count ${count == 1 ? 'Row' : 'Rows'}'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          settings.setGridRowCount(value);
                        }
                      },
                    ),

                    Constants.h16,

                    // Row Distribution
                    _buildSectionSubtitle('Characters per Row'),

                    // For each row, show a number picker
                    ...List.generate(
                      settings.gridRowCount,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text('Row ${index + 1}:'),
                            ),
                            SizedBox(
                              width: 120,
                              child: DropdownButtonFormField<int>(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                value:
                                    index < settings.gridRowDistribution.length
                                        ? settings.gridRowDistribution[index]
                                        : 1,
                                items: List.generate(5, (i) => i + 1)
                                    .map((count) => DropdownMenuItem(
                                          value: count,
                                          child: Text('$count'),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    settings.updateRowDistributionAt(
                                        index, value);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Constants.h16,

                    // Grid Spacing
                    _buildSectionSubtitle('Grid Spacing'),

                    _buildSliderWithLabel(
                      label: 'Horizontal Spacing',
                      value: settings.gridHorizontalSpacing,
                      min: 0.0,
                      max: 50.0,
                      divisions: 50,
                      onChanged: (value) {
                        settings.setGridSpacing(horizontal: value);
                      },
                    ),

                    _buildSliderWithLabel(
                      label: 'Vertical Spacing',
                      value: settings.gridVerticalSpacing,
                      min: 0.0,
                      max: 50.0,
                      divisions: 50,
                      onChanged: (value) {
                        settings.setGridSpacing(vertical: value);
                      },
                    ),

                    // Grid Margin
                    _buildSectionSubtitle('Grid Margins'),

                    _buildSliderWithLabel(
                      label: 'Top Margin',
                      value: settings.gridMargin.top,
                      min: 0.0,
                      max: 50.0,
                      divisions: 50,
                      onChanged: (value) {
                        settings.setGridMargin(EdgeInsets.fromLTRB(
                          settings.gridMargin.left,
                          value,
                          settings.gridMargin.right,
                          settings.gridMargin.bottom,
                        ));
                      },
                    ),

                    _buildSliderWithLabel(
                      label: 'Bottom Margin',
                      value: settings.gridMargin.bottom,
                      min: 0.0,
                      max: 50.0,
                      divisions: 50,
                      onChanged: (value) {
                        settings.setGridMargin(EdgeInsets.fromLTRB(
                          settings.gridMargin.left,
                          settings.gridMargin.top,
                          settings.gridMargin.right,
                          value,
                        ));
                      },
                    ),

                    _buildSliderWithLabel(
                      label: 'Left Margin',
                      value: settings.gridMargin.left,
                      min: 0.0,
                      max: 50.0,
                      divisions: 50,
                      onChanged: (value) {
                        settings.setGridMargin(EdgeInsets.fromLTRB(
                          value,
                          settings.gridMargin.top,
                          settings.gridMargin.right,
                          settings.gridMargin.bottom,
                        ));
                      },
                    ),

                    _buildSliderWithLabel(
                      label: 'Right Margin',
                      value: settings.gridMargin.right,
                      min: 0.0,
                      max: 50.0,
                      divisions: 50,
                      onChanged: (value) {
                        settings.setGridMargin(EdgeInsets.fromLTRB(
                          settings.gridMargin.left,
                          settings.gridMargin.top,
                          value,
                          settings.gridMargin.bottom,
                        ));
                      },
                    ),

                    // Center Last Row
                    SwitchListTile(
                      title: const Text('Center Last Row'),
                      subtitle: const Text(
                          'Center characters if last row is not full'),
                      value: settings.gridCenterLastRow,
                      onChanged: (value) {
                        settings.setGridCenterLastRow(value);
                      },
                    ),
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
                  Constants.h16,
                  // Button dimensions
                  Row(
                    children: [
                      Expanded(
                        child: _buildSliderWithLabel(
                          label: 'Button Width',
                          value: settings.buttonWidth,
                          min: 100.0,
                          max: 300.0,
                          divisions: 20,
                          onChanged: (value) {
                            settings.setButtonDimensions(
                                value, settings.buttonHeight);
                          },
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: _buildSliderWithLabel(
                          label: 'Button Height',
                          value: settings.buttonHeight,
                          min: 40.0,
                          max: 100.0,
                          divisions: 12,
                          onChanged: (value) {
                            settings.setButtonDimensions(
                                settings.buttonWidth, value);
                          },
                        ),
                      ),
                    ],
                  ),

                  // Button Font Size and Weight
                  _buildSliderWithLabel(
                    label: 'Button Font Size',
                    value: settings.buttonFontSize,
                    min: 12.0,
                    max: 32.0,
                    divisions: 20,
                    onChanged: (value) {
                      settings.setButtonStyle(fontSize: value);
                    },
                  ),
                  _buildSliderWithLabel(
                    label: 'Button Border Radius',
                    value: settings.buttonBorderRadius,
                    min: 0,
                    max: 50,
                    divisions: 50,
                    onChanged: (value) =>
                        settings.setButtonStyle(borderRadius: value),
                  ),

                  DropdownButtonFormField<FontWeight>(
                    decoration: const InputDecoration(
                      labelText: 'Button Font Weight',
                      border: OutlineInputBorder(),
                    ),
                    value: settings.buttonFontWeight,
                    items: [
                      const DropdownMenuItem(
                          value: FontWeight.w300, child: Text('Light')),
                      const DropdownMenuItem(
                          value: FontWeight.w400, child: Text('Regular')),
                      const DropdownMenuItem(
                          value: FontWeight.w500, child: Text('Medium')),
                      const DropdownMenuItem(
                          value: FontWeight.w600, child: Text('SemiBold')),
                      const DropdownMenuItem(
                          value: FontWeight.w700, child: Text('Bold')),
                      const DropdownMenuItem(
                          value: FontWeight.w800, child: Text('ExtraBold')),
                      const DropdownMenuItem(
                          value: FontWeight.w900, child: Text('Black')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        settings.setButtonStyle(fontWeight: value);
                      }
                    },
                  ),

                  Constants.h16,

                  // Button Margin
                  _buildSectionSubtitle('Button Margins'),

                  _buildSliderWithLabel(
                    label: 'Top Margin',
                    value: settings.buttonMargin.top,
                    min: 0.0,
                    max: 50.0,
                    divisions: 50,
                    onChanged: (value) {
                      settings.setButtonMargin(EdgeInsets.fromLTRB(
                        settings.buttonMargin.left,
                        value,
                        settings.buttonMargin.right,
                        settings.buttonMargin.bottom,
                      ));
                    },
                  ),

                  _buildSliderWithLabel(
                    label: 'Bottom Margin',
                    value: settings.buttonMargin.bottom,
                    min: 0.0,
                    max: 50.0,
                    divisions: 50,
                    onChanged: (value) {
                      settings.setButtonMargin(EdgeInsets.fromLTRB(
                        settings.buttonMargin.left,
                        settings.buttonMargin.top,
                        settings.buttonMargin.right,
                        value,
                      ));
                    },
                  ),

                  _buildSliderWithLabel(
                    label: 'Left Margin',
                    value: settings.buttonMargin.left,
                    min: 0.0,
                    max: 50.0,
                    divisions: 50,
                    onChanged: (value) {
                      settings.setButtonMargin(EdgeInsets.fromLTRB(
                        value,
                        settings.buttonMargin.top,
                        settings.buttonMargin.right,
                        settings.buttonMargin.bottom,
                      ));
                    },
                  ),

                  _buildSliderWithLabel(
                    label: 'Right Margin',
                    value: settings.buttonMargin.right,
                    min: 0.0,
                    max: 50.0,
                    divisions: 50,
                    onChanged: (value) {
                      settings.setButtonMargin(EdgeInsets.fromLTRB(
                        settings.buttonMargin.left,
                        settings.buttonMargin.top,
                        value,
                        settings.buttonMargin.bottom,
                      ));
                    },
                  ),

                  // Button Padding
                  _buildSectionSubtitle('Button Padding'),

                  _buildSliderWithLabel(
                    label: 'Vertical Padding',
                    value: settings.buttonPadding.top,
                    min: 0.0,
                    max: 30.0,
                    divisions: 30,
                    onChanged: (value) {
                      settings.setButtonPadding(EdgeInsets.symmetric(
                        vertical: value,
                        horizontal: settings.buttonPadding.left,
                      ));
                    },
                  ),

                  _buildSliderWithLabel(
                    label: 'Horizontal Padding',
                    value: settings.buttonPadding.left,
                    min: 0.0,
                    max: 50.0,
                    divisions: 50,
                    onChanged: (value) {
                      settings.setButtonPadding(EdgeInsets.symmetric(
                        vertical: settings.buttonPadding.top,
                        horizontal: value,
                      ));
                    },
                  ),
                  Constants.h16,
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
                            final color = await _showColorPicker(
                                context, settings.buttonColor);
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
                  Constants.h16,
                  SwitchListTile(
                    title: const Text('Button Has Border'),
                    value: settings.buttonHasBorder,
                    onChanged: (value) {
                      settings.setButtonBorder(hasBorder: value);
                    },
                  ),
                  if (settings.buttonHasBorder) ...[
                    Constants.h16,
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
                        Constants.w16,
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

                  Constants.h16,
                  SwitchListTile(
                    title: const Text('Use Image Button'),
                    value: settings.useImageButton,
                    onChanged: (value) {
                      settings.setUseImageButton(value);
                    },
                  ),
                  if (settings.useImageButton) ...[
                    Constants.h16,
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
                        Constants.w16,
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
                            borderRadius: BorderRadius.circular(
                                settings.buttonBorderRadius),
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
          ),
        ],
      ),
    );
  }

  // Helper methods
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSectionSubtitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildSliderWithLabel({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    int? divisions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(value.toStringAsFixed(1)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Future<Color?> _showImprovedColorPicker({
    required BuildContext context,
    required Color color,
    required String title,
  }) async {
    Color? selectedColor;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ImprovedColorPicker(
            pickerColor: color,
            onColorChanged: (color) {
              selectedColor = color;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, selectedColor),
            child: const Text('Select'),
          ),
        ],
      ),
    );

    return selectedColor;
  }
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
      Constants.h16,
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
                                  settings.removeFemaleCharacter(character.id);
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
          child: ImprovedColorPicker(
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
