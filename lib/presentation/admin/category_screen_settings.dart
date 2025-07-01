import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/presentation/category_screen.dart';
import 'package:photobooth_flutter/providers/category_settings_provider.dart';
import 'package:photobooth_flutter/widgets/color_picker.dart';
import 'package:photobooth_flutter/widgets/custom_slider.dart';
import 'package:photobooth_flutter/widgets/file_upload_area.dart';
import 'package:photobooth_flutter/widgets/form_row.dart';
import 'package:photobooth_flutter/widgets/input_decoration.dart';
import 'package:photobooth_flutter/widgets/settings_group.dart';
import 'package:photobooth_flutter/widgets/settings_header.dart';
import 'package:provider/provider.dart';

class CategoryScreenSettings extends StatefulWidget {
  const CategoryScreenSettings({super.key});

  @override
  State<CategoryScreenSettings> createState() => _CategoryScreenSettingsState();
}

class _CategoryScreenSettingsState extends State<CategoryScreenSettings> {
  bool _isPanelOpen = true;

  @override
  Widget build(BuildContext context) {
    double settingsPanelWidth = MediaQuery.of(context).size.width * 0.8;
    return Scaffold(
      body: Stack(
        children: [
          // Full-screen preview
          const CategoriesScreen(),

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
              heroTag: 'categoryBack', // Unique tag
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
              heroTag: 'categoryToggle',
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
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SettingsHeader(
                title: 'Categories Screen Settings',
                subtitle: 'Customize the layout and style of category cards',
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      const _TitleSettingsGroup(),
                      const SizedBox(height: 25),
                      const _BackgroundSettingsGroup(),
                      const SizedBox(height: 25),
                      const _MainCategoriesGroup(),
                      const SizedBox(height: 25),
                      const _SubCategoriesGroup(),
                      const SizedBox(height: 25),
                      _LayoutSettingsGroup(), // New Group
                      const SizedBox(height: 25),
                      _PackagingFieldSettingsGroup(), // New Group
                      const SizedBox(height: 25),
                      _ButtonSettingsGroup(), // New Group
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

class _LayoutSettingsGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategorySettingsProvider>();
    return SettingsGroup(
      icon: '📏',
      title: 'Carousel Layout',
      child: Column(
        children: [
          SliderWithLabel(
            label: 'Carousel Width (%)',
            value: provider.carouselWidth,
            min: 0.2,
            max: 1.0,
            step: 0.01,
            onChanged: (v) =>
                provider.setCarouselDimensions(v, provider.carouselHeight),
          ),
          SliderWithLabel(
            label: 'Carousel Height (%)',
            value: provider.carouselHeight,
            min: 0.2,
            max: 1.0,
            step: 0.01,
            onChanged: (v) =>
                provider.setCarouselDimensions(provider.carouselWidth, v),
          ),
          SliderWithLabel(
            label: 'Arrow Spacing (%)',
            value: provider.arrowSpacing,
            min: 0.0,
            max: 0.5,
            step: 0.01,
            onChanged: (v) => provider.setArrowSpacing(v),
          ),
        ],
      ),
    );
  }
}

class _PackagingFieldSettingsGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategorySettingsProvider>();
    return SettingsGroup(
      icon: '📦',
      title: 'Packaging Field',
      child: Column(
        children: [
          SliderWithLabel(
            label: 'Field Width (%)',
            value: provider.packagingFieldWidth,
            min: 0.2,
            max: 1.0,
            step: 0.01,
            onChanged: (v) => provider.setPackagingFieldWidth(v),
          ),
          SliderWithLabel(
            label: 'Font Size',
            value: provider.packagingFieldFontSize,
            min: 12,
            max: 48,
            onChanged: (v) => provider.setPackagingFieldStyle(fontSize: v),
          ),
          // ... (Color pickers for text and border color)
          //
          //
          SettingsGroup(
            isSubgroup: true,
            icon: '📍',
            title: 'Positioning',
            child: Column(
              children: [
                SliderWithLabel(
                  label: 'From Left (%)',
                  value: provider.packagingFieldLeft,
                  min: 0.0,
                  max: 1.0,
                  step: 0.01,
                  onChanged: (v) => provider.setPackagingFieldPosition(
                      v, provider.packagingFieldBottom),
                ),
                SliderWithLabel(
                  label: 'From Bottom (%)',
                  value: provider.packagingFieldBottom,
                  min: 0.0,
                  max: 1.0,
                  step: 0.01,
                  onChanged: (v) => provider.setPackagingFieldPosition(
                      provider.packagingFieldLeft, v),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ButtonSettingsGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // final provider = context.watch<CategorySettingsProvider>();
    return const SettingsGroup(
      icon: '🔘',
      title: 'Next Button',
      child: Column(
        children: [
          // ... (Sliders for button width, height, left, and bottom, all using percentages)
        ],
      ),
    );
  }
}

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
            SliderWithLabel(
              label: 'Font Size',
              value: provider.titleFontSize,
              min: 16.0,
              max: 60.0,
              onChanged: (value) => provider.setTitleStyle(fontSize: value),
            ),
            const SizedBox(height: 15),
            ColorPickerWidget(
              label: "Title Color",
              color: provider.titleColor,
              onColorChanged: (color) => provider.setTitleStyle(color: color),
            ),
            SettingsGroup(
              isSubgroup: true,
              icon: '📍',
              title: 'Positioning',
              child: Column(children: [
                SliderWithLabel(
                  label: "Horizontal Position (%)",
                  value: provider.titleLeft,
                  min: 0.0,
                  max: 1.0,
                  step: 0.01,
                  onChanged: (v) => provider.setTitlePosition(
                      v, provider.titleTop, provider.titleWidth),
                ),
                SliderWithLabel(
                  label: "Vertical Position (%)",
                  value: provider.titleTop,
                  min: 0.0,
                  max: 1.0,
                  step: 0.01,
                  onChanged: (v) => provider.setTitlePosition(
                      provider.titleLeft, v, provider.titleWidth),
                ),
                SliderWithLabel(
                  label: "Width (%)",
                  value: provider.titleWidth,
                  min: 0.1,
                  max: 1.0,
                  step: 0.01,
                  onChanged: (v) => provider.setTitlePosition(
                      provider.titleLeft, provider.titleTop, v),
                ),
              ]),
            )
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
                child: SliderWithLabel(
                  label: 'Width (%)',
                  value: settings.width,
                  min: 0.1,
                  max: 1.0,
                  step: 0.01,
                  onChanged: (value) => provider.updateCardSettings(
                      cardKey, settings.copyWith(width: value)),
                ),
              ),
              Expanded(
                child: SliderWithLabel(
                  label: 'Height (%)',
                  value: settings.height,
                  min: 0.1,
                  max: 1.0,
                  step: 0.01,
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
              SliderWithLabel(
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
                      child: SliderWithLabel(
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
                        label: "Card Border Color",
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
                  label: "Card Glow Color",
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
