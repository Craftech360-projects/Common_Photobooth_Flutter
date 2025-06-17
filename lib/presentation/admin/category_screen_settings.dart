import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/constants/constants.dart';
import 'package:photobooth_flutter/presentation/category_screen.dart';
import 'package:photobooth_flutter/providers/category_settings_provider.dart';
import 'package:photobooth_flutter/widgets/improved_color_picker.dart';
import 'package:photobooth_flutter/widgets/settings_preview.dart';
import 'package:provider/provider.dart';

class CategoryScreenSettings extends StatelessWidget {
  const CategoryScreenSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<CategorySettingsProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Categories Screen Settings')),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: SettingsPreview(
              width: 1080,
              height: 1920,
              child: CategoriesScreen(),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleSettings(context, settingsProvider),
                  const Divider(height: 32),
                  _buildBackgroundSettings(context, settingsProvider),
                  const Divider(height: 32),
                  _buildSectionTitle('Main Category Cards'),
                  _buildCardSettings(context, settingsProvider, 'aiArtistry',
                      'AI Artistry Card'),
                  _buildCardSettings(
                      context, settingsProvider, 'swaplab', 'Swaplab Card'),
                  const Divider(height: 32),
                  _buildSectionTitle('Sub-Category Cards'),
                  _buildCardSettings(
                      context, settingsProvider, 'ghibli', 'Ghibli Card'),
                  _buildCardSettings(
                      context, settingsProvider, 'pixar', 'Pixar Card'),
                  _buildCardSettings(
                      context, settingsProvider, 'packaging', 'Packaging Card'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSettings(
      BuildContext context, CategorySettingsProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Title Settings'),
        SwitchListTile(
          title: const Text('Show Title'),
          value: provider.showTitle,
          onChanged: (value) => provider.setShowTitle(value),
        ),
        if (provider.showTitle) ...[
          TextFormField(
            initialValue: provider.titleText,
            decoration: const InputDecoration(
                labelText: 'Title Text', border: OutlineInputBorder()),
            onChanged: (value) => provider.setTitleText(value),
          ),
          Constants.h16,
          _buildSliderWithLabel(
            label: 'Font Size',
            value: provider.titleFontSize,
            min: 16.0,
            max: 48.0,
            onChanged: (value) => provider.setTitleStyle(fontSize: value),
          ),
          ListTile(
            title: const Text('Title Color'),
            trailing:
                CircleAvatar(backgroundColor: provider.titleColor, radius: 15),
            onTap: () async {
              final color = await _showImprovedColorPicker(
                  context: context,
                  color: provider.titleColor,
                  title: 'Select Title Color');
              if (color != null) provider.setTitleStyle(color: color);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildBackgroundSettings(
      BuildContext context, CategorySettingsProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Background Settings'),
        SwitchListTile(
          title: const Text('Use Custom Background'),
          value: provider.showBackground,
          onChanged: (value) => provider.setShowBackground(value),
        ),
        if (provider.showBackground) ...[
          ElevatedButton(
            onPressed: () async {
              final result =
                  await FilePicker.platform.pickFiles(type: FileType.image);
              if (result != null && result.files.single.path != null) {
                provider.setBackgroundImage(result.files.single.path,
                    isAsset: false);
              }
            },
            child: const Text('Select Background Image'),
          ),
          if (provider.backgroundImagePath != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('Current: ${provider.backgroundImagePath}'),
            ),
        ]
      ],
    );
  }

  Widget _buildCardSettings(BuildContext context,
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

    return ExpansionTile(
      title: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      childrenPadding: const EdgeInsets.all(8),
      children: [
        ElevatedButton(
          onPressed: () async {
            final result =
                await FilePicker.platform.pickFiles(type: FileType.image);
            if (result?.files.single.path != null) {
              provider.updateCardSettings(
                  cardKey,
                  settings.copyWith(
                    imagePath: result!.files.single.path,
                    isAsset: false,
                  ));
            }
          },
          child: const Text('Select Image'),
        ),
        _buildSliderWithLabel(
          label: 'Width',
          value: settings.width,
          min: 100,
          max: 700,
          onChanged: (value) => provider.updateCardSettings(
              cardKey, settings.copyWith(width: value)),
        ),
        _buildSliderWithLabel(
          label: 'Height',
          value: settings.height,
          min: 100,
          max: 800,
          onChanged: (value) => provider.updateCardSettings(
              cardKey, settings.copyWith(height: value)),
        ),
        _buildSliderWithLabel(
          label: 'Border Radius',
          value: settings.borderRadius,
          min: 0,
          max: 50,
          onChanged: (value) => provider.updateCardSettings(
              cardKey, settings.copyWith(borderRadius: value)),
        ),
        SwitchListTile(
          title: const Text('Show Border'),
          value: settings.showBorder,
          onChanged: (value) => provider.updateCardSettings(
              cardKey, settings.copyWith(showBorder: value)),
        ),
        if (settings.showBorder) ...[
          _buildSliderWithLabel(
            label: 'Border Width',
            value: settings.borderWidth,
            min: 1,
            max: 10,
            onChanged: (value) => provider.updateCardSettings(
                cardKey, settings.copyWith(borderWidth: value)),
          ),
          ListTile(
            title: const Text('Border Color'),
            trailing:
                CircleAvatar(backgroundColor: settings.borderColor, radius: 15),
            onTap: () async {
              final color = await _showImprovedColorPicker(
                  context: context,
                  color: settings.borderColor,
                  title: 'Select Border Color');
              if (color != null) {
                provider.updateCardSettings(
                    cardKey, settings.copyWith(borderColor: color));
              }
            },
          ),
        ],
        SwitchListTile(
          title: const Text('Use Glow Effect'),
          value: settings.useGlow,
          onChanged: (value) => provider.updateCardSettings(
              cardKey, settings.copyWith(useGlow: value)),
        ),
        if (settings.useGlow) ...[
          ListTile(
            title: const Text('Glow Color'),
            trailing:
                CircleAvatar(backgroundColor: settings.glowColor, radius: 15),
            onTap: () async {
              final color = await _showImprovedColorPicker(
                  context: context,
                  color: settings.glowColor,
                  title: 'Select Glow Color');
              if (color != null) {
                provider.updateCardSettings(
                    cardKey, settings.copyWith(glowColor: color));
              }
            },
          ),
        ]
      ],
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      );

  Widget _buildSliderWithLabel(
      {required String label,
      required double value,
      required double min,
      required double max,
      required ValueChanged<double> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label), Text(value.toStringAsFixed(1))],
        ),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }

  Future<Color?> _showImprovedColorPicker(
      {required BuildContext context,
      required Color color,
      required String title}) async {
    return showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
            child: ImprovedColorPicker(
                pickerColor: color, onColorChanged: (c) => color = c)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, color),
              child: const Text('Select')),
        ],
      ),
    );
  }
}
