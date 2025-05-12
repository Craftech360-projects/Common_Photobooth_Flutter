import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ServerManager {
  Process? _serverProcess;
  Process? _comfyProcess;
  bool _isServerRunning = false;
  bool _isComfyRunning = false;

  bool get isServerRunning => _isServerRunning;
  bool get isComfyRunning => _isComfyRunning;

  Future<void> startServer() async {
    if (_isServerRunning) {
      debugPrint('Server is already running');
      return;
    }

    try {
      // Determine the path to the server directory
      final String serverPath = await _getServerPath();

      // Check if Python is installed
      final pythonCommand = Platform.isWindows ? 'python' : 'python3';

      // Prepare the command to run the server
      final List<String> arguments = [path.join(serverPath, 'app.py')];

      debugPrint('Starting server at: $serverPath');
      debugPrint('Command: $pythonCommand ${arguments.join(' ')}');

      // Start the server process
      _serverProcess = await Process.start(
        pythonCommand,
        arguments,
        workingDirectory: serverPath,
        mode: ProcessStartMode.detached,
      );

      _isServerRunning = true;

      // Log server output
      _serverProcess!.stdout
          .transform(const SystemEncoding().decoder)
          .listen((data) {
        debugPrint('Server output: $data');
      });

      _serverProcess!.stderr
          .transform(const SystemEncoding().decoder)
          .listen((data) {
        debugPrint('Server error: $data');
      });

      // Handle server process exit
      await _serverProcess!.exitCode.then((exitCode) {
        debugPrint('Server process exited with code: $exitCode');
        _isServerRunning = false;
        _serverProcess = null;
      });

      debugPrint('Server started successfully');
    } on Exception catch (e) {
      debugPrint('Failed to start server: $e');
      _isServerRunning = false;
    }
  }

  Future<void> startComfyUI() async {
    if (_isComfyRunning) {
      debugPrint('ComfyUI is already running');
      return;
    }

    try {
      // Determine the path to the ComfyUI directory
      final String comfyUIPath = await _getComfyUIPath();

      // Check if Python is installed
      final pythonCommand = Platform.isWindows ? 'python' : 'python3';

      // Prepare the command to run ComfyUI
      final List<String> arguments = [
        'main.py',
        '--listen', // Listen on all interfaces
        '0.0.0.0',
        '--port',
        '8188',
      ];

      debugPrint('Starting ComfyUI at: $comfyUIPath');
      debugPrint('Command: $pythonCommand ${arguments.join(' ')}');

      // Start the ComfyUI process
      _comfyProcess = await Process.start(
        pythonCommand,
        arguments,
        workingDirectory: comfyUIPath,
        mode: ProcessStartMode.detached,
      );

      _isComfyRunning = true;

      // Log ComfyUI output
      _comfyProcess!.stdout
          .transform(const SystemEncoding().decoder)
          .listen((data) {
        debugPrint('ComfyUI output: $data');
      });

      _comfyProcess!.stderr
          .transform(const SystemEncoding().decoder)
          .listen((data) {
        debugPrint('ComfyUI error: $data');
      });

      // Handle ComfyUI process exit
      await _comfyProcess!.exitCode.then((exitCode) {
        debugPrint('ComfyUI process exited with code: $exitCode');
        _isComfyRunning = false;
        _comfyProcess = null;
      });

      debugPrint('ComfyUI started successfully');
    } on Exception catch (e) {
      debugPrint('Failed to start ComfyUI: $e');
      _isComfyRunning = false;
    }
  }

  Future<void> stopServer() async {
    if (!_isServerRunning || _serverProcess == null) {
      debugPrint('Server is not running');
      return;
    }

    try {
      if (Platform.isWindows) {
        // On Windows, we need to kill the process tree
        await Process.run(
            'taskkill', ['/F', '/T', '/PID', '${_serverProcess!.pid}']);
      } else {
        // On Unix-like systems
        _serverProcess!.kill();
      }

      _isServerRunning = false;
      _serverProcess = null;
      debugPrint('Server stopped successfully');
    } on Exception catch (e) {
      debugPrint('Failed to stop server: $e');
    }
  }

  Future<void> stopComfyUI() async {
    if (!_isComfyRunning || _comfyProcess == null) {
      debugPrint('ComfyUI is not running');
      return;
    }

    try {
      if (Platform.isWindows) {
        // On Windows, we need to kill the process tree
        await Process.run(
            'taskkill', ['/F', '/T', '/PID', '${_comfyProcess!.pid}']);
      } else {
        // On Unix-like systems
        _comfyProcess!.kill();
      }

      _isComfyRunning = false;
      _comfyProcess = null;
      debugPrint('ComfyUI stopped successfully');
    } on Exception catch (e) {
      debugPrint('Failed to stop ComfyUI: $e');
    }
  }

  Future<String> _getServerPath() async {
    if (kReleaseMode) {
      // In release mode, the server should be bundled with the app
      final appDir = await getApplicationDocumentsDirectory();

      if (Platform.isWindows) {
        // For Windows, the server will be in a 'server' directory next to the exe
        return path.join(path.dirname(Platform.resolvedExecutable), 'server');
      } else if (Platform.isMacOS) {
        // For macOS, the server will be in the app bundle
        return path.join(
            path.dirname(Platform.resolvedExecutable), '../Resources/server');
      } else {
        // For other platforms
        return path.join(appDir.path, 'server');
      }
    } else {
      // In debug mode, use the server from the project directory
      // This assumes the server is in a 'server' directory at the same level as 'client'
      final currentDir = Directory.current.path;
      final projectDir = path.dirname(currentDir);
      return path.join(projectDir, 'server');
    }
  }

  Future<String> _getComfyUIPath() async {
    if (kReleaseMode) {
      // In release mode, ComfyUI should be bundled with the app
      if (Platform.isWindows) {
        // For Windows, ComfyUI will be in a 'comfyui' directory next to the exe
        return path.join(path.dirname(Platform.resolvedExecutable), 'comfyui');
      } else if (Platform.isMacOS) {
        // For macOS, ComfyUI will be in the app bundle
        return path.join(
            path.dirname(Platform.resolvedExecutable), '../Resources/comfyui');
      } else {
        // For other platforms
        final appDir = await getApplicationDocumentsDirectory();
        return path.join(appDir.path, 'comfyui');
      }
    } else {
      // In debug mode, use the ComfyUI from a specified location
      // You can adjust this path to match where you have ComfyUI installed
      if (Platform.isWindows) {
        return 'C:/ComfyUI'; // Default Windows path
      } else if (Platform.isMacOS) {
        return '/Users/craftech360/ComfyUI'; // Default macOS path
      } else {
        return '/home/user/ComfyUI'; // Default Linux path
      }
    }
  }

  // Method to start both server and ComfyUI
  Future<void> startAll() async {
    await startComfyUI();
    // Wait a moment for ComfyUI to initialize
    await Future.delayed(const Duration(seconds: 5));
    await startServer();
  }

  // Method to stop both server and ComfyUI
  Future<void> stopAll() async {
    await stopServer();
    await stopComfyUI();
  }
}
