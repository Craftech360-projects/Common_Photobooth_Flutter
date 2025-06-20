import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
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
  Future<String?> uploadImage(File imageFile, String? userId,
      {String bucket = 'outputimages', String prefix = 'face_'}) async {
    if (!_isInitialized) {
      throw Exception('Supabase not initialized');
    }

    try {
      // Generate a unique filename
      final fileExt = path.extension(imageFile.path);
      final fileName =
          '$prefix${userId ?? DateTime.now().millisecondsSinceEpoch.toString()}_${DateTime.now().millisecondsSinceEpoch}$fileExt';

      // Upload to Supabase
      await _client.storage.from(bucket).uploadBinary(
            fileName,
            imageFile.readAsBytesSync(),
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      // Get public URL
      final imageUrl = _client.storage.from(bucket).getPublicUrl(fileName);

      return imageUrl;
    } on StorageException catch (e) {
      debugPrint(
          'Storage Exception uploading image: ${e.message}, Status: ${e.statusCode}');
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

  // Upload user face image to Supabase
  Future<String?> uploadUserFaceImage(File imageFile) async {
    return uploadImage(imageFile, null,
        bucket: 'inputimages', prefix: 'face_');
  }

  // Store participant details in Supabase
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
      final result = await _client.from('inputimagetable').insert({
        'name': name,
        'email': email,
        'gender': gender,
        'image_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
      }).select();

      // Return the UUID from the result
      if (result.isNotEmpty && result[0]['unique_id'] != null) {
        return result[0]['unique_id'].toString();
      }
      return null;
    } on Exception catch (e) {
      debugPrint('Error storing participant details: $e');
      return null;
    }
  }

  // Get the most recent output image for a user
  Future<String?> getLatestOutputImage(String participantId,
      {DateTime? afterTime}) async {
    if (!_isInitialized) {
      throw Exception('Supabase not initialized');
    }

    try {
      final response = await _client
          .from('inputimagetable')
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
}