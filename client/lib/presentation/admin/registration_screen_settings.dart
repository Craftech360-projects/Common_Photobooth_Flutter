import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/constants/constants.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/presentation/registration_screen.dart';
import 'package:photobooth_flutter/providers/registration_screen_provider.dart';
import 'package:photobooth_flutter/widgets/improved_color_picker.dart';
import 'package:photobooth_flutter/widgets/settings_preview.dart';
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
        child: Row(
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
                child: const ParticipantDetailsScreen(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Enable/Disable Registration Screen
                    SwitchListTile(
                      title: const Text('Show Registration Screen'),
                      subtitle: const Text(
                          'Enable or disable the registration screen'),
                      value: settings.showRegistrationScreen,
                      onChanged: (value) {
                        settings.setShowRegistrationScreen(value);
                      },
                    ),

                    const Divider(),

                    // Title Settings
                    const Text(
                      'Title Settings',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Constants.h8,

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
                      Constants.h16,

                      // Font Size
                      _buildSliderWithLabel(
                        label: 'Font Size',
                        value: settings.titleFontSize,
                        min: 12,
                        max: 80,
                        divisions: 68,
                        onChanged: (value) => settings.setTitleFontSize(value),
                      ),

                      _buildSliderWithLabel(
                        label: 'Line Height',
                        value: settings.titleLineHeight,
                        min: 0.8,
                        max: 2.0,
                        divisions: 24,
                        onChanged: (value) =>
                            settings.setTitleLineHeight(value),
                      ),
                      Constants.w16,
                      Constants.h16,

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
                      Constants.h16,

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
                      Constants.h16,

                      // Text Color
                      ListTile(
                        title: const Text('Title Text Color'),
                        leading: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: settings.titleTextColor,
                            border: Border.all(color: AppColors.black),
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
                      // Title Margins
                      _buildSectionHeader('Title Margins'),
                      _buildSliderWithLabel(
                        label: 'Top Margin',
                        value: settings.titleMargin.top,
                        min: 0,
                        max: 350,
                        divisions: 60,
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
                        label: 'Left Margin',
                        value: settings.titleMargin.left,
                        min: 0,
                        max: 350,
                        divisions: 60,
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
                        min: 0,
                        max: 350,
                        divisions: 60,
                        onChanged: (value) {
                          settings.setTitleMargin(EdgeInsets.fromLTRB(
                            settings.titleMargin.left,
                            settings.titleMargin.top,
                            value,
                            settings.titleMargin.bottom,
                          ));
                        },
                      ),
                      _buildSliderWithLabel(
                        label: 'Bottom Margin',
                        value: settings.titleMargin.bottom,
                        min: 0,
                        max: 350,
                        divisions: 60,
                        onChanged: (value) {
                          settings.setTitleMargin(EdgeInsets.fromLTRB(
                            settings.titleMargin.left,
                            settings.titleMargin.top,
                            settings.titleMargin.right,
                            value,
                          ));
                        },
                      ),
                    ],

                    const Divider(),

                    // Background Image Settings
                    const Text(
                      'Background Image',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
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
                              await settings.setRegistrationScreenBackground(
                                result.files.first.path,
                                isAsset: false,
                              );
                            }
                          },
                          child: const Text('Select Background Image'),
                        ),
                        Constants.w16,
                        if (settings.registrationScreenBackground != null)
                          ElevatedButton(
                            onPressed: () {
                              settings.setRegistrationScreenBackground(null);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.red,
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
                            border: Border.all(color: AppColors.grey),
                            image: DecorationImage(
                              image: settings
                                      .isRegistrationScreenBackgroundAsset
                                  ? AssetImage(
                                      settings.registrationScreenBackground!)
                                  : FileImage(File(settings
                                          .registrationScreenBackground!))
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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Constants.h8,

                    // Add Text Field Button
                    if (settings.textFields.length < 3)
                      ElevatedButton(
                        onPressed: () {
                          settings.addTextField();
                        },
                        child: const Text('Add Text Field'),
                      ),

                    Constants.h16,

                    // Text Fields List
                    ...settings.textFields
                        .map((field) => _buildTextFieldCard(field, settings)),

                    const Divider(),

                    // Spacing Settings
                    const Text(
                      'Spacing Settings',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Constants.h8,

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
                        Constants.w16,
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

                    Constants.h16,

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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Constants.h8,

                    // Button Type
                    SwitchListTile(
                      title: const Text('Use Image Button'),
                      subtitle:
                          const Text('Toggle between text and image button'),
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
          ],
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
            Constants.h16,
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
            Constants.h16,
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
            Constants.h16,
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
            Constants.h16,
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
                Constants.w16,
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
            Constants.h16,
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
                Constants.w16,
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
            Constants.h16,
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Fill Color'),
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: field.fillColor,
                        border: Border.all(color: AppColors.black),
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
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: field.textColor,
                        border: Border.all(color: AppColors.black),
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
            Constants.h8,
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Label Color'),
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: field.labelColor,
                        border: Border.all(color: AppColors.black),
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
                  Constants.h16,
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
                      Constants.w16,
                      Expanded(
                        child: ListTile(
                          title: const Text('Border Color'),
                          leading: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: field.borderColor,
                              border: Border.all(color: AppColors.black),
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
        Constants.h16,
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
        Constants.h16,
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
                    settings.setButtonDimensions(settings.buttonWidth, height);
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
                    settings.setButtonBorderRadius(radius);
                  }
                },
              ),
            ),
            Constants.w16,
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
                    color: settings.submitButtonColor,
                    border: Border.all(color: AppColors.black),
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
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: settings.submitButtonTextColor,
                    border: Border.all(color: AppColors.black),
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
        Constants.h16,
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
                          settings.setButtonBorder(
                            settings.buttonHasBorder,
                            width,
                            settings.buttonBorderColor,
                          );
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
                  await settings.setButtonImage(
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
              height: 60,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.black),
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
        Constants.h16,
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
                    settings.setButtonDimensions(settings.buttonWidth, height);
                  }
                },
              ),
            ),
          ],
        ),
        Constants.h16,
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
        Constants.h16,
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
                          settings.setButtonBorder(
                            settings.buttonHasBorder,
                            width,
                            settings.buttonBorderColor,
                          );
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
