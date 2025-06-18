import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/constants/constants.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/presentation/gender_selection_screen.dart';
import 'package:photobooth_flutter/providers/gender_selection_provider.dart';
import 'package:photobooth_flutter/widgets/improved_color_picker.dart';
import 'package:photobooth_flutter/widgets/settings_preview.dart';
import 'package:provider/provider.dart';

class GenderScreenSettings extends StatefulWidget {
  const GenderScreenSettings({super.key});

  @override
  State<GenderScreenSettings> createState() => _GenderScreenSettingsState();
}

class _GenderScreenSettingsState extends State<GenderScreenSettings> {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<GenderSelectionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gender Selection Screen Settings'),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SettingsPreview(
              width: 1080,
              height: 1920,
              // scale: 0.45,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.transparent),
                borderRadius: BorderRadius.circular(0),
              ),
              child: const GenderSelectionScreen(),
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

                  _buildSectionSubtitle('Title Position'),

                  _buildSliderWithLabel(
                    label: 'Title Left',
                    value: settings.titleLeft,
                    min: 0.0,
                    max: 1000.0,
                    // divisions: 60,
                    onChanged: (value) {
                      settings.setTitlePosition(
                          value, settings.titleTop, settings.titleWidth);
                    },
                  ),
                  _buildSliderWithLabel(
                    label: 'Title Top',
                    value: settings.titleTop,
                    min: 0.0,
                    max: 1000.0,
                    // divisions: 60,
                    onChanged: (value) {
                      settings.setTitlePosition(
                          settings.titleLeft, value, settings.titleWidth);
                    },
                  ),

                  _buildSliderWithLabel(
                    label: 'Title Width',
                    value: settings.titleWidth,
                    min: 0.0,
                    max: 900.0,
                    // divisions: 60,
                    onChanged: (value) {
                      settings.setTitlePosition(
                          settings.titleLeft, settings.titleTop, value);
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

                  // Title Color
                  ListTile(
                    title: const Text('Title Color'),
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: settings.titleColor,
                        border: Border.all(color: AppColors.black),
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
                              backgroundColor: AppColors.red,
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
                            border: Border.all(color: AppColors.black),
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

                  // Gender Images Settings
                  _buildSectionTitle('Gender Images Settings'),

                  // Images Row Margin and Padding
                  _buildSectionSubtitle('Gender Section Position'),

                  _buildSliderWithLabel(
                    label: 'From Left',
                    value: settings.genderSelectionLeft,
                    min: 0.0,
                    max: 1000.0,
                    // divisions: 60,
                    onChanged: (value) {
                      settings.setGenderCardPosition(
                          value, settings.genderSelectionTop);
                    },
                  ),

                  _buildSliderWithLabel(
                    label: 'From Top',
                    value: settings.genderSelectionTop,
                    min: 0.0,
                    max: 1000.0,
                    // divisions: 60,
                    onChanged: (value) {
                      settings.setGenderCardPosition(
                          settings.genderSelectionLeft, value);
                    },
                  ),

                  // Male Image
                  const Text('Male Image',
                      style: TextStyle(fontWeight: FontWeight.bold)),
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
                            settings.setMaleImage(
                              result.files.first.path,
                              isAsset: false,
                            );
                          }
                        },
                        child: const Text('Select Male Image'),
                      ),
                      Constants.w16,
                      if (settings.maleImagePath != null &&
                          !settings.isMaleImageAsset)
                        ElevatedButton(
                          onPressed: () {
                            settings.setMaleImage(
                                'assets/images/male_avatar.png',
                                isAsset: true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          child: const Text('Reset to Default'),
                        ),
                    ],
                  ),
                  if (settings.maleImagePath != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        width: 100,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.black),
                          borderRadius:
                              BorderRadius.circular(settings.imageBorderRadius),
                          image: DecorationImage(
                            image: settings.isMaleImageAsset
                                ? AssetImage(settings.maleImagePath!)
                                : FileImage(File(settings.maleImagePath!))
                                    as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                  Constants.h16,

                  // Female Image
                  const Text('Female Image',
                      style: TextStyle(fontWeight: FontWeight.bold)),
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
                            settings.setFemaleImage(
                              result.files.first.path,
                              isAsset: false,
                            );
                          }
                        },
                        child: const Text('Select Female Image'),
                      ),
                      Constants.w16,
                      if (settings.femaleImagePath != null &&
                          !settings.isFemaleImageAsset)
                        ElevatedButton(
                          onPressed: () {
                            settings.setFemaleImage(
                                'assets/images/female_avatar.png',
                                isAsset: true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          child: const Text('Reset to Default'),
                        ),
                    ],
                  ),
                  if (settings.femaleImagePath != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        width: 100,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.black),
                          borderRadius:
                              BorderRadius.circular(settings.imageBorderRadius),
                          image: DecorationImage(
                            image: settings.isFemaleImageAsset
                                ? AssetImage(settings.femaleImagePath!)
                                : FileImage(File(settings.femaleImagePath!))
                                    as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                  Constants.h16,

                  // Image Dimensions
                  _buildSectionSubtitle('Image Dimensions'),

                  _buildSliderWithLabel(
                    label: 'Image Width',
                    value: settings.imageWidth,
                    min: 80.0,
                    max: 900.0,
                    onChanged: (value) {
                      settings.setImageDimensions(value, settings.imageHeight);
                    },
                  ),

                  _buildSliderWithLabel(
                    label: 'Image Height',
                    value: settings.imageHeight,
                    min: 80.0,
                    max: 900.0,
                    onChanged: (value) {
                      settings.setImageDimensions(settings.imageWidth, value);
                    },
                  ),

                  _buildSliderWithLabel(
                    label: 'Spacing Between Images',
                    value: settings.imageSpacing,
                    min: 0.0,
                    max: 80.0,
                    divisions: 50,
                    onChanged: (value) {
                      settings.setImageSpacing(value);
                    },
                  ),

                  _buildSliderWithLabel(
                    label: 'Image Border Radius',
                    value: settings.imageBorderRadius,
                    min: 0.0,
                    max: 100.0,
                    divisions: 50,
                    onChanged: (value) {
                      settings.setImageBorder(borderRadius: value);
                    },
                  ),

                  Constants.h16,

                  // Image Border Settings
                  SwitchListTile(
                    title: const Text('Show Image Border'),
                    value: settings.showImageBorder,
                    onChanged: (value) {
                      settings.setImageBorder(showBorder: value);
                    },
                  ),

                  if (settings.showImageBorder) ...[
                    Constants.h16,
                    _buildSliderWithLabel(
                      label: 'Border Width',
                      value: settings.imageBorderWidth < 1.0
                          ? 1.0
                          : settings.imageBorderWidth,
                      min: 1.0,
                      max: 10.0,
                      divisions: 9,
                      onChanged: (value) {
                        settings.setImageBorder(borderWidth: value);
                      },
                    ),
                    ListTile(
                      title: const Text('Border Color'),
                      leading: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: settings.imageBorderColor,
                          border: Border.all(color: AppColors.black),
                        ),
                      ),
                      onTap: () async {
                        final color = await _showImprovedColorPicker(
                          context: context,
                          color: settings.imageBorderColor,
                          title: 'Select Border Color',
                        );
                        if (color != null) {
                          settings.setImageBorder(borderColor: color);
                        }
                      },
                    ),
                  ],

                  const Divider(height: 32),

                  // Selection Effect Settings
                  _buildSectionTitle('Selection Effect Settings'),

                  SwitchListTile(
                    title: const Text('Enable Highlighting'),
                    subtitle: const Text('Scale up selected gender image'),
                    value: settings.useSelectionEffect,
                    onChanged: (value) {
                      settings.setSelectionEffect(useEffect: value);
                    },
                  ),

                  if (settings.useSelectionEffect) ...[
                    Constants.h16,
                    Slider(
                      value: settings.selectedImageScale,
                      min: 1.0,
                      max: 1.5,
                      divisions: 20,
                      label: settings.selectedImageScale.toStringAsFixed(2),
                      onChanged: (value) {
                        settings.setSelectionEffect(scale: value);
                      },
                    ),
                    const Text('Selected Image Scale Factor',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14)),
                    Constants.h16,
                    SwitchListTile(
                      title: const Text('Use Selection Glow'),
                      subtitle: const Text('Add glow effect to selected image'),
                      value: settings.useSelectionGlow,
                      onChanged: (value) {
                        settings.setSelectionEffect(useGlow: value);
                      },
                    ),
                    if (settings.useSelectionGlow) ...[
                      Constants.h16,
                      ListTile(
                        title: const Text('Glow Color'),
                        leading: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: settings.selectionGlowColor,
                            border: Border.all(color: AppColors.black),
                          ),
                        ),
                        onTap: () async {
                          final color = await _showImprovedColorPicker(
                              title: "Select Glow Color",
                              context: context,
                              color: settings.selectionGlowColor);
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
                        divisions: 18,
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

                  // Button Settings
                  _buildSectionTitle('Button Settings'),

                  SwitchListTile(
                    title: const Text('Use Image Button'),
                    value: settings.useImageButton,
                    onChanged: (value) {
                      settings.setUseImageButton(value);
                    },
                  ),

                  Constants.h16,

                  if (settings.useImageButton) ...[
                    // Image Button Settings
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
                                result.files.first.path!,
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
                              settings.setButtonImage(
                                  'assets/images/next_btn.png',
                                  isAsset: true);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.red,
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
                            border: Border.all(color: AppColors.black),
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
                  ] else ...[
                    // Text Button Settings
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

                    DropdownButtonFormField<FontWeight>(
                      decoration: const InputDecoration(
                        labelText: 'Font Weight',
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

                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: const Text('Button Color'),
                            leading: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: settings.buttonColor,
                                border: Border.all(color: AppColors.black),
                              ),
                            ),
                            onTap: () async {
                              final color = await _showImprovedColorPicker(
                                  title: "Select Button Color",
                                  context: context,
                                  color: settings.buttonColor);
                              if (color != null) {
                                settings.setButtonStyle(buttonColor: color);
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: const Text('Text Color'),
                            leading: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: settings.buttonTextColor,
                                border: Border.all(color: AppColors.black),
                              ),
                            ),
                            onTap: () async {
                              final color = await _showImprovedColorPicker(
                                  title: "Select Text Color",
                                  context: context,
                                  color: settings.buttonTextColor);
                              if (color != null) {
                                settings.setButtonStyle(textColor: color);
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                    Constants.h16,

                    TextFormField(
                      initialValue: settings.buttonFontSize.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Button Font Size',
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
                  ],

                  // Button Margin
                  _buildSectionSubtitle('Button Positions'),

                  _buildSliderWithLabel(
                    label: 'From Left',
                    value: settings.buttonLeft,
                    min: 0.0,
                    max: 1000.0,
                    // divisions: 60,
                    onChanged: (value) {
                      settings.setButtonPosition(value, settings.buttonBottom);
                    },
                  ),

                  _buildSliderWithLabel(
                    label: 'From Bottom',
                    value: settings.buttonBottom,
                    min: 0.0,
                    max: 1000.0,
                    // divisions: 60,
                    onChanged: (value) {
                      settings.setButtonPosition(settings.buttonLeft, value);
                    },
                  ),

                  // Common Button Settings
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
                      Constants.w16,
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

                  Constants.h16,

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: settings.buttonBorderRadius.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Button Border Radius',
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

                  Constants.h16,

                  SwitchListTile(
                    title: const Text('Button Border'),
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
                            leading: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: settings.buttonBorderColor,
                                border: Border.all(color: AppColors.black),
                              ),
                            ),
                            onTap: () async {
                              final color = await _showImprovedColorPicker(
                                  title: "Select Border Color",
                                  context: context,
                                  color: settings.buttonBorderColor);
                              if (color != null) {
                                settings.setButtonBorder(borderColor: color);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],

                  const Divider(height: 32),

                  // Layout Settings
                  _buildSectionTitle('Layout Settings'),

                  TextFormField(
                    initialValue: settings.screenPadding.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Screen Padding',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final padding = double.tryParse(value);
                      if (padding != null) {
                        settings.setScreenPadding(padding);
                      }
                    },
                  ),
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
            colorPalette: [
              AppColors.white,
              AppColors.black,
              AppColors.yellow,
              AppColors.goldenYellow,
              AppColors.blue,
              AppColors.darkBlue,
              AppColors.red,
              AppColors.green,
              AppColors.orange,
              AppColors.purple,
              AppColors.deepPurple,
              AppColors.purpleBright,
              AppColors.grey,
              AppColors.lightGrey,
              AppColors.darkGrey,
            ],
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
