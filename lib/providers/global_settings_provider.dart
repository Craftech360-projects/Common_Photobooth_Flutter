import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalSettingsProvider with ChangeNotifier {
  late SharedPreferences _prefs;

  // Add ComfyAPI URL
  String? _comfyApiUrl;
  String? get comfyApiUrl => _comfyApiUrl;

  // Sharing settings
  String _sharingMethod = 'QR Code';
  String get sharingMethod => _sharingMethod;

  // Add offline mode toggle
  bool _isOfflineMode = false;
  bool get isOfflineMode => _isOfflineMode;

  // Add input/output directories for offline mode
  String? _inputDirectory;
  String? _outputDirectory;
  String? get inputDirectory => _inputDirectory;
  String? get outputDirectory => _outputDirectory;

  // Global settings
  String? _backgroundImage;
  bool _isAssetImage = true;
  double _fieldSpacing = 20.0;
  double _buttonSpacing = 40.0;
  double _borderRadius = 4.0;

  // Getters
  String? get backgroundImage => _backgroundImage;
  String? get backgroundImagePath => _backgroundImage;
  bool get isAssetImage => _isAssetImage;
  bool get isBackgroundImageAsset => _isAssetImage;
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
  String? _emailJsServiceId;
  String? _emailJsTemplateId;
  String? _emailJsPublicKey;
  String? _emailJsPrivateKey;

  // Add these getters
  String? get supabaseUrl => _supabaseUrl;
  String? get supabaseAnonKey => _supabaseAnonKey;
  String? get emailJsServiceId => _emailJsServiceId;
  String? get emailJsTemplateId => _emailJsTemplateId;
  String? get emailJsPublicKey => _emailJsPublicKey;
  String? get emailJsPrivateKey => _emailJsPrivateKey;

  Future<void> loadSettings() async {
    _backgroundImage = _prefs.getString('background_image');
    _isAssetImage = _prefs.getBool('is_asset_image') ?? true;

    _sharingMethod = _prefs.getString('sharing_method') ?? 'QR Code';

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

    // Load EmailJS settings
    _emailJsServiceId = _prefs.getString('emailjs_service_id');
    _emailJsTemplateId = _prefs.getString('emailjs_template_id');
    _emailJsPublicKey = _prefs.getString('emailjs_public_key');
    _emailJsPrivateKey = _prefs.getString('emailjs_private_key');

    // Load ComfyAPI settings
    _comfyApiUrl = _prefs.getString('comfy_api_url') ?? 'http://127.0.0.1:8188';

    // Load offline mode settings
    _isOfflineMode = _prefs.getBool('is_offline_mode') ?? false;
    _inputDirectory = _prefs.getString('input_directory');
    _outputDirectory = _prefs.getString('output_directory');

    // Initialize directories if in offline mode and directories not set
    if (_isOfflineMode &&
        (_inputDirectory == null || _outputDirectory == null)) {
      await _initializeOfflineDirectories();
    }

    notifyListeners();
  }

  // Initialize default directories for offline mode
  Future<void> _initializeOfflineDirectories() async {
    // Set fixed paths for input and output directories
    _inputDirectory = "C:\\storage\\input";
    _outputDirectory = "C:\\storage\\output";

    // Create directories if they don't exist
    final inputDir = Directory(_inputDirectory!);
    final outputDir = Directory(_outputDirectory!);

    if (!await inputDir.exists()) {
      await inputDir.create(recursive: true);
    }

    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }

    // Save to preferences
    await _prefs.setString('input_directory', _inputDirectory!);
    await _prefs.setString('output_directory', _outputDirectory!);
  }

  void setSharingMethod(String method) async {
    _sharingMethod = method;
    await _prefs.setString('sharing_method', method);
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

  void setEmailJsServiceId(String serviceId) async {
    _emailJsServiceId = serviceId;
    await _prefs.setString('emailjs_service_id', serviceId);
    notifyListeners();
  }

  void setEmailJsTemplateId(String templateId) async {
    _emailJsTemplateId = templateId;
    await _prefs.setString('emailjs_template_id', templateId);
    notifyListeners();
  }

  void setEmailJsPublicKey(String publicKey) async {
    _emailJsPublicKey = publicKey;
    await _prefs.setString('emailjs_public_key', publicKey);
    notifyListeners();
  }

  void setEmailJsPrivateKey(String privateKey) async {
    _emailJsPrivateKey = privateKey;
    await _prefs.setString('emailjs_private_key', privateKey);
    notifyListeners();
  }

  void setComfyApiUrl(String url) async {
    _comfyApiUrl = url;
    await _prefs.setString('comfy_api_url', url);
    notifyListeners();
  }

  Future<void> setOfflineMode(bool isOffline) async {
    _isOfflineMode = isOffline;
    await _prefs.setBool('is_offline_mode', isOffline);
    if (isOffline) {
      await _initializeOfflineDirectories();
    }

    notifyListeners();
  }

  Future<void> clearAllPreferences() async {
    await _prefs.clear();
    _backgroundImage = null;
    _isAssetImage = true;
    _fieldSpacing = 20.0;
    _buttonSpacing = 40.0;
    _borderRadius = 4.0;
    _supabaseUrl = null;
    _supabaseAnonKey = null;
    _emailJsServiceId = null;
    _emailJsTemplateId = null;
    _emailJsPublicKey = null;
    _emailJsPrivateKey = null;
    _isOfflineMode = false;
    _inputDirectory = null;
    _outputDirectory = null;
    notifyListeners();
  }
}