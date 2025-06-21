import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class LocalStorageService {
  static LocalStorageService? _instance;
  final String _inputDirectory;
  final String _outputDirectory;
  bool _isInitialized = false;

  LocalStorageService._(
      {required String inputDirectory, required String outputDirectory})
      : _inputDirectory = inputDirectory,
        _outputDirectory = outputDirectory;

  static LocalStorageService get instance {
    if (_instance == null) {
      throw Exception('LocalStorageService not initialized');
    }
    return _instance!;
  }

  static Future<void> initialize({
    required String inputDirectory,
    required String outputDirectory,
  }) async {
    try {
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

  static bool get isServiceInitialized => _instance?._isInitialized ?? false;

  Future<String> saveFaceImage(File imageFile) async {
    if (!_isInitialized) throw Exception('LocalStorageService not initialized');
    try {
      final fileExt = path.extension(imageFile.path);
      final fileName = 'input_${DateTime.now().millisecondsSinceEpoch}$fileExt';
      final destinationPath = path.join(_inputDirectory, fileName);
      await imageFile.copy(destinationPath);
      return destinationPath;
    } catch (e) {
      debugPrint('Error saving face image: $e');
      rethrow;
    }
  }

  String getOutputPathWithPrefix() {
    if (!_isInitialized) throw Exception('LocalStorageService not initialized');
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return path.join(_outputDirectory, 'output_$timestamp.png');
  }

  Future<String?> getLatestOutputImage(String prefix, {DateTime? afterTime}) async {
    if (!_isInitialized) throw Exception('LocalStorageService not initialized');
    try {
      final outputDir = Directory(_outputDirectory);
      if (!await outputDir.exists()) return null;
      
      final files = await outputDir.list().toList();
      final matchingFiles = files.whereType<File>().where((file) {
        final fileName = path.basename(file.path);
        final fileCreationTime = file.statSync().modified;
        return fileName.startsWith(path.basename(prefix)) &&
            (afterTime == null || fileCreationTime.isAfter(afterTime));
      }).toList();

      if (matchingFiles.isEmpty) return null;

      matchingFiles.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      final newestFile = matchingFiles.first;

      final initialLength = await newestFile.length();
      if (initialLength == 0) return null;
      
      await Future.delayed(const Duration(milliseconds: 250));
      final finalLength = await newestFile.length();
      
      return (initialLength == finalLength) ? newestFile.path : null;
    } catch (e) {
      debugPrint("Error in getLatestOutputImage: $e");
      return null;
    }
  }
}