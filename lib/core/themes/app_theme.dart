import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/constants/constants.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    appBarTheme: const AppBarTheme(backgroundColor: AppColors.lightWhite),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.deepPurple,
      secondary: AppColors.goldenYellow,
      brightness: Brightness.light,
    ),
    iconTheme: const IconThemeData(color: AppColors.black),
    snackBarTheme: const SnackBarThemeData(closeIconColor: AppColors.white),
    iconButtonTheme: const IconButtonThemeData(
      style: ButtonStyle(
        iconColor: WidgetStatePropertyAll(AppColors.black),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        iconColor: const WidgetStatePropertyAll(AppColors.black),
        textStyle: WidgetStateProperty.all(
          const TextStyle(color: AppColors.black, fontFamily: "Satoshi"),
        ),
        foregroundColor: WidgetStateProperty.all(AppColors.black),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: Constants.br12,
      ),
    ),
    primaryColor: AppColors.deepPurple,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightWhite,
    fontFamily: "Satoshi",
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.black,
        fontSize: 26,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        color: AppColors.black,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        color: AppColors.black,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w500,
        color: AppColors.black,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.black,
      ),
      titleSmall: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: AppColors.black,
      ),
      bodyLarge: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 16,
        color: AppColors.black,
      ),
      bodyMedium: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 14.5,
        color: AppColors.black,
      ),
      bodySmall: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 13,
        color: AppColors.black,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        iconColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.white,
        backgroundColor: AppColors.purpleDark,
        shadowColor: Colors.transparent,
        textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            fontFamily: "Satoshi",
            color: AppColors.white),
        shape: RoundedRectangleBorder(borderRadius: Constants.br12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: Constants.br8,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    iconButtonTheme: const IconButtonThemeData(
      style: ButtonStyle(
        iconColor: WidgetStatePropertyAll(AppColors.commonPink),
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.deepPurple,
      secondary: AppColors.goldenYellow,
      brightness: Brightness.dark,
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        iconColor: const WidgetStatePropertyAll(AppColors.white),
        textStyle: WidgetStateProperty.all(
          const TextStyle(color: AppColors.white, fontFamily: "Satoshi"),
        ),
        foregroundColor: WidgetStateProperty.all(AppColors.white),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: Constants.br12,
      ),
    ),
    appBarTheme: const AppBarTheme(backgroundColor: AppColors.indigo),
    iconTheme: const IconThemeData(color: AppColors.white),
    snackBarTheme:
        const SnackBarThemeData(closeIconColor: AppColors.blueGreyDark),
    primaryColor: AppColors.deepPurple,
    scaffoldBackgroundColor: AppColors.darkBg,
    brightness: Brightness.dark,
    fontFamily: "Satoshi",
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.white,
        fontSize: 26,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        color: AppColors.white,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        color: AppColors.white,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
      ),
      titleSmall: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
      ),
      bodyLarge: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 16,
        color: AppColors.white,
      ),
      bodyMedium: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 14.5,
        color: AppColors.white,
      ),
      bodySmall: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 13,
        color: AppColors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        iconColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.black,
        backgroundColor: AppColors.white,
        shadowColor: Colors.transparent,
        textStyle: const TextStyle(
            fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.black),
        shape: RoundedRectangleBorder(borderRadius: Constants.br12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: const TextStyle(
        color: AppColors.black,
      ),
      border: OutlineInputBorder(
        borderRadius: Constants.br8,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    ),
  );
}
