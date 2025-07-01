// lib/presentation/loading_screen_settings.dart

import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/presentation/loading_screen.dart';
import 'package:photobooth_flutter/providers/loading_screen_provider.dart';
import 'package:photobooth_flutter/widgets/custom_dropdown.dart';
import 'package:photobooth_flutter/widgets/custom_slider.dart';
import 'package:photobooth_flutter/widgets/file_upload_area.dart';
import 'package:photobooth_flutter/widgets/form_row.dart';
import 'package:photobooth_flutter/widgets/color_picker.dart';
import 'package:photobooth_flutter/widgets/settings_group.dart';
import 'package:photobooth_flutter/widgets/settings_header.dart';
import 'package:photobooth_flutter/widgets/settings_preview.dart';
import 'package:provider/provider.dart';

class LoadingScreenSettings extends StatelessWidget {
  const LoadingScreenSettings({super.key});

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
              child: LoadingScreen(),
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
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SettingsHeader(
                  title: 'Loading Screen Settings',
                  subtitle: 'Customize the elements shown during processing',
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      children: [
                        _TitleSettingsGroup(),
                        SizedBox(height: 25),
                        _LoaderSettingsGroup(),
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

// --- SETTINGS WIDGETS ---

class _TitleSettingsGroup extends StatelessWidget {
  const _TitleSettingsGroup();
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<LoadingScreenProvider>();
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
            FormRow(
              children: [
                Expanded(
                  child: SliderWithLabel(
                    label: 'Font Size',
                    value: settings.titleFontSize,
                    min: 16,
                    max: 48,
                    onChanged: (value) => settings.setTitleFontSize(value),
                  ),
                ),
                Expanded(
                  child: SliderWithLabel(
                    label: 'Opacity',
                    value: settings.titleOpacity,
                    min: 0.1,
                    max: 1.0,
                    step: 0.1,
                    onChanged: (value) => settings.setTitleOpacity(value),
                  ),
                )
              ],
            ),
            const SizedBox(height: 15),
            SettingsGroup(
              isSubgroup: true,
              icon: '🎨',
              title: 'Styling',
              child: Column(
                children: [
                  CustomDropdown<FontWeight>(
                    label: 'Font Weight',
                    value: settings.titleFontWeight,
                    items: const {
                      FontWeight.w100: 'Thin',
                      FontWeight.w300: 'Light',
                      FontWeight.w400: 'Regular',
                      FontWeight.w500: 'Medium',
                      FontWeight.w700: 'Bold',
                      FontWeight.w900: 'Extra Bold',
                    },
                    onChanged: (value) => settings.setTitleFontWeight(value!),
                  ),
                  const SizedBox(height: 15),
                  CustomColorPicker(
                    label: 'Title Color',
                    pickerColor: settings.titleColor,
                    onColorChanged: (color) => settings.setTitleColor(color),
                  ),
                ],
              ),
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
                    max: 1000,
                    onChanged: (value) => settings.setTitleTop(value),
                  ),
                  SliderWithLabel(
                    label: 'From Left',
                    value: settings.titleLeft,
                    min: 0,
                    max: 500,
                    onChanged: (value) => settings.setTitleLeft(value),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }
}

class _LoaderSettingsGroup extends StatelessWidget {
  const _LoaderSettingsGroup();
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<LoadingScreenProvider>();
    return SettingsGroup(
      icon: '⏳',
      title: 'Loader Settings',
      child: Column(
        children: [
          SettingsGroup(
            isSubgroup: true,
            icon: '📐',
            title: 'Sizing',
            child: FormRow(
              children: [
                Expanded(
                  child: SliderWithLabel(
                    label: 'Loader Width',
                    value: settings.loaderWidth,
                    min: 50,
                    max: 500,
                    onChanged: (value) => settings.setLoaderWidth(value),
                  ),
                ),
                Expanded(
                  child: SliderWithLabel(
                    label: 'Loader Height',
                    value: settings.loaderHeight,
                    min: 50,
                    max: 500,
                    onChanged: (value) => settings.setLoaderHeight(value),
                  ),
                ),
              ],
            ),
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
                  value: settings.loaderTop,
                  min: 0,
                  max: 1000,
                  onChanged: (value) => settings.setLoaderTop(value),
                ),
                SliderWithLabel(
                  label: 'From Left',
                  value: settings.loaderLeft,
                  min: 0,
                  max: 500,
                  onChanged: (value) => settings.setLoaderLeft(value),
                ),
              ],
            ),
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
    final settings = context.watch<LoadingScreenProvider>();
    final textTheme = Theme.of(context).textTheme;

    return SettingsGroup(
      icon: '🖼️',
      title: 'Background Settings',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Show Custom Background', style: textTheme.bodyLarge),
              Switch(
                value: settings.showBackground,
                onChanged: (value) => settings.setShowBackground(value),
              ),
            ],
          ),
          if (settings.showBackground) ...[
            const SizedBox(height: 15),
            FileUploadArea(
              onTap: () async {
                final result =
                    await FilePicker.platform.pickFiles(type: FileType.image);
                if (result != null && result.files.single.path != null) {
                  settings.setBackgroundImage(result.files.single.path, false);
                }
              },
              icon: '📁',
              text: 'Choose Background Image',
              selectedFile: settings.backgroundImagePath,
            ),
          ]
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
