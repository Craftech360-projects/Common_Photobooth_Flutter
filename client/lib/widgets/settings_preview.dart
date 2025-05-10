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
    // Calculate the scaled dimensions
    final scaledWidth = width * scale;
    final scaledHeight = height * scale;

    return Container(
      width: scaledWidth,
      height: scaledHeight,
      decoration: decoration ??
          BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(0),
          ),
      child: Transform.scale(
        scale: 1,
        alignment: Alignment.center,
        transformHitTests: false,
        child: SizedBox(
          width: width,
          height: height,
          child: child,
        ),
      ),
    );
  }
}
