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
                    TextButton(
                      onPressed: () {
                        Provider.of<OutputScreenProvider>(context,
                                listen: false)
                            .resetToDefaults();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Reset'),
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
              scale: 0.45,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.transparent),
                borderRadius: BorderRadius.circular(0),
              ),
              child: const SwappedFaceScreen(),
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
                            FontWeight.normal: 'Normal',
                            FontWeight.bold: 'Bold',
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

                        _buildSlider(
                          label: 'Title Padding',
                          value: settings.titlePadding,
                          min: 0.0,
                          max: 50.0,
                          onChanged: (value) =>
                              settings.setTitleStyle(padding: value),
                        ),
                        // Remove dropdown for position and keep only the fine-tuning controls
                        _buildSectionTitle('Title Position'),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSlider(
                                label: 'Horizontal Offset',
                                value: settings.titleOffsetX,
                                min: -300.0,
                                max: 300.0,
                                onChanged: (value) => settings.setTitleOffset(
                                    value, settings.titleOffsetY),
                              ),
                            ),
                            Expanded(
                              child: _buildSlider(
                                label: 'Vertical Offset',
                                value: settings.titleOffsetY,
                                min: -300.0,
                                max: 300.0,
                                onChanged: (value) => settings.setTitleOffset(
                                    settings.titleOffsetX, value),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const Divider(),

                      // Image Settings
                      _buildSectionTitle('Image Settings'),
                      _buildSlider(
                        label: 'Image Width',
                        value: settings.imageWidth,
                        min: 200.0,
                        max: 600.0,
                        onChanged: (value) => settings.setImageDimensions(
                            value, settings.imageHeight),
                      ),
                      _buildSlider(
                        label: 'Image Height',
                        value: settings.imageHeight,
                        min: 200.0,
                        max: 800.0,
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
                      _buildSlider(
                        label: 'Image Spacing',
                        value: settings.imageSpacing,
                        min: 0.0,
                        max: 100.0,
                        onChanged: (value) => settings.setImageSpacing(value),
                      ),

                      // Fine-tuning controls for image position
                      _buildSectionTitle('Fine-tune Image Position'),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSlider(
                              label: 'Horizontal Offset',
                              value: settings.imageOffsetX,
                              min: -300.0,
                              max: 300.0,
                              onChanged: (value) => settings.setImageOffset(
                                  value, settings.imageOffsetY),
                            ),
                          ),
                          Expanded(
                            child: _buildSlider(
                              label: 'Vertical Offset',
                              value: settings.imageOffsetY,
                              min: -300.0,
                              max: 300.0,
                              onChanged: (value) => settings.setImageOffset(
                                  settings.imageOffsetX, value),
                            ),
                          ),
                        ],
                      ),

                      const Divider(),

                      // QR Code Settings
                      _buildSectionTitle('QR Code Settings'),
                      _buildSlider(
                        label: 'QR Code Size',
                        value: settings.qrCodeSize,
                        min: 100.0,
                        max: 300.0,
                        onChanged: (value) => settings.setQrCodeSize(value),
                      ),
                      _buildColorPickerWithLabel(
                        context: context,
                        label: 'QR Background Color',
                        color: settings.qrCodeBackgroundColor,
                        onColorChanged: (color) =>
                            settings.setQrCodeColors(backgroundColor: color),
                      ),

                      _buildColorPickerWithLabel(
                        context: context,
                        label: 'QR Foreground Color',
                        color: settings.qrCodeForegroundColor,
                        onColorChanged: (color) =>
                            settings.setQrCodeColors(foregroundColor: color),
                      ),
                      _buildTextField(
                        label: 'QR Code Text',
                        value: settings.qrCodeText,
                        onChanged: (value) => settings.setQrCodeText(value),
                      ),
                      _buildSlider(
                        label: 'Text Font Size',
                        value: settings.qrCodeTextFontSize,
                        min: 12.0,
                        max: 24.0,
                        onChanged: (value) =>
                            settings.setQrCodeTextStyle(fontSize: value),
                      ),
                      _buildColorPickerWithLabel(
                        context: context,
                        label: 'Text Color',
                        color: settings.qrCodeTextColor,
                        onColorChanged: (color) =>
                            settings.setQrCodeTextStyle(color: color),
                      ),
                      _buildDropdown<QrCodeLayout>(
                        label: 'QR Code Layout',
                        value: settings.qrCodeLayout,
                        items: {
                          QrCodeLayout.below: 'Text Below QR',
                          QrCodeLayout.above: 'Text Above QR',
                          QrCodeLayout.leftOfQr: 'Text Left of QR',
                          QrCodeLayout.rightOfQr: 'Text Right of QR',
                          QrCodeLayout.sideBySide: 'Side by Side',
                        },
                        onChanged: (value) => settings.setQrCodeLayout(value!),
                      ),
                      _buildSlider(
                        label: 'QR Code Spacing',
                        value: settings.qrCodeSpacing,
                        min: 0.0,
                        max: 100.0,
                        onChanged: (value) => settings.setQrCodeSpacing(value),
                      ),

                      // Fine-tuning controls for QR code position
                      _buildSectionTitle('Fine-tune QR Code Position'),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSlider(
                              label: 'Horizontal Offset',
                              value: settings.qrCodeOffsetX,
                              min: -100.0,
                              max: 100.0,
                              onChanged: (value) => settings.setQrCodeOffset(
                                  value, settings.qrCodeOffsetY),
                            ),
                          ),
                          Expanded(
                            child: _buildSlider(
                              label: 'Vertical Offset',
                              value: settings.qrCodeOffsetY,
                              min: -100.0,
                              max: 100.0,
                              onChanged: (value) => settings.setQrCodeOffset(
                                  settings.qrCodeOffsetX, value),
                            ),
                          ),
                        ],
                      ),

                      const Divider(),

                      // Button Settings
                      _buildSectionTitle('Button Settings'),
                      _buildTextField(
                        label: 'Button Text',
                        value: settings.buttonText,
                        onChanged: (value) => settings.setButtonText(value),
                      ),
                      _buildSlider(
                        label: 'Font Size',
                        value: settings.buttonFontSize,
                        min: 16.0,
                        max: 32.0,
                        onChanged: (value) =>
                            settings.setButtonStyle(fontSize: value),
                      ),
                      _buildColorPickerWithLabel(
                        context: context,
                        label: 'Button Color',
                        color: settings.buttonColor,
                        onColorChanged: (color) =>
                            settings.setButtonStyle(color: color),
                      ),
                      _buildColorPickerWithLabel(
                        context: context,
                        label: 'Text Color',
                        color: settings.buttonTextColor,
                        onColorChanged: (color) =>
                            settings.setButtonStyle(textColor: color),
                      ),
                      _buildSlider(
                        label: 'Horizontal Padding',
                        value: settings.buttonPaddingHorizontal,
                        min: 10.0,
                        max: 100.0,
                        onChanged: (value) =>
                            settings.setButtonStyle(paddingHorizontal: value),
                      ),
                      _buildSlider(
                        label: 'Vertical Padding',
                        value: settings.buttonPaddingVertical,
                        min: 5.0,
                        max: 50.0,
                        onChanged: (value) =>
                            settings.setButtonStyle(paddingVertical: value),
                      ),
                      _buildSlider(
                        label: 'Button Spacing',
                        value: settings.buttonSpacing,
                        min: 0.0,
                        max: 100.0,
                        onChanged: (value) => settings.setButtonSpacing(value),
                      ),

                      // Fine-tuning controls for button position
                      _buildSectionTitle('Fine-tune Button Position'),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSlider(
                              label: 'Horizontal Offset',
                              value: settings.buttonOffsetX,
                              min: -300.0, // Changed from -100
                              max: 300.0, // Changed from 100
                              onChanged: (value) => settings.setButtonOffset(
                                  value, settings.buttonOffsetY),
                            ),
                          ),
                          Expanded(
                            child: _buildSlider(
                              label: 'Vertical Offset',
                              value: settings.buttonOffsetY,
                              min: -300.0, // Changed from -100
                              max: 300.0, // Changed from 100
                              onChanged: (value) => settings.setButtonOffset(
                                  settings.buttonOffsetX, value),
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
                        onChanged: (value) => settings.setShowBackground(value),
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
                                onPressed: () => settings
                                    .setBackgroundImage(null, isAsset: true),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
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
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
