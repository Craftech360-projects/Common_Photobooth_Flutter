import 'package:flutter/material.dart';
import 'package:photobooth_flutter/providers/admin_watermark_provider.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/services/auth_service.dart';
import 'package:photobooth_flutter/services/license_service.dart';
import 'package:photobooth_flutter/services/supabase_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = true;
  BuildContext? _context;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  void setContext(BuildContext context) {
    _context = context;
  }

  void setError(String? errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isAuthenticated = await LicenseService.instance.isLicenseValid();
      _updateWatermarkVisibility();
    } on Exception catch (e) {
      _error = 'Failed to check authentication status: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyAuthCode(
      {required String requestId, required String authCode}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AuthService.instance.verifyAuthCode(
        requestId: requestId,
        authCode: authCode,
      );

      if (response.success) {
        final serviceDetails =
            await AuthService.instance.fetchServiceDetails(requestId);
        if (serviceDetails != null) {
          // await LicenseService.instance.storeServiceDetails(serviceDetails);       < = = = = = = = = = = = = = = = 
          _isAuthenticated = true;
          _updateWatermarkVisibility();
        } else {
          _error = 'Failed to fetch service details';
          return false;
        }
      } else {
        _error = response.message ?? 'Authentication failed';
      }
      return response.success;
    } on Exception catch (e) {
      _error = 'Error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyLicense(String certificate) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await LicenseService.instance.verifyLicense(certificate);

      if (result.isValid && result.eventId != null) {
        // Initialize Supabase if needed
        if (_context != null) {
          final globalSettings = Provider.of<GlobalSettingsProvider>(
            _context!,
            listen: false,
          );
          
          if (!SupabaseService.instance.isInitialized) {
            await SupabaseService.instance.initialize(
              url: globalSettings.supabaseUrl!,
              anonKey: globalSettings.supabaseAnonKey!,
            );
          }
        }

        // Check if license is already activated
        final isAlreadyActivated = await SupabaseService.instance
            .checkLicenseActivation(result.eventId!);
        
        if (isAlreadyActivated) {
          _error = 'This license has already been used';
          return false;
        }

        // Activate the license
        final activated = await SupabaseService.instance
            .activateLicense(result.eventId!);
        
        if (!activated) {
          _error = 'Failed to activate license';
          return false;
        }

        _isAuthenticated = true;
        _updateWatermarkVisibility();
      } else {
        _error = result.message;
      }
      return result.isValid;
    } on Exception catch (e) {
      _error = 'Error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await LicenseService.instance.logout();
      _isAuthenticated = false;
      _updateWatermarkVisibility();

      // Clear the selected workflow on logout
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('selected_workflow');
    } on Exception catch (e) {
      _error = 'Failed to logout: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateWatermarkVisibility() {
    if (_context != null) {
      try {
        final watermarkProvider = Provider.of<AdminWatermarkProvider>(
          _context!,
          listen: false,
        );
        watermarkProvider.setShowWatermark(!_isAuthenticated);
      } on Exception catch (e) {
        debugPrint('Error updating watermark visibility: $e');
      }
    }
  }
}