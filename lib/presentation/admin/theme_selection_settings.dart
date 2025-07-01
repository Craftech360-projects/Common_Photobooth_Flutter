// lib/presentation/theme_selection_settings.dart

import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/presentation/theme_selection_screen.dart';
import 'package:photobooth_flutter/providers/theme_selection_provider.dart'
    hide Theme;
import 'package:photobooth_flutter/widgets/custom_slider.dart';
import 'package:photobooth_flutter/widgets/file_upload_area.dart';
import 'package:photobooth_flutter/widgets/form_row.dart';
import 'package:photobooth_flutter/widgets/settings_group.dart';
import 'package:photobooth_flutter/widgets/settings_header.dart';
import 'package:photobooth_flutter/widgets/settings_preview.dart';
import 'package:provider/provider.dart';

class ThemeSelectionSettingsScreen extends StatelessWidget {
  const ThemeSelectionSettingsScreen({super.key});

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
              child: ThemeSelectionScreen(),
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
              color: AppColors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: AppColors.white.withValues(alpha: 0.2)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SettingsHeader(
                  title: 'Theme Screen Settings',
                  subtitle: 'Customize the theme selection carousel and layout',
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      children: [
                        _TitleSettingsGroup(),
                        SizedBox(height: 25),
                        _BackgroundSettingsGroup(),
                        SizedBox(height: 25),
                        _CarouselSettingsGroup(),
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
      ),
    );
  }
}

// --- SETTINGS WIDGETS ---

class _TitleSettingsGroup extends StatelessWidget {
  const _TitleSettingsGroup();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<ThemeSelectionProvider>();
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
              decoration: _inputDecoration(context, 'Enter title text'),
              onChanged: (value) => settings.setTitleText(value),
            ),
            const SizedBox(height: 15),
            CustomSliderWithLabel(
              label: 'Font Size',
              value: settings.titleFontSize,
              min: 16,
              max: 90,
              onChanged: (v) => settings.setTitleFontSize(v),
            ),
            CustomSliderWithLabel(
              label: 'Top Position',
              value: settings.titleTop,
              min: 50,
              max: 900,
              onChanged: (v) => settings.setTitleTop(v),
            ),
          ],
        ],
      ),
    );
  }
}

class _BackgroundSettingsGroup extends StatelessWidget {
  const _BackgroundSettingsGroup();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<ThemeSelectionProvider>();
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
                if (result?.files.single.path != null) {
                  settings.setBackgroundImage(result!.files.single.path,
                      isAsset: false);
                }
              },
              icon: '📁',
              text: 'Select Background Image',
              selectedFile: settings.backgroundImagePath,
            ),
          ]
        ],
      ),
    );
  }
}

class _CarouselSettingsGroup extends StatelessWidget {
  const _CarouselSettingsGroup();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<ThemeSelectionProvider>();

    return SettingsGroup(
      icon: '🎠',
      title: 'Carousel & Card Settings',
      child: Column(
        children: [
          CustomSliderWithLabel(
            label: 'Carousel Top Position',
            value: settings.carouselTop,
            min: 100,
            max: 1200,
            onChanged: (v) => settings.setCarouselTop(v),
          ),
          CustomSliderWithLabel(
            label: 'Carousel Height',
            value: settings.carouselHeight,
            min: 300,
            max: 1000,
            onChanged: (v) => settings.setCarouselHeight(v),
          ),
          // CustomSliderWithLabel(    =========>   Need to Check
          //   label: 'Arrow Spacing',
          //   value: settings.arrowSpacing,
          //   min: 0,
          //   max: 150,
          //   onChanged: (v) => settings.setArrowSpacing(v),
          // ),
          const SizedBox(height: 15),
          SettingsGroup(
            isSubgroup: true,
            icon: '🃏',
            title: 'Card Style',
            child: Column(
              children: [
                FormRow(
                  children: [
                    Expanded(
                      child: CustomSliderWithLabel(
                        label: 'Card Width',
                        value: settings.cardWidth,
                        min: 200,
                        max: 700,
                        onChanged: (v) => settings.setCardWidth(v),
                      ),
                    ),
                    Expanded(
                      child: CustomSliderWithLabel(
                        label: 'Card Height',
                        value: settings.cardHeight,
                        min: 300,
                        max: 900,
                        onChanged: (v) => settings.setCardHeight(v),
                      ),
                    ),
                  ],
                ),
                CustomSliderWithLabel(
                  label: 'Card Border Radius',
                  value: settings.cardBorderRadius,
                  min: 0,
                  max: 50,
                  onChanged: (v) => settings.setCardBorderRadius(v),
                ),
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
    final settings = context.watch<ThemeSelectionProvider>();
    final textTheme = Theme.of(context).textTheme;

    return SettingsGroup(
      icon: '🔘',
      title: 'Button Settings',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Use Image Button', style: textTheme.bodyLarge),
              Switch(
                value: settings.useImageButton,
                onChanged: (value) => settings.setUseImageButton(value),
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (settings.useImageButton)
            FileUploadArea(
              onTap: () async {
                final result =
                    await FilePicker.platform.pickFiles(type: FileType.image);
                if (result?.files.single.path != null) {
                  settings.setButtonImage(result!.files.single.path,
                      isAsset: false);
                }
              },
              icon: '🖼️',
              text: 'Select Button Image',
              selectedFile: settings.buttonImagePath,
            ),
          const SizedBox(height: 15),
          FormRow(
            children: [
              Expanded(
                child: CustomSliderWithLabel(
                  label: 'Button Width',
                  value: settings.buttonWidth,
                  min: 100,
                  max: 800,
                  onChanged: (v) => settings.setButtonWidth(v),
                ),
              ),
              Expanded(
                child: CustomSliderWithLabel(
                  label: 'Button Height',
                  value: settings.buttonHeight,
                  min: 50,
                  max: 300,
                  onChanged: (v) => settings.setButtonHeight(v),
                ),
              ),
            ],
          ),
          CustomSliderWithLabel(
            label: 'Button Bottom Position',
            value: settings.buttonBottom,
            min: 100,
            max: 1000,
            onChanged: (v) => settings.setButtonBottom(v),
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
    fillColor: AppColors.white.withValues(alpha: 0.8),
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
