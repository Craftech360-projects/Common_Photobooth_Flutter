import 'package:flutter/material.dart';
import 'package:photobooth_flutter/providers/admin_watermark_provider.dart';
import 'package:photobooth_flutter/services/auth_service.dart';
import 'package:photobooth_flutter/services/license_service.dart';
import 'package:provider/provider.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  BuildContext? _context;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  // Set context for accessing other providers
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
      // First check online authentication
      _isAuthenticated = AuthService.instance.isAuthenticated;

      // If not authenticated online, check license
      if (!_isAuthenticated) {
        _isAuthenticated = await LicenseService.instance.isLicenseValid();
      }

      // Update watermark visibility based on authentication status
      _updateWatermarkVisibility();
    } on Exception catch (e) {
      _error = 'Failed to check authentication status: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Existing online verification method
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
        // Fetch service details after successful authentication
        final serviceDetails = await AuthService.instance.fetchServiceDetails(requestId);
        
        if (serviceDetails != null) {
          // Store service details in LicenseService
          await LicenseService.instance.storeServiceDetails(serviceDetails);
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

  // New method for license verification
  Future<bool> verifyLicense(String certificate) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await LicenseService.instance.verifyLicense(certificate);

      if (result.isValid) {
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
      await AuthService.instance.logout();
      await LicenseService.instance.logout();
      _isAuthenticated = false;
      _updateWatermarkVisibility();
    } on Exception catch (e) {
      _error = 'Failed to logout: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to update watermark visibility
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
