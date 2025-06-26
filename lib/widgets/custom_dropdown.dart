import 'package:flutter/material.dart';
import 'package:photobooth_flutter/widgets/input_decoration.dart';
// Import the new helper file

class CustomDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final Map<T, String> items;
  final ValueChanged<T?> onChanged;

  const CustomDropdown(
      {super.key,
      required this.label,
      required this.value,
      required this.items,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.bodyMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items.entries
              .map((e) =>
                  DropdownMenuItem<T>(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: onChanged,
          // Use the global function here
          decoration: inputDecoration(context, ''),
        ),
      ],
    );
  }
}
