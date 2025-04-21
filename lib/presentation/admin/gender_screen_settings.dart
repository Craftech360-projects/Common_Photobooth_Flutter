import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/providers/gender_selection_provider.dart';
import 'package:photobooth_flutter/widgets/improved_color_picker.dart';
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
      body: SingleChildScrollView(
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

            const SizedBox(height: 16),

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

            // Title Padding
            _buildSliderWithLabel(
              label: 'Padding',
              value: settings.titlePadding,
              min: 0.0,
              max: 50.0,
              divisions: 50,
              onChanged: (value) {
                settings.setTitleStyle(padding: value);
              },
            ),

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

            const SizedBox(height: 16),

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
                    value: TextAlign.left, icon: Icon(Icons.format_align_left)),
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

            const SizedBox(height: 16),

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

            // Gender Images Settings
            _buildSectionTitle('Gender Images Settings'),

            // Images Row Margin and Padding
            _buildSectionSubtitle('Images Row Margins'),

            _buildSliderWithLabel(
              label: 'Top Margin',
              value: settings.imagesRowMargin.top,
              min: 0.0,
              max: 50.0,
              divisions: 50,
              onChanged: (value) {
                settings.setImagesRowMargin(EdgeInsets.fromLTRB(
                  settings.imagesRowMargin.left,
                  value,
                  settings.imagesRowMargin.right,
                  settings.imagesRowMargin.bottom,
                ));
              },
            ),

            _buildSliderWithLabel(
              label: 'Bottom Margin',
              value: settings.imagesRowMargin.bottom,
              min: 0.0,
              max: 50.0,
              divisions: 50,
              onChanged: (value) {
                settings.setImagesRowMargin(EdgeInsets.fromLTRB(
                  settings.imagesRowMargin.left,
                  settings.imagesRowMargin.top,
                  settings.imagesRowMargin.right,
                  value,
                ));
              },
            ),

            _buildSliderWithLabel(
              label: 'Left Margin',
              value: settings.imagesRowMargin.left,
              min: 0.0,
              max: 50.0,
              divisions: 50,
              onChanged: (value) {
                settings.setImagesRowMargin(EdgeInsets.fromLTRB(
                  value,
                  settings.imagesRowMargin.top,
                  settings.imagesRowMargin.right,
                  settings.imagesRowMargin.bottom,
                ));
              },
            ),

            _buildSliderWithLabel(
              label: 'Right Margin',
              value: settings.imagesRowMargin.right,
              min: 0.0,
              max: 50.0,
              divisions: 50,
              onChanged: (value) {
                settings.setImagesRowMargin(EdgeInsets.fromLTRB(
                  settings.imagesRowMargin.left,
                  settings.imagesRowMargin.top,
                  value,
                  settings.imagesRowMargin.bottom,
                ));
              },
            ),

            _buildSectionSubtitle('Images Row Padding'),

            _buildSliderWithLabel(
              label: 'Top Padding',
              value: settings.imagesRowPadding.top,
              min: 0.0,
              max: 50.0,
              divisions: 50,
              onChanged: (value) {
                settings.setImagesRowPadding(EdgeInsets.fromLTRB(
                  settings.imagesRowPadding.left,
                  value,
                  settings.imagesRowPadding.right,
                  settings.imagesRowPadding.bottom,
                ));
              },
            ),

            _buildSliderWithLabel(
              label: 'Bottom Padding',
              value: settings.imagesRowPadding.bottom,
              min: 0.0,
              max: 50.0,
              divisions: 50,
              onChanged: (value) {
                settings.setImagesRowPadding(EdgeInsets.fromLTRB(
                  settings.imagesRowPadding.left,
                  settings.imagesRowPadding.top,
                  settings.imagesRowPadding.right,
                  value,
                ));
              },
            ),

            _buildSliderWithLabel(
              label: 'Left Padding',
              value: settings.imagesRowPadding.left,
              min: 0.0,
              max: 50.0,
              divisions: 50,
              onChanged: (value) {
                settings.setImagesRowPadding(EdgeInsets.fromLTRB(
                  value,
                  settings.imagesRowPadding.top,
                  settings.imagesRowPadding.right,
                  settings.imagesRowPadding.bottom,
                ));
              },
            ),

            _buildSliderWithLabel(
              label: 'Right Padding',
              value: settings.imagesRowPadding.right,
              min: 0.0,
              max: 50.0,
              divisions: 50,
              onChanged: (value) {
                settings.setImagesRowPadding(EdgeInsets.fromLTRB(
                  settings.imagesRowPadding.left,
                  settings.imagesRowPadding.top,
                  value,
                  settings.imagesRowPadding.bottom,
                ));
              },
            ),

            // Male Image
            const Text('Male Image',
                style: TextStyle(fontWeight: FontWeight.bold)),
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
                      settings.setMaleImage(
                        result.files.first.path,
                        isAsset: false,
                      );
                    }
                  },
                  child: const Text('Select Male Image'),
                ),
                const SizedBox(width: 16),
                if (settings.maleImagePath != null &&
                    !settings.isMaleImageAsset)
                  ElevatedButton(
                    onPressed: () {
                      settings.setMaleImage('assets/images/male_avatar.png',
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
                    border: Border.all(color: Colors.grey),
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

            const SizedBox(height: 16),

            // Female Image
            const Text('Female Image',
                style: TextStyle(fontWeight: FontWeight.bold)),
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
                      settings.setFemaleImage(
                        result.files.first.path,
                        isAsset: false,
                      );
                    }
                  },
                  child: const Text('Select Female Image'),
                ),
                const SizedBox(width: 16),
                if (settings.femaleImagePath != null &&
                    !settings.isFemaleImageAsset)
                  ElevatedButton(
                    onPressed: () {
                      settings.setFemaleImage('assets/images/female_avatar.png',
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
                    border: Border.all(color: Colors.grey),
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

            const SizedBox(height: 16),

            // Image Dimensions
            _buildSectionSubtitle('Image Dimensions'),

            _buildSliderWithLabel(
              label: 'Image Width',
              value: settings.imageWidth,
              min: 80.0,
              max: 300.0,
              divisions: 22,
              onChanged: (value) {
                settings.setImageDimensions(value, settings.imageHeight);
              },
            ),

            _buildSliderWithLabel(
              label: 'Image Height',
              value: settings.imageHeight,
              min: 80.0,
              max: 300.0,
              divisions: 22,
              onChanged: (value) {
                settings.setImageDimensions(settings.imageWidth, value);
              },
            ),

            _buildSliderWithLabel(
              label: 'Spacing Between Images',
              value: settings.imageSpacing,
              min: 0.0,
              max: 100.0,
              divisions: 20,
              onChanged: (value) {
                settings.setImageSpacing(value);
              },
            ),

            _buildSliderWithLabel(
              label: 'Image Border Radius',
              value: settings.imageBorderRadius,
              min: 0.0,
              max: 50.0,
              divisions: 50,
              onChanged: (value) {
                settings.setImageBorder(borderRadius: value);
              },
            ),

            const SizedBox(height: 16),

            // Image Border Settings
            SwitchListTile(
              title: const Text('Show Image Border'),
              value: settings.showImageBorder,
              onChanged: (value) {
                settings.setImageBorder(showBorder: value);
              },
            ),

            if (settings.showImageBorder) ...[
              const SizedBox(height: 16),
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
                trailing: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: settings.imageBorderColor,
                    border: Border.all(color: Colors.grey),
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
              title: const Text('Use Selection Effect'),
              subtitle: const Text('Scale up selected gender image'),
              value: settings.useSelectionEffect,
              onChanged: (value) {
                settings.setSelectionEffect(useEffect: value);
              },
            ),

            if (settings.useSelectionEffect) ...[
              const SizedBox(height: 16),
              Slider(
                value: settings.selectedImageScale,
                min: 1.0,
                max: 1.3,
                divisions: 6,
                label: settings.selectedImageScale.toStringAsFixed(2),
                onChanged: (value) {
                  settings.setSelectionEffect(scale: value);
                },
              ),
              const Text('Selected Image Scale Factor',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Use Selection Glow'),
                subtitle: const Text('Add glow effect to selected image'),
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
                    final color = await _showImprovedColorPicker(
                        title: "Select Glow Color",
                        context: context,
                        color: settings.selectionGlowColor);
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

            // Button Settings
            _buildSectionTitle('Button Settings'),

            SwitchListTile(
              title: const Text('Use Image Button'),
              value: settings.useImageButton,
              onChanged: (value) {
                settings.setUseImageButton(value);
              },
            ),

            const SizedBox(height: 16),

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

              const SizedBox(height: 16),

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
                      trailing: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: settings.buttonTextColor,
                          border: Border.all(color: Colors.grey),
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

              const SizedBox(height: 16),

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

            const SizedBox(height: 16),

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
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
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
                ),
              ],
            ),

            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Button Border'),
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
              Colors.white,
              Colors.black,
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
