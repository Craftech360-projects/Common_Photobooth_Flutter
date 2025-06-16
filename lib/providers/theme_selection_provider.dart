import 'package:flutter/material.dart';

class Theme {
  final String name;
  final String imagePath;

  Theme({required this.name, required this.imagePath});
}

class ThemeSelectionProvider extends ChangeNotifier {
  final List<Theme> _themes = [
    Theme(
        name: 'Stranger Things',
        imagePath: 'assets/characters/stranger_things.png'),
    Theme(
        name: 'Jurassic Rebirth',
        imagePath: 'assets/characters/jurassic_rebirth.png'),
    Theme(
        name: 'Final Destination',
        imagePath: 'assets/characters/final_destination.png'),
    Theme(name: 'Superheroes', imagePath: 'assets/characters/superheroes.png'),
    Theme(
        name: 'Supervillains',
        imagePath: 'assets/characters/supervillains.png'),
  ];

  Theme? _selectedTheme;

  List<Theme> get themes => _themes;
  Theme? get selectedTheme => _selectedTheme;

  void selectTheme(Theme theme) {
    _selectedTheme = theme;
    notifyListeners();
  }
}
