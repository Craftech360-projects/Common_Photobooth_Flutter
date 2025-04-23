import 'package:flutter/material.dart';
import 'package:photobooth_flutter/services/auth_service.dart';
import 'package:photobooth_flutter/services/license_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

    void setError(String? errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      // First check online authentication
      _isAuthenticated = await AuthService.instance.isAuthenticated();

      // If not authenticated online, check license
      if (!_isAuthenticated) {
        _isAuthenticated = await LicenseService.instance.isLicenseValid();
      }
    } on Exception catch (e) {
      _error = 'Failed to check authentication status: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Existing online verification method
  Future<bool> verifyAuthCode({
    required String eventId,
    required String authCode,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AuthService.instance.verifyAuthCode(
        eventId: eventId,
        authCode: authCode,
      );

      if (response.success) {
        _isAuthenticated = true;
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

  // New method for license verification
  Future<bool> verifyLicense(String certificate) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await LicenseService.instance.verifyLicense(certificate);

      if (result.isValid) {
        _isAuthenticated = true;
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
      await AuthService.instance.logout();
      await LicenseService.instance.logout();
      _isAuthenticated = false;
    } on Exception catch (e) {
      _error = 'Failed to logout: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
