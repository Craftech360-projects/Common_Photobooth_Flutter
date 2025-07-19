import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/presentation/gender_screen.dart';
import 'package:photobooth_flutter/providers/gender_screen_provider.dart';
import 'package:photobooth_flutter/widgets/color_picker.dart';
import 'package:photobooth_flutter/widgets/custom_dropdown.dart';
import 'package:photobooth_flutter/widgets/custom_slider.dart';
import 'package:photobooth_flutter/widgets/file_upload_area.dart';
import 'package:photobooth_flutter/widgets/form_row.dart';
import 'package:photobooth_flutter/widgets/input_decoration.dart';
import 'package:photobooth_flutter/widgets/settings_group.dart';
import 'package:photobooth_flutter/widgets/settings_header.dart';
import 'package:photobooth_flutter/widgets/toggle_btn_group.dart';
import 'package:provider/provider.dart';

class GenderScreenSettings extends StatefulWidget {
  const GenderScreenSettings({super.key});

  @override
  State<GenderScreenSettings> createState() => _GenderScreenSettingsState();
}

class _GenderScreenSettingsState extends State<GenderScreenSettings> {
  bool _isPanelOpen = true;

  @override
  Widget build(BuildContext context) {
    double settingsPanelWidth = MediaQuery.of(context).size.width * 0.8;
    return Scaffold(
      body: Stack(
        children: [
          // Full-screen preview
          const GenderSelectionScreen(),

          // Sliding settings panel
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
              heroTag: 'genderBack', // Unique tag
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
              heroTag: 'genderToggle', // Unique tag
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
            decoration: inputDecoration(context, 'Enter title text'),
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
                max: 60,
                onChanged: (v) => settings.setTitleStyle(fontSize: v),
              )),
              Expanded(
                  child: SliderWithLabel(
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
                  CustomDropdown<FontWeight>(
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
                  ColorPickerWidget(
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
          FormRow(
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
                FormRow(
                  children: [
                    Expanded(
                        child: SliderWithLabel(
                      label: 'Image Width',
                      value: settings.imageWidth,
                      min: 0.1,
                      max: 1.0,
                      step: 0.01,
                      onChanged: (v) =>
                          settings.setImageDimensions(v, settings.imageHeight),
                    )),
                    Expanded(
                        child: SliderWithLabel(
                      label: 'Image Height',
                      value: settings.imageHeight,
                      min: 0.1,
                      max: 1.0,
                      step: 0.01,
                      onChanged: (v) =>
                          settings.setImageDimensions(settings.imageWidth, v),
                    )),
                  ],
                ),
                SliderWithLabel(
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
                SliderWithLabel(
                  label: 'From Left',
                  value: settings.genderSelectionLeft,
                  min: 0.0,
                  max: 1.0,
                  step: 0.01,
                  onChanged: (v) => settings.setGenderCardPosition(
                      v, settings.genderSelectionTop),
                ),
                SliderWithLabel(
                  label: 'From Top',
                  value: settings.genderSelectionTop,
                  min: 0.0,
                  max: 1.0,
                  step: 0.01,
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
            SliderWithLabel(
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
              ColorPickerWidget(
                label: 'Glow Color',
                color: settings.selectionGlowColor,
                onColorChanged: (c) =>
                    settings.setSelectionEffect(glowColor: c),
              ),
              FormRow(children: [
                Expanded(
                  child: SliderWithLabel(
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
                  child: SliderWithLabel(
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
          ToggleButtonGroup(
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
                  decoration: inputDecoration(context, 'Button Text'),
                  onChanged: (v) => settings.setButtonText(v),
                ),
                const SizedBox(height: 15),
                FormRow(children: [
                  Expanded(
                    child: ColorPickerWidget(
                      label: 'Button Color',
                      color: settings.buttonColor,
                      onColorChanged: (c) =>
                          settings.setButtonStyle(buttonColor: c),
                    ),
                  ),
                  Expanded(
                    child: ColorPickerWidget(
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
                FormRow(children: [
                  Expanded(
                    child: SliderWithLabel(
                      label: 'Width',
                      value: settings.buttonWidth,
                      min: 0.1,
                      max: 1.0,
                      step: 0.01,
                      onChanged: (v) => settings.setButtonDimensions(
                          v, settings.buttonHeight),
                    ),
                  ),
                  Expanded(
                    child: SliderWithLabel(
                      label: 'Height',
                      value: settings.buttonHeight,
                      min: 0.1,
                      max: 1.0,
                      step: 0.01,
                      onChanged: (v) =>
                          settings.setButtonDimensions(settings.buttonWidth, v),
                    ),
                  )
                ]),
                FormRow(children: [
                  Expanded(
                    child: SliderWithLabel(
                      label: 'From Left',
                      value: settings.buttonLeft,
                      min: 0.0,
                      max: 1.0,
                      step: 0.01,
                      onChanged: (v) =>
                          settings.setButtonPosition(v, settings.buttonBottom),
                    ),
                  ),
                  Expanded(
                    child: SliderWithLabel(
                      label: 'From Bottom',
                      value: settings.buttonBottom,
                      min: 0.0,
                      max: 1.0,
                      step: 0.01,
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
      child: SliderWithLabel(
        label: 'Screen Padding',
        value: settings.screenPadding,
        min: 0,
        max: 64,
        onChanged: (v) => settings.setScreenPadding(v),
      ),
    );
  }
}
