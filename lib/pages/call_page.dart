import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_calling_app/pages/signaling.dart';

class CallPage extends StatefulWidget {
  final String roomId;

  const CallPage({super.key, required this.roomId});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  MediaStream? _localStream;
  Signaling? _signaling;
  bool _micMuted = false;
  bool _usingFrontCamera = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    await _initCamera();
    await _startSignaling(isCaller: true);
  }

  Future<void> _initCamera() async {
    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        final cam = await Permission.camera.request();
        final mic = await Permission.microphone.request();

        if (!cam.isGranted || !mic.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Camera/Microphone permission denied"),
            ),
          );
          return;
        }
      }

      final mediaConstraints = {
        'audio': true,
        'video': {
          'facingMode': _usingFrontCamera ? 'user' : 'environment',
          'width': {'ideal': 1280},
          'height': {'ideal': 720},
          'frameRate': {'ideal': 30},
        },
      };

      final stream = await navigator.mediaDevices.getUserMedia(
        mediaConstraints,
      );

      setState(() {
        _localStream = stream;
        _localRenderer.srcObject = stream;
      });
    } catch (e) {
      debugPrint("Camera error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Camera error: $e")));
    }
  }

  Future<void> _startSignaling({required bool isCaller}) async {
    final String wsUrl;
    if (kIsWeb) {
      wsUrl =
          'ws://${Uri.base.host.isEmpty ? 'localhost' : Uri.base.host}:8080';
    } else if (Platform.isAndroid) {
      wsUrl = 'ws://10.0.2.2:8080';
    } else {
      wsUrl = 'ws://localhost:8080';
    }

    _signaling = Signaling(_localRenderer, _remoteRenderer, wsUrl: wsUrl);
    await _signaling!.connect(widget.roomId, isCaller: isCaller);
  }

  void _toggleMic() {
    if (_localStream == null) return;
    final audioTrack = _localStream!.getAudioTracks().firstWhere(
      (track) => track.kind == 'audio',
    );

    setState(() {
      _micMuted = !_micMuted;
      audioTrack.enabled = !_micMuted;
    });
  }

  Future<void> _switchCamera() async {
    if (_localStream == null) return;

    _usingFrontCamera = !_usingFrontCamera;

    for (var track in _localStream!.getTracks()) {
      track.stop();
    }

    await _initCamera();
  }

  void _hangUp() {
    _signaling?.dispose();
    _localRenderer.srcObject = null;
    _remoteRenderer.srcObject = null;
    _localStream?.getTracks().forEach((track) => track.stop());
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _localStream?.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _signaling?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: RTCVideoView(_remoteRenderer)),

          Positioned(
            bottom: 120,
            right: 20,
            child: SizedBox(
              width: 140,
              height: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _localRenderer.srcObject != null
                    ? RTCVideoView(_localRenderer, mirror: _usingFrontCamera)
                    : const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    FloatingActionButton(
                      heroTag: 'switch-camera',
                      backgroundColor: Color.fromARGB(255, 23, 23, 23),
                      onPressed: _switchCamera,
                      child: const Icon(
                        Icons.cameraswitch,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Flip",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
                Column(
                  children: [
                    FloatingActionButton(
                      heroTag: 'mute-mic',
                      backgroundColor: _micMuted
                          ? Color.fromARGB(255, 23, 23, 23)
                          : Color.fromARGB(255, 23, 23, 23),
                      onPressed: _toggleMic,
                      child: Icon(
                        _micMuted ? Icons.mic_off : Icons.mic,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _micMuted ? "Unmute" : "Mute",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
                Column(
                  children: [
                    FloatingActionButton(
                      heroTag: 'hang-up',
                      backgroundColor: Color.fromARGB(255, 23, 23, 23),
                      onPressed: _hangUp,
                      child: const Icon(Icons.call_end, color: Colors.red),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Hang Up",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
