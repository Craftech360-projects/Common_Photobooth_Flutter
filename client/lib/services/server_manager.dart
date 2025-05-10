import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ServerManager {
  Process? _serverProcess;
  bool _isServerRunning = false;

  bool get isServerRunning => _isServerRunning;

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
}
