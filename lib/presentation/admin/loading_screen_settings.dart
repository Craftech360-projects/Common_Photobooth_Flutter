import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/providers/loading_screen_provider.dart';
import 'package:photobooth_flutter/widgets/color_picker.dart';
import 'package:provider/provider.dart';

class LoadingScreenSettings extends StatelessWidget {
  const LoadingScreenSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loading Screen Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<LoadingScreenProvider>(
          builder: (context, settings, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Settings
                const Text(
                  'Title Settings',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
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
                    onChanged: (value) => settings.setTitleFontSize(value),
                  ),
                  _buildDropdown<FontWeight>(
                    label: 'Font Weight',
                    value: settings.titleFontWeight,
                    items: {
                      FontWeight.normal: 'Normal',
                      FontWeight.bold: 'Bold',
                    },
                    onChanged: (value) => settings.setTitleFontWeight(value!),
                  ),
                  _buildColorPicker(
                    label: 'Title Color',
                    color: settings.titleColor,
                    onColorChanged: (color) => settings.setTitleColor(color),
                  ),
                  _buildSlider(
                    label: 'Title Padding',
                    value: settings.titlePadding,
                    min: 0,
                    max: 50,
                    onChanged: (value) => settings.setTitlePadding(value),
                  ),
                ],

                const Divider(height: 32),

                // Loader Settings
                const Text(
                  'Loader Settings',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildSlider(
                  label: 'Loader Width',
                  value: settings.loaderWidth,
                  min: 100,
                  max: 400,
                  onChanged: (value) => settings.setLoaderWidth(value),
                ),
                _buildSlider(
                  label: 'Loader Height',
                  value: settings.loaderHeight,
                  min: 100,
                  max: 400,
                  onChanged: (value) => settings.setLoaderHeight(value),
                ),
                _buildSwitch(
                  label: 'Show Loader Border',
                  value: settings.showLoaderBorder,
                  onChanged: (value) => settings.setShowLoaderBorder(value),
                ),
                if (settings.showLoaderBorder) ...[
                  _buildSlider(
                    label: 'Border Radius',
                    value: settings.loaderBorderRadius,
                    min: 0,
                    max: 50,
                    onChanged: (value) => settings.setLoaderBorderRadius(value),
                  ),
                  _buildColorPicker(
                    label: 'Border Color',
                    color: settings.loaderBorderColor,
                    onColorChanged: (color) =>
                        settings.setLoaderBorderColor(color),
                  ),
                  _buildSlider(
                    label: 'Border Width',
                    value: settings.loaderBorderWidth,
                    min: 1,
                    max: 10,
                    onChanged: (value) => settings.setLoaderBorderWidth(value),
                  ),
                ],

                const SizedBox(height: 16),
                _buildSlider(
                  label: 'Loading Duration (seconds)',
                  value: settings.loaderDurationSeconds.toDouble(),
                  min: 3,
                  max: 20,
                  divisions: 17,
                  onChanged: (value) =>
                      settings.setLoaderDuration(value.toInt()),
                ),

                const Divider(height: 32),

                // Loader File Settings
                const Text(
                  'Loader File',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
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
                      allowedExtensions:
                          fileType == FileType.custom ? [fileExtension] : null,
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildSwitch(
                  label: 'Show Custom Background',
                  value: settings.showBackground,
                  onChanged: (value) => settings.setShowBackground(value),
                ),
                if (settings.showBackground) ...[
                  const SizedBox(height: 16),
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
                      child: Text('Selected: ${settings.backgroundImagePath}'),
                    ),
                ],

                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => settings.resetToDefaults(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Reset to Defaults'),
                ),
              ],
            );
          },
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
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: onChanged,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required Function(double) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ${value.toStringAsFixed(1)}'),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
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
      padding: const EdgeInsets.only(bottom: 16.0),
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
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 8),
          DropdownButton<T>(
            value: value,
            isExpanded: true,
            items: items.entries.map((entry) {
              return DropdownMenuItem<T>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker({
    required String label,
    required Color color,
    required Function(Color) onColorChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 8),
          ColorPicker(
            pickerColor: color,
            onColorChanged: onColorChanged,
          ),
        ],
      ),
    );
  }
}
