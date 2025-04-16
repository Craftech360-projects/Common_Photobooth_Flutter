import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalSettingsProvider extends ChangeNotifier {
  late SharedPreferences _prefs;

  // Global settings
  Size _selectedResolution = const Size(1920, 1080);
  String? _backgroundImage;
  bool _isAssetImage = true;
  double _fieldSpacing = 20.0;
  double _buttonSpacing = 40.0;
  double _borderRadius = 4.0;

  // Getters
  Size get selectedResolution => _selectedResolution;
  String? get backgroundImage => _backgroundImage;
  String? get backgroundImagePath =>
      _backgroundImage; // Added for consistency with other providers
  bool get isAssetImage => _isAssetImage;
  bool get isBackgroundImageAsset =>
      _isAssetImage; // Added for consistency with other providers
  double get fieldSpacing => _fieldSpacing;
  double get buttonSpacing => _buttonSpacing;
  double get borderRadius => _borderRadius;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await loadSettings();
  }

  // Add these properties
  String? _supabaseUrl;
  String? _supabaseAnonKey;

  // Add these getters
  String? get supabaseUrl => _supabaseUrl;
  String? get supabaseAnonKey => _supabaseAnonKey;

  Future<void> loadSettings() async {
    _selectedResolution = Size(
      _prefs.getDouble('resolution_width') ?? 1920,
      _prefs.getDouble('resolution_height') ?? 1080,
    );

    _backgroundImage = _prefs.getString('background_image');
    _isAssetImage = _prefs.getBool('is_asset_image') ?? true;

    // Verify background image file exists if it's not an asset
    if (_backgroundImage != null && !_isAssetImage) {
      final file = File(_backgroundImage!);
      if (!file.existsSync()) {
        _backgroundImage = null;
        await _prefs.remove('background_image');
      }
    }

    _fieldSpacing = _prefs.getDouble('field_spacing') ?? 20.0;
    _buttonSpacing = _prefs.getDouble('button_spacing') ?? 40.0;
    _borderRadius = _prefs.getDouble('border_radius') ?? 4.0;

    // Load Supabase settings
    _supabaseUrl = _prefs.getString('supabase_url');
    _supabaseAnonKey = _prefs.getString('supabase_anon_key');

    notifyListeners();
  }

  void setResolution(Size size) async {
    _selectedResolution = size;
    await _prefs.setDouble('resolution_width', size.width);
    await _prefs.setDouble('resolution_height', size.height);
    notifyListeners();
  }

  Future<void> setBackgroundImage(String sourcePath,
      {required bool isAsset}) async {
    if (isAsset) {
      // For asset images, just store the path
      _backgroundImage = sourcePath;
      _isAssetImage = true;
    } else {
      // For file images, copy to app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName =
          'global_background_${DateTime.now().millisecondsSinceEpoch}${path.extension(sourcePath)}';
      final destinationPath = path.join(appDir.path, fileName);

      try {
        final sourceFile = File(sourcePath);
        await sourceFile.copy(destinationPath);
        _backgroundImage = destinationPath;
        _isAssetImage = false;
      } on Exception catch (e) {
        debugPrint('Error copying background image: $e');
        return;
      }
    }

    await _prefs.setString('background_image', _backgroundImage!);
    await _prefs.setBool('is_asset_image', _isAssetImage);
    notifyListeners();
  }

  void setFieldSpacing(double spacing) async {
    _fieldSpacing = spacing;
    await _prefs.setDouble('field_spacing', spacing);
    notifyListeners();
  }

  void setButtonSpacing(double spacing) async {
    _buttonSpacing = spacing;
    await _prefs.setDouble('button_spacing', spacing);
    notifyListeners();
  }

  void setBorderRadius(double radius) async {
    _borderRadius = radius;
    await _prefs.setDouble('border_radius', radius);
    notifyListeners();
  }

  // Add these methods
  void setSupabaseUrl(String url) async {
    _supabaseUrl = url;
    await _prefs.setString('supabase_url', url);
    notifyListeners();
  }

  void setSupabaseAnonKey(String key) async {
    _supabaseAnonKey = key;
    await _prefs.setString('supabase_anon_key', key);
    notifyListeners();
  }

  Future<void> clearAllPreferences() async {
    await _prefs.clear();

    // Reset to default values
    _selectedResolution = const Size(1920, 1080);
    _backgroundImage = null;
    _isAssetImage = true;
    _fieldSpacing = 20.0;
    _buttonSpacing = 40.0;
    _borderRadius = 4.0;
    _supabaseUrl = null;
    _supabaseAnonKey = null;

    notifyListeners();
  }
}
