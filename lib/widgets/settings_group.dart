import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';

class SettingsGroup extends StatelessWidget {
  final String icon;
  final String title;
  final Widget child;
  final bool isSubgroup;

  const SettingsGroup({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
    this.isSubgroup = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: isSubgroup ? const EdgeInsets.only(top: 10) : EdgeInsets.zero,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: isSubgroup
            ? AppColors.white.withValues(alpha: 0.5)
            : AppColors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.black.withValues(alpha: 0.05)),
        boxShadow: isSubgroup
            ? []
            : [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [
                    AppColors.primaryGradientStart,
                    AppColors.primaryGradientEnd
                  ]),
                ),
                alignment: Alignment.center,
                child: Text(icon, style: const TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(title, style: textTheme.titleLarge)),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
