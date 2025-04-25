import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:photobooth_flutter/core/constants/constants.dart';

class ImprovedColorPicker extends StatefulWidget {
  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;
  final List<Color>? colorPalette;

  const ImprovedColorPicker({
    super.key,
    required this.pickerColor,
    required this.onColorChanged,
    this.colorPalette,
  });

  @override
  State<ImprovedColorPicker> createState() => _ImprovedColorPickerState();
}

class _ImprovedColorPickerState extends State<ImprovedColorPicker> {
  late TextEditingController _hexController;
  late Color _currentColor;

  // Default color palette if none provided
  final List<Color> _defaultPalette = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
    Colors.white,
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
                    ? const Icon(Icons.check, size: 20, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
