import 'package:flutter/material.dart';

class ColorPicker extends StatefulWidget {
  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;

  const ColorPicker({
    super.key,
    required this.pickerColor,
    required this.onColorChanged,
  });

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late Color _currentColor;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.pickerColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Basic color grid
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _colorOption(Colors.red),
            _colorOption(Colors.pink),
            _colorOption(Colors.purple),
            _colorOption(Colors.deepPurple),
            _colorOption(Colors.indigo),
            _colorOption(Colors.blue),
            _colorOption(Colors.lightBlue),
            _colorOption(Colors.cyan),
            _colorOption(Colors.teal),
            _colorOption(Colors.green),
            _colorOption(Colors.lightGreen),
            _colorOption(Colors.lime),
            _colorOption(Colors.yellow),
            _colorOption(Colors.amber),
            _colorOption(Colors.orange),
            _colorOption(Colors.deepOrange),
            _colorOption(Colors.brown),
            _colorOption(Colors.grey),
            _colorOption(Colors.blueGrey),
            _colorOption(Colors.black),
            _colorOption(Colors.white),
          ],
        ),
        const SizedBox(height: 16),
        // Current color display
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: _currentColor,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }

  Widget _colorOption(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() => _currentColor = color);
        widget.onColorChanged(color);
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: _currentColor == color ? Colors.black : Colors.grey,
            width: _currentColor == color ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
