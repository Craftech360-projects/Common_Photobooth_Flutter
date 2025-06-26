// lib/presentation/registration_screen_settings.dart

import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/presentation/registration_screen.dart';
import 'package:photobooth_flutter/providers/registration_screen_provider.dart';
import 'package:photobooth_flutter/widgets/file_upload_area.dart';
import 'package:photobooth_flutter/widgets/improved_color_picker.dart';
import 'package:photobooth_flutter/widgets/settings_preview.dart';
import 'package:photobooth_flutter/widgets/snackbar.dart';
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
            Expanded(flex: 2, child: _PreviewSection()),
            Expanded(flex: 3, child: _SettingsSection()),
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
      padding: const EdgeInsets.all(20.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: SettingsPreview(
                      width: 1080,
                      height: 1920,
                      child: ParticipantDetailsScreen(),
                    ),
                  ),
                ),
                Positioned(
                  top: 25,
                  left: 25,
                  child: Material(
                    color: Colors.white.withOpacity(0.9),
                    shape: const CircleBorder(),
                    elevation: 4.0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: AppColors.labelText),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Back',
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

class _SettingsSection extends StatelessWidget {
  const _SettingsSection();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<RegistrationScreenProvider>();
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 20, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
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
            activeTrackColor: AppColors.primaryGradientStart.withOpacity(0.7),
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
                    AppColors.primaryGradientStart.withOpacity(0.7),
                activeColor: AppColors.primaryGradientEnd,
              ),
            ],
          ),
          if (settings.showTitle) ...[
            const SizedBox(height: 20),
            TextFormField(
              initialValue: settings.titleText,
              decoration: _inputDecoration(context, 'Enter Title Text'),
              onChanged: (value) => settings.setTitleText(value),
            ),
            const SizedBox(height: 15),
            _FormRow(children: [
              Expanded(
                child: _CustomSliderWithLabel(
                  label: 'Font Size',
                  value: settings.titleFontSize,
                  min: 12,
                  max: 80,
                  onChanged: (v) => settings.setTitleFontSize(v),
                ),
              ),
              Expanded(
                child: _CustomSliderWithLabel(
                  label: 'Line Height',
                  value: settings.titleLineHeight,
                  min: 0.8,
                  max: 2.0,
                  step: 0.1,
                  onChanged: (v) => settings.setTitleLineHeight(v),
                ),
              ),
            ]),
            _FormRow(children: [
              Expanded(
                child: _CustomDropdown<FontWeight>(
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
                child: _CustomDropdown<TextAlign>(
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
            _FormRow(
              children: [
                Expanded(
                  child: _CustomColorPicker(
                    label: 'Title Color',
                    color: settings.titleTextColor,
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
                  _CustomSliderWithLabel(
                    label: 'From Left',
                    value: settings.titleLeft,
                    min: 0,
                    max: 1000,
                    onChanged: (v) => settings.setTitlePosition(
                        v, settings.titleTop, settings.titleWidth),
                  ),
                  _CustomSliderWithLabel(
                    label: 'From Top',
                    value: settings.titleTop,
                    min: 0,
                    max: 1000,
                    onChanged: (v) => settings.setTitlePosition(
                        settings.titleLeft, v, settings.titleWidth),
                  ),
                  _CustomSliderWithLabel(
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
          _CustomDropdown<TextFieldType>(
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
            decoration: _inputDecoration(context, 'Label'),
            onChanged: (value) => settings.updateTextField(
                field.id, field.copyWith(label: value)),
          ),
          const SizedBox(height: 15),
          _FormRow(
            children: [
              Expanded(
                  child: _CustomSliderWithLabel(
                label: 'Width',
                value: field.width,
                min: 200,
                max: 1000,
                onChanged: (v) => settings.updateTextField(
                    field.id, field.copyWith(width: v)),
              )),
              Expanded(
                  child: _CustomSliderWithLabel(
                label: 'Height',
                value: field.height,
                min: 40,
                max: 150,
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
                  _FormRow(children: [
                    Expanded(
                        child: _CustomColorPicker(
                            label: "Fill Color",
                            color: field.fillColor,
                            onColorChanged: (c) => settings.updateTextField(
                                field.id, field.copyWith(fillColor: c)))),
                    Expanded(
                        child: _CustomColorPicker(
                            label: "Text Color",
                            color: field.textColor,
                            onColorChanged: (c) => settings.updateTextField(
                                field.id, field.copyWith(textColor: c)))),
                  ]),
                  _FormRow(
                    children: [
                      Expanded(
                          child: _CustomSliderWithLabel(
                              label: 'Font Size',
                              value: field.fontSize,
                              min: 10,
                              max: 30,
                              onChanged: (v) =>
                                  settings.updateTextFieldStyle(id: field.id))),
                      Expanded(
                          child: _CustomSliderWithLabel(
                              label: 'Border Radius',
                              value: field.borderRadius,
                              min: 0,
                              max: 30,
                              onChanged: (v) => settings.updateTextFieldStyle(
                                  id: field.id, borderRadius: v)))
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
                  _CustomSliderWithLabel(
                      label: "From Left",
                      value: field.left,
                      min: 0,
                      max: 1000,
                      onChanged: (v) => settings.updateTextFieldPosition(
                          field.id, v, field.top)),
                  _CustomSliderWithLabel(
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
          _ToggleButtonGroup(
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
                _CustomSliderWithLabel(
                    label: 'From Left',
                    value: settings.buttonLeft,
                    min: 0,
                    max: 1100,
                    onChanged: (v) =>
                        settings.setButtonPosition(v, settings.buttonBottom)),
                _CustomSliderWithLabel(
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
          decoration: _inputDecoration(context, 'Button Text'),
          onChanged: (v) => settings.setSubmitButtonText(v),
        ),
        const SizedBox(height: 15),
        _FormRow(children: [
          Expanded(
            child: _CustomSliderWithLabel(
                label: 'Width',
                value: settings.buttonWidth,
                min: 100,
                max: 800,
                onChanged: (v) =>
                    settings.setButtonDimensions(v, settings.buttonHeight)),
          ),
          Expanded(
            child: _CustomSliderWithLabel(
                label: 'Height',
                value: settings.buttonHeight,
                min: 40,
                max: 200,
                onChanged: (v) =>
                    settings.setButtonDimensions(settings.buttonWidth, v)),
          ),
        ]),
        _FormRow(children: [
          Expanded(
              child: _CustomColorPicker(
                  label: 'Button Color',
                  color: settings.submitButtonColor,
                  onColorChanged: (c) => settings.setSubmitButtonColor(c))),
          Expanded(
              child: _CustomColorPicker(
                  label: 'Text Color',
                  color: settings.submitButtonTextColor,
                  onColorChanged: (c) => settings.setSubmitButtonTextColor(c)))
        ]),
        _CustomSliderWithLabel(
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
        _FormRow(children: [
          Expanded(
            child: _CustomSliderWithLabel(
                label: 'Width',
                value: settings.buttonWidth,
                min: 100,
                max: 800,
                onChanged: (v) =>
                    settings.setButtonDimensions(v, settings.buttonHeight)),
          ),
          Expanded(
            child: _CustomSliderWithLabel(
                label: 'Height',
                value: settings.buttonHeight,
                min: 40,
                max: 200,
                onChanged: (v) =>
                    settings.setButtonDimensions(settings.buttonWidth, v)),
          ),
        ]),
        _CustomSliderWithLabel(
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
        color: Colors.white.withOpacity(0.8),
        border:
            Border(bottom: BorderSide(color: Colors.black.withOpacity(0.1))),
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
            ? Colors.white.withOpacity(0.5)
            : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: isSubgroup
            ? []
            : [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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

class _CustomSliderWithLabel extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final double? step;
  final ValueChanged<double> onChanged;

  const _CustomSliderWithLabel(
      {required this.label,
      required this.value,
      required this.min,
      required this.max,
      this.step,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    int? divisions = step != null ? ((max - min) / step!).round() : null;
    String valueLabel =
        step == 0.1 ? value.toStringAsFixed(1) : value.round().toString();
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: textTheme.bodyMedium),
            Text(valueLabel,
                style: textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primaryGradientEnd,
            inactiveTrackColor: AppColors.inputBorder,
            trackHeight: 6.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
            thumbColor: AppColors.primaryGradientStart,
            overlayColor: AppColors.primaryGradientStart.withOpacity(0.2),
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
          Expanded(child: children[0]),
          const SizedBox(width: 20),
          if (children.length > 1) Expanded(child: children[1]),
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
    fillColor: Colors.white.withOpacity(0.8),
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
          child: ImprovedColorPicker(
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
                color: isActive ? null : Colors.white.withOpacity(0.8),
                border: Border.all(
                    color: isActive
                        ? AppColors.primaryGradientStart
                        : AppColors.inputBorder,
                    width: 2),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                            color:
                                AppColors.primaryGradientStart.withOpacity(0.3),
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
