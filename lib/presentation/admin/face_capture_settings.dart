// lib/presentation/face_capture_settings.dart

import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/presentation/face_capture_screen.dart';
import 'package:photobooth_flutter/providers/face_capture_provider.dart';
import 'package:photobooth_flutter/widgets/custom_slider.dart';
import 'package:photobooth_flutter/widgets/file_upload_area.dart';
import 'package:photobooth_flutter/widgets/form_row.dart';
import 'package:photobooth_flutter/widgets/settings_group.dart';
import 'package:photobooth_flutter/widgets/settings_header.dart';
import 'package:photobooth_flutter/widgets/toggle_btn_group.dart';
import 'package:provider/provider.dart';

class FaceCaptureSettings extends StatefulWidget {
  const FaceCaptureSettings({super.key});

  @override
  State<FaceCaptureSettings> createState() => _FaceCaptureSettingsState();
}

class _FaceCaptureSettingsState extends State<FaceCaptureSettings> {
  bool _isPanelOpen = true;

  @override
  Widget build(BuildContext context) {
    double settingsPanelWidth = MediaQuery.of(context).size.width * 0.8;
    return Scaffold(
      body: Stack(
        children: [
          // Live camera preview as the background
          const FaceCaptureScreen(isPreviewMode: false),

          // Sliding settings panel
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            right: _isPanelOpen ? 0 : -settingsPanelWidth,
            top: 0,
            bottom: 0,
            width: settingsPanelWidth,
            child: const _SettingsSection(),
          ),

          // Control Buttons
          Positioned(
            top: 20,
            left: 20,
            child: FloatingActionButton.small(
              heroTag: 'faceCaptureBack',
              tooltip: 'Back',
              backgroundColor: AppColors.white.withOpacity(0.8),
              child: const Icon(Icons.arrow_back,
                  color: AppColors.primaryGradientEnd),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: 20,
            right: _isPanelOpen ? settingsPanelWidth + 20 : 20,
            child: FloatingActionButton(
              heroTag: 'faceCaptureToggle',
              tooltip: 'Toggle Settings',
              backgroundColor: AppColors.white,
              onPressed: () => setState(() => _isPanelOpen = !_isPanelOpen),
              child: Icon(
                _isPanelOpen
                    ? Icons.arrow_forward_ios_rounded
                    : Icons.arrow_back_ios_rounded,
                color: AppColors.primaryGradientEnd,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 20, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsHeader(
                title: 'Face Capture Screen',
                subtitle: 'Customize the camera and capture UI elements',
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    children: [
                      _TitleSettingsGroup(),
                      SizedBox(height: 25),
                      _CameraPreviewSettingsGroup(),
                      SizedBox(height: 25),
                      _ButtonSettingsGroup(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TitleSettingsGroup extends StatelessWidget {
  const _TitleSettingsGroup();
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<FaceCaptureProvider>();
    return SettingsGroup(
      icon: '✏️',
      title: 'Title Settings',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Show Title', style: Theme.of(context).textTheme.bodyLarge),
              Switch(
                  value: settings.showTitle,
                  onChanged: (v) => settings.setShowTitle(v)),
            ],
          ),
          if (settings.showTitle) ...[
            const SizedBox(height: 15),
            SliderWithLabel(
                label: 'From Top (%)',
                value: settings.titleTop,
                min: 0.0,
                max: 1.0,
                step: 0.01,
                onChanged: (v) => settings.setTitleTop(v)),
            SliderWithLabel(
                label: 'From Left (%)',
                value: settings.titleLeft,
                min: 0.0,
                max: 1.0,
                step: 0.01,
                onChanged: (v) => settings.setTitleLeft(v)),
          ]
        ],
      ),
    );
  }
}

class _CameraPreviewSettingsGroup extends StatelessWidget {
  const _CameraPreviewSettingsGroup();
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<FaceCaptureProvider>();
    return SettingsGroup(
      icon: '📷',
      title: 'Camera Preview Settings',
      child: SettingsGroup(
        isSubgroup: true,
        icon: '📐',
        title: 'Sizing & Positioning',
        child: Column(
          children: [
            FormRow(children: [
              Expanded(
                  child: SliderWithLabel(
                      label: 'Preview Width (%)',
                      value: settings.previewWidth,
                      min: 0.1,
                      max: 1.0,
                      step: 0.01,
                      onChanged: (v) => settings.setPreviewWidth(v))),
              Expanded(
                  child: SliderWithLabel(
                      label: 'Preview Height (%)',
                      value: settings.previewHeight,
                      min: 0.1,
                      max: 1.0,
                      step: 0.01,
                      onChanged: (v) => settings.setPreviewHeight(v))),
            ]),
            SliderWithLabel(
                label: 'From Top (%)',
                value: settings.previewTop,
                min: 0.0,
                max: 1.0,
                step: 0.01,
                onChanged: (v) => settings.setPreviewTop(v)),
            SliderWithLabel(
                label: 'From Left (%)',
                value: settings.previewLeft,
                min: 0.0,
                max: 1.0,
                step: 0.01,
                onChanged: (v) => settings.setPreviewLeft(v)),
          ],
        ),
      ),
    );
  }
}

class _ButtonSettingsGroup extends StatelessWidget {
  const _ButtonSettingsGroup();
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<FaceCaptureProvider>();
    return SettingsGroup(
      icon: '🔘',
      title: 'Capture Button Settings',
      child: Column(
        children: [
          ToggleButtonGroup(
            options: const ['Image Button', 'Text Button'],
            selectedIndex: settings.useImageButton ? 0 : 1,
            onSelected: (i) => settings.setUseImageButton(i == 0),
          ),
          if (settings.useImageButton)
            FileUploadArea(
              onTap: () async {
                // File picker logic
              },
              icon: '🖼️',
              text: 'Choose Button Image',
              selectedFile: settings.buttonImagePath,
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
                          label: 'Button Width (%)',
                          value: settings.buttonWidth,
                          min: 0.1,
                          max: 1.0,
                          step: 0.01,
                          onChanged: (v) => settings.setButtonWidth(v))),
                  Expanded(
                      child: SliderWithLabel(
                          label: 'Button Height (%)',
                          value: settings.buttonHeight,
                          min: 0.02,
                          max: 0.2,
                          step: 0.01,
                          onChanged: (v) => settings.setButtonHeight(v))),
                ]),
                SliderWithLabel(
                    label: 'From Top (%)',
                    value: settings.buttonTop,
                    min: 0.0,
                    max: 1.0,
                    step: 0.01,
                    onChanged: (v) => settings.setButtonTop(v)),
                SliderWithLabel(
                    label: 'From Left (%)',
                    value: settings.buttonLeft,
                    min: 0.0,
                    max: 1.0,
                    step: 0.01,
                    onChanged: (v) => settings.setButtonLeft(v)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
