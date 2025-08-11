import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photobooth_flutter/services/license_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;
  late SupabaseClient _client;
  bool _isInitialized = false;

  // Private constructor
  SupabaseService._();

  // Singleton instance
  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  bool get isInitialized => _isInitialized;

  Future<void> initialize(
      {required String url, required String anonKey}) async {
    if (_isInitialized) return;

    try {
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );

      _client = Supabase.instance.client;
      _isInitialized = true;
      debugPrint('Supabase initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Supabase: $e');
      rethrow;
    }
  }

  // Upload image to Supabase storage
  Future<String?> uploadImageBytes(Uint8List imageBytes, String? userId,
      {String bucket = 'outputimages', String prefix = 'face_', String extension = '.jpg'}) async {
    if (!_isInitialized) {
      throw Exception('Supabase not initialized');
    }

    try {
      final fileName =
          '$prefix${userId ?? DateTime.now().millisecondsSinceEpoch.toString()}_${DateTime.now().millisecondsSinceEpoch}$extension';

      await _client.storage.from(bucket).uploadBinary(
            fileName,
            imageBytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      final imageUrl = _client.storage.from(bucket).getPublicUrl(fileName);
      return imageUrl;
    } on StorageException catch (e) {
      // debugPrint(
      //     'Storage Exception uploading image: ${e.message}, Status: ${e.statusCode}');
      if (e.statusCode == 403 &&
          e.message.contains('row-level security policy')) {
        debugPrint(
            'This is a Row Level Security (RLS) policy error. Check your Supabase bucket permissions.');
      }
      return null;
    } on Exception catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  Future<String?> uploadUserFaceImageFromPath(String imagePath) async {
    try {
      // For web, imagePath is a blob URL or data URL from camera
      // We need to fetch the data from this URL
      final response = await http.get(Uri.parse(imagePath));
      if (response.statusCode == 200) {
        return uploadImageBytes(response.bodyBytes, null, bucket: 'inputimages', prefix: 'face_');
      }
      return null;
    } catch (e) {
      debugPrint('Error uploading user face image: $e');
      return null;
    }
  }

  Future<String?> storeParticipantDetails({
    required String name,
    required String email,
    required String gender,
    String? imageUrl,
  }) async {
    if (!_isInitialized) {
      throw Exception('Supabase not initialized');
    }

    try {
      // Get authenticated user ID and event ID from license service
      final userId = await LicenseService.instance.getUserId();
      final eventId = await LicenseService.instance.getEventId();

      if (userId == null || eventId == null) {
        throw Exception('User not authenticated or event ID not found');
      }

      final result = await _client.from('event_output_images').insert({
        'name': name,
        'email': email,
        'gender': gender,
        'image_url': imageUrl,
        'userId': userId,
        'eventId': eventId,
        'created_at': DateTime.now().toIso8601String(),
      }).select();

      if (result.isNotEmpty && result[0]['unique_id'] != null) {
        return result[0]['unique_id'].toString();
      }
      return null;
    } on Exception catch (e) {
      debugPrint('Error storing participant details: $e');
      return null;
    }
  }

  /// NEW: Selects a random character image from Supabase and updates the table.
  Future<void> selectAndUpdateRandomCharacterImage({
    required String uniqueId,
    required String gender,
    required String themeName,
  }) async {
    if (!_isInitialized) {
      throw Exception('Supabase not initialized');
    }

    try {
      final themeFolderName = themeName.toLowerCase().replaceAll(' ', '_');
      final genderFolder = gender.toLowerCase();
      final characterPrefix = gender.toLowerCase() == 'male' ? 'm' : 'f';
      // Select a random number from 1 to 4
      final randomNumber = Random().nextInt(4) + 1;
      final imageName = '$characterPrefix$randomNumber.png';

      final fullPathInBucket = '$genderFolder/$themeFolderName/$imageName';

      // debugPrint(
      //     'Selecting character image from Supabase path: $fullPathInBucket');

      // Get the public URL of the random character image
      final publicUrl =
          _client.storage.from('themes').getPublicUrl(fullPathInBucket);

      // Update the 'characterimage' column in the table for the user's row
      await _client
          .from('event_output_images')
          .update({'characterimage': publicUrl}).eq('unique_id', uniqueId);

      // debugPrint(
      //     'Successfully updated characterimage for unique_id: $uniqueId');
    } on Exception catch (e) {
      debugPrint('Error updating character image in Supabase: $e');
      rethrow;
    }
  }

  Future<String?> getLatestOutputImage(String participantId,
      {DateTime? afterTime}) async {
    if (!_isInitialized) {
      throw Exception('Supabase not initialized');
    }

    try {
      final response = await _client
          .from('event_output_images')
          .select('output')
          .eq('unique_id', participantId)
          .single();

      if (response.isNotEmpty && response['output'] != null) {
        return response['output'] as String;
      }

      return null;
    } on Exception catch (e) {
      debugPrint('Error getting latest output image: $e');
      return null;
    }
  }

  // Check if license is already activated for the event
  Future<bool> checkLicenseActivation(String eventId) async {
    if (!_isInitialized) {
      throw Exception('Supabase not initialized');
    }

    try {
      final response = await _client
          .from('events')
          .select('is_license_activated')
          .eq('id', eventId)
          .single();

      return response['is_license_activated'] == true;
    } on Exception catch (e) {
      debugPrint('Error checking license activation: $e');
      return false;
    }
  }

  // Activate license for the event
  Future<bool> activateLicense(String eventId) async {
    if (!_isInitialized) {
      throw Exception('Supabase not initialized');
    }

    try {
      await _client
          .from('events')
          .update({'is_license_activated': true}).eq('id', eventId);

      return true;
    } on Exception catch (e) {
      debugPrint('Error activating license: $e');
      return false;
    }
  }

  // Get current credits for the user from credits table
  Future<int?> getUserCreditsLeft(String userId) async {
    if (!_isInitialized) {
      throw Exception('Supabase not initialized');
    }

    try {
      final response = await _client
          .from('user_credits')
          .select('credits_left')
          .eq('user_id', userId)
          .single();

      if (response.isNotEmpty && response['credits_left'] != null) {
        return response['credits_left'] as int;
      }

      return null;
    } on Exception catch (e) {
      debugPrint('Error getting user credits left: $e');
      return null;
    }
  }

  // Decrement credits for the user
  Future<bool> decrementUserCredits(String userId) async {
    if (!_isInitialized) {
      throw Exception('Supabase not initialized');
    }

    try {
      // First get current credits
      final currentCredits = await getUserCreditsLeft(userId);
      if (currentCredits == null || currentCredits <= 0) {
        return false;
      }

      // Decrement by 1
      await _client
          .from('user_credits')
          .update({'credits_left': currentCredits - 1}).eq('user_id', userId);

      return true;
    } on Exception catch (e) {
      debugPrint('Error decrementing user credits: $e');
      return false;
    }
  }
}
