import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class LicenseService {
  static final LicenseService instance = LicenseService._internal();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  final String _secretKey =
      'b7f8e2d1c9a4f6e3b2d7c8a9e1f4b6d2c3a8e7f1b5d9c2a6f3e8b1d4c7a2f9e5';

  factory LicenseService() {
    return instance;
  }

  LicenseService._internal();

  Future<LicenseVerificationResult> verifyLicense(String certificate) async {
    debugPrint("[LicenseService] Starting license verification...");
    try {
      final parts = certificate.split('.');
      if (parts.length != 3) {
        debugPrint(
            "[LicenseService] FAILED: Invalid certificate format (not 3 parts).");
        return LicenseVerificationResult(
            isValid: false, message: 'Invalid certificate format');
      }

      // Verify Signature
      debugPrint("[LicenseService] Verifying signature...");
      final signatureValid = _verifySignature(parts[0], parts[1], parts[2]);
      if (!signatureValid) {
        debugPrint("[LicenseService] FAILED: Invalid certificate signature.");
        return LicenseVerificationResult(
            isValid: false, message: 'Invalid certificate signature');
      }
      debugPrint("[LicenseService] Signature is valid.");

      // Decode Payload
      final payload = json
          .decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      debugPrint("[LicenseService] Decoded Payload: $payload");

      // Check Expiration
      final expirationString = payload['end_date_time'];
      if (expirationString == null) {
        debugPrint("[LicenseService] FAILED: License has no 'end_date_time'.");
        return LicenseVerificationResult(
            isValid: false,
            message: 'Invalid license: missing expiration date');
      }

      final expiration = DateTime.parse(expirationString);
      debugPrint("[LicenseService] License expires at (UTC): $expiration");

      final currentTime = await _getSecureTime();
      debugPrint("[LicenseService] Current time (UTC): $currentTime");

      if (currentTime.isAfter(expiration)) {
        debugPrint("[LicenseService] FAILED: License has expired.");
        return LicenseVerificationResult(
            isValid: false, message: 'License has expired');
      }
      debugPrint("[LicenseService] License is not expired.");

      // If all checks pass
      await _storeLicenseData(payload, expiration.millisecondsSinceEpoch);
      debugPrint("[LicenseService] SUCCESS: License verified and data stored.");
      return LicenseVerificationResult(
        isValid: true,
        message: 'License verified successfully',
      );
    } on Exception catch (e) {
      debugPrint("[LicenseService] FAILED: An unexpected error occurred: $e");
      return LicenseVerificationResult(
          isValid: false, message: 'Error verifying license: $e');
    }
  }

  bool _verifySignature(String header, String payload, String signature) {
    final key = utf8.encode(_secretKey);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(utf8.encode('$header.$payload'));
    final calculatedSignature =
        base64Url.encode(digest.bytes).replaceAll('=', '');
    final receivedSignature = signature.replaceAll('=', '');

    // Added logging for easier debugging
    if (calculatedSignature != receivedSignature) {
      debugPrint("Signature Mismatch:");
      debugPrint("  Calculated: $calculatedSignature");
      debugPrint("  Received:   $receivedSignature");
      return false;
    }
    return true;
  }

  Future<DateTime> _getSecureTime() async {
    try {
      final response = await http
          .get(Uri.parse('https://worldtimeapi.org/api/timezone/Etc/UTC'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return DateTime.parse(body['utc_datetime']);
      }
    } on Exception catch (e) {
      debugPrint(
          '[LicenseService] Failed to get server time, using device time: $e');
    }
    return DateTime.now().toUtc(); // Use UTC for consistent comparison
  }

  Future<void> _storeLicenseData(
      Map<String, dynamic> payload, int expirationTimestamp) async {
    try {
      // Clear old values first
      await _secureStorage.deleteAll();

      // Store new values
      await _secureStorage.write(
          key: 'license_expiration', value: expirationTimestamp.toString());
      if (payload['start_date_time'] != null) {
        await _secureStorage.write(
            key: 'photobooth_start_time', value: payload['start_date_time']);
      }
      if (payload['themes_selected'] != null) {
        await _secureStorage.write(
            key: 'photobooth_themes', value: payload['themes_selected']);
      }
      if (payload['selected_builds'] != null) {
        await _secureStorage.write(
            key: 'photobooth_builds', value: payload['selected_builds']);
      }
      if (payload['photobooth_mode'] != null) {
        await _secureStorage.write(
            key: 'photobooth_mode', value: payload['photobooth_mode']);
      }
      if (payload['issuedAt'] != null) {
        await _secureStorage.write(
            key: 'license_issued_at', value: payload['issuedAt']);
      }

      await _secureStorage.write(key: 'is_authenticated', value: 'true');
    } on Exception catch (e) {
      debugPrint('Error storing license data in secure storage: $e');
    }
  }

  Future<bool> isLicenseValid() async {
    try {
      final isAuthenticatedStr =
          await _secureStorage.read(key: 'is_authenticated');
      if (isAuthenticatedStr != 'true') return false;

      final expirationStr =
          await _secureStorage.read(key: 'license_expiration');
      if (expirationStr == null) return false;

      final expiration = int.parse(expirationStr);
      final expirationDate = DateTime.fromMillisecondsSinceEpoch(expiration);
      final currentTime = await _getSecureTime();

      if (currentTime.isAfter(expirationDate)) {
        await logout();
        return false;
      }

      return true;
    } on Exception catch (e) {
      debugPrint('Error checking license validity: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _secureStorage.deleteAll();
  }
}

class LicenseVerificationResult {
  final bool isValid;
  final String message;

  LicenseVerificationResult({
    required this.isValid,
    required this.message,
  });
}

