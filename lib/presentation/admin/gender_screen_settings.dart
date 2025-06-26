// lib/presentation/gender_screen_settings.dart

import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/presentation/gender_selection_screen.dart';
import 'package:photobooth_flutter/providers/gender_selection_provider.dart';
import 'package:photobooth_flutter/widgets/custom_slider.dart';
import 'package:photobooth_flutter/widgets/file_upload_area.dart';
import 'package:photobooth_flutter/widgets/improved_color_picker.dart';
import 'package:photobooth_flutter/widgets/settings_group.dart';
import 'package:photobooth_flutter/widgets/settings_header.dart';
import 'package:photobooth_flutter/widgets/settings_preview.dart';
import 'package:provider/provider.dart';

class GenderScreenSettings extends StatelessWidget {
  const GenderScreenSettings({super.key});

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
              child: GenderSelectionScreen(),
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
                  title: 'Gender Screen Settings',
                  subtitle: 'Customize the gender selection options and style',
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
                        _GenderImagesGroup(),
                        SizedBox(height: 25),
                        _SelectionEffectGroup(),
                        SizedBox(height: 25),
                        _ButtonSettingsGroup(),
                        SizedBox(height: 25),
                        _LayoutSettingsGroup(),
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

// --- SETTINGS GROUPS ---

class _TitleSettingsGroup extends StatelessWidget {
  const _TitleSettingsGroup();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<GenderSelectionProvider>();
    final textTheme = Theme.of(context).textTheme;

    return SettingsGroup(
      icon: '✏️',
      title: 'Title Settings',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            initialValue: settings.titleText,
            decoration: _inputDecoration(context, 'Enter title text'),
            onChanged: (value) => settings.setTitleText(value),
          ),
          const SizedBox(height: 15),
          _FormRow(
            children: [
              Expanded(
                  child: CustomSliderWithLabel(
                label: 'Font Size',
                value: settings.titleFontSize,
                min: 16,
                max: 60,
                onChanged: (v) => settings.setTitleStyle(fontSize: v),
              )),
              Expanded(
                  child: CustomSliderWithLabel(
                label: 'Opacity',
                value: settings.titleOpacity,
                min: 0.1,
                max: 1.0,
                step: 0.1,
                onChanged: (v) => settings.setTitleStyle(opacity: v),
              )),
            ],
          ),
          const SizedBox(height: 15),
          SettingsGroup(
              isSubgroup: true,
              icon: '🎨',
              title: 'Styling',
              child: Column(
                children: [
                  _CustomDropdown<FontWeight>(
                    label: 'Font Weight',
                    value: settings.titleFontWeight,
                    items: const {
                      FontWeight.w300: 'Light',
                      FontWeight.w400: 'Regular',
                      FontWeight.w500: 'Medium',
                      FontWeight.w700: 'Bold',
                      FontWeight.w900: 'Black'
                    },
                    onChanged: (v) => settings.setTitleStyle(fontWeight: v),
                  ),
                  const SizedBox(height: 15),
                  _CustomColorPicker(
                    label: 'Title Color',
                    color: settings.titleColor,
                    onColorChanged: (c) => settings.setTitleStyle(color: c),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Alignment', style: textTheme.bodyMedium),
                      ),
                      SegmentedButton<TextAlign>(
                        segments: const [
                          ButtonSegment(
                              value: TextAlign.left,
                              icon: Icon(Icons.format_align_left)),
                          ButtonSegment(
                              value: TextAlign.center,
                              icon: Icon(Icons.format_align_center)),
                          ButtonSegment(
                              value: TextAlign.right,
                              icon: Icon(Icons.format_align_right)),
                        ],
                        selected: {settings.titleAlignment},
                        onSelectionChanged: (s) =>
                            settings.setTitleStyle(alignment: s.first),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Italic Style', style: textTheme.bodyMedium),
                      Switch(
                        value: settings.titleItalic,
                        onChanged: (v) => settings.setTitleStyle(italic: v),
                      ),
                    ],
                  ),
                ],
              )),
          const SizedBox(height: 15),
          SettingsGroup(
            isSubgroup: true,
            icon: '📍',
            title: 'Positioning',
            child: Column(
              children: [
                CustomSliderWithLabel(
                    label: 'From Left',
                    value: settings.titleLeft,
                    min: 0,
                    max: 1000,
                    onChanged: (v) => settings.setTitlePosition(
                        v, settings.titleTop, settings.titleWidth)),
                CustomSliderWithLabel(
                    label: 'From Top',
                    value: settings.titleTop,
                    min: 0,
                    max: 1000,
                    onChanged: (v) => settings.setTitlePosition(
                        settings.titleLeft, v, settings.titleWidth)),
                CustomSliderWithLabel(
                    label: 'Width',
                    value: settings.titleWidth,
                    min: 200,
                    max: 900,
                    onChanged: (v) => settings.setTitlePosition(
                        settings.titleLeft, settings.titleTop, v)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _BackgroundSettingsGroup extends StatelessWidget {
  const _BackgroundSettingsGroup();
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<GenderSelectionProvider>();
    return SettingsGroup(
      icon: '🖼️',
      title: 'Background',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Show Background',
                  style: Theme.of(context).textTheme.bodyLarge),
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
                  settings.setBackgroundImage(result.files.single.path,
                      isAsset: false);
                }
              },
              icon: '📁',
              text: 'Choose background image',
              selectedFile: settings.backgroundImagePath,
            ),
          ]
        ],
      ),
    );
  }
}

class _GenderImagesGroup extends StatelessWidget {
  const _GenderImagesGroup();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<GenderSelectionProvider>();
    return SettingsGroup(
      icon: '🧑‍🤝‍🧑',
      title: 'Gender Images',
      child: Column(
        children: [
          _FormRow(
            children: [
              Expanded(
                child: FileUploadArea(
                  onTap: () async {
                    final result = await FilePicker.platform
                        .pickFiles(type: FileType.image);
                    if (result != null && result.files.single.path != null) {
                      settings.setMaleImage(result.files.single.path,
                          isAsset: false);
                    }
                  },
                  icon: '👨',
                  text: 'Select Male Image',
                  selectedFile: settings.maleImagePath,
                ),
              ),
              Expanded(
                child: FileUploadArea(
                  onTap: () async {
                    final result = await FilePicker.platform
                        .pickFiles(type: FileType.image);
                    if (result != null && result.files.single.path != null) {
                      settings.setFemaleImage(result.files.single.path,
                          isAsset: false);
                    }
                  },
                  icon: '👩',
                  text: 'Select Female Image',
                  selectedFile: settings.femaleImagePath,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SettingsGroup(
            isSubgroup: true,
            icon: '📐',
            title: 'Sizing & Spacing',
            child: Column(
              children: [
                _FormRow(
                  children: [
                    Expanded(
                        child: CustomSliderWithLabel(
                      label: 'Image Width',
                      value: settings.imageWidth,
                      min: 80,
                      max: 900,
                      onChanged: (v) =>
                          settings.setImageDimensions(v, settings.imageHeight),
                    )),
                    Expanded(
                        child: CustomSliderWithLabel(
                      label: 'Image Height',
                      value: settings.imageHeight,
                      min: 80,
                      max: 900,
                      onChanged: (v) =>
                          settings.setImageDimensions(settings.imageWidth, v),
                    )),
                  ],
                ),
                CustomSliderWithLabel(
                  label: 'Spacing Between',
                  value: settings.imageSpacing,
                  min: 0,
                  max: 100,
                  onChanged: (v) => settings.setImageSpacing(v),
                )
              ],
            ),
          ),
          const SizedBox(height: 15),
          SettingsGroup(
            isSubgroup: true,
            icon: '📍',
            title: "Positioning",
            child: Column(
              children: [
                CustomSliderWithLabel(
                  label: 'From Left',
                  value: settings.genderSelectionLeft,
                  min: 0,
                  max: 1000,
                  onChanged: (v) => settings.setGenderCardPosition(
                      v, settings.genderSelectionTop),
                ),
                CustomSliderWithLabel(
                  label: 'From Top',
                  value: settings.genderSelectionTop,
                  min: 0,
                  max: 1000,
                  onChanged: (v) => settings.setGenderCardPosition(
                      settings.genderSelectionLeft, v),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionEffectGroup extends StatelessWidget {
  const _SelectionEffectGroup();
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<GenderSelectionProvider>();
    return SettingsGroup(
      icon: '✨',
      title: 'Selection Effect',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Enable Highlighting',
                  style: Theme.of(context).textTheme.bodyLarge),
              Switch(
                value: settings.useSelectionEffect,
                onChanged: (v) => settings.setSelectionEffect(useEffect: v),
              ),
            ],
          ),
          if (settings.useSelectionEffect) ...[
            const SizedBox(height: 15),
            CustomSliderWithLabel(
              label: 'Selected Image Scale',
              value: settings.selectedImageScale,
              min: 1.0,
              max: 1.5,
              step: 0.05,
              onChanged: (v) => settings.setSelectionEffect(scale: v),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Enable Selection Glow',
                    style: Theme.of(context).textTheme.bodyLarge),
                Switch(
                  value: settings.useSelectionGlow,
                  onChanged: (v) => settings.setSelectionEffect(useGlow: v),
                ),
              ],
            ),
            if (settings.useSelectionGlow) ...[
              const SizedBox(height: 15),
              _CustomColorPicker(
                label: 'Glow Color',
                color: settings.selectionGlowColor,
                onColorChanged: (c) =>
                    settings.setSelectionEffect(glowColor: c),
              ),
              _FormRow(children: [
                Expanded(
                  child: CustomSliderWithLabel(
                    label: 'Glow Intensity',
                    value: settings.selectionGlowIntensity,
                    min: 0.1,
                    max: 1.0,
                    step: 0.1,
                    onChanged: (v) =>
                        settings.setSelectionEffect(glowIntensity: v),
                  ),
                ),
                Expanded(
                  child: CustomSliderWithLabel(
                    label: 'Glow Spread',
                    value: settings.selectionGlowSpread,
                    min: 1.0,
                    max: 20.0,
                    onChanged: (v) =>
                        settings.setSelectionEffect(glowSpread: v),
                  ),
                ),
              ]),
            ]
          ]
        ],
      ),
    );
  }
}

class _ButtonSettingsGroup extends StatelessWidget {
  const _ButtonSettingsGroup();
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<GenderSelectionProvider>();
    return SettingsGroup(
      icon: '🔘',
      title: 'Next Button',
      child: Column(
        children: [
          _ToggleButtonGroup(
            options: const ['Text Button', 'Image Button'],
            selectedIndex: settings.useImageButton ? 1 : 0,
            onSelected: (i) => settings.setUseImageButton(i == 1),
          ),
          const SizedBox(height: 20),
          if (settings.useImageButton)
            FileUploadArea(
              onTap: () async {
                final result =
                    await FilePicker.platform.pickFiles(type: FileType.image);
                if (result != null && result.files.single.path != null) {
                  settings.setButtonImage(result.files.single.path!,
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
                _FormRow(children: [
                  Expanded(
                    child: _CustomColorPicker(
                      label: 'Button Color',
                      color: settings.buttonColor,
                      onColorChanged: (c) =>
                          settings.setButtonStyle(buttonColor: c),
                    ),
                  ),
                  Expanded(
                    child: _CustomColorPicker(
                      label: 'Text Color',
                      color: settings.buttonTextColor,
                      onColorChanged: (c) =>
                          settings.setButtonStyle(textColor: c),
                    ),
                  )
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
                _FormRow(children: [
                  Expanded(
                    child: CustomSliderWithLabel(
                      label: 'Width',
                      value: settings.buttonWidth,
                      min: 100,
                      max: 800,
                      onChanged: (v) => settings.setButtonDimensions(
                          v, settings.buttonHeight),
                    ),
                  ),
                  Expanded(
                    child: CustomSliderWithLabel(
                      label: 'Height',
                      value: settings.buttonHeight,
                      min: 40,
                      max: 200,
                      onChanged: (v) =>
                          settings.setButtonDimensions(settings.buttonWidth, v),
                    ),
                  )
                ]),
                _FormRow(children: [
                  Expanded(
                    child: CustomSliderWithLabel(
                      label: 'From Left',
                      value: settings.buttonLeft,
                      min: 0,
                      max: 1000,
                      onChanged: (v) =>
                          settings.setButtonPosition(v, settings.buttonBottom),
                    ),
                  ),
                  Expanded(
                    child: CustomSliderWithLabel(
                      label: 'From Bottom',
                      value: settings.buttonBottom,
                      min: 0,
                      max: 1000,
                      onChanged: (v) =>
                          settings.setButtonPosition(settings.buttonLeft, v),
                    ),
                  )
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LayoutSettingsGroup extends StatelessWidget {
  const _LayoutSettingsGroup();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<GenderSelectionProvider>();
    return SettingsGroup(
      icon: '📏',
      title: 'Layout',
      child: CustomSliderWithLabel(
        label: 'Screen Padding',
        value: settings.screenPadding,
        min: 0,
        max: 64,
        onChanged: (v) => settings.setScreenPadding(v),
      ),
    );
  }
}

// --- TEMPORARY HELPERS (Can be moved to global files) ---
// These are added here for completeness, but should be moved to the settings_ui_helpers directory.

class _FormRow extends StatelessWidget {
  final List<Widget> children;
  const _FormRow({required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          children[0],
          const SizedBox(width: 20),
          if (children.length > 1) children[1],
        ],
      ),
    );
  }
}

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

class _CustomDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final Map<T, String> items;
  final ValueChanged<T?> onChanged;

  const _CustomDropdown(
      {required this.label,
      required this.value,
      required this.items,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.bodyMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items.entries
              .map((e) =>
                  DropdownMenuItem<T>(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: onChanged,
          decoration: _inputDecoration(context, ''),
        ),
      ],
    );
  }
}

class _CustomColorPicker extends StatelessWidget {
  final String label;
  final Color color;
  final ValueChanged<Color> onColorChanged;

  const _CustomColorPicker(
      {required this.label, required this.color, required this.onColorChanged});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.bodyMedium),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showColorPickerDialog(context),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.inputBorder, width: 2),
              color: Colors.white.withValues(alpha: 0.8),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showColorPickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select $label'),
        content: SingleChildScrollView(
          child: CustomColorPicker(
            pickerColor: color,
            onColorChanged: onColorChanged,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class _ToggleButtonGroup extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _ToggleButtonGroup(
      {required this.options,
      required this.selectedIndex,
      required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: List.generate(options.length, (index) {
        final bool isActive = selectedIndex == index;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(vertical: 12),
              margin:
                  EdgeInsets.only(right: index < options.length - 1 ? 10 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: isActive
                    ? const LinearGradient(colors: [
                        AppColors.primaryGradientStart,
                        AppColors.primaryGradientEnd
                      ])
                    : null,
                color: isActive ? null : Colors.white.withValues(alpha: 0.8),
                border: Border.all(
                    color: isActive
                        ? AppColors.primaryGradientStart
                        : AppColors.inputBorder,
                    width: 2),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                            color: AppColors.primaryGradientStart
                                .withValues(alpha: 0.3),
                            blurRadius: 15,
                            spreadRadius: -5)
                      ]
                    : [],
              ),
              alignment: Alignment.center,
              child: Text(
                options[index],
                style: textTheme.bodyMedium?.copyWith(
                    color: isActive ? Colors.white : AppColors.labelText),
              ),
            ),
          ),
        );
      }),
    );
  }
}
