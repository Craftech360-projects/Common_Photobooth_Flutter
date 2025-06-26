import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';

// This is now a top-level function that can be imported anywhere.
InputDecoration inputDecoration(BuildContext context, String hintText) {
  final theme = Theme.of(context);
  return InputDecoration(
    hintText: hintText,
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.8),
    hintStyle: theme.textTheme.bodyMedium
        ?.copyWith(color: AppColors.black.withValues(alpha: 0.7)),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.inputBorder, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.inputBorder, width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide:
          const BorderSide(color: AppColors.primaryGradientStart, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
  );
}
