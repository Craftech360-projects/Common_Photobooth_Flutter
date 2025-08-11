// lib/widgets/file_upload_area.dart

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';

class FileUploadArea extends StatelessWidget {
  final VoidCallback onTap;
  final String icon;
  final String text;
  final String? selectedFile;

  const FileUploadArea({
    super.key,
    required this.onTap,
    required this.icon,
    required this.text,
    this.selectedFile,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final fileName = selectedFile != null
        ? selectedFile!.split('/').last
        : null;

    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        options: const RoundedRectDottedBorderOptions(
          dashPattern: [10, 5],
          strokeWidth: 2,
          radius: Radius.circular(16),
          color: AppColors.darkGrey,
          padding: EdgeInsets.all(16),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.primaryGradientStart.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(icon, style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 10),
                Text.rich(
                  TextSpan(
                    style: textTheme.bodyMedium
                        ?.copyWith(color: AppColors.fileUploadText),
                    children: [
                      TextSpan(text: '$text\n'),
                      if (fileName != null)
                        TextSpan(
                          text: 'Selected: $fileName',
                          style: textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
