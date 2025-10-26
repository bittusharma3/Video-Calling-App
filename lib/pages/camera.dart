// camera.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';

class TestCameraPage extends StatefulWidget {
  const TestCameraPage({super.key});

  @override
  State<TestCameraPage> createState() => _TestCameraPageState();
}

class _TestCameraPageState extends State<TestCameraPage> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  MediaStream? _localStream;
  bool _initializing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initRenderer();
  }

  Future<void> _initRenderer() async {
    await _localRenderer.initialize();
  }

  Future<bool> _requestPermissions() async {
    if (kIsWeb) return true;
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      final statuses = await [Permission.camera, Permission.microphone].request();
      final cam = statuses[Permission.camera]?.isGranted ?? false;
      final mic = statuses[Permission.microphone]?.isGranted ?? false;
      return cam && mic;
    }
    // Desktop: assume allowed (user must enable via OS settings)
    return true;
  }

  Future<void> startLocalCamera() async {
    if (_initializing) return;
    _initializing = true;
    _error = null;
    setState(() {});

    try {
      final ok = await _requestPermissions();
      if (!ok) {
        _error = 'Camera/Microphone permissions not granted';
        setState(() {});
        return;
      }

      if (_localStream != null) {
        setState(() {});
        return;
      }

      final constraints = {
        'audio': true,
        'video': {
          'facingMode': 'user',
          'width': {'ideal': 1280},
          'height': {'ideal': 720},
          'frameRate': {'ideal': 30}
        }
      };

      final stream = await navigator.mediaDevices.getUserMedia(constraints);
      if (!mounted) {
        stream.getTracks().forEach((t) => t.stop());
        return;
      }
      _localStream = stream;
      _localRenderer.srcObject = _localStream;
      setState(() {});
    } catch (e, st) {
      debugPrint('startLocalCamera error: $e\n$st');
      _error = 'Error starting camera: $e';
      try {
        _localStream?.getTracks().forEach((t) => t.stop());
      } catch (_) {}
      _localStream = null;
      setState(() {});
    } finally {
      _initializing = false;
    }
  }

  Future<void> stopLocalCamera() async {
    try {
      _localStream?.getTracks().forEach((t) => t.stop());
    } catch (_) {}
    _localStream = null;
    _localRenderer.srcObject = null;
    setState(() {});
  }

  @override
  void dispose() {
    try {
      _localStream?.getTracks().forEach((t) => t.stop());
    } catch (_) {}
    _localRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Camera / WebRTC'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.black87,
              child: Center(
                child: _error != null
                    ? Text(_error!, style: const TextStyle(color: Colors.red))
                    : (_localStream == null
                        ? const Text('Camera not started', style: TextStyle(color: Colors.white))
                        : AspectRatio(
                            aspectRatio: 16 / 9,
                            child: RTCVideoView(_localRenderer,
                                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
                          )),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.videocam),
                  label: const Text("Start Camera"),
                  onPressed: startLocalCamera,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.stop_circle),
                  label: const Text("Stop Camera"),
                  onPressed: stopLocalCamera,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
