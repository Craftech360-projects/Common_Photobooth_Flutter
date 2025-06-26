import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';

class CustomSliderWithLabel extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final double? step;
  final ValueChanged<double> onChanged;

  const CustomSliderWithLabel({
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
    int? divisions = step != null ? ((max - min) / step!).round() : null;
    String valueLabel =
        step == 0.1 ? value.toStringAsFixed(1) : value.round().toString();
    final textTheme = Theme.of(context).textTheme;
    final clampedValue = value.clamp(min, max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: textTheme.bodyMedium),
            Text(valueLabel,
                style: textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primaryGradientEnd,
            inactiveTrackColor: AppColors.inputBorder,
            trackHeight: 6.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
            thumbColor: AppColors.primaryGradientStart,
            overlayColor: AppColors.primaryGradientStart.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: clampedValue,
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
