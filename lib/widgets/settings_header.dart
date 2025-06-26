import 'package:flutter/material.dart';

class SettingsHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const SettingsHeader(
      {super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        border: Border(
            bottom: BorderSide(color: Colors.black.withValues(alpha: 0.1))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.headlineMedium),
          const SizedBox(height: 5),
          Text(subtitle, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}
