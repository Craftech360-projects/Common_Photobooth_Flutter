import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/presentation/theme_selection_screen.dart';
import 'package:photobooth_flutter/providers/theme_selection_provider.dart'
    hide Theme;
import 'package:photobooth_flutter/widgets/custom_slider.dart';
import 'package:photobooth_flutter/widgets/file_upload_area.dart';
import 'package:photobooth_flutter/widgets/form_row.dart';
import 'package:photobooth_flutter/widgets/input_decoration.dart';
import 'package:photobooth_flutter/widgets/settings_group.dart';
import 'package:photobooth_flutter/widgets/settings_header.dart';
import 'package:provider/provider.dart';

class ThemeSelectionSettingsScreen extends StatefulWidget {
  const ThemeSelectionSettingsScreen({super.key});

  @override
  State<ThemeSelectionSettingsScreen> createState() =>
      _ThemeSelectionSettingsScreenState();
}

class _ThemeSelectionSettingsScreenState
    extends State<ThemeSelectionSettingsScreen> {
  bool _isPanelOpen = true;

  @override
  Widget build(BuildContext context) {
    double settingsPanelWidth = MediaQuery.of(context).size.width * 0.8;
    return Scaffold(
      body: Stack(
        children: [
          const ThemeSelectionScreen(),
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
              heroTag: 'themeBack',
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
              heroTag: 'themeToggle',
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
                      _CarouselCardTransformGroup(),
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
    );
  }
}

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
              decoration: inputDecoration(context, 'Enter title text'),
              onChanged: (value) => settings.setTitleText(value),
            ),
            const SizedBox(height: 15),
            SliderWithLabel(
              label: 'Font Size',
              value: settings.titleFontSize,
              min: 16,
              max: 90,
              onChanged: (v) => settings.setTitleFontSize(v),
            ),
            SliderWithLabel(
              label: 'Top Position',
              value: settings.titleTop,
              min: 0.0,
              max: 1.0,
              step: 0.01,
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
          SliderWithLabel(
            label: 'Carousel Top Position',
            value: settings.carouselTop,
            min: 0.0,
            max: 1.0,
            step: 0.01,
            onChanged: (v) => settings.setCarouselTop(v),
          ),
          SliderWithLabel(
            label: 'Carousel Height',
            value: settings.carouselHeight,
            min: 0.1,
            max: 1.0,
            step: 0.01,
            onChanged: (v) => settings.setCarouselHeight(v),
          ),
          SliderWithLabel(
            label: 'Arrow Spacing',
            value: settings.arrowSpacing,
            min: 0.0,
            max: 1.0,
            step: 0.01,
            onChanged: (v) => settings.setArrowSpacing(v),
          ),
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
                      child: SliderWithLabel(
                        label: 'Card Width',
                        value: settings.cardWidth,
                        min: 0.1,
                        max: 1.0,
                        step: 0.01,
                        onChanged: (v) => settings.setCardWidth(v),
                      ),
                    ),
                    Expanded(
                      child: SliderWithLabel(
                        label: 'Card Height',
                        value: settings.cardHeight,
                        min: 0.1,
                        max: 1.0,
                        step: 0.01,
                        onChanged: (v) => settings.setCardHeight(v),
                      ),
                    ),
                  ],
                ),
                SliderWithLabel(
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

class _CarouselCardTransformGroup extends StatelessWidget {
  const _CarouselCardTransformGroup();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<ThemeSelectionProvider>();
    return SettingsGroup(
      icon: '✨',
      title: 'Carousel Card Effects',
      child: Column(
        children: [
          SettingsGroup(
            isSubgroup: true,
            icon: '🃏',
            title: 'Left Card (Position 1)',
            child: Column(
              children: [
                SliderWithLabel(
                  label: 'Scale',
                  value: settings.card1Scale,
                  min: 0.5,
                  max: 1.5,
                  step: 0.01,
                  onChanged: (v) =>
                      settings.setCarouselCardTransforms(card1Scale: v),
                ),
                SliderWithLabel(
                  label: 'X-Offset (Horizontal)',
                  value: settings.card1XOffset,
                  min: -300,
                  max: 300,
                  onChanged: (v) =>
                      settings.setCarouselCardTransforms(card1XOffset: v),
                ),
                SliderWithLabel(
                  label: 'Y-Offset (Vertical)',
                  value: settings.card1YOffset,
                  min: 0,
                  max: 300,
                  onChanged: (v) =>
                      settings.setCarouselCardTransforms(card1YOffset: v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          SettingsGroup(
            isSubgroup: true,
            icon: '🃏',
            title: 'Right Card (Position 2)',
            child: Column(
              children: [
                SliderWithLabel(
                  label: 'Scale',
                  value: settings.card2Scale,
                  min: 0.5,
                  max: 1.5,
                  step: 0.01,
                  onChanged: (v) =>
                      settings.setCarouselCardTransforms(card2Scale: v),
                ),
                SliderWithLabel(
                  label: 'X-Offset (Horizontal)',
                  value: settings.card2XOffset,
                  min: -300,
                  max: 300,
                  onChanged: (v) =>
                      settings.setCarouselCardTransforms(card2XOffset: v),
                ),
                SliderWithLabel(
                  label: 'Y-Offset (Vertical)',
                  value: settings.card2YOffset,
                  min: 0,
                  max: 300,
                  onChanged: (v) =>
                      settings.setCarouselCardTransforms(card2YOffset: v),
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
                child: SliderWithLabel(
                  label: 'Button Width',
                  value: settings.buttonWidth,
                  min: 0.05,
                  max: 1.0,
                  step: 0.01,
                  onChanged: (v) => settings.setButtonWidth(v),
                ),
              ),
              Expanded(
                child: SliderWithLabel(
                  label: 'Button Height',
                  value: settings.buttonHeight,
                  min: 0.02,
                  max: 1.0,
                  step: 0.01,
                  onChanged: (v) => settings.setButtonHeight(v),
                ),
              ),
            ],
          ),
          SliderWithLabel(
            label: 'Button Bottom Position',
            value: settings.buttonBottom,
            min: 0.0,
            max: 1.0,
            step: 0.01,
            onChanged: (v) => settings.setButtonBottom(v),
          ),
          // SliderWithLabel(  =====> Add This
          //   label: 'Button Border Radius',
          //   value: settings.borderRadius,
          //   min: 0.0,
          //   max: 1.0,
          //   step: 0.01,
          //   onChanged: (v) => settings.setBorderRadius(v),
          // ),
        ],
      ),
    );
  }
}
