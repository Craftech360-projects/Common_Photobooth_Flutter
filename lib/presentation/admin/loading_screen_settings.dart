import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/presentation/loading_screen.dart';
import 'package:photobooth_flutter/providers/loading_screen_provider.dart';
import 'package:photobooth_flutter/widgets/color_picker.dart';
import 'package:photobooth_flutter/widgets/custom_dropdown.dart';
import 'package:photobooth_flutter/widgets/custom_slider.dart';
import 'package:photobooth_flutter/widgets/file_upload_area.dart';
import 'package:photobooth_flutter/widgets/form_row.dart';
import 'package:photobooth_flutter/widgets/input_decoration.dart';
import 'package:photobooth_flutter/widgets/settings_group.dart';
import 'package:photobooth_flutter/widgets/settings_header.dart';
import 'package:provider/provider.dart';

class LoadingScreenSettings extends StatefulWidget {
  const LoadingScreenSettings({super.key});

  @override
  State<LoadingScreenSettings> createState() => _LoadingScreenSettingsState();
}

class _LoadingScreenSettingsState extends State<LoadingScreenSettings> {
  bool _isPanelOpen = true;

  @override
  Widget build(BuildContext context) {
    double settingsPanelWidth = MediaQuery.of(context).size.width * 0.8;
    return Scaffold(
      body: Stack(
        children: [
          const LoadingScreen(isPreviewMode: true),
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
              heroTag: 'loadingBack',
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
              heroTag: 'loadingToggle',
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
                title: 'Loading Screen Settings',
                subtitle: 'Customize the elements shown during processing',
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    children: [
                      _LoaderSettingsGroup(),
                      SizedBox(height: 25),
                      _TitleSettingsGroup(),
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
      title: 'Loader Asset',
      child: Column(
        children: [
          FileUploadArea(
            onTap: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['mp4', 'mov', 'gif'],
              );
              if (result?.files.single.path != null) {
                settings.setLoaderAsset(result!.files.single.path);
              }
            },
            icon: '📁',
            text: 'Select Loader (.mp4, .gif)',
            selectedFile: settings.loaderAssetPath,
          ),
          if (settings.loaderAssetType == 'video') ...[
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Display Fullscreen',
                    style: Theme.of(context).textTheme.bodyLarge),
                Switch(
                    value: settings.loaderIsFullscreen,
                    onChanged: (v) => settings.setLoaderStyle(isFullscreen: v)),
              ],
            ),
          ],
          if (!settings.loaderIsFullscreen ||
              settings.loaderAssetType == 'gif') ...[
            const SizedBox(height: 15),
            SettingsGroup(
              isSubgroup: true,
              icon: '📐',
              title: 'Sizing & Positioning',
              child: Column(
                children: [
                  FormRow(children: [
                    Expanded(
                        child: SliderWithLabel(
                            label: 'Width (%)',
                            value: settings.loaderWidth,
                            min: 0.1,
                            max: 1.0,
                            step: 0.01,
                            onChanged: (v) =>
                                settings.setLoaderDimensions(width: v))),
                    Expanded(
                        child: SliderWithLabel(
                            label: 'Height (%)',
                            value: settings.loaderHeight,
                            min: 0.1,
                            max: 1.0,
                            step: 0.01,
                            onChanged: (v) =>
                                settings.setLoaderDimensions(height: v))),
                  ]),
                  SliderWithLabel(
                      label: 'From Top (%)',
                      value: settings.loaderTop,
                      min: 0.0,
                      max: 1.0,
                      step: 0.01,
                      onChanged: (v) => settings.setLoaderPosition(top: v)),
                  SliderWithLabel(
                      label: 'From Left (%)',
                      value: settings.loaderLeft,
                      min: 0.0,
                      max: 1.0,
                      step: 0.01,
                      onChanged: (v) => settings.setLoaderPosition(left: v)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TitleSettingsGroup extends StatelessWidget {
  const _TitleSettingsGroup();
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<LoadingScreenProvider>();
    return SettingsGroup(
      icon: '✏️',
      title: 'Title Settings',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Show Title', style: Theme.of(context).textTheme.bodyLarge),
              Switch(
                  value: settings.showTitle,
                  onChanged: (v) => settings.setTitleStyle(show: v)),
            ],
          ),
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
                max: 100,
                onChanged: (v) => settings.setTitleStyle(fontSize: v)),
            SliderWithLabel(
                label: 'Opacity',
                value: settings.titleOpacity,
                min: 0.0,
                max: 1.0,
                step: 0.01,
                onChanged: (v) => settings.setTitleStyle(opacity: v)),
            const SizedBox(height: 15),
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
                onColorChanged: (c) => settings.setTitleStyle(color: c)),
            const SizedBox(height: 15),
            SettingsGroup(
              isSubgroup: true,
              icon: '📍',
              title: 'Positioning',
              child: Column(
                children: [
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
                ],
              ),
            ),
          ]
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
    return SettingsGroup(
      icon: '🖼️',
      title: 'Background Settings',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Show Custom Background',
                  style: Theme.of(context).textTheme.bodyLarge),
              Switch(
                  value: settings.showBackground,
                  onChanged: (v) => settings.setShowBackground(v)),
            ],
          ),
          if (settings.showBackground) ...[
            const SizedBox(height: 15),
            FileUploadArea(
              onTap: () async {
                final result =
                    await FilePicker.platform.pickFiles(type: FileType.image);
                if (result?.files.single.path != null) {
                  settings.setBackgroundImage(result!.files.single.path);
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
