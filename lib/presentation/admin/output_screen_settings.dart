import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/constants/constants.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/presentation/output_screen.dart';
import 'package:photobooth_flutter/providers/output_screen_provider.dart';
import 'package:photobooth_flutter/widgets/color_picker.dart';
import 'package:photobooth_flutter/widgets/custom_dropdown.dart';
import 'package:photobooth_flutter/widgets/custom_slider.dart';
import 'package:photobooth_flutter/widgets/file_upload_area.dart';
import 'package:photobooth_flutter/widgets/form_row.dart';
import 'package:photobooth_flutter/widgets/input_decoration.dart';
import 'package:photobooth_flutter/widgets/settings_group.dart';
import 'package:photobooth_flutter/widgets/settings_header.dart';
import 'package:provider/provider.dart';

class OutputScreenSettings extends StatefulWidget {
  const OutputScreenSettings({super.key});
  @override
  State<OutputScreenSettings> createState() => _OutputScreenSettingsState();
}

class _OutputScreenSettingsState extends State<OutputScreenSettings> {
  bool _isPanelOpen = true;
  @override
  Widget build(BuildContext context) {
    double settingsPanelWidth = MediaQuery.of(context).size.width * 0.8;
    return Scaffold(
      body: Stack(
        children: [
          const SwappedFaceScreen(isPreviewMode: true),
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
              heroTag: 'outputBack',
              tooltip: 'Back',
              backgroundColor: AppColors.white.withOpacity(0.8),
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
              heroTag: 'outputToggle',
              tooltip: 'Toggle Settings',
              backgroundColor: AppColors.white,
              onPressed: () => setState(() => _isPanelOpen = !_isPanelOpen),
              child: Icon(
                  _isPanelOpen
                      ? Icons.arrow_forward_ios_rounded
                      : Icons.arrow_back_ios_rounded,
                  color: AppColors.primaryGradientEnd),
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
            color: AppColors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: AppColors.white.withOpacity(0.2)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsHeader(
                  title: 'Output Screen Settings',
                  subtitle: 'Customize the final output screen elements'),
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
              )),
            ],
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
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Show Title', style: Theme.of(context).textTheme.bodyLarge),
            Switch(
                value: settings.showTitle,
                onChanged: (v) => settings.setShowTitle(v)),
          ]),
          if (settings.showTitle) ...[
            const SizedBox(height: 15),
            TextFormField(
                initialValue: settings.titleText,
                decoration: inputDecoration(context, 'Title Text'),
                onChanged: (v) => settings.setTitleStyle(text: v)),
            const SizedBox(height: 15),
            SliderWithLabel(
                label: 'Font Size',
                value: settings.titleFontSize,
                min: 16,
                max: 120,
                onChanged: (v) => settings.setTitleStyle(fontSize: v)),
            SliderWithLabel(
                label: 'Opacity',
                value: settings.titleOpacity,
                min: 0.0,
                max: 1.0,
                step: 0.01,
                onChanged: (v) => settings.setTitleStyle(opacity: v)),
            const SizedBox(height: 15),
            SettingsGroup(
                isSubgroup: true,
                icon: '🎨',
                title: 'Styling',
                child: Column(children: [
                  CustomDropdown<FontWeight>(
                      label: 'Font Weight',
                      value: settings.titleFontWeight,
                      items: const {
                        FontWeight.w300: 'Light',
                        FontWeight.w400: 'Regular',
                        FontWeight.w700: 'Bold'
                      },
                      onChanged: (v) => settings.setTitleStyle(fontWeight: v)),
                  const SizedBox(height: 15),
                  ColorPickerWidget(
                      label: 'Title Color',
                      color: settings.titleColor,
                      onColorChanged: (c) => settings.setTitleStyle(color: c)),
                ])),
            const SizedBox(height: 15),
            SettingsGroup(
                isSubgroup: true,
                icon: '📍',
                title: 'Positioning',
                child: Column(children: [
                  SliderWithLabel(
                      label: 'From Top (%)',
                      value: settings.titleTop,
                      min: 0.0,
                      max: 1.0,
                      step: 0.01,
                      onChanged: (v) => settings.setTitlePosition(top: v)),
                  SliderWithLabel(
                      label: 'Width (%)',
                      value: settings.titleWidth,
                      min: 0.1,
                      max: 1.0,
                      step: 0.01,
                      onChanged: (v) => settings.setTitlePosition(width: v)),
                ])),
          ]
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
        title: 'Output Image Settings',
        child: Column(children: [
          SettingsGroup(
              isSubgroup: true,
              icon: '📐',
              title: 'Sizing & Positioning',
              child: Column(children: [
                FormRow(children: [
                  Expanded(
                      child: SliderWithLabel(
                          label: 'Width (%)',
                          value: settings.imageWidth,
                          min: 0.1,
                          max: 1.0,
                          step: 0.01,
                          onChanged: (v) =>
                              settings.setImageDimensions(width: v))),
                  Expanded(
                      child: SliderWithLabel(
                          label: 'Height (%)',
                          value: settings.imageHeight,
                          min: 0.1,
                          max: 1.0,
                          step: 0.01,
                          onChanged: (v) =>
                              settings.setImageDimensions(height: v))),
                ]),
                FormRow(children: [
                  Expanded(
                      child: SliderWithLabel(
                          label: 'From Left (%)',
                          value: settings.imageLeft,
                          min: 0.0,
                          max: 1.0,
                          step: 0.01,
                          onChanged: (v) =>
                              settings.setImagePosition(left: v))),
                  Expanded(
                      child: SliderWithLabel(
                          label: 'From Top (%)',
                          value: settings.imageTop,
                          min: 0.0,
                          max: 1.0,
                          step: 0.01,
                          onChanged: (v) => settings.setImagePosition(top: v))),
                ]),
              ])),
          const SizedBox(height: 15),
          SettingsGroup(
              isSubgroup: true,
              icon: '🎨',
              title: 'Border Style',
              child: Column(children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Show Border',
                          style: Theme.of(context).textTheme.bodyLarge),
                      Switch(
                          value: settings.showImageBorder,
                          onChanged: (v) =>
                              settings.setImageStyle(showBorder: v)),
                    ]),
                if (settings.showImageBorder) ...[
                  SliderWithLabel(
                      label: 'Border Width',
                      value: settings.imageBorderWidth,
                      min: 1,
                      max: 20,
                      onChanged: (v) => settings.setImageStyle(borderWidth: v)),
                  ColorPickerWidget(
                      label: 'Border Color',
                      color: settings.imageBorderColor,
                      onColorChanged: (c) =>
                          settings.setImageStyle(borderColor: c)),
                ],
                SliderWithLabel(
                    label: 'Border Radius',
                    value: settings.imageBorderRadius,
                    min: 0,
                    max: 100,
                    onChanged: (v) => settings.setImageStyle(borderRadius: v)),
              ])),
        ]));
  }
}

class _QrCodeSettingsGroup extends StatelessWidget {
  const _QrCodeSettingsGroup();
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<OutputScreenProvider>();
    final isRow = settings.qrCodeLayout == QrCodeLayout.qrLeftTextRight ||
        settings.qrCodeLayout == QrCodeLayout.qrRightTextLeft;

    return SettingsGroup(
        icon: '📱',
        title: 'QR Code Section Settings',
        child: Column(children: [
          SliderWithLabel(
              label: 'QR Code Size',
              value: settings.qrCodeSize,
              min: 50,
              max: 500,
              onChanged: (v) => settings.setQrCodeStyle(size: v)),
          const SizedBox(height: 15),
          SettingsGroup(
              isSubgroup: true,
              icon: '📍',
              title: 'Positioning',
              child: FormRow(children: [
                Expanded(
                    child: SliderWithLabel(
                        label: 'From Left (%)',
                        value: settings.qrCodeSectionLeft,
                        min: 0.0,
                        max: 1.0,
                        step: 0.01,
                        onChanged: (v) => settings.setQrCodePosition(left: v))),
                Expanded(
                    child: SliderWithLabel(
                        label: 'From Bottom (%)',
                        value: settings.qrCodeSectionBottom,
                        min: 0.0,
                        max: 1.0,
                        step: 0.01,
                        onChanged: (v) =>
                            settings.setQrCodePosition(bottom: v))),
              ])),
          const SizedBox(height: 15),
          SettingsGroup(
              isSubgroup: true,
              icon: '✍️',
              title: 'Label Text',
              child: Column(children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Show Label',
                          style: Theme.of(context).textTheme.bodyLarge),
                      Switch(
                          value: settings.showQrCodeText,
                          onChanged: (v) =>
                              settings.setQrCodeStyle(showText: v)),
                    ]),
                if (settings.showQrCodeText) ...[
                  const SizedBox(height: 15),
                  CustomDropdown<QrCodeLayout>(
                    label: 'Layout Style',
                    value: settings.qrCodeLayout,
                    items: const {
                      QrCodeLayout.qrTopTextBottom: 'Text Below QR',
                      QrCodeLayout.qrBottomTextTop: 'Text Above QR',
                      QrCodeLayout.qrLeftTextRight: 'Text on Right',
                      QrCodeLayout.qrRightTextLeft: 'Text on Left',
                    },
                    onChanged: (v) => settings.setQrCodeStyle(layout: v),
                  ),
                  const SizedBox(height: 15),
                  if (isRow)
                    CustomDropdown<CrossAxisAlignment>(
                      label: 'Vertical Alignment',
                      value: settings.qrCodeRowAlignment,
                      items: const {
                        CrossAxisAlignment.start: 'Top',
                        CrossAxisAlignment.center: 'Center',
                        CrossAxisAlignment.end: 'Bottom'
                      },
                      onChanged: (v) =>
                          settings.setQrCodeStyle(rowAlignment: v),
                    )
                  else // is Column
                    CustomDropdown<CrossAxisAlignment>(
                      label: 'Horizontal Alignment',
                      value: settings.qrCodeColumnAlignment,
                      items: const {
                        CrossAxisAlignment.start: 'Left',
                        CrossAxisAlignment.center: 'Center',
                        CrossAxisAlignment.end: 'Right'
                      },
                      onChanged: (v) =>
                          settings.setQrCodeStyle(columnAlignment: v),
                    ),
                  const SizedBox(height: 15),
                  TextFormField(
                      initialValue: settings.qrCodeText,
                      decoration: inputDecoration(context, 'QR Code Label'),
                      onChanged: (v) => settings.setQrCodeStyle(text: v)),
                  const SizedBox(height: 15),
                  SliderWithLabel(
                      label: 'Font Size',
                      value: settings.qrCodeTextFontSize,
                      min: 10,
                      max: 40,
                      onChanged: (v) =>
                          settings.setQrCodeStyle(textFontSize: v)),
                  CustomDropdown<FontWeight>(
                    label: 'Font Weight',
                    value: settings.qrCodeTextFontWeight,
                    items: const {
                      FontWeight.w100: 'Thin',
                      FontWeight.w300: 'Light',
                      FontWeight.w400: 'Regular',
                      FontWeight.w500: 'Medium',
                      FontWeight.w700: 'Bold',
                      FontWeight.w900: 'Black',
                    },
                    onChanged: (v) =>
                        settings.setQrCodeStyle(textFontWeight: (v)),
                  ),
                  Constants.h16,
                  SliderWithLabel(
                      label: 'Label Width',
                      value: settings.qrLabelWidth,
                      min: 10,
                      max: 300,
                      onChanged: (v) =>
                          settings.setQrCodeStyle(qrLabelWidth: v)),
                  ColorPickerWidget(
                      label: 'Text Color',
                      color: settings.qrCodeTextColor,
                      onColorChanged: (c) =>
                          settings.setQrCodeStyle(textColor: c)),
                ]
              ])),
        ]));
  }
}

class _ButtonSettingsGroup extends StatelessWidget {
  const _ButtonSettingsGroup();
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<OutputScreenProvider>();
    return SettingsGroup(
        icon: '✅',
        title: 'Home Button Settings',
        child: Column(children: [
          const SizedBox(height: 15),
          FormRow(children: [
            Expanded(
                child: SliderWithLabel(
                    label: 'Width (%)',
                    value: settings.doneButtonWidth,
                    min: 0.1,
                    max: 1.0,
                    step: 0.01,
                    onChanged: (v) =>
                        settings.setDoneButtonDimensions(width: v))),
            Expanded(
                child: SliderWithLabel(
                    label: 'Height (%)',
                    value: settings.doneButtonHeight,
                    min: 0.02,
                    max: 0.2,
                    step: 0.01,
                    onChanged: (v) =>
                        settings.setDoneButtonDimensions(height: v))),
          ]),
          FormRow(children: [
            Expanded(
                child: SliderWithLabel(
                    label: 'From Left (%)',
                    value: settings.doneButtonLeft,
                    min: 0.0,
                    max: 1.0,
                    step: 0.01,
                    onChanged: (v) => settings.setDoneButtonPosition(left: v))),
            Expanded(
                child: SliderWithLabel(
                    label: 'From Bottom (%)',
                    value: settings.doneButtonBottom,
                    min: 0.0,
                    max: 1.0,
                    step: 0.01,
                    onChanged: (v) =>
                        settings.setDoneButtonPosition(bottom: v))),
          ]),
        ]));
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
            selectedFile: settings.backgroundImagePath));
  }
}
