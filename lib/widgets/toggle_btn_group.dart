import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';

class ToggleButtonGroup extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const ToggleButtonGroup(
      {super.key,
      required this.options,
      required this.selectedIndex,
      required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: List.generate(options.length, (index) {
        final bool isActive = selectedIndex == index;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(vertical: 12),
              margin:
                  EdgeInsets.only(right: index < options.length - 1 ? 10 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: isActive
                    ? const LinearGradient(colors: [
                        AppColors.primaryGradientStart,
                        AppColors.primaryGradientEnd
                      ])
                    : null,
                color: isActive ? null : AppColors.white.withValues(alpha: 0.8),
                border: Border.all(
                    color: isActive
                        ? AppColors.primaryGradientStart
                        : AppColors.inputBorder,
                    width: 2),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                            color: AppColors.primaryGradientStart
                                .withValues(alpha: 0.3),
                            blurRadius: 15,
                            spreadRadius: -5)
                      ]
                    : [],
              ),
              alignment: Alignment.center,
              child: Text(
                options[index],
                style: textTheme.bodyMedium?.copyWith(
                    color: isActive ? AppColors.white : AppColors.labelText),
              ),
            ),
          ),
        );
      }),
    );
  }
}
