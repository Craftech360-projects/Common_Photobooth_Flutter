import 'package:flutter/material.dart';

class SettingsPreview extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final double scale;
  final BoxDecoration? decoration;

  const SettingsPreview({
    super.key,
    required this.child,
    this.width = 1080,
    this.height = 1920,
    this.scale = 0.45,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate the available space
    final screenSize = MediaQuery.of(context).size;
    final availableHeight = screenSize.height * 0.85; // Leave some margin

    // Calculate the scale that would fit the height
    final heightScale = availableHeight / height;

    // Use the smaller of the provided scale or height-based scale
    final effectiveScale = scale < heightScale ? scale : heightScale;

    // Calculate the scaled dimensions
    final scaledWidth = width * effectiveScale;
    final scaledHeight = height * effectiveScale;

    return SizedBox(
      width: scaledWidth,
      height: scaledHeight,
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: width,
          height: height,
          child: child,
        ),
      ),
    );
  }
}
