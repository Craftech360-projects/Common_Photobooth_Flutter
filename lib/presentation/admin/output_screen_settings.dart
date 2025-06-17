import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/presentation/output_screen.dart';
import 'package:photobooth_flutter/providers/output_screen_provider.dart';
import 'package:photobooth_flutter/widgets/improved_color_picker.dart';
import 'package:photobooth_flutter/widgets/settings_preview.dart';
import 'package:provider/provider.dart';

class OutputScreenSettings extends StatelessWidget {
  const OutputScreenSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Output Screen Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset to Defaults'),
                  content: const Text(
                      'Are you sure you want to reset all settings to defaults?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
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
              // In the SettingsPreview widget
              child: const SwappedFaceScreen(isPreviewMode: true),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<OutputScreenProvider>(
                builder: (context, settings, child) {
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Settings
                        _buildSectionTitle('Title Settings'),
                        _buildSwitch(
                          label: 'Show Title',
                          value: settings.showTitle,
                          onChanged: (value) => settings.setShowTitle(value),
                        ),
                        if (settings.showTitle) ...[
                          _buildTextField(
                            label: 'Title Text',
                            value: settings.titleText,
                            onChanged: (value) => settings.setTitleText(value),
                          ),
                          _buildSlider(
                            label: 'Font Size',
                            value: settings.titleFontSize,
                            min: 16.0,
                            max: 48.0,
                            onChanged: (value) =>
                                settings.setTitleStyle(fontSize: value),
                          ),
                          _buildDropdown<FontWeight>(
                            label: 'Font Weight',
                            value: settings.titleFontWeight,
                            items: {
                              FontWeight.w100: 'Thin (100)',
                              FontWeight.w200: 'Extra Light (200)',
                              FontWeight.w300: 'Light (300)',
                              FontWeight.w400: 'Regular (400)',
                              FontWeight.w500: 'Medium (500)',
                              FontWeight.w600: 'Semi Bold (600)',
                              FontWeight.w700: 'Bold (700)',
                              FontWeight.w800: 'Extra Bold (800)',
                              FontWeight.w900: 'Black (900)',
                            },
                            onChanged: (value) =>
                                settings.setTitleStyle(fontWeight: value),
                          ),
                          _buildColorPickerWithLabel(
                            context: context,
                            label: 'Text Color',
                            color: settings.titleColor,
                            onColorChanged: (color) =>
                                settings.setTitleStyle(color: color),
                          ),

                          // Remove dropdown for position and keep only the fine-tuning controls
                          _buildSectionTitle('Title Position'),
                          Row(
                            children: [
                              Expanded(
                                child: _buildSlider(
                                  label: 'From Left',
                                  value: settings.titleLeft,
                                  min: 0.0,
                                  max: 1080.0,
                                  onChanged: (value) =>
                                      settings.setTitlePosition(
                                    value,
                                    settings.titleTop,
                                    settings.titleWidth,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: _buildSlider(
                                  label: 'From Top',
                                  value: settings.titleTop,
                                  min: 0.0,
                                  max: 1920.0,
                                  onChanged: (value) =>
                                      settings.setTitlePosition(
                                    settings.titleLeft,
                                    value,
                                    settings.titleWidth,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          _buildSlider(
                            label: 'Width',
                            value: settings.titleWidth,
                            min: 100.0,
                            max: 1000.0,
                            onChanged: (value) => settings.setTitlePosition(
                              settings.titleLeft,
                              settings.titleTop,
                              value,
                            ),
                          ),

                          const Divider(),

                          // Image Settings
                          _buildSectionTitle('Image Settings'),
                          _buildSlider(
                            label: 'Image Width',
                            value: settings.imageWidth,
                            min: 200.0,
                            max: 1200.0,
                            onChanged: (value) => settings.setImageDimensions(
                                value, settings.imageHeight),
                          ),
                          _buildSlider(
                            label: 'Image Height',
                            value: settings.imageHeight,
                            min: 200.0,
                            max: 1200.0,
                            onChanged: (value) => settings.setImageDimensions(
                                settings.imageWidth, value),
                          ),
                          _buildSlider(
                            label: 'Border Radius',
                            value: settings.imageBorderRadius,
                            min: 0.0,
                            max: 50.0,
                            onChanged: (value) =>
                                settings.setImageBorder(radius: value),
                          ),
                          _buildColorPickerWithLabel(
                            context: context,
                            label: 'Border Color',
                            color: settings.imageBorderColor,
                            onColorChanged: (color) =>
                                settings.setImageBorder(color: color),
                          ),

                          _buildSlider(
                            label: 'Border Width',
                            value: settings.imageBorderWidth,
                            min: 0.0,
                            max: 10.0,
                            onChanged: (value) =>
                                settings.setImageBorder(width: value),
                          ),

                          // Fine-tuning controls for image position
                          _buildSectionTitle('Image Position'),
                          Row(
                            children: [
                              Expanded(
                                child: _buildSlider(
                                  label: 'From Left',
                                  value: settings.imageLeft,
                                  min: 0.0,
                                  max: 1080.0,
                                  onChanged: (value) =>
                                      settings.setImagePosition(
                                    value,
                                    settings.imageTop,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: _buildSlider(
                                  label: 'From Top',
                                  value: settings.imageTop,
                                  min: 0.0,
                                  max: 1920.0,
                                  onChanged: (value) =>
                                      settings.setImagePosition(
                                    settings.imageLeft,
                                    value,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const Divider(),

                          // Button Settings
                          _buildSectionTitle('Button Settings'),
                          SwitchListTile(
                            title: const Text('Use Image Button'),
                            value: settings.useImageButton,
                            onChanged: (value) =>
                                settings.setUseImageButton(value),
                          ),

                          if (settings.useImageButton) ...[
                            ListTile(
                              title: const Text('Button Image'),
                              subtitle: Text(settings.buttonImagePath ??
                                  'No image selected'),
                              trailing: ElevatedButton(
                                onPressed: () async {
                                  final result = await FilePicker.platform
                                      .pickFiles(type: FileType.image);
                                  if (result != null &&
                                      result.files.single.path != null) {
                                    settings.setButtonImage(
                                        result.files.single.path,
                                        isAsset: false);
                                  }
                                },
                                child: const Text('Choose...'),
                              ),
                            ),
                            _buildSlider(
                                label: 'Width',
                                value: settings.buttonWidth,
                                min: 100,
                                max: 900,
                                onChanged: (v) =>
                                    settings.setButtonStyle(width: v)),
                            _buildSlider(
                                label: 'Height',
                                value: settings.buttonHeight,
                                min: 50,
                                max: 900,
                                onChanged: (v) =>
                                    settings.setButtonStyle(height: v)),
                          ] else ...[
                            _buildTextField(
                                label: 'Button Text',
                                value: settings.buttonText,
                                onChanged: (value) =>
                                    settings.setButtonText(value)),
                            _buildSlider(
                                label: 'Font Size',
                                value: settings.buttonFontSize,
                                min: 16.0,
                                max: 90.0,
                                onChanged: (value) =>
                                    settings.setButtonStyle(fontSize: value)),
                            _buildColorPickerWithLabel(
                                context: context,
                                label: 'Button Color',
                                color: settings.buttonColor,
                                onColorChanged: (color) =>
                                    settings.setButtonStyle(color: color)),
                            _buildColorPickerWithLabel(
                                context: context,
                                label: 'Text Color',
                                color: settings.buttonTextColor,
                                onColorChanged: (color) =>
                                    settings.setButtonStyle(textColor: color)),
                            _buildSlider(
                                label: 'Horizontal Padding',
                                value: settings.buttonPaddingHorizontal,
                                min: 10.0,
                                max: 100.0,
                                onChanged: (value) => settings.setButtonStyle(
                                    paddingHorizontal: value)),
                            _buildSlider(
                                label: 'Vertical Padding',
                                value: settings.buttonPaddingVertical,
                                min: 5.0,
                                max: 50.0,
                                onChanged: (value) => settings.setButtonStyle(
                                    paddingVertical: value)),
                          ],

                          _buildSlider(
                              label: 'Button Border Radius',
                              value: settings.buttonBorderRadius,
                              min: 0.0,
                              max: 30.0,
                              onChanged: (value) =>
                                  settings.setButtonStyle(borderRadius: value)),

                          _buildSectionTitle('Button Position'),
                          Row(
                            children: [
                              Expanded(
                                child: _buildSlider(
                                  label: 'From Left',
                                  value: settings.buttonLeft,
                                  min: 0.0,
                                  max: 1080.0,
                                  onChanged: (value) =>
                                      settings.setButtonPosition(
                                    value,
                                    settings.buttonBottom,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: _buildSlider(
                                  label: 'From Bottom',
                                  value: settings.buttonBottom,
                                  min: 0.0,
                                  max: 1920.0,
                                  onChanged: (value) =>
                                      settings.setButtonPosition(
                                    settings.buttonLeft,
                                    value,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const Divider(),

                          // Background Settings
                          _buildSectionTitle('Background Settings'),
                          _buildSwitch(
                            label: 'Show Custom Background',
                            value: settings.showBackground,
                            onChanged: (value) =>
                                settings.setShowBackground(value),
                          ),
                          if (settings.showBackground) ...[
                            ListTile(
                              title: const Text('Background Image'),
                              subtitle: Text(settings.backgroundImagePath ??
                                  'No custom background selected'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.folder_open),
                                    onPressed: () async {
                                      final result =
                                          await FilePicker.platform.pickFiles(
                                        type: FileType.image,
                                        allowMultiple: false,
                                      );
                                      if (result != null &&
                                          result.files.isNotEmpty) {
                                        settings.setBackgroundImage(
                                            result.files.first.path,
                                            isAsset: false);
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () =>
                                        settings.setBackgroundImage(null,
                                            isAsset: true),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required Function(String) onChanged,
  }) {
    // Create a TextEditingController with the initial value
    final controller = TextEditingController(text: value);

    // Set the cursor position at the end of the text
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        // Don't use onChanged directly with the controller
        onChanged: (text) {
          // Call the provided onChanged callback
          onChanged(text);
        },
        // Enable multiline input for longer text
        maxLines: label.contains('QR Code Text') ? 2 : 1,
        // Ensure keyboard type is appropriate
        keyboardType: TextInputType.text,
        // Enable text actions
        textInputAction: TextInputAction.done,
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required Function(double) onChanged,
    int? divisions,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ${value.toStringAsFixed(1)}'),
          // REMOVED Row and Expanded
          Slider(
            // Slider is now a direct child of the Column
            value: value,
            min: min,
            max: max,
            divisions: divisions ??
                ((max - min) ~/ 1).toInt(), // Ensure divisions is int
            label: value.toStringAsFixed(1), // Good practice to add label
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitch({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
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
            items: items.entries
                .map((e) => DropdownMenuItem<T>(
                      value: e.key,
                      child: Text(e.value),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildColorPickerWithLabel({
    required BuildContext context,
    required String label,
    required Color color,
    required Function(Color) onColorChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Select $label'),
                  content: SingleChildScrollView(
                    child: ImprovedColorPicker(
                      pickerColor: color,
                      onColorChanged: onColorChanged,
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
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                border: Border.all(color: AppColors.black),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
