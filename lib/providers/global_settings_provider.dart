import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalSettingsProvider with ChangeNotifier {
  late SharedPreferences _prefs;

  String? _comfyApiUrl;
  String? get comfyApiUrl => _comfyApiUrl;

  String? _inputDirectory;
  String? _outputDirectory;
  String? get inputDirectory => _inputDirectory;
  String? get outputDirectory => _outputDirectory;

  String? _backgroundImage;
  bool _isAssetImage = true;
  String? get backgroundImage => _backgroundImage;
  bool get isAssetImage => _isAssetImage;
  
  String? _supabaseUrl;
  String? _supabaseAnonKey;
  String? get supabaseUrl => _supabaseUrl;
  String? get supabaseAnonKey => _supabaseAnonKey;


  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await loadSettings();
  }

  Future<void> loadSettings() async {
    _backgroundImage = _prefs.getString('background_image');
    _isAssetImage = _prefs.getBool('is_asset_image') ?? true;

    if (_backgroundImage != null && !_isAssetImage) {
      final file = File(_backgroundImage!);
      if (!await file.exists()) {
        _backgroundImage = null;
        await _prefs.remove('background_image');
      }
    }

    _supabaseUrl = _prefs.getString('supabase_url') ?? 'https://your-project-url.supabase.co';
    _supabaseAnonKey = _prefs.getString('supabase_anon_key') ?? 'your-supabase-anon-key';
    _comfyApiUrl = _prefs.getString('comfy_api_url') ?? 'http://127.0.0.1:8188';

    _inputDirectory = _prefs.getString('input_directory') ?? "C:\\storage\\input";
    _outputDirectory = _prefs.getString('output_directory') ?? "C:\\storage\\output";
    
    await _initializeOfflineDirectories(); // Ensure directories exist

    notifyListeners();
  }

  Future<void> _initializeOfflineDirectories() async {
    final inputDir = Directory(_inputDirectory!);
    final outputDir = Directory(_outputDirectory!);
    if (!await inputDir.exists()) await inputDir.create(recursive: true);
    if (!await outputDir.exists()) await outputDir.create(recursive: true);
  }

  Future<void> setBackgroundImage(String sourcePath, {required bool isAsset}) async {
    if (isAsset) {
      _backgroundImage = sourcePath;
      _isAssetImage = true;
    } else {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'global_background_${DateTime.now().millisecondsSinceEpoch}${path.extension(sourcePath)}';
      final destinationPath = path.join(appDir.path, fileName);
      try {
        await File(sourcePath).copy(destinationPath);
        _backgroundImage = destinationPath;
        _isAssetImage = false;
      } catch (e) {
        debugPrint('Error copying background image: $e');
        return;
      }
    }
    await _prefs.setString('background_image', _backgroundImage!);
    await _prefs.setBool('is_asset_image', _isAssetImage);
    notifyListeners();
  }

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
  
  void setComfyApiUrl(String url) async {
    _comfyApiUrl = url;
    await _prefs.setString('comfy_api_url', url);
    notifyListeners();
  }

  Future<void> clearAllPreferences() async {
    await _prefs.clear();
    _backgroundImage = null;
    _isAssetImage = true;
    _supabaseUrl = null;
    _supabaseAnonKey = null;
    _inputDirectory = null;
    _outputDirectory = null;
    await loadSettings(); // Reload defaults
    notifyListeners();
  }
}