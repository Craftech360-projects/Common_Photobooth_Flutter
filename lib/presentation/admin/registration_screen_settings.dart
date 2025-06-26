// lib/presentation/registration_screen_settings.dart

import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/presentation/registration_screen.dart';
import 'package:photobooth_flutter/providers/registration_screen_provider.dart';
import 'package:photobooth_flutter/widgets/custom_dropdown.dart';
import 'package:photobooth_flutter/widgets/custom_slider.dart';
import 'package:photobooth_flutter/widgets/file_upload_area.dart';
import 'package:photobooth_flutter/widgets/form_row.dart';
import 'package:photobooth_flutter/widgets/improved_color_picker.dart';
import 'package:photobooth_flutter/widgets/input_decoration.dart';
import 'package:photobooth_flutter/widgets/settings_preview.dart';
import 'package:photobooth_flutter/widgets/snackbar.dart';
import 'package:photobooth_flutter/widgets/toggle_btn_group.dart';
import 'package:provider/provider.dart';

class RegistrationScreenSettings extends StatelessWidget {
  const RegistrationScreenSettings({super.key});

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
              child: ParticipantDetailsScreen(),
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
    final settings = context.watch<RegistrationScreenProvider>();
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
                const _SettingsHeader(
                  title: 'Registration Screen Settings',
                  subtitle:
                      'Customize the fields and appearance of the registration form',
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                        _GeneralSettingsGroup(),
                        if (settings.showRegistrationScreen) ...[
                          const SizedBox(height: 25),
                          _TitleSettingsGroup(),
                          const SizedBox(height: 25),
                          _BackgroundSettingsGroup(),
                          const SizedBox(height: 25),
                          _TextFieldsSettingsGroup(),
                          const SizedBox(height: 25),
                          _ButtonSettingsGroup(),
                        ]
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

class _GeneralSettingsGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<RegistrationScreenProvider>();
    final textTheme = Theme.of(context).textTheme;

    return _SettingsGroup(
      icon: '⚙️',
      title: 'General',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Enable Registration Screen', style: textTheme.bodyLarge),
          Switch(
            value: settings.showRegistrationScreen,
            onChanged: (value) => settings.setShowRegistrationScreen(value),
            activeTrackColor:
                AppColors.primaryGradientStart.withValues(alpha: 0.7),
            activeColor: AppColors.primaryGradientEnd,
          ),
        ],
      ),
    );
  }
}

class _TitleSettingsGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<RegistrationScreenProvider>();
    final textTheme = Theme.of(context).textTheme;

    return _SettingsGroup(
      icon: '✏️',
      title: 'Screen Title',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Show Title', style: textTheme.bodyLarge),
              Switch(
                value: settings.showTitle,
                onChanged: (value) => settings.setShowTitle(value),
                activeTrackColor:
                    AppColors.primaryGradientStart.withValues(alpha: 0.7),
                activeColor: AppColors.primaryGradientEnd,
              ),
            ],
          ),
          if (settings.showTitle) ...[
            const SizedBox(height: 20),
            TextFormField(
              initialValue: settings.titleText,
              decoration: inputDecoration(context, 'Enter Title Text'),
              onChanged: (value) => settings.setTitleText(value),
            ),
            const SizedBox(height: 15),
            FormRow(children: [
              Expanded(
                child: CustomSliderWithLabel(
                  label: 'Font Size',
                  value: settings.titleFontSize,
                  min: 12,
                  max: 80,
                  onChanged: (v) => settings.setTitleFontSize(v),
                ),
              ),
              Expanded(
                child: CustomSliderWithLabel(
                  label: 'Line Height',
                  value: settings.titleLineHeight,
                  min: 0.8,
                  max: 2.0,
                  step: 0.1,
                  onChanged: (v) => settings.setTitleLineHeight(v),
                ),
              ),
            ]),
            FormRow(children: [
              Expanded(
                child: CustomDropdown<FontWeight>(
                  label: 'Font Weight',
                  value: settings.titleFontWeight,
                  items: const {
                    FontWeight.w100: 'Thin',
                    FontWeight.w300: 'Light',
                    FontWeight.w400: 'Normal',
                    FontWeight.w500: 'Medium',
                    FontWeight.bold: 'Bold',
                    FontWeight.w900: 'Black',
                  },
                  onChanged: (v) => settings.setTitleFontWeight(v!),
                ),
              ),
              Expanded(
                child: CustomDropdown<TextAlign>(
                  label: 'Text Align',
                  value: settings.titleTextAlign,
                  items: const {
                    TextAlign.left: 'Left',
                    TextAlign.center: 'Center',
                    TextAlign.right: 'Right',
                  },
                  onChanged: (v) => settings.setTitleTextAlign(v!),
                ),
              ),
            ]),
            FormRow(
              children: [
                Expanded(
                  child: CustomColorPicker(
                    pickerColor: settings.titleTextColor,
                    onColorChanged: (c) => settings.setTitleTextColor(c),
                  ),
                ),
              ],
            ),
            _SettingsGroup(
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
                        v, settings.titleTop, settings.titleWidth),
                  ),
                  CustomSliderWithLabel(
                    label: 'From Top',
                    value: settings.titleTop,
                    min: 0,
                    max: 1000,
                    onChanged: (v) => settings.setTitlePosition(
                        settings.titleLeft, v, settings.titleWidth),
                  ),
                  CustomSliderWithLabel(
                    label: 'Width',
                    value: settings.titleWidth,
                    min: 0,
                    max: 1000,
                    onChanged: (v) => settings.setTitlePosition(
                        settings.titleLeft, settings.titleTop, v),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BackgroundSettingsGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<RegistrationScreenProvider>();
    return _SettingsGroup(
      icon: '🖼️',
      title: 'Background Image',
      child: FileUploadArea(
        onTap: () => _pickBgImage(context, settings),
        icon: '📁',
        text: 'Click to upload a background',
        selectedFile: settings.registrationScreenBackground,
      ),
    );
  }

  void _pickBgImage(
      BuildContext context, RegistrationScreenProvider provider) async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.path != null) {
        await provider.setRegistrationScreenBackground(result.files.single.path,
            isAsset: false);
        showSnackBar(context, 'Background updated');
      }
    } catch (e) {
      showSnackBar(context, 'Error selecting file: $e');
    }
  }
}

class _TextFieldsSettingsGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<RegistrationScreenProvider>();
    final textTheme = Theme.of(context).textTheme;

    return _SettingsGroup(
      icon: '📝',
      title: 'Input Fields',
      child: Column(
        children: [
          if (settings.textFields.length < 3)
            ElevatedButton.icon(
              onPressed: () => settings.addTextField(),
              icon: const Icon(Icons.add),
              label: const Text('Add Input Field'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          const SizedBox(height: 20),
          ...settings.textFields.map((field) =>
              _buildTextFieldCard(context, field, settings, textTheme)),
        ],
      ),
    );
  }

  Widget _buildTextFieldCard(BuildContext context, CustomTextField field,
      RegistrationScreenProvider settings, TextTheme textTheme) {
    return _SettingsGroup(
      isSubgroup: true,
      icon: '🔹',
      title: field.label,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Enabled', style: textTheme.bodyLarge),
              Switch(
                value: field.isEnabled,
                onChanged: (value) =>
                    settings.toggleTextFieldEnabled(field.id, value),
              ),
              if (settings.textFields.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.red),
                  onPressed: () => settings.removeTextField(field.id),
                ),
            ],
          ),
          const SizedBox(height: 15),
          CustomDropdown<TextFieldType>(
            label: 'Field Type',
            value: field.fieldType,
            items: {
              for (var type in TextFieldType.values)
                type: type.toString().split('.').last
            },
            onChanged: (v) {
              if (v != null) {
                settings.updateTextField(
                    field.id, field.copyWith(fieldType: v));
              }
            },
          ),
          const SizedBox(height: 15),
          TextFormField(
            initialValue: field.label,
            decoration: inputDecoration(context, 'Label'),
            onChanged: (value) => settings.updateTextField(
                field.id, field.copyWith(label: value)),
          ),
          const SizedBox(height: 15),
          FormRow(
            children: [
              Expanded(
                  child: CustomSliderWithLabel(
                label: 'Width',
                value: field.width,
                min: 200,
                max: 1000,
                onChanged: (v) => settings.updateTextField(
                    field.id, field.copyWith(width: v)),
              )),
              Expanded(
                  child: CustomSliderWithLabel(
                label: 'Height',
                value: field.height,
                min: 40,
                max: 200,
                onChanged: (v) => settings.updateTextField(
                    field.id, field.copyWith(height: v)),
              ))
            ],
          ),
          const SizedBox(height: 15),
          _SettingsGroup(
              isSubgroup: true,
              icon: '🎨',
              title: 'Styling',
              child: Column(
                children: [
                  FormRow(children: [
                    Expanded(
                        child: CustomColorPicker(
                            pickerColor: field.fillColor,
                            onColorChanged: (c) => settings.updateTextField(
                                field.id, field.copyWith(fillColor: c)))),
                    Expanded(
                        child: CustomColorPicker(
                            pickerColor: field.textColor,
                            onColorChanged: (c) => settings.updateTextField(
                                field.id, field.copyWith(textColor: c)))),
                  ]),
                  FormRow(
                    children: [
                      Expanded(
                          child: CustomSliderWithLabel(
                              label: 'Font Size',
                              value: field.fontSize,
                              min: 10,
                              max: 40,
                              onChanged: (v) {
                                settings.updateTextField(
                                    field.id, field.copyWith(fontSize: v));
                              })),
                      Expanded(
                          child: CustomSliderWithLabel(
                              label: 'Border Radius',
                              value: field.borderRadius,
                              min: 0,
                              max: 30,
                              onChanged: (v) => settings.updateTextField(
                                  field.id, field.copyWith(borderRadius: v))))
                    ],
                  ),
                ],
              )),
          const SizedBox(height: 15),
          _SettingsGroup(
              isSubgroup: true,
              icon: '📍',
              title: 'Positioning',
              child: Column(
                children: [
                  CustomSliderWithLabel(
                      label: "From Left",
                      value: field.left,
                      min: 0,
                      max: 1000,
                      onChanged: (v) => settings.updateTextFieldPosition(
                          field.id, v, field.top)),
                  CustomSliderWithLabel(
                      label: "From Top",
                      value: field.top,
                      min: 0,
                      max: 1800,
                      onChanged: (v) => settings.updateTextFieldPosition(
                          field.id, field.left, v)),
                ],
              ))
        ],
      ),
    );
  }
}

class _ButtonSettingsGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<RegistrationScreenProvider>();
    return _SettingsGroup(
      icon: '🔘',
      title: 'Submit Button',
      child: Column(
        children: [
          ToggleButtonGroup(
            options: const ['Text Button', 'Image Button'],
            selectedIndex: settings.useImageButton ? 1 : 0,
            onSelected: (index) => settings.setUseImageButton(index == 1),
          ),
          const SizedBox(height: 20),
          if (settings.useImageButton)
            const _ImageButtonSettings()
          else
            const _TextButtonSettings(),
          const SizedBox(height: 20),
          _SettingsGroup(
            isSubgroup: true,
            icon: '📍',
            title: 'Positioning',
            child: Column(
              children: [
                CustomSliderWithLabel(
                    label: 'From Left',
                    value: settings.buttonLeft,
                    min: 0,
                    max: 1100,
                    onChanged: (v) =>
                        settings.setButtonPosition(v, settings.buttonBottom)),
                CustomSliderWithLabel(
                    label: 'From Bottom',
                    value: settings.buttonBottom,
                    min: 0,
                    max: 1100,
                    onChanged: (v) =>
                        settings.setButtonPosition(settings.buttonLeft, v)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _TextButtonSettings extends StatelessWidget {
  const _TextButtonSettings();
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<RegistrationScreenProvider>();
    return Column(
      children: [
        TextFormField(
          initialValue: settings.submitButtonText,
          decoration: inputDecoration(context, 'Button Text'),
          onChanged: (v) => settings.setSubmitButtonText(v),
        ),
        const SizedBox(height: 15),
        FormRow(children: [
          Expanded(
            child: CustomSliderWithLabel(
                label: 'Width',
                value: settings.buttonWidth,
                min: 100,
                max: 800,
                onChanged: (v) =>
                    settings.setButtonDimensions(v, settings.buttonHeight)),
          ),
          Expanded(
            child: CustomSliderWithLabel(
                label: 'Height',
                value: settings.buttonHeight,
                min: 40,
                max: 200,
                onChanged: (v) =>
                    settings.setButtonDimensions(settings.buttonWidth, v)),
          ),
        ]),
        FormRow(children: [
          Expanded(
              child: CustomColorPicker(
                  pickerColor: settings.submitButtonColor,
                  onColorChanged: (c) => settings.setSubmitButtonColor(c))),
          Expanded(
              child: CustomColorPicker(
                  pickerColor: settings.submitButtonTextColor,
                  onColorChanged: (c) => settings.setSubmitButtonTextColor(c)))
        ]),
        CustomSliderWithLabel(
            label: 'Border Radius',
            value: settings.buttonBorderRadius,
            min: 0,
            max: 50,
            onChanged: (v) => settings.setButtonBorderRadius(v))
      ],
    );
  }
}

class _ImageButtonSettings extends StatelessWidget {
  const _ImageButtonSettings();
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<RegistrationScreenProvider>();
    return Column(
      children: [
        FileUploadArea(
          onTap: () async {
            try {
              final result =
                  await FilePicker.platform.pickFiles(type: FileType.image);
              if (result != null && result.files.single.path != null) {
                await settings.setButtonImage(result.files.single.path,
                    isAsset: false);
                showSnackBar(context, 'Button image updated');
              }
            } catch (e) {
              showSnackBar(context, 'Error selecting file: $e');
            }
          },
          icon: '🖼️',
          text: 'Choose Button Image',
          selectedFile: settings.buttonImagePath,
        ),
        const SizedBox(height: 15),
        FormRow(children: [
          Expanded(
            child: CustomSliderWithLabel(
                label: 'Width',
                value: settings.buttonWidth,
                min: 100,
                max: 800,
                onChanged: (v) =>
                    settings.setButtonDimensions(v, settings.buttonHeight)),
          ),
          Expanded(
            child: CustomSliderWithLabel(
                label: 'Height',
                value: settings.buttonHeight,
                min: 40,
                max: 200,
                onChanged: (v) =>
                    settings.setButtonDimensions(settings.buttonWidth, v)),
          ),
        ]),
        CustomSliderWithLabel(
            label: 'Border Radius',
            value: settings.buttonBorderRadius,
            min: 0,
            max: 50,
            onChanged: (v) => settings.setButtonBorderRadius(v))
      ],
    );
  }
}

// --- GENERIC HELPER WIDGETS (can be extracted to separate files) ---

class _SettingsHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SettingsHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        border: Border(
            bottom: BorderSide(color: Colors.black.withValues(alpha: 0.1))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.headlineMedium),
          const SizedBox(height: 5),
          Text(subtitle, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String icon;
  final String title;
  final Widget child;
  final bool isSubgroup;

  const _SettingsGroup(
      {required this.icon,
      required this.title,
      required this.child,
      this.isSubgroup = false});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: isSubgroup ? const EdgeInsets.only(top: 10) : EdgeInsets.zero,
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
                    offset: const Offset(0, 4))
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
              Expanded(child: Text(title, style: textTheme.titleLarge)),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
