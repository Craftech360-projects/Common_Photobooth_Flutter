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
  Future<String?> uploadUserFaceImage(File imageFile) async {
    return uploadImage(imageFile, null, bucket: 'input-images', prefix: 'face_');
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
      final result = await _client.from('inputimagetable').insert({
        'name': name,
        'email': email,
        'contact': contact,
        'gender': gender,
        'character_id': characterId,
        'image_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
      }).select();

      // Return the UUID from the result
      if (result.isNotEmpty && result[0]['id'] != null) {
        return result[0]['id'].toString();
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
      // List files from the 'outputimages' bucket without server-side sorting
      final fileList = await _client.storage.from('outputimages').list();

      if (fileList.isEmpty) {
        debugPrint('No images found in the outputimages bucket');
        return null;
      }

      // Sort the list manually in Dart based on createdAt (most recent first)
      fileList.sort((a, b) {
        final aDate =
            a.createdAt != null ? DateTime.tryParse(a.createdAt!) : null;
        final bDate =
            b.createdAt != null ? DateTime.tryParse(b.createdAt!) : null;

        if (bDate == null) return -1; // Treat nulls as older
        if (aDate == null) return 1; // Treat nulls as older
        return bDate.compareTo(aDate); // Compare actual dates (descending)
      });

      List<FileObject> filesToConsider = fileList;

      // Filter by time if needed
      if (afterTime != null) {
        filesToConsider = fileList.where((file) {
          final fileDate = file.createdAt != null
              ? DateTime.tryParse(file.createdAt!)
              : null;
          // Keep the file if its date is not null and is after the specified time
          return fileDate != null && fileDate.isAfter(afterTime);
        }).toList();

        if (filesToConsider.isEmpty) {
          debugPrint('No images found after: ${afterTime.toIso8601String()}');
          return null;
        }
      }

      // Get the most recent file from the (potentially filtered) list
      final latestFile = filesToConsider.first;
      debugPrint(
          'Found image: ${latestFile.name}, created at: ${latestFile.createdAt}');

      // Get public URL for the file
      final imageUrl =
          _client.storage.from('outputimages').getPublicUrl(latestFile.name);
      return imageUrl;
    } on Exception catch (e) {
      debugPrint('Error getting latest output image: $e');
      return null;
    }
  }
}
