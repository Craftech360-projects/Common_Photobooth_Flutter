import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';

class SliderWithLabel extends StatelessWidget {
   final String label;
  final double value;
  final double min;
  final double max;
  final double? step;
  final ValueChanged<double> onChanged;

  const SliderWithLabel({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.step,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Clamp the value to ensure it's within the min/max range, preventing crashes
    final safeValue = value.clamp(min, max);

    int? divisions = step != null ? ((max - min) / step!).round() : null;
    String valueLabel;

    if (max == 1.0 && min == 0.0) {
      valueLabel = '${(safeValue * 100).toStringAsFixed(0)}%'; // Show as percentage
    } else if (step == 0.1) {
      valueLabel = safeValue.toStringAsFixed(1);
    } else {
      valueLabel = safeValue.round().toString();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.labelText)),
            Text(valueLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.labelText)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primaryGradientEnd,
            inactiveTrackColor: AppColors.inputBorder,
            trackHeight: 6.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
            thumbColor: AppColors.primaryGradientStart,
            overlayColor: AppColors.primaryGradientStart.withOpacity(0.2),
          ),
          child: Slider(
            value: safeValue,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}