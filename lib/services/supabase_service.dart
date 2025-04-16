import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
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
  Future<String?> uploadImage(File imageFile, String userId) async {
    if (!_isInitialized) {
      throw Exception('Supabase not initialized');
    }

    try {
      // Compress the image
      final compressedImage = await _compressImage(imageFile);
      if (compressedImage == null) {
        throw Exception('Failed to compress image');
      }

      // Generate a unique filename
      final fileExt = path.extension(imageFile.path);
      final fileName =
          'face_$userId${DateTime.now().millisecondsSinceEpoch}$fileExt';

      // Upload to Supabase
      final response = await _client.storage.from('faces').uploadBinary(
            fileName,
            compressedImage,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      // Get public URL
      final imageUrl = _client.storage.from('faces').getPublicUrl(fileName);
      debugPrint('Image uploaded successfully: $imageUrl');

      return imageUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  // Store participant details in Supabase
  Future<String?> storeParticipantDetails({
    required String name,
    required String email,
    String? contact,
    required String gender,
    String? characterId,
    String? imageUrl,
  }) async {
    if (!_isInitialized) {
      throw Exception('Supabase not initialized');
    }

    try {
      // Create a unique ID for the participant
      final userId = DateTime.now().millisecondsSinceEpoch.toString();

      // Debug log to verify data before insertion
      debugPrint(
          'Storing participant details - Name: $name, Email: $email, Gender: $gender, CharacterId: $characterId');

      // Insert data into the 'users' table
      final response = await _client.from('users').insert({
        'id': userId,
        'name': name,
        'email': email,
        'contact': contact,
        'gender': gender,
        'character_id': characterId,
        'image_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
      }).select();

      debugPrint('Participant details stored successfully: $response');
      return userId;
    } catch (e) {
      debugPrint('Error storing participant details: $e');
      return null;
    }
  }

  // Compress image to reduce file size
  Future<Uint8List?> _compressImage(File file) async {
    try {
      // Read the file
      final bytes = await file.readAsBytes();

      // Decode the image
      final image = img.decodeImage(bytes);
      if (image == null) return null;

      // Resize the image to reduce size while maintaining aspect ratio
      final resized = img.copyResize(
        image,
        width: 800, // Adjust width as needed
        interpolation: img.Interpolation.linear,
      );

      // Encode as JPEG with quality setting
      return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return null;
    }
  }
}
