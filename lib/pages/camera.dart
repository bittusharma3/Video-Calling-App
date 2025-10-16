import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class TestCameraPage extends StatefulWidget {
  const TestCameraPage({super.key});

  @override
  State<TestCameraPage> createState() => _TestCameraPageState();
}

class _TestCameraPageState extends State<TestCameraPage> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();
    initRenderer();
  }

  Future<void> initRenderer() async {
    await _localRenderer.initialize();

    // Request video + audio stream
    final mediaConstraints = {
      'audio': true,
      'video': {
        'facingMode': 'user', // front camera
      },
    };

    try {
      final stream =
          await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localRenderer.srcObject = stream;
    } catch (e) {
      debugPrint('Error getting media: $e');
    }

    setState(() {});
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera Test')),
      body: Center(
        child: Container(
          width: 300,
          height: 400,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: RTCVideoView(
            _localRenderer,
            mirror: true,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final tracks = _localRenderer.srcObject?.getTracks() ?? [];
          for (var track in tracks) {
            track.stop();
          }
          await initRenderer();
        },
        child: const Icon(Icons.cameraswitch),
      ),
    );
  }
}
