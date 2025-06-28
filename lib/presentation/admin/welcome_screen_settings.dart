import 'dart:io';
import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/presentation/welcome_screen.dart';
import 'package:photobooth_flutter/providers/admin_watermark_provider.dart';
import 'package:photobooth_flutter/providers/welcome_screen_provider.dart';
import 'package:photobooth_flutter/widgets/improved_color_picker.dart';
import 'package:photobooth_flutter/widgets/settings_preview.dart';
import 'package:photobooth_flutter/widgets/snackbar.dart';
import 'package:photobooth_flutter/widgets/watermark_overlay.dart';
import 'package:provider/provider.dart';

class _AppTextStyles {
  static const TextStyle settingsTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.settingsTitle,
  );
  static const TextStyle groupTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.settingsTitle,
  );
  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.labelText,
  );
}

// --- MAIN WELCOME SCREEN SETTINGS WIDGET ---
class WelcomeScreenSettings extends StatelessWidget {
  const WelcomeScreenSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final watermarkProvider = context.watch<AdminWatermarkProvider>();

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
        child: WatermarkOverlay(
          show: watermarkProvider.showWatermark,
          child: const Row(
            children: [
              _PreviewSection(),
              Expanded(child: _SettingsSection()),
            ],
          ),
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
              child: WelcomeScreen(),
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
    final welcomeSettings = context.watch<WelcomeScreenProvider>();
    return Padding(
      padding: const EdgeInsets.all(12),
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
              children: [
                const _SettingsHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _GeneralSettingsGroup(),
                        if (welcomeSettings.showWelcomeScreen) ...[
                          const SizedBox(height: 25),
                          _WelcomeMessageGroup(),
                          const SizedBox(height: 25),
                          _TextStylingGroup(),
                          const SizedBox(height: 25),
                          _BackgroundSettingsGroup(),
                          const SizedBox(height: 25),
                          _ButtonSettingsGroup(),
                        ],
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

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        border: Border(
            bottom: BorderSide(color: Colors.black.withValues(alpha: 0.1))),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome Screen Settings', style: _AppTextStyles.settingsTitle),
        ],
      ),
    );
  }
}

// --- SETTINGS GROUPS ---

class _GeneralSettingsGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final welcomeSettings = context.watch<WelcomeScreenProvider>();
    return _SettingsGroup(
      icon: '🎯',
      title: 'General Settings',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Enable Welcome Screen', style: _AppTextStyles.label),
          Switch(
            value: welcomeSettings.showWelcomeScreen,
            onChanged: (value) {
              welcomeSettings.setShowWelcomeScreen(value);
              showSnackBar(context,
                  value ? 'Welcome screen enabled' : 'Welcome screen disabled');
            },
            activeTrackColor:
                AppColors.primaryGradientStart.withValues(alpha: 0.7),
            activeColor: AppColors.primaryGradientEnd,
          ),
        ],
      ),
    );
  }
}

class _WelcomeMessageGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final welcomeSettings = context.watch<WelcomeScreenProvider>();
    return _SettingsGroup(
      icon: '💬',
      title: 'Welcome Message',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Message Text', style: _AppTextStyles.label),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: welcomeSettings.welcomeMessage,
            decoration: _inputDecoration('Enter welcome message'),
            onChanged: (value) => welcomeSettings.setWelcomeMessage(value),
          ),
        ],
      ),
    );
  }
}

class _TextStylingGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final welcomeSettings = context.watch<WelcomeScreenProvider>();
    return _SettingsGroup(
      icon: '🎨',
      title: 'Text Styling',
      child: Column(
        children: [
          _FormRow(
            children: [
              Expanded(
                child: _CustomSliderWithLabel(
                  label: 'Font Size',
                  value: welcomeSettings.welcomeMessageFontSize,
                  min: 12,
                  max: 80,
                  onChanged: (v) =>
                      welcomeSettings.setWelcomeMessageFontSize(v),
                ),
              ),
              Expanded(
                child: _CustomDropdown<FontWeight>(
                  label: 'Font Weight',
                  value: welcomeSettings.welcomeMessageFontWeight,
                  items: const {
                    FontWeight.w100: 'Thin',
                    FontWeight.w300: 'Light',
                    FontWeight.w400: 'Regular',
                    FontWeight.w500: 'Medium',
                    FontWeight.w700: 'Bold',
                    FontWeight.w900: 'Black',
                  },
                  onChanged: (v) =>
                      welcomeSettings.setWelcomeMessageFontWeight(v!),
                ),
              ),
            ],
          ),
          _FormRow(
            children: [
              Expanded(
                child: _CustomSliderWithLabel(
                  label: 'Line Height',
                  value: welcomeSettings.welcomeMessageLineHeight,
                  min: 0.8,
                  max: 2.0,
                  step: 0.1,
                  onChanged: (v) =>
                      welcomeSettings.setWelcomeMessageLineHeight(v),
                ),
              ),
              Expanded(
                child: _CustomDropdown<TextAlign>(
                  label: 'Text Alignment',
                  value: welcomeSettings.welcomeMessageTextAlign,
                  items: const {
                    TextAlign.left: 'Left',
                    TextAlign.center: 'Center',
                    TextAlign.right: 'Right',
                  },
                  onChanged: (v) =>
                      welcomeSettings.setWelcomeMessageTextAlign(v!),
                ),
              ),
            ],
          ),
          _FormRow(
            children: [
              Expanded(
                child: _CustomColorPicker(
                  label: 'Text Color',
                  color: welcomeSettings.welcomeMessageColor,
                  onColorChanged: (c) =>
                      welcomeSettings.setWelcomeMessageColor(c),
                ),
              ),
              Expanded(
                child: _CustomSliderWithLabel(
                  label: 'Text Opacity',
                  value: welcomeSettings.welcomeMessageOpacity,
                  min: 0.1,
                  max: 1.0,
                  step: 0.1,
                  onChanged: (v) => welcomeSettings.setWelcomeMessageOpacity(v),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Italic Style', style: _AppTextStyles.label),
              Switch(
                value: welcomeSettings.welcomeMessageItalic,
                onChanged: (v) => welcomeSettings.setWelcomeMessageItalic(v),
                activeTrackColor:
                    AppColors.primaryGradientStart.withValues(alpha: 0.7),
                activeColor: AppColors.primaryGradientEnd,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SettingsGroup(
            isSubgroup: true,
            icon: '📍',
            title: 'Positioning',
            child: Column(
              children: [
                _CustomSliderWithLabel(
                  label: 'Left Position',
                  value: welcomeSettings.welcomeMessageLeft,
                  min: 0,
                  max: 1080,
                  onChanged: (v) => welcomeSettings.setWelcomeMessagePosition(
                      v,
                      welcomeSettings.welcomeMessageTop,
                      welcomeSettings.welcomeMessageWidth),
                ),
                _CustomSliderWithLabel(
                  label: 'Top Position',
                  value: welcomeSettings.welcomeMessageTop,
                  min: 0,
                  max: 1000,
                  onChanged: (v) => welcomeSettings.setWelcomeMessagePosition(
                      welcomeSettings.welcomeMessageLeft,
                      v,
                      welcomeSettings.welcomeMessageWidth),
                ),
                _CustomSliderWithLabel(
                  label: 'Width',
                  value: welcomeSettings.welcomeMessageWidth,
                  min: 200,
                  max: 1080,
                  onChanged: (v) => welcomeSettings.setWelcomeMessagePosition(
                      welcomeSettings.welcomeMessageLeft,
                      welcomeSettings.welcomeMessageTop,
                      v),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _BackgroundSettingsGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final welcomeSettings = context.watch<WelcomeScreenProvider>();
    final hasCustomBg = welcomeSettings.welcomeScreenBackground != null;

    return _SettingsGroup(
      icon: '🖼️',
      title: 'Background Settings',
      child: Column(
        children: [
          _ToggleButtonGroup(
            options: const ['Choose Custom', 'Use Global'],
            selectedIndex: hasCustomBg ? 0 : 1,
            onSelected: (index) {
              if (index == 1) {
                // Use Global
                welcomeSettings.setWelcomeScreenBackground(null);
                showSnackBar(context, 'Using global background image');
              } else {
                // Choose Custom - trigger file picker
                _pickBgImage(context, welcomeSettings);
              }
            },
          ),
          const SizedBox(height: 15),
          _FileUploadArea(
            onTap: () => _pickBgImage(context, welcomeSettings),
            icon: '📁',
            text: 'Click to upload or drag and drop',
            selectedFile:
                hasCustomBg ? welcomeSettings.welcomeScreenBackground : null,
          ),
        ],
      ),
    );
  }

  void _pickBgImage(
      BuildContext context, WelcomeScreenProvider provider) async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.path != null) {
        await provider.setWelcomeScreenBackground(result.files.single.path,
            isAsset: false);
        showSnackBar(context, 'Welcome screen background updated');
      }
    } on Exception catch (e) {
      showSnackBar(context, 'Error selecting file: $e');
    }
  }
}

class _ButtonSettingsGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final welcomeSettings = context.watch<WelcomeScreenProvider>();
    return _SettingsGroup(
      icon: '🔘',
      title: 'Button Settings',
      child: Column(
        children: [
          _FormRow(children: [
            Expanded(
                child: _CustomSliderWithLabel(
              label: 'Position (Left)',
              value: welcomeSettings.buttonLeft,
              min: 0,
              max: 1000,
              onChanged: (v) => welcomeSettings.setButtonPosition(
                  v, welcomeSettings.buttonBottom),
            )),
            Expanded(
                child: _CustomSliderWithLabel(
              label: 'Position (Bottom)',
              value: welcomeSettings.buttonBottom,
              min: 0,
              max: 1000,
              onChanged: (v) => welcomeSettings.setButtonPosition(
                  welcomeSettings.buttonLeft, v),
            )),
          ]),
          _FormRow(children: [
            Expanded(
                child: _CustomSliderWithLabel(
              label: 'Width',
              value: welcomeSettings.buttonWidth,
              min: 100,
              max: 800,
              onChanged: (v) => welcomeSettings.setButtonWidth(v),
            )),
            Expanded(
                child: _CustomSliderWithLabel(
              label: 'Height',
              value: welcomeSettings.buttonHeight,
              min: 20,
              max: 300,
              onChanged: (v) => welcomeSettings.setButtonHeight(v),
            )),
          ]),
          _FormRow(children: [
            Expanded(
                child: _CustomSliderWithLabel(
              label: 'Border Radius',
              value: welcomeSettings.buttonBorderRadius,
              min: 0,
              max: 50,
              onChanged: (v) => welcomeSettings.setButtonBorderRadius(v),
            )),
            Expanded(
                child: _CustomSliderWithLabel(
              label: 'Opacity',
              value: welcomeSettings.buttonOpacity,
              min: 0.1,
              max: 1.0,
              step: 0.1,
              onChanged: (v) => welcomeSettings.setButtonOpacity(v),
            )),
          ]),
          const SizedBox(height: 15),
          _ToggleButtonGroup(
            options: const ['Text Button', 'Image Button'],
            selectedIndex: welcomeSettings.useImageButton ? 1 : 0,
            onSelected: (index) =>
                welcomeSettings.setUseImageButton(index == 1),
          ),
          const SizedBox(height: 20),
          if (welcomeSettings.useImageButton)
            const _ImageButtonSettings()
          else
            const _TextButtonSettings(),
        ],
      ),
    );
  }
}

class _TextButtonSettings extends StatelessWidget {
  const _TextButtonSettings();

  @override
  Widget build(BuildContext context) {
    final welcomeSettings = context.watch<WelcomeScreenProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Button Text', style: _AppTextStyles.label),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: welcomeSettings.welcomeButtonText,
          decoration: _inputDecoration('Enter Button Text'),
          onChanged: (v) => welcomeSettings.setWelcomeButtonText(v),
        ),
        const SizedBox(height: 15),
        _FormRow(children: [
          Expanded(
              child: _CustomColorPicker(
            label: 'Button Color',
            color: welcomeSettings.welcomeButtonColor,
            onColorChanged: (c) => welcomeSettings.setWelcomeButtonColor(c),
          )),
          Expanded(
              child: _CustomColorPicker(
            label: 'Text Color',
            color: welcomeSettings.welcomeButtonTextColor,
            onColorChanged: (c) => welcomeSettings.setWelcomeButtonTextColor(c),
          )),
        ]),
        _FormRow(children: [
          Expanded(
              child: _CustomSliderWithLabel(
            label: 'Text Font Size',
            value: welcomeSettings.buttonTextFontSize,
            min: 12,
            max: 60,
            onChanged: (v) => welcomeSettings.setButtonTextFontSize(v),
          )),
          Expanded(
              child: _CustomDropdown<FontWeight>(
            label: 'Text Font Weight',
            value: welcomeSettings.buttonTextFontWeight,
            items: const {
              FontWeight.w100: 'Thin',
              FontWeight.w300: 'Light',
              FontWeight.w400: 'Regular',
              FontWeight.w500: 'Medium',
              FontWeight.w700: 'Bold',
              FontWeight.w900: 'Black',
            },
            onChanged: (v) => welcomeSettings.setButtonTextFontWeight(v!),
          )),
        ]),
      ],
    );
  }
}

class _ImageButtonSettings extends StatelessWidget {
  const _ImageButtonSettings();

  @override
  Widget build(BuildContext context) {
    final welcomeSettings = context.watch<WelcomeScreenProvider>();
    return _FileUploadArea(
      onTap: () async {
        try {
          final result =
              await FilePicker.platform.pickFiles(type: FileType.image);
          if (result != null && result.files.single.path != null) {
            await welcomeSettings.setButtonImage(result.files.single.path,
                isAsset: false);
            showSnackBar(context, 'Button image updated');
          }
        } on Exception catch (e) {
          showSnackBar(context, 'Error selecting file: $e');
        }
      },
      icon: '🖼️',
      text: 'Choose Button Image',
      selectedFile: welcomeSettings.buttonImagePath,
    );
  }
}

// --- GENERIC WIDGETS ---

class _SettingsGroup extends StatelessWidget {
  final String icon;
  final String title;
  final Widget child;
  final bool isSubgroup;

  const _SettingsGroup({
    required this.icon,
    required this.title,
    required this.child,
    this.isSubgroup = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: isSubgroup
            ? Colors.white.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: isSubgroup
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [
                    AppColors.primaryGradientStart,
                    AppColors.primaryGradientEnd
                  ]),
                ),
                alignment: Alignment.center,
                child: Text(icon, style: const TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 10),
              Text(title, style: _AppTextStyles.groupTitle),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _CustomSliderWithLabel extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final double? step;
  final ValueChanged<double> onChanged;

  const _CustomSliderWithLabel({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.step,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    int? divisions = step != null ? ((max - min) / step!).round() : null;
    String valueLabel =
        step == 0.1 ? value.toStringAsFixed(1) : value.round().toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: _AppTextStyles.label),
            Text(valueLabel,
                style:
                    _AppTextStyles.label.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primaryGradientEnd,
            inactiveTrackColor: AppColors.inputBorder,
            trackHeight: 6.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
            thumbColor: AppColors.primaryGradientStart,
            overlayColor: AppColors.primaryGradientStart.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

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

InputDecoration _inputDecoration(String hintText) {
  return InputDecoration(
    hintText: hintText,
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.8),
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

  const _CustomDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _AppTextStyles.label),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items.entries
              .map((e) =>
                  DropdownMenuItem<T>(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: onChanged,
          decoration: _inputDecoration(''),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _AppTextStyles.label),
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
                  style: _AppTextStyles.label,
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
    return Row(
      children: List.generate(options.length, (index) {
        final bool isActive = selectedIndex == index;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(vertical: 12),
              margin: EdgeInsets.only(right: index == 0 ? 10 : 0),
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
                style: _AppTextStyles.label.copyWith(
                    color: isActive ? Colors.white : AppColors.labelText),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _FileUploadArea extends StatelessWidget {
  final VoidCallback onTap;
  final String icon;
  final String text;
  final String? selectedFile;

  const _FileUploadArea(
      {required this.onTap,
      required this.icon,
      required this.text,
      this.selectedFile});

  @override
  Widget build(BuildContext context) {
    final fileName = selectedFile != null
        ? File(selectedFile!).path.split(Platform.pathSeparator).last
        : null;
    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        options: const RoundedRectDottedBorderOptions(
          dashPattern: [10, 5],
          strokeWidth: 2,
          radius: Radius.circular(16),
          color: AppColors.fileUploadBorder,
          padding: EdgeInsets.all(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: AppColors.primaryGradientStart.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(icon, style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 10),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                          text: '$text\n',
                          style: const TextStyle(
                              color: AppColors.fileUploadText, fontSize: 14)),
                      if (fileName != null)
                        TextSpan(
                          text: 'Selected: $fileName',
                          style: _AppTextStyles.label.copyWith(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
