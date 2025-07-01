import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/presentation/registration_screen.dart';
import 'package:photobooth_flutter/providers/registration_screen_provider.dart';
import 'package:photobooth_flutter/widgets/color_picker.dart';
import 'package:photobooth_flutter/widgets/custom_dropdown.dart';
import 'package:photobooth_flutter/widgets/custom_slider.dart';
import 'package:photobooth_flutter/widgets/file_upload_area.dart';
import 'package:photobooth_flutter/widgets/form_row.dart';
import 'package:photobooth_flutter/widgets/input_decoration.dart';
import 'package:photobooth_flutter/widgets/settings_group.dart';
import 'package:photobooth_flutter/widgets/settings_header.dart';
import 'package:photobooth_flutter/widgets/snackbar.dart';
import 'package:photobooth_flutter/widgets/toggle_btn_group.dart';
import 'package:provider/provider.dart';

class RegistrationScreenSettings extends StatefulWidget {
  const RegistrationScreenSettings({super.key});

  @override
  State<RegistrationScreenSettings> createState() =>
      _RegistrationScreenSettingsState();
}

class _RegistrationScreenSettingsState
    extends State<RegistrationScreenSettings> {
  bool _isPanelOpen = true;

  @override
  Widget build(BuildContext context) {
    double settingsPanelWidth = MediaQuery.of(context).size.width * 0.8;
    return Scaffold(
      body: Stack(
        children: [
          const RegistrationScreen(),

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
              heroTag: 'registrationBack', // Unique tag
              tooltip: 'Back',
              backgroundColor: AppColors.white.withOpacity(0.8),
              child: const Icon(Icons.arrow_back,
                  color: AppColors.primaryGradientEnd),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            top: 20,
            right: _isPanelOpen ? settingsPanelWidth + 20 : 20,
            child: FloatingActionButton(
              heroTag: 'registrationToggle', // Unique tag
              tooltip: 'Toggle Settings',
              backgroundColor: AppColors.white,
              onPressed: () {
                setState(() {
                  _isPanelOpen = !_isPanelOpen;
                });
              },
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
    final settings = context.watch<RegistrationScreenProvider>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 20, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SettingsHeader(
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

class _GeneralSettingsGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<RegistrationScreenProvider>();
    final textTheme = Theme.of(context).textTheme;

    return SettingsGroup(
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

    return SettingsGroup(
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
                child: SliderWithLabel(
                  label: 'Font Size',
                  value: settings.titleFontSize,
                  min: 12,
                  max: 80,
                  onChanged: (v) => settings.setTitleFontSize(v),
                ),
              ),
              Expanded(
                child: SliderWithLabel(
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
                  child: ColorPickerWidget(
                    label: "Title Color",
                    color: settings.titleTextColor,
                    onColorChanged: (c) => settings.setTitleTextColor(c),
                  ),
                ),
              ],
            ),
            SettingsGroup(
              isSubgroup: true,
              icon: '📍',
              title: 'Positioning',
              child: Column(
                children: [
                  SliderWithLabel(
                    label: 'Horizontal Position (%)',
                    value: settings.titleLeft,
                    min: 0.0,
                    max: 1.0,
                    step: 0.01,
                    onChanged: (v) => settings.setTitlePosition(
                        v, settings.titleTop, settings.titleWidth),
                  ),
                  SliderWithLabel(
                    label: 'Vertical Position (%)',
                    value: settings.titleTop,
                    min: 0.0,
                    max: 1.0,
                    step: 0.01,
                    onChanged: (v) => settings.setTitlePosition(
                        settings.titleLeft, v, settings.titleWidth),
                  ),
                  SliderWithLabel(
                    label: 'Width (%)',
                    value: settings.titleWidth,
                    min: 0.1,
                    max: 1.0,
                    step: 0.01,
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
    return SettingsGroup(
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
    } on Exception catch (e) {
      showSnackBar(context, 'Error selecting file: $e');
    }
  }
}

class _TextFieldsSettingsGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<RegistrationScreenProvider>();
    final textTheme = Theme.of(context).textTheme;

    return SettingsGroup(
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
    return SettingsGroup(
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
          FormRow(children: [
            Expanded(
                child: SliderWithLabel(
              label: 'Width (%)',
              value: field.width,
              min: 0.1, max: 1.0, step: 0.01, // Percentage range
              onChanged: (v) =>
                  settings.updateTextField(field.id, field.copyWith(width: v)),
            )),
            Expanded(
                child: SliderWithLabel(
              label: 'Height (%)',
              value: field.height,
              min: 0.01, max: 0.2, step: 0.01, // Percentage range
              onChanged: (v) =>
                  settings.updateTextField(field.id, field.copyWith(height: v)),
            )),
          ]),
          const SizedBox(height: 15),
          SettingsGroup(
              isSubgroup: true,
              icon: '🎨',
              title: 'Styling',
              child: Column(
                children: [
                  FormRow(children: [
                    Expanded(
                        child: ColorPickerWidget(
                            label: "Fill Color",
                            color: field.fillColor,
                            onColorChanged: (c) => settings.updateTextField(
                                field.id, field.copyWith(fillColor: c)))),
                    Expanded(
                        child: ColorPickerWidget(
                            label: "Text Color",
                            color: field.textColor,
                            onColorChanged: (c) => settings.updateTextField(
                                field.id, field.copyWith(textColor: c)))),
                  ]),
                  FormRow(
                    children: [
                      Expanded(
                          child: SliderWithLabel(
                              label: 'Font Size',
                              value: field.fontSize,
                              min: 10,
                              max: 40,
                              onChanged: (v) {
                                settings.updateTextField(
                                    field.id, field.copyWith(fontSize: v));
                              })),
                      Expanded(
                          child: SliderWithLabel(
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
          SettingsGroup(
            isSubgroup: true,
            icon: '📍',
            title: 'Positioning',
            child: Column(
              children: [
                SliderWithLabel(
                    label: "Horizontal Position (%)",
                    value: field.left,
                    min: 0.0,
                    max: 1.0,
                    step: 0.01,
                    onChanged: (v) => settings.updateTextFieldPosition(
                        field.id, v, field.top)),
                SliderWithLabel(
                    label: "Vertical Position (%)",
                    value: field.top,
                    min: 0.0,
                    max: 1.0,
                    step: 0.01,
                    onChanged: (v) => settings.updateTextFieldPosition(
                        field.id, field.left, v)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ButtonSettingsGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<RegistrationScreenProvider>();
    return SettingsGroup(
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
          SettingsGroup(
            isSubgroup: true,
            icon: '📍',
            title: 'Positioning',
            child: Column(
              children: [
                SliderWithLabel(
                    label: 'From Left (%)',
                    value: settings.buttonLeft,
                    min: 0.0,
                    max: 1.0,
                    step: 0.01,
                    onChanged: (v) =>
                        settings.setButtonPosition(v, settings.buttonBottom)),
                SliderWithLabel(
                    label: 'From Bottom (%)',
                    value: settings.buttonBottom,
                    min: 0.0,
                    max: 1.0,
                    step: 0.01,
                    onChanged: (v) =>
                        settings.setButtonPosition(settings.buttonLeft, v)),
              ],
            ),
          ),
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
            child: SliderWithLabel(
                label: 'Width (%)',
                value: settings.buttonWidth,
                min: 0.1,
                max: 1.0,
                step: 0.01, // Percentage range
                onChanged: (v) =>
                    settings.setButtonDimensions(v, settings.buttonHeight)),
          ),
          Expanded(
            child: SliderWithLabel(
                label: 'Height (%)',
                value: settings.buttonHeight,
                min: 0.01,
                max: 0.2,
                step: 0.01, // Percentage range
                onChanged: (v) =>
                    settings.setButtonDimensions(settings.buttonWidth, v)),
          ),
        ]),
        FormRow(children: [
          Expanded(
              child: ColorPickerWidget(
                  label: "Button Fill Color",
                  color: settings.submitButtonColor,
                  onColorChanged: (c) => settings.setSubmitButtonColor(c))),
          Expanded(
              child: ColorPickerWidget(
                  label: "Button Text Color",
                  color: settings.submitButtonTextColor,
                  onColorChanged: (c) => settings.setSubmitButtonTextColor(c)))
        ]),
        SliderWithLabel(
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
            } on Exception catch (e) {
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
            child: SliderWithLabel(
                label: 'Width (%)',
                value: settings.buttonWidth,
                min: 0.1,
                max: 1.0,
                step: 0.01, // Percentage range
                onChanged: (v) =>
                    settings.setButtonDimensions(v, settings.buttonHeight)),
          ),
          Expanded(
            child: SliderWithLabel(
                label: 'Height (%)',
                value: settings.buttonHeight,
                min: 0.01,
                max: 0.2,
                step: 0.01, // Percentage range
                onChanged: (v) =>
                    settings.setButtonDimensions(settings.buttonWidth, v)),
          ),
        ]),
        SliderWithLabel(
            label: 'Border Radius',
            value: settings.buttonBorderRadius,
            min: 0,
            max: 50,
            onChanged: (v) => settings.setButtonBorderRadius(v))
      ],
    );
  }
}
