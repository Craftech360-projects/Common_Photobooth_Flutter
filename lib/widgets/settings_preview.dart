import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';

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

    return Container(
      width: scaledWidth,
      height: scaledHeight,
      decoration: decoration ??
          BoxDecoration(
            color: Colors.black12, // Light gray background to show boundaries
            border: Border.all(color: AppColors.grey.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(8),
          ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: width,
            height: height,
            child: child,
          ),
        ),
      ),
    );
  }
}
