import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/presentation/theme_selection_screen.dart';
import 'package:photobooth_flutter/providers/theme_selection_provider.dart';
import 'package:photobooth_flutter/widgets/settings_preview.dart';
import 'package:provider/provider.dart';

class ThemeSelectionSettingsScreen extends StatelessWidget {
  const ThemeSelectionSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<ThemeSelectionProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Theme Selection Screen Settings')),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: SettingsPreview(
              width: 1080,
              height: 1920,
              child: ThemeSelectionScreen(),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleSettings(settings),
                  const Divider(height: 32),
                  _buildBackgroundSettings(settings),
                  const Divider(height: 32),
                  _buildCarouselSettings(settings),
                  const Divider(height: 32),
                  _buildButtonSettings(settings),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      );

  Widget _buildSlider(String label, double value, double min, double max,
      ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(0)}'),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }

  Widget _buildTitleSettings(ThemeSelectionProvider settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Title Settings'),
        SwitchListTile(
          title: const Text('Show Title'),
          value: settings.showTitle,
          onChanged: (value) => settings.setShowTitle(value),
        ),
        if (settings.showTitle) ...[
          TextFormField(
            initialValue: settings.titleText,
            decoration: const InputDecoration(
                labelText: 'Title Text', border: OutlineInputBorder()),
            onChanged: (value) => settings.setTitleText(value),
          ),
          _buildSlider('Font Size', settings.titleFontSize, 16, 90,
              (v) => settings.setTitleFontSize(v)),
          _buildSlider('Top Position', settings.titleTop, 50, 900,
              (v) => settings.setTitleTop(v)),
        ]
      ],
    );
  }

  Widget _buildBackgroundSettings(ThemeSelectionProvider settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Background Settings'),
        SwitchListTile(
          title: const Text('Show Custom Background'),
          value: settings.showBackground,
          onChanged: (value) => settings.setShowBackground(value),
        ),
        if (settings.showBackground)
          ElevatedButton(
            onPressed: () async {
              final result =
                  await FilePicker.platform.pickFiles(type: FileType.image);
              if (result?.files.single.path != null) {
                settings.setBackgroundImage(result!.files.single.path,
                    isAsset: false);
              }
            },
            child: const Text('Select Background'),
          ),
      ],
    );
  }

  Widget _buildCarouselSettings(ThemeSelectionProvider settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Carousel & Card Settings'),
        _buildSlider('Carousel Top Position', settings.carouselTop, 100, 1000,
            (v) => settings.setCarouselTop(v)),
        _buildSlider('Carousel Height', settings.carouselHeight, 300, 1000,
            (v) => settings.setCarouselHeight(v)),
        _buildSlider('Arrow Spacing', settings.arrowSpacing, 0, 100,
            (v) => settings.setArrowSpacing(v)),
        _buildSlider('Card Width', settings.cardWidth, 200, 700,
            (v) => settings.setCardWidth(v)),
        _buildSlider('Card Height', settings.cardHeight, 300, 900,
            (v) => settings.setCardHeight(v)),
        _buildSlider('Card Border Radius', settings.cardBorderRadius, 0, 50,
            (v) => settings.setCardBorderRadius(v)),
      ],
    );
  }

  Widget _buildButtonSettings(ThemeSelectionProvider settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Button Settings'),
        SwitchListTile(
          title: const Text('Use Image Button'),
          value: settings.useImageButton,
          onChanged: (value) => settings.setUseImageButton(value),
        ),
        if (settings.useImageButton)
          ElevatedButton(
            onPressed: () async {
              final result =
                  await FilePicker.platform.pickFiles(type: FileType.image);
              if (result?.files.single.path != null) {
                settings.setButtonImage(result!.files.single.path,
                    isAsset: false);
              }
            },
            child: const Text('Select Button Image'),
          ),
        _buildSlider('Button Width', settings.buttonWidth, 100, 800,
            (v) => settings.setButtonWidth(v)),
        _buildSlider('Button Height', settings.buttonHeight, 50, 300,
            (v) => settings.setButtonHeight(v)),
        _buildSlider('Button Bottom Position', settings.buttonBottom, 100, 1000,
            (v) => settings.setButtonBottom(v)),
      ],
    );
  }
}
