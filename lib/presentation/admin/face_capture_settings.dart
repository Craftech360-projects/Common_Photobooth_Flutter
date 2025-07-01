// lib/presentation/face_capture_settings.dart

import 'dart:ui';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/presentation/face_capture_screen.dart';
import 'package:photobooth_flutter/providers/face_capture_provider.dart';
import 'package:photobooth_flutter/widgets/custom_dropdown.dart';
import 'package:photobooth_flutter/widgets/custom_slider.dart';
import 'package:photobooth_flutter/widgets/file_upload_area.dart';
import 'package:photobooth_flutter/widgets/form_row.dart';
import 'package:photobooth_flutter/widgets/color_picker.dart';
import 'package:photobooth_flutter/widgets/settings_group.dart';
import 'package:photobooth_flutter/widgets/settings_header.dart';
import 'package:photobooth_flutter/widgets/settings_preview.dart';
import 'package:photobooth_flutter/widgets/toggle_btn_group.dart';
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryGradientStart,
              AppColors.primaryGradientEnd
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            const _PreviewSection(),
            Expanded(
              child: _SettingsSection(
                cameras: _cameras,
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- UI SECTIONS ---
class _PreviewSection extends StatelessWidget {
  const _PreviewSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Stack(
        children: [
          const Center(
            child: SettingsPreview(
              width: 1080,
              height: 1920,
              child: FaceCaptureScreen(
                isPreviewMode: true,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Material(
              color: AppColors.white.withValues(alpha: 0.9),
              shape: const CircleBorder(),
              elevation: 2.0,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.labelText),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Back',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final List<CameraDescription> cameras;
  final bool isLoading;

  const _SettingsSection({required this.cameras, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 20, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SettingsHeader(
                  title: 'Face Capture Screen',
                  subtitle: 'Customize the camera and capture UI elements',
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                        _TitleSettingsGroup(),
                        const SizedBox(height: 25),
                        _CameraPreviewSettingsGroup(
                            cameras: cameras, isLoading: isLoading),
                        const SizedBox(height: 25),
                        _ButtonSettingsGroup(),
                        const SizedBox(height: 25),
                        _BackgroundSettingsGroup(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- SETTINGS WIDGETS ---
class _TitleSettingsGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<FaceCaptureProvider>();
    final textTheme = Theme.of(context).textTheme;

    return SettingsGroup(
      icon: '✏️',
      title: 'Title Settings',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Show Title', style: textTheme.bodyLarge),
              Switch(
                  value: settings.showTitle,
                  onChanged: (v) => settings.setShowTitle(v)),
            ],
          ),
          if (settings.showTitle) ...[
            const SizedBox(height: 15),
            TextFormField(
              initialValue: settings.titleText,
              decoration: _inputDecoration(context, 'Title Text'),
              onChanged: (v) => settings.setTitleText(v),
            ),
            const SizedBox(height: 15),
            SliderWithLabel(
              label: 'Font Size',
              value: settings.titleFontSize,
              min: 16,
              max: 80,
              onChanged: (v) => settings.setTitleFontSize(v),
            ),
            const SizedBox(height: 15),
            SettingsGroup(
              isSubgroup: true,
              icon: '📍',
              title: 'Positioning',
              child: Column(
                children: [
                  SliderWithLabel(
                      label: 'From Top',
                      value: settings.titleTop,
                      min: 0,
                      max: 1200,
                      onChanged: (v) => settings.setTitleTop(v)),
                  SliderWithLabel(
                      label: 'From Left',
                      value: settings.titleLeft,
                      min: 0,
                      max: 900,
                      onChanged: (v) => settings.setTitleLeft(v)),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }
}

class _CameraPreviewSettingsGroup extends StatelessWidget {
  final List<CameraDescription> cameras;
  final bool isLoading;

  const _CameraPreviewSettingsGroup(
      {required this.cameras, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<FaceCaptureProvider>();
    return SettingsGroup(
      icon: '📷',
      title: 'Camera Preview Settings',
      child: Column(
        children: [
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else
            CustomDropdown<int>(
              label: 'Select Camera',
              value: settings.selectedCameraIndex < cameras.length
                  ? settings.selectedCameraIndex
                  : 0,
              items: {
                for (int i = 0; i < cameras.length; i++)
                  i: 'Camera ${i + 1} (${cameras[i].name})'
              },
              onChanged: (v) => settings.setSelectedCameraIndex(v ?? 0),
            ),
          const SizedBox(height: 15),
          SettingsGroup(
            isSubgroup: true,
            icon: '📐',
            title: 'Sizing & Positioning',
            child: Column(
              children: [
                FormRow(children: [
                  Expanded(
                      child: SliderWithLabel(
                          label: 'Preview Width',
                          value: settings.previewWidth,
                          min: 200,
                          max: 900,
                          onChanged: (v) => settings.setPreviewWidth(v))),
                  Expanded(
                      child: SliderWithLabel(
                          label: 'Preview Height',
                          value: settings.previewHeight,
                          min: 200,
                          max: 900,
                          onChanged: (v) => settings.setPreviewHeight(v))),
                ]),
                SliderWithLabel(
                    label: 'From Top',
                    value: settings.previewTop,
                    min: 0,
                    max: 1000,
                    onChanged: (v) => settings.setPreviewTop(v)),
                SliderWithLabel(
                    label: 'From Left',
                    value: settings.previewLeft,
                    min: 0,
                    max: 800,
                    onChanged: (v) => settings.setPreviewLeft(v)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ButtonSettingsGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<FaceCaptureProvider>();
    return SettingsGroup(
      icon: '🔘',
      title: 'Capture Button Settings',
      child: Column(
        children: [
          ToggleButtonGroup(
            options: const ['Text Button', 'Image Button'],
            selectedIndex: settings.useImageButton ? 1 : 0,
            onSelected: (i) => settings.setUseImageButton(i == 1),
          ),
          const SizedBox(height: 15),
          if (settings.useImageButton)
            FileUploadArea(
              onTap: () async {
                final result =
                    await FilePicker.platform.pickFiles(type: FileType.image);
                if (result?.files.single.path != null) {
                  settings.setButtonImagePath(result!.files.single.path,
                      isAsset: false);
                }
              },
              icon: '🖼️',
              text: 'Choose Button Image',
              selectedFile: settings.buttonImagePath,
            )
          else
            Column(
              children: [
                TextFormField(
                  initialValue: settings.buttonText,
                  decoration: _inputDecoration(context, 'Button Text'),
                  onChanged: (v) => settings.setButtonText(v),
                ),
                const SizedBox(height: 15),
                CustomColorPicker(
                    label: 'Button Color',
                    pickerColor: settings.buttonColor,
                    onColorChanged: (c) => settings.setButtonColor(c)),
                const SizedBox(height: 10),
                CustomColorPicker(
                    label: 'Text Color',
                    pickerColor: settings.buttonTextColor,
                    onColorChanged: (c) => settings.setButtonTextColor(c)),
              ],
            ),
          const SizedBox(height: 20),
          SettingsGroup(
            isSubgroup: true,
            icon: '📐',
            title: 'Sizing & Positioning',
            child: Column(
              children: [
                FormRow(children: [
                  Expanded(
                      child: SliderWithLabel(
                          label: 'Button Width',
                          value: settings.buttonWidth,
                          min: 100,
                          max: 500,
                          onChanged: (v) => settings.setButtonWidth(v))),
                  Expanded(
                      child: SliderWithLabel(
                          label: 'Button Height',
                          value: settings.buttonHeight,
                          min: 40,
                          max: 200,
                          onChanged: (v) => settings.setButtonHeight(v))),
                ]),
                SliderWithLabel(
                    label: 'From Top',
                    value: settings.buttonTop,
                    min: 0,
                    max: 1500,
                    onChanged: (v) => settings.setButtonTop(v)),
                SliderWithLabel(
                    label: 'From Left',
                    value: settings.buttonLeft,
                    min: 0,
                    max: 800,
                    onChanged: (v) => settings.setButtonLeft(v)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundSettingsGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<FaceCaptureProvider>();
    final textTheme = Theme.of(context).textTheme;

    return SettingsGroup(
      icon: '🖼️',
      title: 'Background Settings',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Show Background Image', style: textTheme.bodyLarge),
              Switch(
                  value: settings.showBackground,
                  onChanged: (v) => settings.setShowBackground(v)),
            ],
          ),
          const SizedBox(height: 15),
          if (settings.showBackground)
            FileUploadArea(
              onTap: () async {
                final result =
                    await FilePicker.platform.pickFiles(type: FileType.image);
                if (result?.files.single.path != null) {
                  settings.setBackgroundImagePath(result!.files.single.path,
                      isAsset: false);
                }
              },
              icon: '📁',
              text: 'Select Background Image',
              selectedFile: settings.backgroundImagePath,
            ),
        ],
      ),
    );
  }
}

// --- HELPER METHODS ---

InputDecoration _inputDecoration(BuildContext context, String hintText) {
  final theme = Theme.of(context);
  return InputDecoration(
    hintText: hintText,
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.8),
    hintStyle: theme.textTheme.bodyMedium
        ?.copyWith(color: AppColors.labelText.withValues(alpha: 0.7)),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.inputBorder, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.inputBorder, width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide:
          const BorderSide(color: AppColors.primaryGradientStart, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
  );
}
