import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:photobooth_flutter/core/constants/constants.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';

class ColorPickerWidget extends StatelessWidget {
  final String label;
  final Color color;
  final ValueChanged<Color> onColorChanged;

  const ColorPickerWidget(
      {super.key,
      required this.label,
      required this.color,
      required this.onColorChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showColorPickerDialog(context),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.inputBorder, width: 2),
              color: AppColors.white.withValues(alpha: 0.8),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showColorPickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select $label'),
        content: SingleChildScrollView(
          child: CustomColorPicker(
            pickerColor: color,
            onColorChanged: onColorChanged,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class CustomColorPicker extends StatefulWidget {
  final String? label;
  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;
  final List<Color>? colorPalette;

  const CustomColorPicker({
    super.key,
    required this.pickerColor,
    required this.onColorChanged,
    this.colorPalette,
    this.label,
  });

  @override
  State<CustomColorPicker> createState() => _CustomColorPickerState();
}

class _CustomColorPickerState extends State<CustomColorPicker> {
  late TextEditingController _hexController;
  late Color _currentColor;

  // Default color palette if none provided
  final List<Color> _defaultPalette = [
    AppColors.red,
    AppColors.purple,
    AppColors.deepPurple,
    AppColors.indigo,
    AppColors.blue,
    AppColors.green,
    AppColors.yellow,
    AppColors.orange,
    AppColors.grey,
    AppColors.black,
    AppColors.white,
  ];

  @override
  void initState() {
    super.initState();
    _currentColor = widget.pickerColor;
    _hexController = TextEditingController(
      text: _colorToHex(_currentColor),
    );
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  void _updateColorFromHex(String hex) {
    try {
      if (hex.startsWith('#') && (hex.length == 7 || hex.length == 9)) {
        final color = _hexToColor(hex);
        setState(() {
          _currentColor = color;
        });
        widget.onColorChanged(color);
      }
    } on Exception catch (e) {
      // Invalid hex, ignore
      debugPrint('Invalid hex: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text(
            widget.label ?? "Select Color",
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        // Color picker
        ColorPicker(
          pickerColor: _currentColor,
          onColorChanged: (color) {
            setState(() {
              _currentColor = color;
              _hexController.text = _colorToHex(color);
            });
            widget.onColorChanged(color);
          },
          enableAlpha: true,
          displayThumbColor: true,
          portraitOnly: true,
        ),

        Constants.h16,

        // Hex input field
        Row(
          children: [
            const Text('Hex: '),
            Expanded(
              child: TextField(
                controller: _hexController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F#]')),
                  LengthLimitingTextInputFormatter(9),
                ],
                onChanged: (value) {
                  if (value.startsWith('#') &&
                      (value.length == 7 || value.length == 9)) {
                    _updateColorFromHex(value);
                  }
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () => _updateColorFromHex(_hexController.text),
            ),
          ],
        ),

        Constants.h16,

        // Color palette
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: (widget.colorPalette ?? _defaultPalette).map((color) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _currentColor = color;
                  _hexController.text = _colorToHex(color);
                });
                widget.onColorChanged(color);
              },
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(
                    color: Colors.grey,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: _currentColor.value == color.value
                    ? const Icon(Icons.check, size: 20, color: AppColors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
