// lib/widgets/snackbar.dart

import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/constants/constants.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';

// MODIFIED: Added an 'isError' parameter
void showSnackBar(
  BuildContext context,
  String content, {
  bool isError = false,
}) {
  if (!context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor:
          isError ? AppColors.red.withValues(alpha: 0.6) : AppColors.green,
      content: Text(
        content,
        style: const TextStyle(
          fontFamily: "SwitzerVariable",
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: Constants.br4),
      padding: const EdgeInsets.all(12),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom: 55, left: 16, right: 16, top: 0),
      elevation: 1,
      dismissDirection: DismissDirection.horizontal,
    ),
  );
}
