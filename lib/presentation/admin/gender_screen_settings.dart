import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/providers/gender_selection_provider.dart';
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

            // Gender Images Settings
            _buildSectionTitle('Gender Images Settings'),

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
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: settings.imageWidth.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Image Width',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final width = double.tryParse(value);
                      if (width != null) {
                        settings.setImageDimensions(
                            width, settings.imageHeight);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: settings.imageHeight.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Image Height',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final height = double.tryParse(value);
                      if (height != null) {
                        settings.setImageDimensions(
                            settings.imageWidth, height);
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            TextFormField(
              initialValue: settings.imageSpacing.toString(),
              decoration: const InputDecoration(
                labelText: 'Spacing Between Images',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final spacing = double.tryParse(value);
                if (spacing != null) {
                  settings.setImageSpacing(spacing);
                }
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              initialValue: settings.imageBorderRadius.toString(),
              decoration: const InputDecoration(
                labelText: 'Image Border Radius',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final radius = double.tryParse(value);
                if (radius != null) {
                  settings.setImageBorder(borderRadius: radius);
                }
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
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: settings.imageBorderWidth.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Border Width',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final width = double.tryParse(value);
                        if (width != null) {
                          settings.setImageBorder(borderWidth: width);
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
                          color: settings.imageBorderColor,
                          border: Border.all(color: Colors.grey),
                        ),
                      ),
                      onTap: () async {
                        final color = await _showColorPicker(
                            context, settings.imageBorderColor);
                        if (color != null) {
                          settings.setImageBorder(borderColor: color);
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
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14)),
              
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<Color?> _showColorPicker(
      BuildContext context, Color initialColor) async {
    Color selectedColor = initialColor;

    return showDialog<Color>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Simple color picker with predefined colors
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _colorOption(Colors.white, selectedColor, (color) {
                      selectedColor = color;
                    }),
                    _colorOption(Colors.black, selectedColor, (color) {
                      selectedColor = color;
                    }),
                    _colorOption(Colors.red, selectedColor, (color) {
                      selectedColor = color;
                    }),
                    _colorOption(Colors.green, selectedColor, (color) {
                      selectedColor = color;
                    }),
                    _colorOption(Colors.blue, selectedColor, (color) {
                      selectedColor = color;
                    }),
                    _colorOption(Colors.yellow, selectedColor, (color) {
                      selectedColor = color;
                    }),
                    _colorOption(Colors.orange, selectedColor, (color) {
                      selectedColor = color;
                    }),
                    _colorOption(Colors.purple, selectedColor, (color) {
                      selectedColor = color;
                    }),
                    _colorOption(Colors.pink, selectedColor, (color) {
                      selectedColor = color;
                    }),
                    _colorOption(Colors.teal, selectedColor, (color) {
                      selectedColor = color;
                    }),
                    _colorOption(Colors.grey, selectedColor, (color) {
                      selectedColor = color;
                    }),
                    _colorOption(AppColors.goldenYellow, selectedColor,
                        (color) {
                      selectedColor = color;
                    }),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(selectedColor);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _colorOption(
      Color color, Color selectedColor, Function(Color) onSelect) {
    final isSelected = color.value == selectedColor.value;

    return GestureDetector(
      onTap: () {
        onSelect(color);
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
