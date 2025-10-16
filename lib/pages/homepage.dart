import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final TextEditingController roomController = TextEditingController();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  bool _cameraOn = false;
  bool _isFrontcamera = true ;

  @override
  void initState() {
    super.initState();
    // _localRenderer.initialize();
    _initSetup();
  }
  Future<void>_initSetup()async{
    await requestPermissions();
    await _localRenderer.initialize();
  }
  Future<void> requestPermissions()async{
    // ignore: unused_local_variable
    final statuses = await[
      Permission.camera, 
      Permission.microphone,   ].request();
  }

  Future<void> _startCamera() async {
    try {
      final mediaConstraints = {
        'audio': true,
        'video': {
          'facingMode': _isFrontcamera ? 'user' : 'environment',
        },
      };

      final stream =
          await navigator.mediaDevices.getUserMedia(mediaConstraints);

      setState(() {
        _localRenderer.srcObject = stream;
        _cameraOn = true;
      });
    } catch (e) {
      debugPrint('Error accessing camera: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to access camera: $e')),
      );
    }
  }

  Future<void > switchCamera()async{
    try {
      _isFrontcamera = !_isFrontcamera;
      await _stopCamera();
      await _startCamera();
    }catch(e){
      debugPrint('Error switiching camera: $e');
    }
  }

  Future<void> _stopCamera() async {
    try {
      _localRenderer.srcObject?.getTracks().forEach((track) {
        track.stop();
      });
      _localRenderer.srcObject = null;
      setState(() {
        _cameraOn = false;
      });
    } catch (e) {
      debugPrint('Error stopping camera: $e');
    }
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Join a Room',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Enter Room ID to Join Video Call",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: roomController,
              decoration: InputDecoration(
                hintText: "Room ID (e.g. room123)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                final roomID = roomController.text.trim();
                if (roomID.isNotEmpty) {
                  _startCamera();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Enter Room ID first")),
                  );
                }
              },
              child: const Text("Join Room & Start Camera"),
            ),
            const SizedBox(height: 30),
            // Camera Preview Section
            if (_cameraOn)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4))
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: RTCVideoView(
                      _localRenderer,
                      mirror: true,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            if (_cameraOn)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 45),
                ),
                icon: const Icon(Icons.stop),
                label: const Text("Stop Camera"),
                onPressed: _stopCamera,
              ),
        
            if (_cameraOn)
               ElevatedButton.icon(
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.blue,
                   minimumSize: const Size(double.infinity, 45),
                 ),
                 icon: const Icon(Icons.cameraswitch),
                 label: const Text("Switch Camera"),
                 onPressed: switchCamera,
  ),
          ],
        ),
      ),
    );
  }
}
