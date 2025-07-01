import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/presentation/category_screen.dart';
import 'package:photobooth_flutter/providers/category_settings_provider.dart';
import 'package:photobooth_flutter/widgets/custom_slider.dart';
import 'package:photobooth_flutter/widgets/file_upload_area.dart';
import 'package:photobooth_flutter/widgets/form_row.dart';
import 'package:photobooth_flutter/widgets/color_picker.dart';
import 'package:photobooth_flutter/widgets/input_decoration.dart';
import 'package:photobooth_flutter/widgets/settings_group.dart';
import 'package:photobooth_flutter/widgets/settings_header.dart';
import 'package:photobooth_flutter/widgets/settings_preview.dart';
import 'package:provider/provider.dart';

class CategoryScreenSettings extends StatelessWidget {
  const CategoryScreenSettings({super.key});

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
              child: CategoriesScreen(),
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
              color: AppColors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: AppColors.white.withValues(alpha: 0.2)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SettingsHeader(
                  title: 'Categories Screen Settings',
                  subtitle: 'Customize the layout and style of category cards',
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
                        _MainCategoriesGroup(),
                        SizedBox(height: 25),
                        _SubCategoriesGroup(),
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

// --- SETTINGS WIDGETS ---

class _TitleSettingsGroup extends StatelessWidget {
  const _TitleSettingsGroup();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategorySettingsProvider>();
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
                value: provider.showTitle,
                onChanged: (value) => provider.setShowTitle(value),
              ),
            ],
          ),
          if (provider.showTitle) ...[
            const SizedBox(height: 15),
            TextFormField(
              initialValue: provider.titleText,
              decoration: inputDecoration(context, 'Enter title text'),
              onChanged: (value) => provider.setTitleText(value),
            ),
            const SizedBox(height: 15),
            CustomSliderWithLabel(
              label: 'Font Size',
              value: provider.titleFontSize,
              min: 16.0,
              max: 60.0,
              onChanged: (value) => provider.setTitleStyle(fontSize: value),
            ),
            const SizedBox(height: 15),
            ColorPickerWidget(
            label: "Title Text Color",
              color: provider.titleColor,
              onColorChanged: (color) => provider.setTitleStyle(color: color),
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
    final provider = context.watch<CategorySettingsProvider>();
    final textTheme = Theme.of(context).textTheme;

    return SettingsGroup(
      icon: '🖼️',
      title: 'Background Settings',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Use Custom Background', style: textTheme.bodyLarge),
              Switch(
                value: provider.showBackground,
                onChanged: (value) => provider.setShowBackground(value),
              ),
            ],
          ),
          if (provider.showBackground) ...[
            const SizedBox(height: 15),
            FileUploadArea(
              onTap: () async {
                final result =
                    await FilePicker.platform.pickFiles(type: FileType.image);
                if (result != null && result.files.single.path != null) {
                  provider.setBackgroundImage(result.files.single.path,
                      isAsset: false);
                }
              },
              icon: '📁',
              text: 'Select Background Image',
              selectedFile: provider.backgroundImagePath,
            ),
          ]
        ],
      ),
    );
  }
}

class _MainCategoriesGroup extends StatelessWidget {
  const _MainCategoriesGroup();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategorySettingsProvider>();
    return SettingsGroup(
      icon: '📂',
      title: 'Main Category Cards',
      child: Column(
        children: [
          _buildCardSettingsGroup(
              context, provider, 'aiArtistry', 'AI Artistry Card'),
          const SizedBox(height: 15),
          _buildCardSettingsGroup(context, provider, 'swaplab', 'Swaplab Card'),
        ],
      ),
    );
  }
}

class _SubCategoriesGroup extends StatelessWidget {
  const _SubCategoriesGroup();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategorySettingsProvider>();
    return SettingsGroup(
      icon: '📁',
      title: 'Sub-Category Cards',
      child: Column(
        children: [
          _buildCardSettingsGroup(context, provider, 'ghibli', 'Ghibli Card'),
          const SizedBox(height: 15),
          _buildCardSettingsGroup(context, provider, 'pixar', 'Pixar Card'),
          const SizedBox(height: 15),
          _buildCardSettingsGroup(
              context, provider, 'packaging', 'Packaging Card'),
        ],
      ),
    );
  }
}

// --- COMMON BUILDER FOR CARD SETTINGS ---

Widget _buildCardSettingsGroup(BuildContext context,
    CategorySettingsProvider provider, String cardKey, String title) {
  CategoryCardSettings settings;
  switch (cardKey) {
    case 'aiArtistry':
      settings = provider.aiArtistryCard;
      break;
    case 'swaplab':
      settings = provider.swaplabCard;
      break;
    case 'ghibli':
      settings = provider.ghibliCard;
      break;
    case 'pixar':
      settings = provider.pixarCard;
      break;
    case 'packaging':
      settings = provider.packagingCard;
      break;
    default:
      return const SizedBox.shrink();
  }
  final textTheme = Theme.of(context).textTheme;

  return SettingsGroup(
    isSubgroup: true,
    icon: '🔹',
    title: title,
    child: Column(
      children: [
        FileUploadArea(
          onTap: () async {
            final result =
                await FilePicker.platform.pickFiles(type: FileType.image);
            if (result?.files.single.path != null) {
              provider.updateCardSettings(
                  cardKey,
                  settings.copyWith(
                      imagePath: result!.files.single.path, isAsset: false));
            }
          },
          icon: '🖼️',
          text: 'Select Card Image',
          selectedFile: settings.imagePath,
        ),
        const SizedBox(height: 20),
        SettingsGroup(
          isSubgroup: true,
          icon: '📐',
          title: 'Sizing',
          child: FormRow(
            children: [
              Expanded(
                child: CustomSliderWithLabel(
                  label: 'Width',
                  value: settings.width,
                  min: 100,
                  max: 700,
                  onChanged: (value) => provider.updateCardSettings(
                      cardKey, settings.copyWith(width: value)),
                ),
              ),
              Expanded(
                child: CustomSliderWithLabel(
                  label: 'Height',
                  value: settings.height,
                  min: 100,
                  max: 800,
                  onChanged: (value) => provider.updateCardSettings(
                      cardKey, settings.copyWith(height: value)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        SettingsGroup(
          isSubgroup: true,
          icon: '🎨',
          title: 'Border & Glow',
          child: Column(
            children: [
              CustomSliderWithLabel(
                label: 'Border Radius',
                value: settings.borderRadius,
                min: 0,
                max: 100,
                onChanged: (value) => provider.updateCardSettings(
                    cardKey, settings.copyWith(borderRadius: value)),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Show Border', style: textTheme.bodyLarge),
                  Switch(
                    value: settings.showBorder,
                    onChanged: (value) => provider.updateCardSettings(
                        cardKey, settings.copyWith(showBorder: value)),
                  ),
                ],
              ),
              if (settings.showBorder)
                FormRow(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomSliderWithLabel(
                        label: 'Border Width',
                        value: settings.borderWidth,
                        min: 1,
                        max: 10,
                        onChanged: (value) => provider.updateCardSettings(
                            cardKey, settings.copyWith(borderWidth: value)),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: ColorPickerWidget(
                      label: "Border Color",
                        color: settings.borderColor,
                        onColorChanged: (color) => provider.updateCardSettings(
                            cardKey, settings.copyWith(borderColor: color)),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Use Glow Effect', style: textTheme.bodyLarge),
                  Switch(
                    value: settings.useGlow,
                    onChanged: (value) => provider.updateCardSettings(
                        cardKey, settings.copyWith(useGlow: value)),
                  ),
                ],
              ),
              if (settings.useGlow)
                ColorPickerWidget(
                label: "Glow Color",
                  color: settings.glowColor,
                  onColorChanged: (color) => provider.updateCardSettings(
                      cardKey, settings.copyWith(glowColor: color)),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}
