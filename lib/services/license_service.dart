import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LicenseService {
  static final LicenseService instance = LicenseService._internal();
  late final FlutterSecureStorage _secureStorage;
  bool _useSecureStorage = true;

  // This key should be embedded in your app and kept secret
  // In a production app, you'd use more sophisticated key protection
  final String _secretKey = 'photobooth_license_secret_key_2025';

  factory LicenseService() {
    return instance;
  }

  LicenseService._internal() {
    _initSecureStorage();
  }

  void _initSecureStorage() {
    try {
      _secureStorage = const FlutterSecureStorage();
    } on Exception catch (e) {
      debugPrint('Failed to initialize secure storage: $e');
      _useSecureStorage = false;
    }
  }

  Future<void> storeServiceDetails(Map<String, dynamic> serviceDetails) async {
    try {
      if (_useSecureStorage) {
        // Store in secure storage
        if (serviceDetails['userId'] != null) {
          await _secureStorage.write(
              key: 'license_user_id', value: serviceDetails['userId']);
        }

        if (serviceDetails['serviceId'] != null) {
          await _secureStorage.write(
              key: 'license_service_id', value: serviceDetails['serviceId']);
        }

        if (serviceDetails['licenseSecurityKey'] != null) {
          await _secureStorage.write(
              key: 'license_security_key',
              value: serviceDetails['licenseSecurityKey']);
        }

        // Store expiration date if available
        if (serviceDetails['licenseEndDateTime'] != null) {
          final expirationTimestamp =
              DateTime.parse(serviceDetails['licenseEndDateTime'])
                  .millisecondsSinceEpoch;
          await _secureStorage.write(
            key: 'license_expiration',
            value: expirationTimestamp.toString(),
          );
        }

        // Store requestId
        if (serviceDetails['requestId'] != null) {
          await _secureStorage.write(
              key: 'license_request_id', value: serviceDetails['requestId']);
        }

        // Store deviceId
        if (serviceDetails['deviceId'] != null) {
          await _secureStorage.write(
              key: 'license_device_id', value: serviceDetails['deviceId']);
        }

        // Store startDateTime
        if (serviceDetails['startDateTime'] != null) {
          await _secureStorage.write(
              key: 'license_start_date',
              value: serviceDetails['startDateTime']);
        }

        // Store issuedAt
        if (serviceDetails['licenseIssuedAt'] != null) {
          await _secureStorage.write(
              key: 'license_issued_at',
              value: serviceDetails['licenseIssuedAt']);
        }

        // Store last verification time
        await _secureStorage.write(
          key: 'last_verification_time',
          value: DateTime.now().millisecondsSinceEpoch.toString(),
        );
      }

      // Also store authentication flag in regular preferences for quick access
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_authenticated', true);

      if (serviceDetails['serviceId'] != null) {
        await prefs.setString(
            'authenticated_service_id', serviceDetails['serviceId']);
      }

      if (serviceDetails['licenseEndDateTime'] != null) {
        final expirationTimestamp =
            DateTime.parse(serviceDetails['licenseEndDateTime'])
                .millisecondsSinceEpoch;
        await prefs.setString(
            'license_expiration', expirationTimestamp.toString());
      }
    } on Exception catch (e) {
      debugPrint('Error storing service details: $e');
      // Fall back to just storing in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_authenticated', true);

      if (serviceDetails['serviceId'] != null) {
        await prefs.setString(
            'authenticated_service_id', serviceDetails['serviceId']);
      }
    }
  }

  // Verify a license certificate
  Future<LicenseVerificationResult> verifyLicense(String certificate) async {
    try {
      // Split the JWT parts
      final parts = certificate.split('.');
      if (parts.length != 3) {
        return LicenseVerificationResult(
          isValid: false,
          message: 'Invalid certificate format',
        );
      }

      // Decode the payload
      final payload = json
          .decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));

      // Verify signature
      final signatureValid = _verifySignature(parts[0], parts[1], parts[2]);
      if (!signatureValid) {
        return LicenseVerificationResult(
          isValid: false,
          message: 'Invalid certificate signature',
        );
      }

      // Check expiration - use endDateTime instead of exp
      final expiration = payload['exp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000)
          : payload['endDateTime'] != null
              ? DateTime.parse(payload['endDateTime'])
              : null;

      if (expiration == null) {
        return LicenseVerificationResult(
          isValid: false,
          message: 'Invalid license: missing expiration date',
        );
      }

      // Get server time if possible to prevent time manipulation
      final currentTime = await _getSecureTime();

      if (currentTime.isAfter(expiration)) {
        return LicenseVerificationResult(
          isValid: false,
          message: 'License has expired',
        );
      }

      // Store license data securely
      await _storeLicenseData(
        payload,
        expiration.millisecondsSinceEpoch,
      );

      return LicenseVerificationResult(
        isValid: true,
        message: 'License verified successfully',
        userId: payload['userId'],
        eventId: payload['serviceId'], // Use serviceId instead of eventId
        expirationDate: expiration,
      );
    } on Exception catch (e) {
      debugPrint('License verification error: $e');
      return LicenseVerificationResult(
        isValid: false,
        message: 'Error verifying license: $e',
      );
    }
  }

  // Store license data securely
  Future<void> _storeLicenseData(
    Map<String, dynamic> payload,
    int expirationTimestamp,
  ) async {
    try {
      if (_useSecureStorage) {
        // Store in secure storage
        await _secureStorage.write(
            key: 'license_user_id', value: payload['userId']);
        await _secureStorage.write(
            key: 'license_service_id', value: payload['serviceId']);
        await _secureStorage.write(
            key: 'license_security_key', value: payload['securityKey']);
        await _secureStorage.write(
          key: 'license_expiration',
          value: expirationTimestamp.toString(),
        );

        // Store requestId instead of eventId
        if (payload['requestId'] != null) {
          await _secureStorage.write(
              key: 'license_request_id', value: payload['requestId']);
        }

        // Store deviceId as a new field
        if (payload['deviceId'] != null) {
          await _secureStorage.write(
              key: 'license_device_id', value: payload['deviceId']);
        }

        // Store startDateTime if available
        if (payload['startDateTime'] != null) {
          await _secureStorage.write(
              key: 'license_start_date', value: payload['startDateTime']);
        }

        // Store issuedAt if available
        if (payload['issuedAt'] != null) {
          await _secureStorage.write(
              key: 'license_issued_at', value: payload['issuedAt']);
        }

        // Store last verification time
        await _secureStorage.write(
          key: 'last_verification_time',
          value: DateTime.now().millisecondsSinceEpoch.toString(),
        );
      }

      // Also store authentication flag in regular preferences for quick access
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_authenticated', true);
      await prefs.setString('authenticated_service_id', payload['serviceId']);
    } on Exception catch (e) {
      debugPrint('Error storing license data: $e');
      // Fall back to just storing in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_authenticated', true);
      await prefs.setString('authenticated_service_id', payload['serviceId']);
      await prefs.setString(
          'license_expiration', expirationTimestamp.toString());
    }
  }

  // Verify the JWT signature
  bool _verifySignature(String header, String payload, String signature) {
    final key = utf8.encode(_secretKey);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(utf8.encode('$header.$payload'));
    final calculatedSignature = base64Url.encode(digest.bytes);

    // Remove padding for comparison
    return calculatedSignature.replaceAll('=', '') == signature;
  }

  // Check if license is still valid
  Future<bool> isLicenseValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isAuthenticated = prefs.getBool('is_authenticated') ?? false;

      if (!isAuthenticated) return false;

      // Get expiration timestamp from secure storage
      final expirationStr =
          await _secureStorage.read(key: 'license_expiration');
      if (expirationStr == null) return false;

      final expiration = int.parse(expirationStr);
      final expirationDate = DateTime.fromMillisecondsSinceEpoch(expiration);

      // Get current time, preferably from a secure source
      final currentTime = await _getSecureTime();

      // Check if license has expired
      if (currentTime.isAfter(expirationDate)) {
        // License expired, clear authentication
        await logout();
        return false;
      }

      // Periodically verify with server if possible
      await _performPeriodicServerCheck();

      return true;
    } on Exception catch (e) {
      debugPrint('Error checking license validity: $e');
      return false;
    }
  }

  // Try to get time from a time server to prevent manipulation
  Future<DateTime> _getSecureTime() async {
    try {
      // Try to get time from a time server
      final response = await http
          .head(Uri.parse('https://google.com'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final serverTime = response.headers['date'];
        if (serverTime != null) {
          return HttpDate.parse(serverTime);
        }
      }
    } on Exception catch (e) {
      debugPrint('Failed to get server time: $e');
    }

    // Fall back to device time if server time is unavailable
    return DateTime.now();
  }

  // Periodically check with server to validate license
  Future<void> _performPeriodicServerCheck() async {
    try {
      final lastVerificationStr = await _secureStorage.read(
        key: 'last_verification_time',
      );

      if (lastVerificationStr == null) return;

      final lastVerification = int.parse(lastVerificationStr);
      final lastVerificationTime =
          DateTime.fromMillisecondsSinceEpoch(lastVerification);

      // If it's been more than 7 days since last online verification
      if (DateTime.now().difference(lastVerificationTime).inDays > 7) {
        // Try to verify with server if online
        final eventId = await _secureStorage.read(key: 'license_event_id');
        final securityKey =
            await _secureStorage.read(key: 'license_security_key');

        if (eventId != null && securityKey != null) {
          // Attempt to verify with server
          // This would call your API endpoint
          // If verification fails, you might want to set a grace period
          // before disabling the app
        }
      }
    } on Exception catch (e) {
      debugPrint('Error in periodic server check: $e');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authenticated_service_id');
    await prefs.setBool('is_authenticated', false);

    // Clear secure storage
    await _secureStorage.delete(key: 'license_user_id');
    await _secureStorage.delete(key: 'license_request_id');
    await _secureStorage.delete(key: 'license_service_id');
    await _secureStorage.delete(key: 'license_device_id');
    await _secureStorage.delete(key: 'license_start_date');
    await _secureStorage.delete(key: 'license_security_key');
    await _secureStorage.delete(key: 'license_expiration');
    await _secureStorage.delete(key: 'license_issued_at');
    await _secureStorage.delete(key: 'last_verification_time');
  }
}

class LicenseVerificationResult {
  final bool isValid;
  final String message;
  final String? userId;
  final String? eventId;
  final DateTime? expirationDate;

  LicenseVerificationResult({
    required this.isValid,
    required this.message,
    this.userId,
    this.eventId,
    this.expirationDate,
  });
}
