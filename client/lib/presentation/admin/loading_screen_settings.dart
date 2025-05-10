import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/constants/constants.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/presentation/loading_screen.dart';
import 'package:photobooth_flutter/providers/loading_screen_provider.dart';
import 'package:photobooth_flutter/widgets/improved_color_picker.dart';
import 'package:photobooth_flutter/widgets/settings_preview.dart';
import 'package:provider/provider.dart';

class LoadingScreenSettings extends StatelessWidget {
  const LoadingScreenSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loading Screen Settings'),
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
              child: const LoadingScreen(),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<LoadingScreenProvider>(
                builder: (context, settings, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Settings
                      const Text(
                        'Title Settings',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Constants.h16,
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
                          min: 16,
                          max: 48,
                          onChanged: (value) =>
                              settings.setTitleFontSize(value),
                        ),
                        _buildSlider(
                          label: 'Line Height',
                          value: settings.titleLineHeight,
                          min: 0.8,
                          max: 2.0,
                          divisions: 24,
                          onChanged: (value) =>
                              settings.setTitleLineHeight(value),
                        ),
                        _buildSlider(
                          label: 'Text Opacity',
                          value: settings.titleOpacity,
                          min: 0.1,
                          max: 1.0,
                          divisions: 9,
                          onChanged: (value) => settings.setTitleOpacity(value),
                        ),
                        _buildDropdown<FontWeight>(
                          label: 'Font Weight',
                          value: settings.titleFontWeight,
                          items: {
                            FontWeight.w100: 'Thin',
                            FontWeight.w300: 'Light',
                            FontWeight.w400: 'Regular',
                            FontWeight.w500: 'Medium',
                            FontWeight.w700: 'Bold',
                            FontWeight.w900: 'Extra Bold',
                          },
                          onChanged: (value) =>
                              settings.setTitleFontWeight(value!),
                        ),
                        // Title Color with Dialog
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
                              settings.setTitleColor(color);
                            }
                          },
                        ),

                        // Title Margins
                        Constants.h16,
                        const Text(
                          'Title Padding',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Constants.h8,

                        _buildSlider(
                          label: 'Top Padding',
                          value: settings.titlePadding.top,
                          min: 0,
                          max: 400,
                          onChanged: (value) => settings.setTitlePadding(
                            EdgeInsets.fromLTRB(
                              settings.titlePadding.left,
                              value,
                              settings.titlePadding.right,
                              settings.titlePadding.bottom,
                            ),
                          ),
                        ),

                        _buildSlider(
                          label: 'Bottom Padding',
                          value: settings.titlePadding.bottom,
                          min: 0,
                          max: 400,
                          onChanged: (value) => settings.setTitlePadding(
                            EdgeInsets.fromLTRB(
                              settings.titlePadding.left,
                              settings.titlePadding.top,
                              settings.titlePadding.right,
                              value,
                            ),
                          ),
                        ),

                        _buildSlider(
                          label: 'Left Padding',
                          value: settings.titlePadding.left,
                          min: 0,
                          max: 400,
                          onChanged: (value) => settings.setTitlePadding(
                            EdgeInsets.fromLTRB(
                              value,
                              settings.titlePadding.top,
                              settings.titlePadding.right,
                              settings.titlePadding.bottom,
                            ),
                          ),
                        ),

                        _buildSlider(
                          label: 'Right Padding',
                          value: settings.titlePadding.right,
                          min: 0,
                          max: 400,
                          onChanged: (value) => settings.setTitlePadding(
                            EdgeInsets.fromLTRB(
                              settings.titlePadding.left,
                              settings.titlePadding.top,
                              value,
                              settings.titlePadding.bottom,
                            ),
                          ),
                        ),
                      ],

                      const Divider(height: 32),

                      // Loader Settings
                      const Text(
                        'Loader Settings',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Constants.h16,
                      _buildSlider(
                        label: 'Loader Width',
                        value: settings.loaderWidth,
                        min: 50,
                        max: 500,
                        onChanged: (value) => settings.setLoaderWidth(value),
                      ),
                      _buildSlider(
                        label: 'Loader Height',
                        value: settings.loaderHeight,
                        min: 50,
                        max: 500,
                        onChanged: (value) => settings.setLoaderHeight(value),
                      ),

                      // Loader Margins
                      Constants.h16,
                      const Text(
                        'Loader Margins',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Constants.h8,

                      _buildSlider(
                        label: 'Top Margin',
                        value: settings.loaderMargin.top,
                        min: 0,
                        max: 500,
                        onChanged: (value) => settings.setLoaderMargin(
                          EdgeInsets.fromLTRB(
                            settings.loaderMargin.left,
                            value,
                            settings.loaderMargin.right,
                            settings.loaderMargin.bottom,
                          ),
                        ),
                      ),

                      _buildSlider(
                        label: 'Bottom Margin',
                        value: settings.loaderMargin.bottom,
                        min: 0,
                        max: 500,
                        onChanged: (value) => settings.setLoaderMargin(
                          EdgeInsets.fromLTRB(
                            settings.loaderMargin.left,
                            settings.loaderMargin.top,
                            settings.loaderMargin.right,
                            value,
                          ),
                        ),
                      ),

                      _buildSlider(
                        label: 'Left Margin',
                        value: settings.loaderMargin.left,
                        min: 0,
                        max: 500,
                        onChanged: (value) => settings.setLoaderMargin(
                          EdgeInsets.fromLTRB(
                            value,
                            settings.loaderMargin.top,
                            settings.loaderMargin.right,
                            settings.loaderMargin.bottom,
                          ),
                        ),
                      ),

                      _buildSlider(
                        label: 'Right Margin',
                        value: settings.loaderMargin.right,
                        min: 0,
                        max: 500,
                        onChanged: (value) => settings.setLoaderMargin(
                          EdgeInsets.fromLTRB(
                            settings.loaderMargin.left,
                            settings.loaderMargin.top,
                            value,
                            settings.loaderMargin.bottom,
                          ),
                        ),
                      ),

                      const Divider(height: 32),

                      // Loader File Settings
                      const Text(
                        'Loader File',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Constants.h16,
                      _buildDropdown<String>(
                        label: 'Loader File Type',
                        value: settings.loaderFileType,
                        items: {
                          'gif': 'GIF Animation',
                          'json': 'Lottie Animation (JSON)',
                          'mp4': 'MP4 Video',
                          'mov': 'MOV Video',
                        },
                        onChanged: (value) => settings.setLoaderFile(
                          settings.loaderFilePath,
                          settings.isLoaderFileAsset,
                          value!,
                        ),
                      ),
                      Constants.h16,
                      ElevatedButton(
                        onPressed: () async {
                          FileType fileType;
                          String fileExtension;

                          switch (settings.loaderFileType) {
                            case 'gif':
                              fileType = FileType.image;
                              fileExtension = 'gif';
                              break;
                            case 'json':
                              fileType = FileType.custom;
                              fileExtension = 'json';
                              break;
                            case 'mp4':
                              fileType = FileType.video;
                              fileExtension = 'mp4';
                              break;
                            case 'mov':
                              fileType = FileType.custom;
                              fileExtension = 'mov';
                              break;
                            default:
                              fileType = FileType.any;
                              fileExtension = '*';
                          }

                          final result = await FilePicker.platform.pickFiles(
                            type: fileType,
                            allowedExtensions: fileType == FileType.custom
                                ? [fileExtension]
                                : null,
                          );

                          if (result != null && result.files.isNotEmpty) {
                            final file = result.files.first;
                            if (file.path != null) {
                              settings.setLoaderFile(
                                file.path,
                                false,
                                settings.loaderFileType,
                              );
                            }
                          }
                        },
                        child: const Text('Choose Loader File'),
                      ),
                      if (settings.loaderFilePath != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('Selected: ${settings.loaderFilePath}'),
                        ),

                      const Divider(height: 32),

                      // Background Settings
                      const Text(
                        'Background Settings',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Constants.h16,
                      _buildSwitch(
                        label: 'Show Custom Background',
                        value: settings.showBackground,
                        onChanged: (value) => settings.setShowBackground(value),
                      ),
                      if (settings.showBackground) ...[
                        Constants.h16,
                        ElevatedButton(
                          onPressed: () async {
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.image,
                            );

                            if (result != null && result.files.isNotEmpty) {
                              final file = result.files.first;
                              if (file.path != null) {
                                settings.setBackgroundImage(
                                  file.path,
                                  false,
                                );
                              }
                            }
                          },
                          child: const Text('Choose Background Image'),
                        ),
                        if (settings.backgroundImagePath != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                                'Selected: ${settings.backgroundImagePath}'),
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

  Widget _buildTextField({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    // Create a controller with the current value
    final controller = TextEditingController(text: value);

    // Set the cursor position at the end of the text
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        controller: controller,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ${value.toStringAsFixed(1)}'),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: divisions,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required Map<T, String> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<T>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        value: value,
        items: items.entries
            .map((e) => DropdownMenuItem<T>(
                  value: e.key,
                  child: Text(e.value),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSwitch({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // Remove the direct color picker and add this method for the dialog
  Future<Color?> _showImprovedColorPicker({
    required BuildContext context,
    required Color color,
    required String title,
  }) async {
    return showDialog<Color>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ImprovedColorPicker(
              pickerColor: color,
              onColorChanged: (color) => color,
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
              child: const Text('Select'),
              onPressed: () {
                Navigator.of(context).pop(color);
              },
            ),
          ],
        );
      },
    );
  }
}
