// lib/widgets/custom_slider.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';

class SliderWithLabel extends StatefulWidget {
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
  State<SliderWithLabel> createState() => _SliderWithLabelState();
}

class _SliderWithLabelState extends State<SliderWithLabel> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toStringAsFixed(2));
    _focusNode = FocusNode();

    // Add a listener to handle when the user finishes editing the text field.
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Sync the text field if the parent widget updates the value.
  @override
  void didUpdateWidget(SliderWithLabel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && !_focusNode.hasFocus) {
      _controller.text = widget.value.toStringAsFixed(2);
    }
  }

  // Parse and submit the value when the text field loses focus.
  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _submitValue();
    }
  }

  // Logic to parse, validate, and update the value from the text field.
  void _submitValue() {
    final text = _controller.text;
    final parsedValue = double.tryParse(text);

    if (parsedValue != null) {
      // Clamp the value to ensure it's within the allowed min/max range.
      final clampedValue = parsedValue.clamp(widget.min, widget.max);

      if (clampedValue != widget.value) {
        widget.onChanged(clampedValue);
      }
      // Update the text field to show the validated (and possibly clamped) value.
      _controller.text = clampedValue.toStringAsFixed(2);
    } else {
      // If parsing fails, reset the text to the last known good value.
      _controller.text = widget.value.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int? divisions = widget.step != null
        ? ((widget.max - widget.min) / widget.step!).round()
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.label,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.labelText)),
            // Add a Row for the text field and the value label
            Row(
              children: [
                SizedBox(
                  width: 70, // Constrain the width of the text field
                  height: 35,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))
                    ],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.labelText),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: AppColors.inputBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: AppColors.black, width: 2),
                      ),
                    ),
                    onSubmitted: (_) => _submitValue(),
                  ),
                ),
              ],
            ),
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
            value: widget.value.clamp(widget.min, widget.max),
            min: widget.min,
            max: widget.max,
            divisions: divisions,
            label: widget.value.toStringAsFixed(2),
            onChanged: (newValue) {
              // Update the parent widget's state when the slider is moved.
              widget.onChanged(newValue);
            },
          ),
        ),
      ],
    );
  }
}
