import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:photobooth_flutter/api/workflow.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/providers/photobooth_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:photobooth_flutter/services/comfy_api_service.dart';
import 'package:photobooth_flutter/services/supabase_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late final Player _player;
  late final VideoController _videoController;
  String? _errorMessage;
  final bool _isProcessing = true;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _videoController = VideoController(_player);
    _player.open(Media('asset://assets/videos/loading_bg.mp4'), play: true);
    _player.setPlaylistMode(PlaylistMode.single);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processImage();
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _setErrorMessage(String message) {
    if (mounted) {
      setState(() {
        _errorMessage = message;
        _player.pause();
      });
    }
  }

  Future<void> _processImage() async {
    final provider = Provider.of<PhotoboothProvider>(context, listen: false);
    final globalSettings =
        Provider.of<GlobalSettingsProvider>(context, listen: false);

    if (provider.faceImagePath == null) {
      _setErrorMessage('No face image captured');
      return;
    }
    final imageFile = File(provider.faceImagePath!);
    if (!await imageFile.exists()) {
      _setErrorMessage('Image file not found');
      return;
    }

    if (!ComfyApiService.isInitialized) {
      await ComfyApiService.initialize(
        apiUrl: globalSettings.comfyApiUrl ?? "http://127.0.0.1:8188",
      );
    }

    final seed = DateTime.now().millisecondsSinceEpoch;
    final isSwaplabFlow = provider.selectedTheme != null;
    final prefs = await SharedPreferences.getInstance();

    final String workflowFileName;
    final String watcherNodeId;

    if (isSwaplabFlow) {
      workflowFileName = 'faceswaponline.json';
      watcherNodeId = '44'; // As per faceswaponline.json
    } else {
      workflowFileName = prefs.getString('selected_workflow') ?? 'ghiblionline.json';
      watcherNodeId = '283'; // As per AI Artistry JSON files
    }

    await _processOnlineFlow(
      imageFile: imageFile,
      provider: provider,
      globalSettings: globalSettings,
      seed: seed,
      workflowFileName: workflowFileName,
      watcherNodeId: watcherNodeId,
      isSwaplab: isSwaplabFlow,
    );
  }

  Future<void> _processOnlineFlow({
    required File imageFile,
    required PhotoboothProvider provider,
    required GlobalSettingsProvider globalSettings,
    required int seed,
    required String workflowFileName,
    required String watcherNodeId,
    required bool isSwaplab,
  }) async {
    final supabaseUrl = globalSettings.supabaseUrl;
    final supabaseAnonKey = globalSettings.supabaseAnonKey;

    if (supabaseUrl == null || supabaseAnonKey == null) {
      _setErrorMessage('Supabase credentials not configured.');
      return;
    }

    if (!SupabaseService.instance.isInitialized) {
      await SupabaseService.instance.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
    }

    try {
      final faceImageUrl =
          await SupabaseService.instance.uploadUserFaceImage(imageFile);
      if (faceImageUrl == null) {
        _setErrorMessage('Failed to upload face image.');
        return;
      }

      final uniqueId = await SupabaseService.instance.storeParticipantDetails(
        name: provider.name ?? 'N/A',
        email: provider.email ?? 'N/A',
        gender: provider.gender ?? 'male',
        imageUrl: faceImageUrl,
      );
      if (uniqueId == null) {
        _setErrorMessage('Failed to store participant details in Supabase.');
        return;
      }

      final workflow = await Workflow.getWorkflow(workflowFileName);

      // Update nodes common to all online workflows
      workflow.updateSupabaseWatcherNode(uniqueId, nodeId: watcherNodeId);
      workflow.updateNoiseSeed(seed);

      // Specific updates for Swaplab workflow
      if (isSwaplab) {
        final themeName =
            provider.selectedTheme!.name.toLowerCase().replaceAll(' ', '_');
        final gender = provider.gender ?? 'male';
        final characterNumber = Random().nextInt(4) + 1;
        final characterImageName =
            '${gender == 'male' ? 'm' : 'f'}$characterNumber.png';
        final characterImagePath =
            'C:/storage/themes/$gender/$themeName/$characterImageName';
        workflow.updateSwaplabCharacterImage(characterImagePath);
      }

      final response = await ComfyApiService.instance
          .sendOnlineWorkflow(workflow.toMap());

      if (response.containsKey('sentTime')) {
        provider.setWorkflowSentTime(DateTime.parse(response['sentTime']));
      }

      // Polling for the result
      int attempts = 0;
      const maxAttempts = 120; // 4 minutes timeout
      const pollDelay = Duration(seconds: 2);

      while (attempts < maxAttempts) {
        final supabaseImageUrl =
            await SupabaseService.instance.getLatestOutputImage(
          uniqueId,
          afterTime: provider.workflowSentTime,
        );

        if (supabaseImageUrl != null) {
          debugPrint('Found new image in Supabase: $supabaseImageUrl');
          provider.setSwappedImage(supabaseImageUrl);
          provider.setCapturedImageUrl(supabaseImageUrl);
          if (mounted) {
            await Navigator.of(context)
                .pushReplacementNamed(AppRoutes.swappedFace);
          }
          return;
        }
        await Future.delayed(pollDelay);
        attempts++;
      }
      _setErrorMessage('Timed out waiting for image processing.');
    } on Exception catch (e) {
      _setErrorMessage('Error processing image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _errorMessage != null
            ? _buildErrorDisplay()
            : Video(
                controls: NoVideoControls,
                controller: _videoController,
              ),
      ),
    );
  }

  Widget _buildErrorDisplay() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 60),
          const SizedBox(height: 20),
          const Text(
            'An Error Occurred',
            style: TextStyle(
                color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ],
      ),
    );
  }
}