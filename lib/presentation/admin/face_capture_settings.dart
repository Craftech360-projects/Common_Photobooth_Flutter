import 'dart:io';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/presentation/face_capture_screen.dart';
import 'package:photobooth_flutter/providers/face_capture_provider.dart';
import 'package:photobooth_flutter/widgets/improved_color_picker.dart';
import 'package:photobooth_flutter/widgets/settings_preview.dart';
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
      _cameras = await CameraPlatform.instance.availableCameras();
    } on Exception catch (e) {
      debugPrint('Error loading cameras: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Add method to switch camera in settings
  void _switchCamera(int newIndex, FaceCaptureProvider settings) {
    if (newIndex >= 0 && newIndex < _cameras.length) {
      settings.setSelectedCameraIndex(newIndex);
      // Show confirmation to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Camera switched to: ${_cameras[newIndex].name}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<FaceCaptureProvider>();

    return Scaffold(
        appBar: AppBar(
          title: const Text('Face Capture Settings'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
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
                child: const FaceCaptureScreen(isPreview: true),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
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
                            onChanged: (value) =>
                                settings.setTitleFontSize(value),
                          ),
                          if (Platform.isWindows) ...[
                            _buildDropdown<String>(
                              label: 'Picture Format',
                              value: settings.pictureFormat,
                              items: {
                                'jpeg': 'JPEG',
                                'png': 'PNG',
                              },
                              onChanged: (value) =>
                                  settings.setPictureFormat(value!),
                            ),
                          ],
                          _buildDropdown<FontWeight>(
                            label: 'Title Font Weight',
                            value: settings.titleFontWeight,
                            items: {
                              FontWeight.w100: 'Thin',
                              FontWeight.w400: 'Regular',
                              FontWeight.w500: 'Medium',
                              FontWeight.w700: 'Bold',
                              FontWeight.w900: 'Extra Bold',
                            },
                            onChanged: (value) =>
                                settings.setTitleFontWeight(value!),
                          ),
                          _buildSlider(
                            label: 'Line Height',
                            value: settings.titleLineHeight,
                            min: 1.0,
                            max: 2.0,
                            onChanged: (value) =>
                                settings.setTitleLineHeight(value),
                          ),
                          _buildSlider(
                            label: 'Text Opacity',
                            value: settings.titleOpacity,
                            min: 0.0,
                            max: 1.0,
                            onChanged: (value) =>
                                settings.setTitleOpacity(value),
                          ),
                          _buildDropdown<TextAlign>(
                            label: 'Text Alignment',
                            value: settings.titleAlignment,
                            items: {
                              TextAlign.left: 'Left',
                              TextAlign.center: 'Center',
                              TextAlign.right: 'Right',
                            },
                            onChanged: (value) =>
                                settings.setTitleAlignment(value!),
                          ),
                          _buildSectionTitle('Title Padding'),
                          _buildSlider(
                            label: 'Left Padding',
                            value: settings.titlePadding.left,
                            min: 0.0,
                            max: 50.0,
                            onChanged: (value) => settings.setTitlePadding(
                              settings.titlePadding.copyWith(left: value),
                            ),
                          ),
                          _buildSlider(
                            label: 'Top Padding',
                            value: settings.titlePadding.top,
                            min: 0.0,
                            max: 50.0,
                            onChanged: (value) => settings.setTitlePadding(
                              settings.titlePadding.copyWith(top: value),
                            ),
                          ),
                          _buildSlider(
                            label: 'Right Padding',
                            value: settings.titlePadding.right,
                            min: 0.0,
                            max: 50.0,
                            onChanged: (value) => settings.setTitlePadding(
                              settings.titlePadding.copyWith(right: value),
                            ),
                          ),
                          _buildSlider(
                            label: 'Bottom Padding',
                            value: settings.titlePadding.bottom,
                            min: 0.0,
                            max: 50.0,
                            onChanged: (value) => settings.setTitlePadding(
                              settings.titlePadding.copyWith(bottom: value),
                            ),
                          ),
                          _buildColorPicker(
                            label: 'Title Color',
                            color: settings.titleColor,
                            onColorChanged: (color) =>
                                settings.setTitleColor(color),
                          ),
                        ],

                        const Divider(),

                        // Camera Preview Settings
                        _buildSectionTitle('Camera Preview Settings'),
                        // Update the camera dropdown to use the _switchCamera method
                        if (_cameras.isNotEmpty)
                          _buildDropdown<int>(
                            label: 'Select Camera',
                            value:
                                settings.selectedCameraIndex < _cameras.length
                                    ? settings.selectedCameraIndex
                                    : 0,
                            items: {
                              for (int i = 0; i < _cameras.length; i++)
                                i: 'Camera ${i + 1} (${_cameras[i].name})',
                            },
                            onChanged: (value) =>
                                _switchCamera(value!, settings),
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
                          min: 200.0,
                          max: 600.0,
                          onChanged: (value) =>
                              settings.setPreviewHeight(value),
                        ),
                        _buildSlider(
                          label: 'Border Radius',
                          value: settings.previewBorderRadius,
                          min: 0.0,
                          max: 50.0,
                          onChanged: (value) =>
                              settings.setPreviewBorderRadius(value),
                        ),
                        SwitchListTile(
                          title: const Text('Show Preview Border'),
                          value: settings.showPreviewBorder,
                          onChanged: (value) =>
                              settings.setShowPreviewBorder(value),
                        ),
                        if (settings.showPreviewBorder) ...[
                          _buildColorPicker(
                            label: 'Preview Border Color',
                            color: settings.previewBorderColor,
                            onColorChanged: (color) =>
                                settings.setPreviewBorderColor(color),
                          ),
                          _buildSlider(
                            label: 'Preview Border Width',
                            value: settings.previewBorderWidth,
                            min: 0.0,
                            max: 10.0,
                            onChanged: (value) =>
                                settings.setPreviewBorderWidth(value),
                          ),
                        ],

                        _buildSectionTitle('Preview Margins'),
                        _buildSlider(
                          label: 'Left Margin',
                          value: settings.previewMargin.left,
                          min: 0.0,
                          max: 50.0,
                          onChanged: (value) => settings.setPreviewMargin(
                            settings.previewMargin.copyWith(left: value),
                          ),
                        ),
                        _buildSlider(
                          label: 'Top Margin',
                          value: settings.previewMargin.top,
                          min: 0.0,
                          max: 50.0,
                          onChanged: (value) => settings.setPreviewMargin(
                            settings.previewMargin.copyWith(top: value),
                          ),
                        ),
                        _buildSlider(
                          label: 'Right Margin',
                          value: settings.previewMargin.right,
                          min: 0.0,
                          max: 50.0,
                          onChanged: (value) => settings.setPreviewMargin(
                            settings.previewMargin.copyWith(right: value),
                          ),
                        ),
                        _buildSlider(
                          label: 'Bottom Margin',
                          value: settings.previewMargin.bottom,
                          min: 0.0,
                          max: 50.0,
                          onChanged: (value) => settings.setPreviewMargin(
                            settings.previewMargin.copyWith(bottom: value),
                          ),
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
                                final result =
                                    await FilePicker.platform.pickFiles(
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
                            onChanged: (value) =>
                                settings.setButtonFontSize(value),
                          ),
                          _buildDropdown<FontWeight>(
                            label: 'Button Font Weight',
                            value: settings.buttonFontWeight,
                            items: {
                              FontWeight.w100: 'Thin',
                              FontWeight.w400: 'Regular',
                              FontWeight.w500: 'Medium',
                              FontWeight.w700: 'Bold',
                              FontWeight.w900: 'Extra Bold',
                            },
                            onChanged: (value) =>
                                settings.setButtonFontWeight(value!),
                          ),
                          _buildColorPicker(
                            label: 'Button Color',
                            color: settings.buttonColor,
                            onColorChanged: (color) =>
                                settings.setButtonColor(color),
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
                          onChanged: (value) =>
                              settings.setButtonBorderRadius(value),
                        ),
                        _buildSectionTitle('Button Margins'),
                        _buildSlider(
                          label: 'Left Margin',
                          value: settings.buttonMargin.left,
                          min: 0.0,
                          max: 100.0,
                          onChanged: (value) => settings.setButtonMargin(
                            settings.buttonMargin.copyWith(left: value),
                          ),
                        ),
                        _buildSlider(
                          label: 'Top Margin',
                          value: settings.buttonMargin.top,
                          min: 0.0,
                          max: 100.0,
                          onChanged: (value) => settings.setButtonMargin(
                            settings.buttonMargin.copyWith(top: value),
                          ),
                        ),
                        _buildSlider(
                          label: 'Right Margin',
                          value: settings.buttonMargin.right,
                          min: 0.0,
                          max: 100.0,
                          onChanged: (value) => settings.setButtonMargin(
                            settings.buttonMargin.copyWith(right: value),
                          ),
                        ),
                        _buildSlider(
                          label: 'Bottom Margin',
                          value: settings.buttonMargin.bottom,
                          min: 0.0,
                          max: 100.0,
                          onChanged: (value) => settings.setButtonMargin(
                            settings.buttonMargin.copyWith(bottom: value),
                          ),
                        ),

                        _buildSectionTitle('Button Padding'),
                        _buildSlider(
                          label: 'Left Padding',
                          value: settings.buttonPadding.left,
                          min: 0.0,
                          max: 50.0,
                          onChanged: (value) => settings.setButtonPadding(
                            settings.buttonPadding.copyWith(left: value),
                          ),
                        ),
                        _buildSlider(
                          label: 'Top Padding',
                          value: settings.buttonPadding.top,
                          min: 0.0,
                          max: 50.0,
                          onChanged: (value) => settings.setButtonPadding(
                            settings.buttonPadding.copyWith(top: value),
                          ),
                        ),
                        _buildSlider(
                          label: 'Right Padding',
                          value: settings.buttonPadding.right,
                          min: 0.0,
                          max: 50.0,
                          onChanged: (value) => settings.setButtonPadding(
                            settings.buttonPadding.copyWith(right: value),
                          ),
                        ),
                        _buildSlider(
                          label: 'Bottom Padding',
                          value: settings.buttonPadding.bottom,
                          min: 0.0,
                          max: 50.0,
                          onChanged: (value) => settings.setButtonPadding(
                            settings.buttonPadding.copyWith(bottom: value),
                          ),
                        ),
                        SwitchListTile(
                          title: const Text('Button Has Border'),
                          value: settings.buttonHasBorder,
                          onChanged: (value) =>
                              settings.setButtonHasBorder(value),
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
                          onChanged: (value) =>
                              settings.setShowBackground(value),
                        ),
                        if (settings.showBackground) ...[
                          ListTile(
                            title: const Text('Background Image'),
                            subtitle: Text(settings.backgroundImagePath ??
                                'No image selected'),
                            trailing: ElevatedButton(
                              onPressed: () async {
                                final result =
                                    await FilePicker.platform.pickFiles(
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: settings.isBackgroundImageAsset
                                        ? AssetImage(
                                            settings.backgroundImagePath!)
                                        : FileImage(File(
                                                settings.backgroundImagePath!))
                                            as ImageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ]),
                ),
              ),
            ),
          ],
        ));
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
                  child: Text(
                    softWrap: true,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    entry.value,
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                  ),
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
            child: ImprovedColorPicker(
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
