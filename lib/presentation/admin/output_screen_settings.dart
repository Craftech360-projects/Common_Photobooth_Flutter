import 'package:flutter/material.dart';
import 'package:photobooth_flutter/presentation/output_screen.dart';
import 'package:photobooth_flutter/providers/output_screen_provider.dart';
import 'package:photobooth_flutter/widgets/settings_preview.dart';
import 'package:provider/provider.dart';

class OutputScreenSettings extends StatelessWidget {
  const OutputScreenSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Output Screen Settings'),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SettingsPreview(
              width: 1080,
              height: 1920,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.transparent),
                borderRadius: BorderRadius.circular(0),
              ),
              child: const SwappedFaceScreen(isPreviewMode: true),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<OutputScreenProvider>(
                builder: (context, settings, child) {
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Title Settings'),
                        _buildSwitch(
                          label: 'Show Title',
                          value: settings.showTitle,
                          onChanged: (value) => settings.setShowTitle(value),
                        ),
                        if (settings.showTitle) ...[
                          // Title settings UI...
                        ],
                        const Divider(),
                        _buildSectionTitle('AI Artistry Image Settings'),
                        // AI Artistry settings UI...
                        const Divider(),
                        _buildSectionTitle('Swaplab Image Settings'),
                        // Swaplab settings UI...
                        const Divider(),
                        _buildSectionTitle('QR Code Settings'),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSlider(
                                label: 'From Left',
                                value: settings.qrCodeLeft,
                                min: 0.0,
                                max: 1080.0,
                                onChanged: (value) =>
                                    settings.setQrCodePosition(
                                  value,
                                  settings.qrCodeBottom,
                                ),
                              ),
                            ),
                            Expanded(
                              child: _buildSlider(
                                label: 'From Bottom',
                                value: settings.qrCodeBottom,
                                min: 0.0,
                                max: 1920.0,
                                onChanged: (value) =>
                                    settings.setQrCodePosition(
                                  settings.qrCodeLeft,
                                  value,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        _buildSectionTitle('Button Settings'),
                        // Button settings UI...
                        const Divider(),
                        _buildSectionTitle('Background Settings'),
                        // Background settings UI...
                      ]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widgets (_buildSectionTitle, _buildSwitch, etc.) remain the same
  // ...
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSwitch({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required Function(double) onChanged,
    int? divisions,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ${value.toStringAsFixed(1)}'),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions ?? ((max - min) ~/ 1).toInt(),
            label: value.toStringAsFixed(1),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
