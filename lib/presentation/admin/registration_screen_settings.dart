import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/providers/registration_screen_provider.dart';
import 'package:photobooth_flutter/widgets/improved_color_picker.dart';
import 'package:provider/provider.dart';

class RegistrationScreenSettings extends StatefulWidget {
  const RegistrationScreenSettings({super.key});

  @override
  State<RegistrationScreenSettings> createState() =>
      _RegistrationScreenSettingsState();
}

class _RegistrationScreenSettingsState
    extends State<RegistrationScreenSettings> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<RegistrationScreenProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration Screen Settings'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enable/Disable Registration Screen
              SwitchListTile(
                title: const Text('Show Registration Screen'),
                subtitle:
                    const Text('Enable or disable the registration screen'),
                value: settings.showRegistrationScreen,
                onChanged: (value) {
                  settings.setShowRegistrationScreen(value);
                },
              ),

              const Divider(),

              // Title Settings
              const Text(
                'Title Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Enable/Disable Title
              SwitchListTile(
                title: const Text('Show Title'),
                subtitle: const Text('Enable or disable the title'),
                value: settings.showTitle,
                onChanged: (value) {
                  settings.setShowTitle(value);
                },
              ),

              if (settings.showTitle) ...[
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

                // Font Size
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
                            settings.setTitleFontSize(size);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        initialValue: settings.titleLineHeight.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Line Height',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final height = double.tryParse(value);
                          if (height != null) {
                            settings.setTitleLineHeight(height);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Font Weight
                DropdownButtonFormField<FontWeight>(
                  value: settings.titleFontWeight,
                  decoration: const InputDecoration(
                    labelText: 'Font Weight',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: FontWeight.normal,
                      child: Text('Normal'),
                    ),
                    const DropdownMenuItem(
                      value: FontWeight.bold,
                      child: Text('Bold'),
                    ),
                    const DropdownMenuItem(
                      value: FontWeight.w100,
                      child: Text('Thin'),
                    ),
                    const DropdownMenuItem(
                      value: FontWeight.w300,
                      child: Text('Light'),
                    ),
                    const DropdownMenuItem(
                      value: FontWeight.w500,
                      child: Text('Medium'),
                    ),
                    const DropdownMenuItem(
                      value: FontWeight.w900,
                      child: Text('Black'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      settings.setTitleFontWeight(value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Text Align
                DropdownButtonFormField<TextAlign>(
                  value: settings.titleTextAlign,
                  decoration: const InputDecoration(
                    labelText: 'Text Align',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: TextAlign.left,
                      child: Text('Left'),
                    ),
                    const DropdownMenuItem(
                      value: TextAlign.center,
                      child: Text('Center'),
                    ),
                    const DropdownMenuItem(
                      value: TextAlign.right,
                      child: Text('Right'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      settings.setTitleTextAlign(value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Text Color
                ListTile(
                  title: const Text('Title Text Color'),
                  trailing: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: settings.titleTextColor,
                      border: Border.all(color: Colors.grey),
                    ),
                  ),
                  onTap: () async {
                    final color = await _buildColorPickerWithLabel(
                      context,
                      settings.titleTextColor,
                      label: 'Title Text Color',
                    );
                    if (color != null) {
                      settings.setTitleTextColor(color);
                    }
                  },
                ),

                // Title Margins
                _buildSectionHeader('Title Margins'),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: settings.titleMargin.top.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Top',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final top = double.tryParse(value);
                          if (top != null) {
                            settings.setTitleMargin(EdgeInsets.fromLTRB(
                              settings.titleMargin.left,
                              top,
                              settings.titleMargin.right,
                              settings.titleMargin.bottom,
                            ));
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: settings.titleMargin.bottom.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Bottom',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final bottom = double.tryParse(value);
                          if (bottom != null) {
                            settings.setTitleMargin(EdgeInsets.fromLTRB(
                              settings.titleMargin.left,
                              settings.titleMargin.top,
                              settings.titleMargin.right,
                              bottom,
                            ));
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: settings.titleMargin.left.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Left',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final left = double.tryParse(value);
                          if (left != null) {
                            settings.setTitleMargin(EdgeInsets.fromLTRB(
                              left,
                              settings.titleMargin.top,
                              settings.titleMargin.right,
                              settings.titleMargin.bottom,
                            ));
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: settings.titleMargin.right.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Right',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final right = double.tryParse(value);
                          if (right != null) {
                            settings.setTitleMargin(EdgeInsets.fromLTRB(
                              settings.titleMargin.left,
                              settings.titleMargin.top,
                              right,
                              settings.titleMargin.bottom,
                            ));
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],

              const Divider(),

              // Background Image Settings
              const Text(
                'Background Image',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
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
                        await settings.setRegistrationScreenBackground(
                          result.files.first.path,
                          isAsset: false,
                        );
                      }
                    },
                    child: const Text('Select Background Image'),
                  ),
                  const SizedBox(width: 16),
                  if (settings.registrationScreenBackground != null)
                    ElevatedButton(
                      onPressed: () {
                        settings.setRegistrationScreenBackground(null);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Remove Background'),
                    ),
                ],
              ),

              if (settings.registrationScreenBackground != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    width: 200,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      image: DecorationImage(
                        image: settings.isRegistrationScreenBackgroundAsset
                            ? AssetImage(settings.registrationScreenBackground!)
                            : FileImage(File(
                                    settings.registrationScreenBackground!))
                                as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

              const Divider(),

              // Text Fields Settings
              const Text(
                'Text Fields',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Add Text Field Button
              if (settings.textFields.length < 3)
                ElevatedButton(
                  onPressed: () {
                    settings.addTextField();
                  },
                  child: const Text('Add Text Field'),
                ),

              const SizedBox(height: 16),

              // Text Fields List
              ...settings.textFields
                  .map((field) => _buildTextFieldCard(field, settings)),

              const Divider(),

              // Spacing Settings
              const Text(
                'Spacing Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: settings.fieldSpacing.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Field Spacing',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final spacing = double.tryParse(value);
                        if (spacing != null) {
                          settings.setFieldSpacing(spacing);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: settings.buttonSpacing.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Button Spacing',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final spacing = double.tryParse(value);
                        if (spacing != null) {
                          settings.setButtonSpacing(spacing);
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              TextFormField(
                initialValue: settings.borderRadius.toString(),
                decoration: const InputDecoration(
                  labelText: 'Border Radius',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final radius = double.tryParse(value);
                  if (radius != null) {
                    settings.setBorderRadius(radius);
                  }
                },
              ),

              const Divider(),

              // Button Settings
              const Text(
                'Button Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Button Type
              SwitchListTile(
                title: const Text('Use Image Button'),
                subtitle: const Text('Toggle between text and image button'),
                value: settings.useImageButton,
                onChanged: (value) {
                  settings.setUseImageButton(value);
                },
              ),

              if (settings.useImageButton)
                _buildImageButtonSettings(settings)
              else
                _buildTextButtonSettings(settings),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSliderWithLabel({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Function(double) onChanged,
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

  Future<Color?> _buildColorPickerWithLabel(BuildContext context, Color color,
      {String label = 'Color'}) async {
    Color? selectedColor;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select $label'),
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
            child: const Text('Done'),
          ),
        ],
      ),
    );

    return selectedColor;
  }

  Widget _buildSwitchWithLabel({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDropdownWithLabel<T>({
    required String label,
    required T value,
    required Map<T, String> items,
    required Function(T?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          DropdownButton<T>(
            value: value,
            onChanged: onChanged,
            items: items.entries.map((entry) {
              return DropdownMenuItem<T>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldCard(
      CustomTextField field, RegistrationScreenProvider settings) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  field.label,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Switch(
                      value: field.isEnabled,
                      onChanged: (value) {
                        settings.toggleTextFieldEnabled(field.id, value);
                      },
                    ),
                    const SizedBox(width: 8),
                    if (settings.textFields.length > 1)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          settings.removeTextField(field.id);
                        },
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDropdownWithLabel<TextFieldType>(
              label: 'Field Type',
              value: field.fieldType,
              items: TextFieldType.values.asMap().map((key, value) => MapEntry(
                  value,
                  value
                      .toString())), // Convert enum to Map<TextFieldType, String>
              onChanged: (TextFieldType? newValue) {
                if (newValue != null) {
                  // Create a new field object with the updated type
                  final updatedField = CustomTextField(
                    id: field.id,
                    label: field.label, // Keep existing values
                    hintText: field.hintText,
                    isEnabled: field.isEnabled,
                    isRequired: field.isRequired,
                    fillColor: field.fillColor,
                    textColor: field.textColor,
                    labelColor: field.labelColor,
                    fontSize: field.fontSize,
                    fontWeight: field.fontWeight,
                    isItalic: field.isItalic,
                    hasBorder: field.hasBorder,
                    borderWidth: field.borderWidth,
                    borderColor: field.borderColor,
                    borderRadius: field.borderRadius,
                    width: field.width,
                    height: field.height,
                    margin: field.margin,
                    padding: field.padding,
                    fieldType: newValue, // Set the new type
                  );
                  settings.updateTextField(field.id, updatedField);
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: field.label,
              decoration: const InputDecoration(
                labelText: 'Label',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final updatedField = CustomTextField(
                  id: field.id,
                  label: value, // Updated value
                  hintText: field.hintText,
                  isEnabled: field.isEnabled,
                  isRequired: field.isRequired,
                  fillColor: field.fillColor,
                  textColor: field.textColor,
                  labelColor: field.labelColor,
                  fontSize: field.fontSize,
                  fontWeight: field.fontWeight,
                  isItalic: field.isItalic,
                  hasBorder: field.hasBorder,
                  borderWidth: field.borderWidth,
                  borderColor: field.borderColor,
                  borderRadius: field.borderRadius,
                  width: field.width,
                  height: field.height,
                  margin: field.margin,
                  padding: field.padding,
                  fieldType: field.fieldType, // Preserve existing type
                );
                settings.updateTextField(field.id, updatedField);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: field.hintText,
              decoration: const InputDecoration(
                labelText: 'Hint Text',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // IMPORTANT: Preserve fieldType
                final updatedField = CustomTextField(
                  id: field.id,
                  label: field.label,
                  hintText: value, // Updated value
                  isEnabled: field.isEnabled,
                  isRequired: field.isRequired,
                  fillColor: field.fillColor,
                  textColor: field.textColor,
                  labelColor: field.labelColor,
                  fontSize: field.fontSize,
                  fontWeight: field.fontWeight,
                  isItalic: field.isItalic,
                  hasBorder: field.hasBorder,
                  borderWidth: field.borderWidth,
                  borderColor: field.borderColor,
                  borderRadius: field.borderRadius,
                  width: field.width,
                  height: field.height,
                  margin: field.margin,
                  padding: field.padding,
                  fieldType: field.fieldType, // Preserve existing type
                );
                settings.updateTextField(field.id, updatedField);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: field.width.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Width (% of screen)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final width = double.tryParse(value);
                      if (width != null) {
                        final updatedField = CustomTextField(
                          id: field.id,
                          label: field.label,
                          hintText: field.hintText,
                          fieldType: field.fieldType,
                          isEnabled: field.isEnabled,
                          isRequired: field.isRequired,
                          fillColor: field.fillColor,
                          textColor: field.textColor,
                          labelColor: field.labelColor,
                          fontSize: field.fontSize,
                          hasBorder: field.hasBorder,
                          borderWidth: field.borderWidth,
                          borderColor: field.borderColor,
                          width: width,
                          height: field.height,
                        );
                        settings.updateTextField(field.id, updatedField);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: field.height.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Height',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final height = double.tryParse(value);
                      if (height != null) {
                        final updatedField = CustomTextField(
                          id: field.id,
                          label: field.label,
                          hintText: field.hintText,
                          fieldType: field.fieldType,
                          isEnabled: field.isEnabled,
                          isRequired: field.isRequired,
                          fillColor: field.fillColor,
                          textColor: field.textColor,
                          labelColor: field.labelColor,
                          fontSize: field.fontSize,
                          hasBorder: field.hasBorder,
                          borderWidth: field.borderWidth,
                          borderColor: field.borderColor,
                          width: field.width,
                          height: height,
                        );
                        settings.updateTextField(field.id, updatedField);
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
                    initialValue: field.fontSize.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Font Size',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final fontSize = double.tryParse(value);
                      if (fontSize != null) {
                        final updatedField = CustomTextField(
                          id: field.id,
                          label: field.label,
                          hintText: field.hintText,
                          fieldType: field.fieldType,
                          isEnabled: field.isEnabled,
                          isRequired: field.isRequired,
                          fillColor: field.fillColor,
                          textColor: field.textColor,
                          labelColor: field.labelColor,
                          fontSize: fontSize,
                          hasBorder: field.hasBorder,
                          borderWidth: field.borderWidth,
                          borderColor: field.borderColor,
                          width: field.width,
                          height: field.height,
                        );
                        settings.updateTextField(field.id, updatedField);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SwitchListTile(
                    title: const Text('Required'),
                    value: field.isRequired,
                    onChanged: (value) {
                      final updatedField = CustomTextField(
                        id: field.id,
                        label: field.label,
                        hintText: field.hintText,
                        fieldType: field.fieldType,
                        isEnabled: field.isEnabled,
                        isRequired: value,
                        fillColor: field.fillColor,
                        textColor: field.textColor,
                        labelColor: field.labelColor,
                        fontSize: field.fontSize,
                        hasBorder: field.hasBorder,
                        borderWidth: field.borderWidth,
                        borderColor: field.borderColor,
                        width: field.width,
                        height: field.height,
                      );
                      settings.updateTextField(field.id, updatedField);
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
                    title: const Text('Fill Color'),
                    trailing: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: field.fillColor,
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                    onTap: () async {
                      final color = await _buildColorPickerWithLabel(
                          context, field.fillColor);
                      if (color != null) {
                        final updatedField = CustomTextField(
                          id: field.id,
                          label: field.label,
                          hintText: field.hintText,
                          fieldType: field.fieldType,
                          isEnabled: field.isEnabled,
                          isRequired: field.isRequired,
                          fillColor: color,
                          textColor: field.textColor,
                          labelColor: field.labelColor,
                          fontSize: field.fontSize,
                          hasBorder: field.hasBorder,
                          borderWidth: field.borderWidth,
                          borderColor: field.borderColor,
                          width: field.width,
                          height: field.height,
                        );
                        settings.updateTextField(field.id, updatedField);
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
                        color: field.textColor,
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                    onTap: () async {
                      final color = await _buildColorPickerWithLabel(
                          context, field.textColor);
                      if (color != null) {
                        final updatedField = CustomTextField(
                          id: field.id,
                          label: field.label,
                          hintText: field.hintText,
                          fieldType: field.fieldType,
                          isEnabled: field.isEnabled,
                          isRequired: field.isRequired,
                          fillColor: field.fillColor,
                          textColor: color,
                          labelColor: field.labelColor,
                          fontSize: field.fontSize,
                          hasBorder: field.hasBorder,
                          borderWidth: field.borderWidth,
                          borderColor: field.borderColor,
                          width: field.width,
                          height: field.height,
                        );
                        settings.updateTextField(field.id, updatedField);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Label Color'),
                    trailing: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: field.labelColor,
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                    onTap: () async {
                      final color = await _buildColorPickerWithLabel(
                          context, field.labelColor);
                      if (color != null) {
                        final updatedField = CustomTextField(
                          id: field.id,
                          label: field.label,
                          hintText: field.hintText,
                          fieldType: field.fieldType,
                          isEnabled: field.isEnabled,
                          isRequired: field.isRequired,
                          fillColor: field.fillColor,
                          textColor: field.textColor,
                          labelColor: color,
                          fontSize: field.fontSize,
                          hasBorder: field.hasBorder,
                          borderWidth: field.borderWidth,
                          borderColor: field.borderColor,
                          width: field.width,
                          height: field.height,
                        );
                        settings.updateTextField(field.id, updatedField);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: SwitchListTile(
                    title: const Text('Border'),
                    value: field.hasBorder,
                    onChanged: (value) {
                      final updatedField = CustomTextField(
                        id: field.id,
                        label: field.label,
                        hintText: field.hintText,
                        fieldType: field.fieldType,
                        isEnabled: field.isEnabled,
                        isRequired: field.isRequired,
                        fillColor: field.fillColor,
                        textColor: field.textColor,
                        labelColor: field.labelColor,
                        fontSize: field.fontSize,
                        hasBorder: value,
                        borderWidth: field.borderWidth,
                        borderColor: field.borderColor,
                        width: field.width,
                        height: field.height,
                      );
                      settings.updateTextField(field.id, updatedField);
                    },
                  ),
                ),
              ],
            ),
            if (field.hasBorder)
              Column(
                children: [
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: field.borderWidth.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Border Width',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final width = double.tryParse(value);
                            if (width != null) {
                              final updatedField = CustomTextField(
                                id: field.id,
                                label: field.label,
                                hintText: field.hintText,
                                fieldType: field.fieldType,
                                isEnabled: field.isEnabled,
                                isRequired: field.isRequired,
                                fillColor: field.fillColor,
                                textColor: field.textColor,
                                labelColor: field.labelColor,
                                fontSize: field.fontSize,
                                hasBorder: field.hasBorder,
                                borderWidth: width,
                                borderColor: field.borderColor,
                                width: field.width,
                                height: field.height,
                              );
                              settings.updateTextField(field.id, updatedField);
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
                              color: field.borderColor,
                              border: Border.all(color: Colors.grey),
                            ),
                          ),
                          onTap: () async {
                            final color = await _buildColorPickerWithLabel(
                                context, field.borderColor);
                            if (color != null) {
                              final updatedField = CustomTextField(
                                id: field.id,
                                label: field.label,
                                hintText: field.hintText,
                                fieldType: field.fieldType,
                                isEnabled: field.isEnabled,
                                isRequired: field.isRequired,
                                fillColor: field.fillColor,
                                textColor: field.textColor,
                                labelColor: field.labelColor,
                                fontSize: field.fontSize,
                                hasBorder: field.hasBorder,
                                borderWidth: field.borderWidth,
                                borderColor: color,
                                width: field.width,
                                height: field.height,
                              );
                              settings.updateTextField(field.id, updatedField);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            _buildSectionHeader('Text Field Styling'),

            // Font Weight
            _buildDropdownWithLabel<FontWeight>(
              label: 'Font Weight',
              value: field.fontWeight,
              items: {
                FontWeight.w100: 'Thin',
                FontWeight.w300: 'Light',
                FontWeight.w400: 'Regular',
                FontWeight.w500: 'Medium',
                FontWeight.w700: 'Bold',
                FontWeight.w900: 'Black',
              },
              onChanged: (value) {
                if (value != null) {
                  settings.updateTextFieldStyle(
                    id: field.id,
                    fontWeight: value,
                  );
                }
              },
            ),

            // Font Style (Italic)
            _buildSwitchWithLabel(
              label: 'Italic',
              value: field.isItalic,
              onChanged: (value) {
                settings.updateTextFieldStyle(
                  id: field.id,
                  isItalic: value,
                );
              },
            ),

            // Border Radius
            _buildSliderWithLabel(
              label: 'Border Radius',
              value: field.borderRadius,
              min: 0,
              max: 30,
              divisions: 30,
              onChanged: (value) {
                settings.updateTextFieldStyle(
                  id: field.id,
                  borderRadius: value,
                );
              },
            ),

            // Margins
            _buildSectionHeader('Margins'),

            _buildSliderWithLabel(
              label: 'Top Margin',
              value: field.margin.top,
              min: 0,
              max: 50,
              divisions: 50,
              onChanged: (value) {
                settings.updateTextFieldStyle(
                  id: field.id,
                  margin: EdgeInsets.fromLTRB(
                    field.margin.left,
                    value,
                    field.margin.right,
                    field.margin.bottom,
                  ),
                );
              },
            ),

            _buildSliderWithLabel(
              label: 'Bottom Margin',
              value: field.margin.bottom,
              min: 0,
              max: 50,
              divisions: 50,
              onChanged: (value) {
                settings.updateTextFieldStyle(
                  id: field.id,
                  margin: EdgeInsets.fromLTRB(
                    field.margin.left,
                    field.margin.top,
                    field.margin.right,
                    value,
                  ),
                );
              },
            ),

            _buildSliderWithLabel(
              label: 'Left Margin',
              value: field.margin.left,
              min: 0,
              max: 50,
              divisions: 50,
              onChanged: (value) {
                settings.updateTextFieldStyle(
                  id: field.id,
                  margin: EdgeInsets.fromLTRB(
                    value,
                    field.margin.top,
                    field.margin.right,
                    field.margin.bottom,
                  ),
                );
              },
            ),

            _buildSliderWithLabel(
              label: 'Right Margin',
              value: field.margin.right,
              min: 0,
              max: 50,
              divisions: 50,
              onChanged: (value) {
                settings.updateTextFieldStyle(
                  id: field.id,
                  margin: EdgeInsets.fromLTRB(
                    field.margin.left,
                    field.margin.top,
                    value,
                    field.margin.bottom,
                  ),
                );
              },
            ),

            // Padding
            _buildSectionHeader('Padding'),

            _buildSliderWithLabel(
              label: 'Top Padding',
              value: field.padding.top,
              min: 0,
              max: 30,
              divisions: 30,
              onChanged: (value) {
                settings.updateTextFieldStyle(
                  id: field.id,
                  padding: EdgeInsets.fromLTRB(
                    field.padding.left,
                    value,
                    field.padding.right,
                    field.padding.bottom,
                  ),
                );
              },
            ),

            _buildSliderWithLabel(
              label: 'Bottom Padding',
              value: field.padding.bottom,
              min: 0,
              max: 30,
              divisions: 30,
              onChanged: (value) {
                settings.updateTextFieldStyle(
                  id: field.id,
                  padding: EdgeInsets.fromLTRB(
                    field.padding.left,
                    field.padding.top,
                    field.padding.right,
                    value,
                  ),
                );
              },
            ),

            _buildSliderWithLabel(
              label: 'Left Padding',
              value: field.padding.left,
              min: 0,
              max: 30,
              divisions: 30,
              onChanged: (value) {
                settings.updateTextFieldStyle(
                  id: field.id,
                  padding: EdgeInsets.fromLTRB(
                    value,
                    field.padding.top,
                    field.padding.right,
                    field.padding.bottom,
                  ),
                );
              },
            ),

            _buildSliderWithLabel(
              label: 'Right Padding',
              value: field.padding.right,
              min: 0,
              max: 30,
              divisions: 30,
              onChanged: (value) {
                settings.updateTextFieldStyle(
                  id: field.id,
                  padding: EdgeInsets.fromLTRB(
                    field.padding.left,
                    field.padding.top,
                    value,
                    field.padding.bottom,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextButtonSettings(RegistrationScreenProvider settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        TextFormField(
          initialValue: settings.submitButtonText,
          decoration: const InputDecoration(
            labelText: 'Button Text',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            settings.setSubmitButtonText(value);
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
                    settings.setButtonDimensions(width, settings.buttonHeight);
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
                    settings.setButtonDimensions(settings.buttonWidth, height);
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
                    settings.setButtonBorderRadius(radius);
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                initialValue: settings.buttonFontSize.toString(),
                decoration: const InputDecoration(
                  labelText: 'Button Font Size',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final size = double.tryParse(value);
                  if (size != null) {
                    settings.setButtonFontSize(size);
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
                    color: settings.submitButtonColor,
                    border: Border.all(color: Colors.grey),
                  ),
                ),
                onTap: () async {
                  final color = await _buildColorPickerWithLabel(
                      context, settings.submitButtonTextColor);
                  if (color != null) {
                    settings.setSubmitButtonTextColor(color);
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
                    color: settings.submitButtonTextColor,
                    border: Border.all(color: Colors.grey),
                  ),
                ),
                onTap: () async {
                  final color = await _buildColorPickerWithLabel(
                      context, settings.submitButtonTextColor,
                      label: "Button Text Color");
                  if (color != null) {
                    settings.setSubmitButtonTextColor(color);
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
            settings.setButtonBorder(
              value,
              settings.buttonBorderWidth,
              settings.buttonBorderColor,
            );
          },
        ),
        if (settings.buttonHasBorder)
          Column(
            children: [
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
                          settings.setButtonBorder(
                            settings.buttonHasBorder,
                            width,
                            settings.buttonBorderColor,
                          );
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
                        final color = await _buildColorPickerWithLabel(
                            context, settings.buttonBorderColor);
                        if (color != null) {
                          settings.setButtonBorder(
                            settings.buttonHasBorder,
                            settings.buttonBorderWidth,
                            color,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        _buildSectionHeader('Button Text Styling'),
        _buildDropdownWithLabel<FontWeight>(
          label: 'Font Weight',
          value: settings.buttonFontWeight,
          items: {
            FontWeight.w100: 'Thin',
            FontWeight.w300: 'Light',
            FontWeight.w400: 'Regular',
            FontWeight.w500: 'Medium',
            FontWeight.w700: 'Bold',
            FontWeight.w900: 'Black',
          },
          onChanged: (value) {
            if (value != null) {
              settings.setButtonFontWeight(value);
            }
          },
        ),
        _buildSwitchWithLabel(
          label: 'Italic',
          value: settings.buttonIsItalic,
          onChanged: (value) {
            settings.setButtonIsItalic(value);
          },
        ),
        _buildSectionHeader('Button Opacity'),
        _buildSliderWithLabel(
          label: 'Button Opacity',
          value: settings.buttonOpacity,
          min: 0.1,
          max: 1.0,
          divisions: 9,
          onChanged: (value) {
            settings.setButtonOpacity(value);
          },
        ),
        _buildSliderWithLabel(
          label: 'Text Opacity',
          value: settings.buttonTextOpacity,
          min: 0.1,
          max: 1.0,
          divisions: 9,
          onChanged: (value) {
            settings.setButtonTextOpacity(value);
          },
        ),
        _buildSectionHeader('Button Margins'),
        _buildSliderWithLabel(
          label: 'Top Margin',
          value: settings.buttonMargin.top,
          min: 0,
          max: 50,
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
          min: 0,
          max: 50,
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
          min: 0,
          max: 50,
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
          min: 0,
          max: 50,
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
        _buildSectionHeader('Button Padding'),
        _buildSliderWithLabel(
          label: 'Vertical Padding',
          value: settings.buttonPadding.top, // Using top as vertical
          min: 0,
          max: 30,
          divisions: 30,
          onChanged: (value) {
            settings.setButtonPadding(EdgeInsets.symmetric(
              vertical: value,
              horizontal:
                  settings.buttonPadding.left, // Using left as horizontal
            ));
          },
        ),
        _buildSliderWithLabel(
          label: 'Horizontal Padding',
          value: settings.buttonPadding.left, // Using left as horizontal
          min: 0,
          max: 50,
          divisions: 50,
          onChanged: (value) {
            settings.setButtonPadding(EdgeInsets.symmetric(
              vertical: settings.buttonPadding.top, // Using top as vertical
              horizontal: value,
            ));
          },
        ),
      ],
    );
  }

  Widget _buildImageButtonSettings(RegistrationScreenProvider settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  await settings.setButtonImage(
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
              height: 60,
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
                    settings.setButtonDimensions(width, settings.buttonHeight);
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
                    settings.setButtonDimensions(settings.buttonWidth, height);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: settings.buttonBorderRadius.toString(),
          decoration: const InputDecoration(
            labelText: 'Button Border Radius',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final radius = double.tryParse(value);
            if (radius != null) {
              settings.setButtonBorderRadius(radius);
            }
          },
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Button Border'),
          value: settings.buttonHasBorder,
          onChanged: (value) {
            settings.setButtonBorder(
              value,
              settings.buttonBorderWidth,
              settings.buttonBorderColor,
            );
          },
        ),
        if (settings.buttonHasBorder)
          Column(
            children: [
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
                          settings.setButtonBorder(
                            settings.buttonHasBorder,
                            width,
                            settings.buttonBorderColor,
                          );
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
                        final color = await _buildColorPickerWithLabel(
                            context, settings.buttonBorderColor);
                        if (color != null) {
                          settings.setButtonBorder(
                            settings.buttonHasBorder,
                            settings.buttonBorderWidth,
                            color,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        _buildSectionHeader('Image Button Opacity'),
        _buildSliderWithLabel(
          label: 'Image Opacity',
          value: settings.buttonImageOpacity,
          min: 0.1,
          max: 1.0,
          divisions: 9,
          onChanged: (value) {
            settings.setButtonImageOpacity(value);
          },
        ),
        _buildSectionHeader('Image Button Margins'),
        _buildSliderWithLabel(
          label: 'Top Margin',
          value: settings.buttonMargin.top,
          min: 0,
          max: 50,
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
          min: 0,
          max: 50,
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
          min: 0,
          max: 50,
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
          min: 0,
          max: 50,
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
      ],
    );
  }
}
