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
  Future<String?> uploadImage(File imageFile, String userId,
      {String bucket = 'outputimages', String prefix = 'face_'}) async {
    if (!_isInitialized) {
      throw Exception('Supabase not initialized');
    }

    try {
      // Generate a unique filename
      final fileExt = path.extension(imageFile.path);
      final fileName =
          '$prefix${userId}_${DateTime.now().millisecondsSinceEpoch}$fileExt';

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

  // Upload character image to Supabase
  Future<String?> uploadCharacterImage(
      File imageFile, String characterId) async {
    return uploadImage(imageFile, characterId,
        bucket: 'characters', prefix: 'character_');
  }

  // Store character details in Supabase
  Future<String?> storeCharacterDetails({
    required String characterId,
    required String name,
    String? description,
    String? imageUrl,
  }) async {
    if (!_isInitialized) {
      throw Exception('Supabase not initialized');
    }

    try {
      // Insert data into the 'characters' table
      await _client.from('characters').insert({
        'character_id': characterId, // Use character_id field instead of id
        'name': name,
        'description': description,
        'image_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
      }).select();
      return characterId;
    } on Exception catch (e) {
      debugPrint('Error storing character details: $e');
      return null;
    }
  }

  // Upload user face image to Supabase
  Future<String?> uploadUserFaceImage(File imageFile, String userId) async {
    return uploadImage(imageFile, userId, bucket: 'userfaces', prefix: 'face_');
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

      // Insert data into the 'user_faces' table
      await _client.from('user_faces').insert({
        'user_id': userId,
        'name': name,
        'email': email,
        'contact': contact,
        'gender': gender,
        'character_id': characterId,
        'face_image_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
      }).select();

      return userId;
    } on Exception catch (e) {
      debugPrint('Error storing participant details: $e');
      return null;
    }
  }

  // Get the most recent output image for a user
  Future<String?> getLatestOutputImage(String userId) async {
    if (!_isInitialized) {
      throw Exception('Supabase not initialized');
    }

    try {
      // List files in the outputimages bucket, sorted by creation time
      final response = await _client.storage.from('outputimages').list(
              searchOptions: const SearchOptions(
            sortBy: SortBy(
              column: 'created_at',
              order: 'desc',
            ),
            limit: 1,
          ));

      if (response.isNotEmpty) {
        // Get the public URL of the most recent file
        final fileName = response.first.name;
        debugPrint('Found latest output image: $fileName');
        return _client.storage.from('outputimages').getPublicUrl(fileName);
      }
      
      debugPrint('No output images found in the bucket');
      return null;
    } on Exception catch (e) {
      debugPrint('Error getting latest output image: $e');
      return null;
    }
  }
}
