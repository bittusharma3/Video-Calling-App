// lib/pages/homepage.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'signaling.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final TextEditingController roomController = TextEditingController();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  Signaling? _signaling;
  bool _inCall = false;
  bool _cameraReady = false;
  MediaStream? _localStream;

  @override
  void initState() {
    super.initState();
    _initializeRenderers();
  }

  Future<void> _initializeRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    await _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        final cam = await Permission.camera.request();
        final mic = await Permission.microphone.request();

        if (!cam.isGranted || !mic.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Camera/Microphone permission denied")),
          );
          return;
        }
      }

      final Map<String, dynamic> constraints = {
        'audio': true,
        'video': {
          'facingMode': 'user',
          'width': {'ideal': 1280},
          'height': {'ideal': 720},
          'frameRate': {'ideal': 30},
        },
      };

      _localStream = await navigator.mediaDevices.getUserMedia(constraints);
      _localRenderer.srcObject = _localStream;
      setState(() => _cameraReady = true);
    } catch (e) {
      debugPrint("Camera init failed: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Camera error: $e")));
    }
  }

  Future<void> _joinRoom({required bool isCaller}) async {
    final roomId = roomController.text.trim();
    if (roomId.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Enter a valid Room ID")));
      return;
    }

    final String wsUrl;
    if (kIsWeb) {
      wsUrl = 'ws://${Uri.base.host.isEmpty ? 'localhost' : Uri.base.host}:8080';
    } else if (Platform.isAndroid) {
      wsUrl = 'ws://10.0.2.2:8080';
    } else {
      wsUrl = 'ws://localhost:8080';
    }

    _signaling = Signaling(_localRenderer, _remoteRenderer, wsUrl: wsUrl);
    await _signaling!.connect(roomId, isCaller: isCaller);
    setState(() => _inCall = true);
  }

  void _hangUp() {
    _signaling?.dispose();
    _localRenderer.srcObject = null;
    _remoteRenderer.srcObject = null;
    _localStream?.getTracks().forEach((t) => t.stop());
    setState(() {
      _inCall = false;
      _cameraReady = false;
    });
    _initCamera();
  }

  @override
  void dispose() {
    roomController.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _localStream?.dispose();
    _signaling?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Omegle-Style Video Chat'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: !_inCall ? _buildPreviewUI() : _buildCallUI(),
        ),
      ),
    );
  }

  Widget _buildPreviewUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            color: Colors.black,
            child: Center(
              child: _cameraReady
                  ? RTCVideoView(_localRenderer, mirror: true)
                  : const CircularProgressIndicator(),
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: roomController,
          decoration: const InputDecoration(
            labelText: 'Room ID',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.call),
              label: const Text("Create Call"),
              onPressed: _cameraReady ? () => _joinRoom(isCaller: true) : null,
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.meeting_room),
              label: const Text("Join Call"),
              onPressed: _cameraReady ? () => _joinRoom(isCaller: false) : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCallUI() {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: Colors.black,
            child: RTCVideoView(_remoteRenderer),
          ),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: SizedBox(
            width: 140,
            height: 180,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: RTCVideoView(_localRenderer, mirror: true),
            ),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: FloatingActionButton(
            backgroundColor: Colors.red,
            onPressed: _hangUp,
            child: const Icon(Icons.call_end),
          ),
        ),
      ],
    );
  }
}
