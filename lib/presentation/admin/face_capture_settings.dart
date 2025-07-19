import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/presentation/face_capture_screen.dart';
import 'package:photobooth_flutter/providers/face_capture_provider.dart';
import 'package:photobooth_flutter/widgets/color_picker.dart';
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
          const FaceCaptureScreen(isPreviewMode: false),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            right: _isPanelOpen ? 0 : -settingsPanelWidth,
            top: 0,
            bottom: 0,
            width: settingsPanelWidth,
            child: const _SettingsSection(),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: FloatingActionButton.small(
              heroTag: 'faceCaptureBack',
              tooltip: 'Back',
              backgroundColor: AppColors.white.withValues(alpha: 0.8),
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
            color: AppColors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.2)),
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
            TextFormField(
              initialValue: settings.titleText,
              decoration: const InputDecoration(labelText: 'Title Text'),
              onChanged: (v) => settings.setTitleStyle(text: v),
            ),
            const SizedBox(height: 15),
            SliderWithLabel(
                label: 'Font Size',
                value: settings.titleFontSize,
                min: 16,
                max: 120,
                onChanged: (v) => settings.setTitleStyle(fontSize: v)),
            SliderWithLabel(
                label: 'Opacity',
                value: settings.titleOpacity,
                min: 0.0,
                max: 1.0,
                step: 0.01,
                onChanged: (v) => settings.setTitleStyle(opacity: v)),
            const SizedBox(height: 15),
            SettingsGroup(
              isSubgroup: true,
              icon: '📍',
              title: 'Positioning',
              child: Column(
                children: [
                  SliderWithLabel(
                      label: 'From Top (%)',
                      value: settings.titleTop,
                      min: 0.0,
                      max: 1.0,
                      step: 0.01,
                      onChanged: (v) => settings.setTitlePosition(top: v)),
                  SliderWithLabel(
                      label: 'From Left (%)',
                      value: settings.titleLeft,
                      min: 0.0,
                      max: 1.0,
                      step: 0.01,
                      onChanged: (v) => settings.setTitlePosition(left: v)),
                  SliderWithLabel(
                      label: 'Width (%)',
                      value: settings.titleWidth,
                      min: 0.1,
                      max: 1.0,
                      step: 0.01,
                      onChanged: (v) => settings.setTitlePosition(width: v)),
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
  const _CameraPreviewSettingsGroup();
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<FaceCaptureProvider>();
    return SettingsGroup(
      icon: '📷',
      title: 'Camera Preview Settings',
      child: Column(
        children: [
          SettingsGroup(
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
                          onChanged: (v) => settings.setPreviewDimensions(
                              v, settings.previewHeight))),
                  Expanded(
                      child: SliderWithLabel(
                          label: 'Preview Height (%)',
                          value: settings.previewHeight,
                          min: 0.1,
                          max: 1.0,
                          step: 0.01,
                          onChanged: (v) => settings.setPreviewDimensions(
                              settings.previewWidth, v))),
                ]),
                SliderWithLabel(
                    label: 'From Top (%)',
                    value: settings.previewTop,
                    min: 0.0,
                    max: 1.0,
                    step: 0.01,
                    onChanged: (v) =>
                        settings.setPreviewPosition(settings.previewLeft, v)),
                SliderWithLabel(
                    label: 'From Left (%)',
                    value: settings.previewLeft,
                    min: 0.0,
                    max: 1.0,
                    step: 0.01,
                    onChanged: (v) =>
                        settings.setPreviewPosition(v, settings.previewTop)),
              ],
            ),
          ),
          const SizedBox(height: 15),
          SettingsGroup(
            isSubgroup: true,
            icon: '🖼️',
            title: 'Border Style',
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Show Border',
                        style: Theme.of(context).textTheme.bodyLarge),
                    Switch(
                        value: settings.showPreviewBorder,
                        onChanged: (v) =>
                            settings.setPreviewStyle(showBorder: v)),
                  ],
                ),
                if (settings.showPreviewBorder) ...[
                  SliderWithLabel(
                      label: 'Border Width',
                      value: settings.previewBorderWidth,
                      min: 1,
                      max: 20,
                      onChanged: (v) =>
                          settings.setPreviewStyle(borderWidth: v)),
                  SliderWithLabel(
                      label: 'Border Radius',
                      value: settings.previewBorderRadius,
                      min: 0,
                      max: 100,
                      onChanged: (v) =>
                          settings.setPreviewStyle(borderRadius: v)),
                ],
              ],
            ),
          ),
        ],
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
          const SizedBox(height: 20),
          if (settings.useImageButton)
            Column(
              children: [
                FileUploadArea(
                  onTap: () async {/* File picker logic */},
                  icon: '🖼️',
                  text: 'Choose Button Image',
                  selectedFile: settings.buttonImagePath,
                ),
                SliderWithLabel(
                    label: 'Opacity',
                    value: settings.buttonImageOpacity,
                    min: 0.0,
                    max: 1.0,
                    step: 0.01,
                    onChanged: (v) => settings.setButtonStyle(imageOpacity: v)),
              ],
            )
          else
            Column(
              children: [
                TextFormField(
                    initialValue: settings.buttonText,
                    decoration: const InputDecoration(labelText: 'Button Text'),
                    onChanged: (v) => settings.setButtonStyle(text: v)),
                const SizedBox(height: 15),
                FormRow(children: [
                  Expanded(
                      child: SliderWithLabel(
                          label: 'Font Size',
                          value: settings.buttonFontSize,
                          min: 12,
                          max: 48,
                          onChanged: (v) =>
                              settings.setButtonStyle(fontSize: v))),
                  Expanded(
                      child: SliderWithLabel(
                          label: 'Border Radius',
                          value: settings.buttonBorderRadius,
                          min: 0,
                          max: 50,
                          onChanged: (v) =>
                              settings.setButtonStyle(borderRadius: v))),
                ]),
                const SizedBox(height: 15),
                FormRow(children: [
                  Expanded(
                      child: ColorPickerWidget(
                          label: 'Background',
                          color: settings.buttonBackgroundColor,
                          onColorChanged: (c) =>
                              settings.setButtonStyle(backgroundColor: c))),
                  Expanded(
                      child: ColorPickerWidget(
                          label: 'Text Color',
                          color: settings.buttonForegroundColor,
                          onColorChanged: (c) =>
                              settings.setButtonStyle(foregroundColor: c))),
                ]),
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
                          label: 'Button Width (%)',
                          value: settings.buttonWidth,
                          min: 0.1,
                          max: 1.0,
                          step: 0.01,
                          onChanged: (v) => settings.setButtonDimensions(
                              v, settings.buttonHeight))),
                  Expanded(
                      child: SliderWithLabel(
                          label: 'Button Height (%)',
                          value: settings.buttonHeight,
                          min: 0.02,
                          max: 0.2,
                          step: 0.01,
                          onChanged: (v) => settings.setButtonDimensions(
                              settings.buttonWidth, v))),
                ]),
                SliderWithLabel(
                    label: 'From Top (%)',
                    value: settings.buttonTop,
                    min: 0.0,
                    max: 1.0,
                    step: 0.01,
                    onChanged: (v) =>
                        settings.setButtonPosition(settings.buttonLeft, v)),
                SliderWithLabel(
                    label: 'From Left (%)',
                    value: settings.buttonLeft,
                    min: 0.0,
                    max: 1.0,
                    step: 0.01,
                    onChanged: (v) =>
                        settings.setButtonPosition(v, settings.buttonTop)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
