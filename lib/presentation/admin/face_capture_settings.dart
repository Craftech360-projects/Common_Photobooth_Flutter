import 'dart:io';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/providers/face_capture_provider.dart';
import 'package:photobooth_flutter/widgets/color_picker.dart';
import 'package:provider/provider.dart';

class FaceCaptureSettings extends StatefulWidget {
  const FaceCaptureSettings({super.key});

  @override
  State<FaceCaptureSettings> createState() => _FaceCaptureSettingsState();
}

class _FaceCaptureSettingsState extends State<FaceCaptureSettings> {
  List<CameraDescription> _cameras = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCameras();
  }

  Future<void> _loadCameras() async {
    try {
      _cameras = await availableCameras();
    } on Exception catch (e) {
      debugPrint('Error loading cameras: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<FaceCaptureProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Capture Screen Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Settings
                  _buildSectionTitle('Title Settings'),
                  SwitchListTile(
                    title: const Text('Show Title'),
                    value: settings.showTitle,
                    onChanged: (value) => settings.setShowTitle(value),
                  ),
                  if (settings.showTitle) ...[
                    _buildTextField(
                      label: 'Title Text',
                      initialValue: settings.titleText,
                      onChanged: (value) => settings.setTitleText(value),
                    ),
                    _buildSlider(
                      label: 'Title Font Size',
                      value: settings.titleFontSize,
                      min: 16.0,
                      max: 48.0,
                      onChanged: (value) => settings.setTitleFontSize(value),
                    ),
                    if (Platform.isMacOS) ...[
                      _buildDropdown<String>(
                        label: 'Picture Format',
                        value: settings.pictureFormat,
                        items: {
                          'jpeg': 'JPEG',
                          'tiff': 'TIFF',
                          'heic': 'HEIC',
                        },
                        onChanged: (value) => settings.setPictureFormat(value!),
                      ),
                      _buildDropdown<String>(
                        label: 'Picture Resolution',
                        value: settings.pictureResolution,
                        items: {
                          'max': 'Maximum',
                          'medium': 'Medium',
                          'low': 'Low',
                        },
                        onChanged: (value) =>
                            settings.setPictureResolution(value!),
                      ),
                    ],
                    _buildDropdown<FontWeight>(
                      label: 'Title Font Weight',
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
                      min: 0.0,
                      max: 50.0,
                      onChanged: (value) => settings.setTitlePadding(value),
                    ),
                  ],

                  const Divider(),

                  // Camera Preview Settings
                  _buildSectionTitle('Camera Preview Settings'),
                  _buildDropdown<int>(
                    label: 'Select Camera',
                    value: settings.selectedCameraIndex < _cameras.length
                        ? settings.selectedCameraIndex
                        : 0,
                    items: {
                      for (int i = 0; i < _cameras.length; i++)
                        i: 'Camera ${i + 1} (${_cameras[i].name})',
                    },
                    onChanged: (value) =>
                        settings.setSelectedCameraIndex(value!),
                  ),
                  _buildSlider(
                    label: 'Preview Width',
                    value: settings.previewWidth,
                    min: 200.0,
                    max: 600.0,
                    onChanged: (value) => settings.setPreviewWidth(value),
                  ),
                  _buildSlider(
                    label: 'Preview Height',
                    value: settings.previewHeight,
                    min: 300.0,
                    max: 800.0,
                    onChanged: (value) => settings.setPreviewHeight(value),
                  ),
                  SwitchListTile(
                    title: const Text('Show Preview Border'),
                    value: settings.showPreviewBorder,
                    onChanged: (value) => settings.setShowPreviewBorder(value),
                  ),
                  if (settings.showPreviewBorder) ...[
                    _buildSlider(
                      label: 'Preview Border Radius',
                      value: settings.previewBorderRadius,
                      min: 0.0,
                      max: 50.0,
                      onChanged: (value) =>
                          settings.setPreviewBorderRadius(value),
                    ),
                    _buildColorPicker(
                      label: 'Preview Border Color',
                      color: settings.previewBorderColor,
                      onColorChanged: (color) =>
                          settings.setPreviewBorderColor(color),
                    ),
                    _buildSlider(
                      label: 'Preview Border Width',
                      value: settings.previewBorderWidth,
                      min: 1.0,
                      max: 10.0,
                      onChanged: (value) =>
                          settings.setPreviewBorderWidth(value),
                    ),
                  ],

                  const Divider(),

                  // Button Settings
                  _buildSectionTitle('Button Settings'),
                  SwitchListTile(
                    title: const Text('Use Image Button'),
                    value: settings.useImageButton,
                    onChanged: (value) => settings.setUseImageButton(value),
                  ),
                  if (settings.useImageButton) ...[
                    ListTile(
                      title: const Text('Button Image'),
                      subtitle:
                          Text(settings.buttonImagePath ?? 'No image selected'),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.image,
                            allowMultiple: false,
                          );
                          if (result != null && result.files.isNotEmpty) {
                            settings.setButtonImagePath(
                              result.files.first.path,
                              isAsset: false,
                            );
                          }
                        },
                        child: const Text('Choose Image'),
                      ),
                    ),
                  ] else ...[
                    _buildTextField(
                      label: 'Button Text',
                      initialValue: settings.buttonText,
                      onChanged: (value) => settings.setButtonText(value),
                    ),
                    _buildSlider(
                      label: 'Button Font Size',
                      value: settings.buttonFontSize,
                      min: 12.0,
                      max: 36.0,
                      onChanged: (value) => settings.setButtonFontSize(value),
                    ),
                    _buildColorPicker(
                      label: 'Button Color',
                      color: settings.buttonColor,
                      onColorChanged: (color) => settings.setButtonColor(color),
                    ),
                    _buildColorPicker(
                      label: 'Button Text Color',
                      color: settings.buttonTextColor,
                      onColorChanged: (color) =>
                          settings.setButtonTextColor(color),
                    ),
                  ],
                  _buildSlider(
                    label: 'Button Width',
                    value: settings.buttonWidth,
                    min: 100.0,
                    max: 400.0,
                    onChanged: (value) => settings.setButtonWidth(value),
                  ),
                  _buildSlider(
                    label: 'Button Height',
                    value: settings.buttonHeight,
                    min: 40.0,
                    max: 100.0,
                    onChanged: (value) => settings.setButtonHeight(value),
                  ),
                  _buildSlider(
                    label: 'Button Border Radius',
                    value: settings.buttonBorderRadius,
                    min: 0.0,
                    max: 50.0,
                    onChanged: (value) => settings.setButtonBorderRadius(value),
                  ),
                  _buildSlider(
                    label: 'Button Top Margin',
                    value: settings.buttonMarginTop,
                    min: 0.0,
                    max: 100.0,
                    onChanged: (value) => settings.setButtonMarginTop(value),
                  ),
                  SwitchListTile(
                    title: const Text('Button Has Border'),
                    value: settings.buttonHasBorder,
                    onChanged: (value) => settings.setButtonHasBorder(value),
                  ),
                  if (settings.buttonHasBorder) ...[
                    _buildColorPicker(
                      label: 'Button Border Color',
                      color: settings.buttonBorderColor,
                      onColorChanged: (color) =>
                          settings.setButtonBorderColor(color),
                    ),
                    _buildSlider(
                      label: 'Button Border Width',
                      value: settings.buttonBorderWidth,
                      min: 1.0,
                      max: 10.0,
                      onChanged: (value) =>
                          settings.setButtonBorderWidth(value),
                    ),
                  ],

                  const Divider(),

                  // Background Settings
                  _buildSectionTitle('Background Settings'),
                  SwitchListTile(
                    title: const Text('Show Background Image'),
                    value: settings.showBackground,
                    onChanged: (value) => settings.setShowBackground(value),
                  ),
                  if (settings.showBackground) ...[
                    ListTile(
                      title: const Text('Background Image'),
                      subtitle: Text(
                          settings.backgroundImagePath ?? 'No image selected'),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.image,
                            allowMultiple: false,
                          );
                          if (result != null && result.files.isNotEmpty) {
                            settings.setBackgroundImagePath(
                              result.files.first.path,
                              isAsset: false,
                            );
                          }
                        },
                        child: const Text('Choose Image'),
                      ),
                    ),
                    if (settings.backgroundImagePath != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
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
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required Function(double) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
    required Function(T?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text('$label: '),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<T>(
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text('$label: '),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              final selectedColor = await _showColorPicker(context, color);
              if (selectedColor != null) {
                onColorChanged(selectedColor);
              }
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

  Future<Color?> _showColorPicker(
      BuildContext context, Color initialColor) async {
    Color selectedColor = initialColor;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
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
}
