// // lib/pages/homepage.dart
// import 'dart:io' show Platform;
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'signaling.dart';

// class Homepage extends StatefulWidget {
//   const Homepage({super.key});

//   @override
//   State<Homepage> createState() => _HomepageState();
// }

// class _HomepageState extends State<Homepage> {
//   final TextEditingController roomController = TextEditingController();
//   final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
//   final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

//   Signaling? _signaling;
//   bool _inCall = false;
//   bool _cameraReady = false;
//   MediaStream? _localStream;

//   @override
//   void initState() {
//     super.initState();
//     _initializeRenderers();
//   }

//   Future<void> _initializeRenderers() async {
//     await _localRenderer.initialize();
//     await _remoteRenderer.initialize();
//     await _initCamera();
//   }

//   Future<void> _initCamera() async {
//     try {
//       if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
//         final cam = await Permission.camera.request();
//         final mic = await Permission.microphone.request();

//         if (!cam.isGranted || !mic.isGranted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("Camera/Microphone permission denied"),
//             ),
//           );
//           return;
//         }
//       }

//       final Map<String, dynamic> constraints = {
//         'audio': true,
//         'video': {
//           'facingMode': 'user',
//           'width': {'ideal': 1280},
//           'height': {'ideal': 720},
//           'frameRate': {'ideal': 30},
//         },
//       };

//       _localStream = await navigator.mediaDevices.getUserMedia(constraints);
//       _localRenderer.srcObject = _localStream;
//       setState(() => _cameraReady = true);
//     } catch (e) {
//       debugPrint("Camera init failed: $e");
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Camera error: $e")));
//     }
//   }

//   Future<void> _joinRoom({required bool isCaller}) async {
//     final roomId = roomController.text.trim();
//     if (roomId.isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Enter a valid Room ID")));
//       return;
//     }

//     final String wsUrl;
//     if (kIsWeb) {
//       wsUrl =
//           'ws://${Uri.base.host.isEmpty ? 'localhost' : Uri.base.host}:8080';
//     } else if (Platform.isAndroid) {
//       wsUrl = 'ws://10.0.2.2:8080';
//     } else {
//       wsUrl = 'ws://localhost:8080';
//     }

//     _signaling = Signaling(_localRenderer, _remoteRenderer, wsUrl: wsUrl);
//     await _signaling!.connect(roomId, isCaller: isCaller);
//     setState(() => _inCall = true);
//   }

//   void _hangUp() {
//     _signaling?.dispose();
//     _localRenderer.srcObject = null;
//     _remoteRenderer.srcObject = null;
//     _localStream?.getTracks().forEach((t) => t.stop());
//     setState(() {
//       _inCall = false;
//       _cameraReady = false;
//     });
//     _initCamera();
//   }

//   @override
//   void dispose() {
//     roomController.dispose();
//     _localRenderer.dispose();
//     _remoteRenderer.dispose();
//     _localStream?.dispose();
//     _signaling?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         title: const Text('Omegle-Style Video Chat'),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: !_inCall ? _buildPreviewUI() : _buildCallUI(),
//         ),
//       ),
//     );
//   }

//   Widget _buildPreviewUI() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Expanded(
//           child: Container(
//             color: Colors.black,
//             child: Center(
//               child: _cameraReady
//                   ? RTCVideoView(_localRenderer, mirror: true)
//                   : const CircularProgressIndicator(),
//             ),
//           ),
//         ),
//         const SizedBox(height: 20),
//         TextField(
//           controller: roomController,
//           decoration: const InputDecoration(
//             labelText: 'Room ID',
//             border: OutlineInputBorder(),
//           ),
//         ),
//         const SizedBox(height: 16),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             ElevatedButton.icon(
//               icon: const Icon(Icons.call),
//               label: const Text("Create Call"),
//               onPressed: _cameraReady ? () => _joinRoom(isCaller: true) : null,
//             ),
//             ElevatedButton.icon(
//               icon: const Icon(Icons.meeting_room),
//               label: const Text("Join Call"),
//               onPressed: _cameraReady ? () => _joinRoom(isCaller: false) : null,
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildCallUI() {
//     return Stack(
//       children: [
//         Positioned.fill(
//           child: Container(
//             color: Colors.black,
//             child: RTCVideoView(_remoteRenderer),
//           ),
//         ),
//         Positioned(
//           bottom: 20,
//           right: 20,
//           child: SizedBox(
//             width: 140,
//             height: 180,
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: RTCVideoView(_localRenderer, mirror: true),
//             ),
//           ),
//         ),
//         Positioned(
//           top: 16,
//           right: 16,
//           child: FloatingActionButton(
//             backgroundColor: Colors.red,
//             onPressed: _hangUp,
//             child: const Icon(Icons.call_end),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'call_page.dart';
import 'join_page.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final TextEditingController roomController = TextEditingController();

  void _navigateToNextPage({required bool isCaller}) {
    final roomId = roomController.text.trim();

    if (roomId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid Room ID")),
      );
      return;
    }

    final nextPage = isCaller
        ? CallPage(roomId: roomId)
        : JoinPage(roomId: roomId);

    Navigator.push(context, MaterialPageRoute(builder: (context) => nextPage));
  }

  @override
  void dispose() {
    roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Center(
          child: const Text(
            "V I D E O - C H A T",
            style: TextStyle(color: Colors.white),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 0.5),
              borderRadius: BorderRadius.circular(5),
            ),
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.menu, color: Colors.white),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(5),
              ),
              child: IconButton(
                onPressed: () {},
                icon: Icon(Icons.menu, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 23, 23, 23),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: roomController,
                  style: const TextStyle(color: Colors.white),

                  decoration: const InputDecoration(
                    labelText: 'Enter Room ID',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2),
                    ),

                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 0, 0, 0),
                  ),
                  icon: const Icon(Icons.video_call, color: Colors.white),
                  label: const Text(
                    "Create Call",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () => _navigateToNextPage(isCaller: true),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 0, 0, 0),
                  ),
                  icon: const Icon(Icons.meeting_room, color: Colors.white),
                  label: const Text(
                    "Join Call",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () => _navigateToNextPage(isCaller: false),
                ),
                const SizedBox(height: 210),
                const Text(
                  '''Terms and Conditions

Welcome to [Your App Name], your gateway to spontaneous video chats with strangers around the world! By using our app, you agree to follow these simple but important rules to keep the experience fun, safe, and respectful for everyone.

Our platform connects you randomly to other users for live video conversations — a place to meet new people, share moments, and explore new friendships. However, please remember that with great freedom comes great responsibility. You must not share any content that is offensive, harmful, hateful, or illegal. Harassment, hate speech, explicit content, and any abusive behavior are strictly prohibited. We reserve the right to monitor conversations and take immediate action against users who violate these rules, including banning or suspending accounts without warning.

Your privacy and safety are very important to us. While we do not record or store your video or audio streams, please be aware that you’re connecting directly with strangers, and we cannot guarantee their identity or intentions. Always use caution and avoid sharing personal or sensitive information.

This app is designed for users aged 18 and over. If you’re underage, please exit now. By continuing, you acknowledge the risks involved and agree not to hold us responsible for any issues arising from your use of the app.

We may update these Terms and Conditions from time to time to improve your experience — so be sure to check back regularly. If you don’t agree with any part of these terms, please discontinue using the app immediately.

Thank you for being part of our community. Now go ahead, connect, chat, and have fun — responsibly!''',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
