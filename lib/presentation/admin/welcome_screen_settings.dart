import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/presentation/welcome_screen.dart';
import 'package:photobooth_flutter/providers/admin_watermark_provider.dart';
import 'package:photobooth_flutter/providers/welcome_screen_provider.dart';
import 'package:photobooth_flutter/widgets/custom_dropdown.dart';
import 'package:photobooth_flutter/widgets/file_upload_area.dart';
import 'package:photobooth_flutter/widgets/form_row.dart';
import 'package:photobooth_flutter/widgets/color_picker.dart';
import 'package:photobooth_flutter/widgets/input_decoration.dart';
import 'package:photobooth_flutter/widgets/settings_group.dart';
import 'package:photobooth_flutter/widgets/custom_slider.dart';
import 'package:photobooth_flutter/widgets/snackbar.dart';
import 'package:photobooth_flutter/widgets/toggle_btn_group.dart';
import 'package:photobooth_flutter/widgets/watermark_overlay.dart';
import 'package:provider/provider.dart';

// --- MAIN WELCOME SCREEN SETTINGS WIDGET ---
class WelcomeScreenSettings extends StatefulWidget {
  const WelcomeScreenSettings({super.key});

  @override
  State<WelcomeScreenSettings> createState() => _WelcomeScreenSettingsState();
}

class _WelcomeScreenSettingsState extends State<WelcomeScreenSettings> {
  bool _isPanelOpen = true;

  @override
  Widget build(BuildContext context) {
    final watermarkProvider = context.watch<AdminWatermarkProvider>();
    double settingsPanelWidth = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      body: WatermarkOverlay(
        show: watermarkProvider.showWatermark,
        child: Stack(
          children: [
            const WelcomeScreen(),
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
                heroTag: 'backButtonWelcome', // Unique tag
                tooltip: 'Back',
                backgroundColor: Colors.white.withOpacity(0.8),
                child: const Icon(Icons.arrow_back, color: Colors.blue),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              top: 20,
              right: _isPanelOpen ? settingsPanelWidth + 20 : 20,
              child: FloatingActionButton(
                heroTag: 'toggleButtonWelcome', // Unique tag
                tooltip: 'Toggle Settings',
                backgroundColor: Colors.white,
                onPressed: () {
                  setState(() {
                    _isPanelOpen = !_isPanelOpen;
                  });
                },
                child: Icon(
                  _isPanelOpen ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
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
          filter: ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(1),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
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
        color: Colors.white.withOpacity(0.8),
        border:
            Border(bottom: BorderSide(color: Colors.black.withOpacity(0.1))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome Screen Settings',
              style: Theme.of(context).textTheme.bodyMedium),
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
    return SettingsGroup(
      icon: '🎯',
      title: 'General Settings',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Enable Welcome Screen',
              style: Theme.of(context).textTheme.bodyMedium),
          Switch(
            value: welcomeSettings.showWelcomeScreen,
            onChanged: (value) {
              welcomeSettings.setShowWelcomeScreen(value);
              showSnackBar(context,
                  value ? 'Welcome screen enabled' : 'Welcome screen disabled');
            },
            activeTrackColor: AppColors.primaryGradientStart.withOpacity(0.7),
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
    return SettingsGroup(
      icon: '💬',
      title: 'Welcome Message',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Message Text', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: welcomeSettings.welcomeMessage,
            decoration: inputDecoration(context, 'Enter welcome message'),
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
    return SettingsGroup(
      // Using the refactored widget
      icon: '🎨',
      title: 'Text Styling',
      child: Column(
        children: [
          FormRow(
            children: [
              Expanded(
                child: SliderWithLabel(
                  label: 'Font Size',
                  value: welcomeSettings.welcomeMessageFontSize,
                  min: 12,
                  max: 80,
                  onChanged: (v) =>
                      welcomeSettings.setWelcomeMessageFontSize(v),
                ),
              ),
              Expanded(
                child: CustomDropdown<FontWeight>(
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
          FormRow(
            children: [
              Expanded(
                child: SliderWithLabel(
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
                child: CustomDropdown<TextAlign>(
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
          FormRow(
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
                child: SliderWithLabel(
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
              Text('Italic Style',
                  style: Theme.of(context).textTheme.bodyMedium),
              Switch(
                value: welcomeSettings.welcomeMessageItalic,
                onChanged: (v) => welcomeSettings.setWelcomeMessageItalic(v),
                activeTrackColor:
                    AppColors.primaryGradientStart.withOpacity(0.7),
                activeColor: AppColors.primaryGradientEnd,
              ),
            ],
          ),
          const SizedBox(height: 20),
          SettingsGroup(
            isSubgroup: true,
            icon: '📍',
            title: 'Positioning (Percentage-based)', // Updated title
            child: Column(
              children: [
                SliderWithLabel(
                  label: 'Horizontal Position (%)',
                  value: welcomeSettings
                      .welcomeMessageLeft, // This now represents a percentage
                  min: 0.0, // Min is 0%
                  max: 1.0, // Max is 100%
                  step: 0.01, // 1% increments
                  onChanged: (v) => welcomeSettings.setWelcomeMessagePosition(
                      v,
                      welcomeSettings.welcomeMessageTop,
                      welcomeSettings.welcomeMessageWidth),
                ),
                SliderWithLabel(
                  label: 'Vertical Position (%)',
                  value: welcomeSettings.welcomeMessageTop,
                  min: 0.0,
                  max: 1.0,
                  step: 0.01,
                  onChanged: (v) => welcomeSettings.setWelcomeMessagePosition(
                      welcomeSettings.welcomeMessageLeft,
                      v,
                      welcomeSettings.welcomeMessageWidth),
                ),
                // The width can remain a percentage of the screen width
                SliderWithLabel(
                  label: 'Width (%)',
                  value: welcomeSettings.welcomeMessageWidth,
                  min: 0.1, // 10% of screen width
                  max: 1.0, // 100% of screen width
                  step: 0.01,
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

    return SettingsGroup(
      icon: '🖼️',
      title: 'Background Settings',
      child: Column(
        children: [
          ToggleButtonGroup(
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
          FileUploadArea(
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
    return SettingsGroup(
      icon: '🔘',
      title: 'Button Settings',
      child: Column(
        children: [
          FormRow(children: [
            Expanded(
                child: SliderWithLabel(
              label: 'Position (Left %)',
              value: welcomeSettings.buttonLeft, // Now a percentage
              min: 0.0,
              max: 1.0,
              step: 0.01,
              onChanged: (v) => welcomeSettings.setButtonPosition(
                  v, welcomeSettings.buttonBottom),
            )),
            Expanded(
                child: SliderWithLabel(
              label: 'Position (Bottom %)',
              value: welcomeSettings.buttonBottom, // Now a percentage
              min: 0.0,
              max: 1.0,
              step: 0.01,
              onChanged: (v) => welcomeSettings.setButtonPosition(
                  welcomeSettings.buttonLeft, v),
            )),
          ]),
          FormRow(children: [
            Expanded(
                child: SliderWithLabel(
              label: 'Width',
              value: welcomeSettings.buttonWidth,
              min: 100,
              max: 800,
              onChanged: (v) => welcomeSettings.setButtonWidth(v),
            )),
            Expanded(
                child: SliderWithLabel(
              label: 'Height',
              value: welcomeSettings.buttonHeight,
              min: 20,
              max: 300,
              onChanged: (v) => welcomeSettings.setButtonHeight(v),
            )),
          ]),
          FormRow(children: [
            Expanded(
                child: SliderWithLabel(
              label: 'Border Radius',
              value: welcomeSettings.buttonBorderRadius,
              min: 0,
              max: 50,
              onChanged: (v) => welcomeSettings.setButtonBorderRadius(v),
            )),
            Expanded(
                child: SliderWithLabel(
              label: 'Opacity',
              value: welcomeSettings.buttonOpacity,
              min: 0.1,
              max: 1.0,
              step: 0.1,
              onChanged: (v) => welcomeSettings.setButtonOpacity(v),
            )),
          ]),
          const SizedBox(height: 15),
          ToggleButtonGroup(
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
        Text('Button Text', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: welcomeSettings.welcomeButtonText,
          decoration: inputDecoration(context, 'Enter Button Text'),
          onChanged: (v) => welcomeSettings.setWelcomeButtonText(v),
        ),
        const SizedBox(height: 15),
        FormRow(children: [
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
        FormRow(children: [
          Expanded(
              child: SliderWithLabel(
            label: 'Text Font Size',
            value: welcomeSettings.buttonTextFontSize,
            min: 12,
            max: 60,
            onChanged: (v) => welcomeSettings.setButtonTextFontSize(v),
          )),
          Expanded(
              child: CustomDropdown<FontWeight>(
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
    return FileUploadArea(
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
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showColorPickerDialog(context),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.inputBorder, width: 2),
              color: Colors.white.withOpacity(0.8),
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
                  style: Theme.of(context).textTheme.bodyMedium,
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
