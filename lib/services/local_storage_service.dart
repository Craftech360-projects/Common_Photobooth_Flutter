import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class LocalStorageService {
  static LocalStorageService? _instance;
  final String _inputDirectory;
  final String _outputDirectory;
  bool _isInitialized = false;

  // Private constructor
  LocalStorageService._(
      {required String inputDirectory, required String outputDirectory})
      : _inputDirectory = inputDirectory,
        _outputDirectory = outputDirectory;

  // Singleton instance
  static LocalStorageService get instance {
    if (_instance == null) {
      throw Exception('LocalStorageService not initialized');
    }
    return _instance!;
  }

  // Initialize the service
  static Future<void> initialize({
    required String inputDirectory,
    required String outputDirectory,
  }) async {
    try {
      // Create directories if they don't exist
      final inputDir = Directory(inputDirectory);
      final outputDir = Directory(outputDirectory);


      if (!await inputDir.exists()) {
        await inputDir.create(recursive: true);
      }

      if (!await outputDir.exists()) {
        await outputDir.create(recursive: true);
      }

      _instance = LocalStorageService._(
        inputDirectory: inputDirectory,
        outputDirectory: outputDirectory,
      );

      _instance!._isInitialized = true;
      debugPrint('LocalStorageService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing LocalStorageService: $e');
      rethrow;
    }
  }

  // Check if the service is initialized
  bool get isInitialized => _isInitialized;
  
  // Add a static method to check if the service is initialized
  static bool get isServiceInitialized => _instance != null;
  
  // Save face image to input directory
  Future<String> saveFaceImage(File imageFile) async {
    if (!_isInitialized) {
      throw Exception('LocalStorageService not initialized');
    }

    try {
      // Generate a unique filename with input_ prefix
      final fileExt = path.extension(imageFile.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final fileName = 'input_$timestamp$fileExt';
      final destinationPath = path.join(_inputDirectory, fileName);

      // Copy the file to the input directory
      await imageFile.copy(destinationPath);

      // MODIFIED: Return the relative path for the API
      return 'input/$fileName';
    } catch (e) {
      debugPrint('Error saving face image: $e');
      rethrow;
    }
  }

  // Get the output directory path with output_ prefix
  String getOutputPathPrefix() {
    if (!_isInitialized) {
      throw Exception('LocalStorageService not initialized');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    // MODIFIED: Return the relative path for the API
    return 'output/output_$timestamp.png';
  }

  // Check for new output image
  Future<String?> getLatestOutputImage(String prefix,
      {DateTime? afterTime}) async {
    if (!_isInitialized) {
      throw Exception('LocalStorageService not initialized');
    }

    try {
      
      final outputDir = Directory(_outputDirectory);
      if (!await outputDir.exists()) {
        return null;
      }
      
      final files = await outputDir.list().toList();
  
      // Filter files by prefix and creation time
      final matchingFiles = files.whereType<File>().where((file) {
        final fileName = path.basename(file.path);
        final fileCreationTime = file.statSync().modified;
        
        final matches = fileName.startsWith(prefix) &&
            (afterTime == null || fileCreationTime.isAfter(afterTime));
        
        return matches;
      }).toList();
  
  
      // Sort by creation time (newest first)
      matchingFiles.sort((a, b) {
        return b.statSync().modified.compareTo(a.statSync().modified);
      });
  
      // Return the path of the newest file if any
      if (matchingFiles.isNotEmpty) {
        return matchingFiles.first.path;
      }
  
      return null;
    } on Exception {
      return null;
    }
  }
}