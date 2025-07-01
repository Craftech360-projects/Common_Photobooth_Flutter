import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/presentation/output_screen.dart';
import 'package:photobooth_flutter/providers/output_screen_provider.dart';
import 'package:photobooth_flutter/widgets/custom_slider.dart';
import 'package:photobooth_flutter/widgets/file_upload_area.dart';
import 'package:photobooth_flutter/widgets/form_row.dart';
import 'package:photobooth_flutter/widgets/color_picker.dart';
import 'package:photobooth_flutter/widgets/settings_group.dart';
import 'package:photobooth_flutter/widgets/settings_header.dart';
import 'package:photobooth_flutter/widgets/settings_preview.dart';
import 'package:photobooth_flutter/widgets/toggle_btn_group.dart';
import 'package:provider/provider.dart';

class OutputScreenSettings extends StatelessWidget {
  const OutputScreenSettings({super.key});

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
        child: const Row(
          children: [
            _PreviewSection(),
            Expanded(child: _SettingsSection()),
          ],
        ),
      ),
    );
  }
}

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
              child: SwappedFaceScreen(
                isPreviewMode: true,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Material(
              color: AppColors.white.withOpacity(0.9),
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
  const _SettingsSection();
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
              color: AppColors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: AppColors.white.withOpacity(0.2)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SettingsHeader(
                  title: 'Output Screen Settings',
                  subtitle: 'Customize the final output screen elements',
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      children: [
                        _TitleSettingsGroup(),
                        SizedBox(height: 25),
                        _ImageSettingsGroup(),
                        SizedBox(height: 25),
                        _QrCodeSettingsGroup(),
                        SizedBox(height: 25),
                        _ButtonSettingsGroup(),
                        SizedBox(height: 25),
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

class _TitleSettingsGroup extends StatelessWidget {
  const _TitleSettingsGroup();
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<OutputScreenProvider>();
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
                onChanged: (value) => settings.setShowTitle(value),
              ),
            ],
          ),
          if (settings.showTitle) ...[
            const SizedBox(height: 15),
            TextFormField(
              initialValue: settings.titleText,
              decoration: _inputDecoration(context, 'Title Text'),
              onChanged: (value) => settings.setTitleText(value),
            ),
            const SizedBox(height: 15),
            CustomSliderWithLabel(
              label: 'Font Size',
              value: settings.titleFontSize,
              min: 16,
              max: 80,
              onChanged: (v) => settings.setTitleFontSize(v),
            ),
            CustomColorPicker(
              label: 'Title Color',
              pickerColor: settings.titleColor,
              onColorChanged: (c) => settings.setTitleColor(c),
            ),
            const SizedBox(height: 15),
            SettingsGroup(
              isSubgroup: true,
              icon: '📍',
              title: 'Positioning',
              child: Column(
                children: [
                  CustomSliderWithLabel(
                      label: 'From Top',
                      value: settings.titleTop,
                      min: 0,
                      max: 1200,
                      onChanged: (v) => settings.setTitlePosition(
                          settings.titleLeft, v, settings.titleWidth)),
                  CustomSliderWithLabel(
                      label: 'From Left',
                      value: settings.titleLeft,
                      min: 0,
                      max: 1080,
                      onChanged: (v) => settings.setTitlePosition(
                          v, settings.titleTop, settings.titleWidth)),
                  CustomSliderWithLabel(
                      label: 'Width',
                      value: settings.titleWidth,
                      min: 100,
                      max: 1080,
                      onChanged: (v) => settings.setTitlePosition(
                          settings.titleLeft, settings.titleTop, v)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ImageSettingsGroup extends StatelessWidget {
  const _ImageSettingsGroup();
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<OutputScreenProvider>();
    return SettingsGroup(
      icon: '🖼️',
      title: 'Image Settings',
      child: Column(
        children: [
          SettingsGroup(
            isSubgroup: true,
            icon: '🤖',
            title: 'AI Artistry Image Position',
            child: FormRow(
              children: [
                Expanded(
                    child: CustomSliderWithLabel(
                        label: 'From Left',
                        value: settings.aiArtistryLeft,
                        min: 0,
                        max: 800,
                        onChanged: (v) => settings.setAiArtistryPosition(
                            v, settings.aiArtistryTop))),
                Expanded(
                    child: CustomSliderWithLabel(
                        label: 'From Top',
                        value: settings.aiArtistryTop,
                        min: 0,
                        max: 1800,
                        onChanged: (v) => settings.setAiArtistryPosition(
                            settings.aiArtistryLeft, v))),
              ],
            ),
          ),
          const SizedBox(height: 15),
          SettingsGroup(
            isSubgroup: true,
            icon: '🎭',
            title: 'Swaplab Image Position & Size',
            child: Column(
              children: [
                FormRow(
                  children: [
                    Expanded(
                        child: CustomSliderWithLabel(
                            label: 'From Left',
                            value: settings.swaplabLeft,
                            min: 0,
                            max: 800,
                            onChanged: (v) => settings.setSwaplabPosition(
                                v, settings.swaplabTop))),
                    Expanded(
                        child: CustomSliderWithLabel(
                            label: 'From Top',
                            value: settings.swaplabTop,
                            min: 0,
                            max: 1800,
                            onChanged: (v) => settings.setSwaplabPosition(
                                settings.swaplabLeft, v))),
                  ],
                ),
                FormRow(
                  children: [
                    Expanded(
                        child: CustomSliderWithLabel(
                            label: 'Width',
                            value: settings.swaplabImageWidth,
                            min: 100,
                            max: 1080,
                            onChanged: (v) =>
                                settings.setSwaplabImageDimensions(
                                    v, settings.swaplabImageHeight))),
                    Expanded(
                        child: CustomSliderWithLabel(
                            label: 'Height',
                            value: settings.swaplabImageHeight,
                            min: 100,
                            max: 1620,
                            onChanged: (v) =>
                                settings.setSwaplabImageDimensions(
                                    settings.swaplabImageWidth, v))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          // NEW: Image border and style settings
          SettingsGroup(
            isSubgroup: true,
            icon: '🎨',
            title: 'Image Border & Style',
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Show Border',
                        style: Theme.of(context).textTheme.bodyLarge),
                    Switch(
                      value: settings.showImageBorder,
                      onChanged: (value) => settings.setShowImageBorder(value),
                    ),
                  ],
                ),
                if (settings.showImageBorder)
                  CustomSliderWithLabel(
                    label: 'Border Width',
                    value: settings.imageBorderWidth,
                    min: 1,
                    max: 20,
                    onChanged: (v) => settings.setImageBorderWidth(v),
                  ),
                if (settings.showImageBorder)
                  CustomColorPicker(
                    label: 'Border Color',
                    pickerColor: settings.imageBorderColor,
                    onColorChanged: (c) => settings.setImageBorderColor(c),
                  ),
                CustomSliderWithLabel(
                  label: 'Border Radius',
                  value: settings.imageBorderRadius,
                  min: 0,
                  max: 100,
                  onChanged: (v) => settings.setImageBorderRadius(v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QrCodeSettingsGroup extends StatelessWidget {
  const _QrCodeSettingsGroup();
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<OutputScreenProvider>();
    return SettingsGroup(
      icon: '📱',
      title: 'QR Code Settings',
      child: Column(
        children: [
          CustomSliderWithLabel(
            label: 'QR Code Size',
            value: settings.qrCodeSize,
            min: 50,
            max: 500,
            onChanged: (v) => settings.setQrCodeSize(v),
          ),
          const SizedBox(height: 15),
          SettingsGroup(
            isSubgroup: true,
            icon: '📍',
            title: 'Positioning',
            child: FormRow(
              children: [
                Expanded(
                    child: CustomSliderWithLabel(
                        label: 'From Left',
                        value: settings.qrCodeLeft,
                        min: 0,
                        max: 1000,
                        onChanged: (v) => settings.setQrCodePosition(
                            v, settings.qrCodeBottom))),
                Expanded(
                    child: CustomSliderWithLabel(
                        label: 'From Bottom',
                        value: settings.qrCodeBottom,
                        min: 0,
                        max: 1000,
                        onChanged: (v) => settings.setQrCodePosition(
                            settings.qrCodeLeft, v))),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ButtonSettingsGroup extends StatelessWidget {
  const _ButtonSettingsGroup();
  @override
  Widget build(BuildContext context) {
    // UPDATED: Removed the logic for the download button.
    final settings = context.watch<OutputScreenProvider>();
    return SettingsGroup(
      isSubgroup: true,
      icon: '✅',
      title: 'Home Button Settings',
      child: Column(
        children: [
          ToggleButtonGroup(
            options: const ['Text', 'Image'],
            selectedIndex: settings.useDoneButtonImage ? 1 : 0,
            onSelected: (i) => settings.setUseDoneButtonImage(i == 1),
          ),
          const SizedBox(height: 15),
          if (settings.useDoneButtonImage)
            FileUploadArea(
              onTap: () async {
                final result =
                    await FilePicker.platform.pickFiles(type: FileType.image);
                if (result?.files.single.path != null) {
                  settings.setDoneButtonImage(result!.files.single.path);
                }
              },
              icon: '🖼️',
              text: 'Choose Home Button Image',
              selectedFile: settings.doneButtonImagePath,
            )
          else
            TextFormField(
              initialValue: settings.doneButtonText,
              decoration: _inputDecoration(context, 'Home Button Text'),
              onChanged: (v) => settings.setDoneButtonText(v),
            ),
          const SizedBox(height: 15),
          FormRow(
            children: [
              Expanded(
                  child: CustomSliderWithLabel(
                      label: 'Width',
                      value: settings.doneButtonWidth,
                      min: 100,
                      max: 500,
                      onChanged: (v) => settings.setDoneButtonWidth(v))),
              Expanded(
                  child: CustomSliderWithLabel(
                      label: 'Height',
                      value: settings.doneButtonHeight,
                      min: 50,
                      max: 300,
                      onChanged: (v) => settings.setDoneButtonHeight(v))),
            ],
          ),
          FormRow(
            children: [
              Expanded(
                  child: CustomSliderWithLabel(
                      label: 'From Left',
                      value: settings.doneButtonLeft,
                      min: 0,
                      max: 1000,
                      onChanged: (v) => settings.setDoneButtonPosition(
                          v, settings.doneButtonBottom))),
              Expanded(
                  child: CustomSliderWithLabel(
                      label: 'From Bottom',
                      value: settings.doneButtonBottom,
                      min: 0,
                      max: 1000,
                      onChanged: (v) => settings.setDoneButtonPosition(
                          settings.doneButtonLeft, v))),
            ],
          ),
        ],
      ),
    );
  }
}

class _BackgroundSettingsGroup extends StatelessWidget {
  const _BackgroundSettingsGroup();
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<OutputScreenProvider>();
    return SettingsGroup(
      icon: '🌌',
      title: 'Background',
      child: FileUploadArea(
        onTap: () async {
          final result =
              await FilePicker.platform.pickFiles(type: FileType.image);
          if (result?.files.single.path != null) {
            settings.setBackgroundImage(result!.files.single.path);
          }
        },
        icon: '📁',
        text: 'Select Background Image',
        selectedFile: settings.backgroundImagePath,
      ),
    );
  }
}

InputDecoration _inputDecoration(BuildContext context, String hintText) {
  final theme = Theme.of(context);
  return InputDecoration(
    hintText: hintText,
    filled: true,
    fillColor: AppColors.white.withOpacity(0.8),
    hintStyle: theme.textTheme.bodyMedium
        ?.copyWith(color: AppColors.labelText.withOpacity(0.7)),
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
