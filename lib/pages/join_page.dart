// // import 'dart:io' show Platform;
// // import 'package:flutter/foundation.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_webrtc/flutter_webrtc.dart';
// // import 'package:permission_handler/permission_handler.dart';
// // import 'package:video_calling_app/services/signaling.dart';
// // import 'package:video_calling_app/services/signaling_service.dart';

// // class JoinPage extends StatefulWidget {
// //   final String roomId;

// //   const JoinPage({super.key, required this.roomId});

// //   @override
// //   State<JoinPage> createState() => _JoinPageState();
// // }

// // class _JoinPageState extends State<JoinPage> {
// //   final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
// //   final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
// //   MediaStream? _localStream;
// //   Signaling? _signaling;
// //   bool _micMuted = false;
// //   bool _usingFrontCamera = true;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _init();
// //   }

// // Future<void> _init() async {
// //   await _localRenderer.initialize();
// //   await _remoteRenderer.initialize();
// //   await _initCamera();

// //   _signaling = await SignalingService.startSignaling(
// //     localRenderer: _localRenderer,
// //     remoteRenderer: _remoteRenderer,
// //     roomId: widget.roomId,
// //     isCaller: false,
// //   );
// // }


// //   Future<void> _initCamera() async {
// //     try {
// //       if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
// //         final cam = await Permission.camera.request();
// //         final mic = await Permission.microphone.request();

// //         if (!cam.isGranted || !mic.isGranted) {
// //           // ignore: use_build_context_synchronously
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             const SnackBar(
// //               content: Text("Camera/Microphone permission denied"),
// //             ),
// //           );
// //           return;
// //         }
// //       }

// //       final mediaConstraints = {
// //         'audio': true,
// //         'video': {
// //           'facingMode': _usingFrontCamera ? 'user' : 'environment',
// //           'width': {'ideal': 1280},
// //           'height': {'ideal': 720},
// //           'frameRate': {'ideal': 30},
// //         },
// //       };

// //       final stream = await navigator.mediaDevices.getUserMedia(
// //         mediaConstraints,
// //       );
// //       setState(() {
// //         _localStream = stream;
// //         _localRenderer.srcObject = stream;
// //       });
// //     } catch (e) {
// //       debugPrint("Camera error: $e");
// //     }
// //   }

// //   void _toggleMic() {
// //     if (_localStream == null) return;
// //     final audioTrack = _localStream!.getAudioTracks().firstWhere(
// //       (track) => track.kind == 'audio',
// //     );

// //     setState(() {
// //       _micMuted = !_micMuted;
// //       audioTrack.enabled = !_micMuted;
// //     });
// //   }

// //   Future<void> _switchCamera() async {
// //     if (_localStream == null) return;

// //     _usingFrontCamera = !_usingFrontCamera;

// //     for (var track in _localStream!.getTracks()) {
// //       track.stop();
// //     }

// //     await _initCamera();
// //   }

// //   void _hangUp() {
// //     _signaling?.dispose();
// //     _localRenderer.srcObject = null;
// //     _remoteRenderer.srcObject = null;
// //     _localStream?.getTracks().forEach((track) => track.stop());
// //     Navigator.pop(context);
// //   }

// //   @override
// //   void dispose() {
// //     _localStream?.dispose();
// //     _localRenderer.dispose();
// //     _remoteRenderer.dispose();
// //     _signaling?.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.black,
// //       body: Stack(
// //         children: [
// //           Positioned.fill(child: RTCVideoView(_remoteRenderer)),

// //           Positioned(
// //             bottom: 120,
// //             right: 20,
// //             child: SizedBox(
// //               width: 140,
// //               height: 180,
// //               child: ClipRRect(
// //                 borderRadius: BorderRadius.circular(12),
// //                 child: _localRenderer.srcObject != null
// //                     ? RTCVideoView(_localRenderer, mirror: _usingFrontCamera)
// //                     : const Center(child: CircularProgressIndicator()),
// //               ),
// //             ),
// //           ),

// //           Positioned(
// //             bottom: 40,
// //             left: 0,
// //             right: 0,
// //             child: Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //               children: [
// //                 Column(
// //                   children: [
// //                     FloatingActionButton(
// //                       heroTag: 'switch-camera',
// //                       backgroundColor: Color.fromARGB(255, 23, 23, 23),
// //                       onPressed: _switchCamera,
// //                       child: const Icon(
// //                         Icons.cameraswitch,
// //                         color: Colors.white,
// //                       ),
// //                     ),
// //                     const SizedBox(height: 6),
// //                     const Text(
// //                       "Flip",
// //                       style: TextStyle(color: Colors.white, fontSize: 12),
// //                     ),
// //                   ],
// //                 ),
// //                 Column(
// //                   children: [
// //                     FloatingActionButton(
// //                       heroTag: 'mute-mic',
// //                       backgroundColor: _micMuted
// //                           ? const Color.fromARGB(255, 23, 23, 23)
// //                           : const Color.fromARGB(255, 23, 23, 23),
// //                       onPressed: _toggleMic,
// //                       child: Icon(
// //                         _micMuted ? Icons.mic_off : Icons.mic,
// //                         color: Colors.white,
// //                       ),
// //                     ),
// //                     const SizedBox(height: 6),
// //                     Text(
// //                       _micMuted ? "Unmute" : "Mute",
// //                       style: const TextStyle(color: Colors.white, fontSize: 12),
// //                     ),
// //                   ],
// //                 ),
// //                 Column(
// //                   children: [
// //                     FloatingActionButton(
// //                       heroTag: 'hang-up',
// //                       backgroundColor: Color.fromARGB(255, 23, 23, 23),
// //                       onPressed: _hangUp,
// //                       child: const Icon(Icons.call_end, color: Colors.red),
// //                     ),
// //                     const SizedBox(height: 6),
// //                     const Text(
// //                       "Hang Up",
// //                       style: TextStyle(color: Colors.white, fontSize: 12),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }












// // lib/join_page.dart
// import 'dart:io' show Platform;
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:video_calling_app/services/signaling.dart';
// import 'package:video_calling_app/services/signaling_service.dart';

// class JoinPage extends StatefulWidget {
//   final String roomId;

//   const JoinPage({super.key, required this.roomId});

//   @override
//   State<JoinPage> createState() => _JoinPageState();
// }

// class _JoinPageState extends State<JoinPage> {
//   final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
//   final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
//   MediaStream? _localStream;
//   Signaling? _signaling;
//   bool _micMuted = false;
//   bool _usingFrontCamera = true;

//   // ✅ show loader while initializing
//   bool _initializing = true;

//   @override
//   void initState() {
//     super.initState();
//     _init();
//   }

//   Future<void> _init() async {
//     await _localRenderer.initialize();
//     await _remoteRenderer.initialize();

//     // 1) get camera first so local preview is ready
//     await _initCamera();

//     // 2) start signaling after local preview exists
//     try {
//       // 🔍 debug: show which room we join
//       debugPrint('🔍 JoinPage: starting signaling for room=${widget.roomId}');

//       _signaling = await SignalingService.startSignaling(
//         localRenderer: _localRenderer,
//         remoteRenderer: _remoteRenderer,
//         roomId: widget.roomId,
//         isCaller: false, // joiner
//       );

//       debugPrint('✅ JoinPage: signaling started (isCaller=false)');
//     } catch (e) {
//       debugPrint('❌ JoinPage: error starting signaling -> $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Signaling error: $e')));
//       }
//     }

//     // small delay to stabilize UI
//     await Future.delayed(const Duration(milliseconds: 200));
//     if (mounted) setState(() => _initializing = false);
//   }

//   Future<void> _initCamera() async {
//     try {
//       if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
//         final cam = await Permission.camera.request();
//         final mic = await Permission.microphone.request();

//         if (!cam.isGranted || !mic.isGranted) {
//           if (!mounted) return;
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Camera/Microphone permission denied")),
//           );
//           return;
//         }
//       }

//       final mediaConstraints = {
//         'audio': true,
//         'video': {
//           'facingMode': _usingFrontCamera ? 'user' : 'environment',
//           'width': {'ideal': 1280},
//           'height': {'ideal': 720},
//           'frameRate': {'ideal': 30},
//         },
//       };

//       // navigator.mediaDevices.getUserMedia may throw if device is busy
//       final stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

//       if (!mounted) return;
//       setState(() {
//         _localStream = stream;
//         _localRenderer.srcObject = stream;
//       });

//       debugPrint('🔍 JoinPage: local camera stream obtained');
//     } catch (e) {
//       debugPrint('❌ JoinPage: Camera error: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Camera error: $e")));
//       }
//     }
//   }

//   void _toggleMic() {
//     if (_localStream == null) return;
//     final audioTrack = _localStream!.getAudioTracks().firstWhere(
//       (track) => track.kind == 'audio',
//       orElse: () => throw StateError('No audio track'),
//     );

//     setState(() {
//       _micMuted = !_micMuted;
//       audioTrack.enabled = !_micMuted;
//     });
//   }

//   Future<void> _switchCamera() async {
//     if (_localStream == null) return;
//     _usingFrontCamera = !_usingFrontCamera;
//     for (var track in _localStream!.getTracks()) track.stop();
//     await _initCamera();
//   }

//   void _hangUp() {
//     try {
//       _signaling?.dispose();
//     } catch (_) {}
//     _localRenderer.srcObject = null;
//     _remoteRenderer.srcObject = null;
//     _localStream?.getTracks().forEach((track) => track.stop());
//     Navigator.pop(context);
//   }

//   @override
//   void dispose() {
//     _localStream?.dispose();
//     _localRenderer.dispose();
//     _remoteRenderer.dispose();
//     _signaling?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_initializing) {
//       return const Scaffold(
//         backgroundColor: Colors.black,
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           // remote fills background; black if null
//           Positioned.fill(
//               child: _remoteRenderer.srcObject != null
//                   ? RTCVideoView(_remoteRenderer)
//                   : Container(color: Colors.black)),

//           // small local preview
//           Positioned(
//             bottom: 120,
//             right: 20,
//             child: SizedBox(
//               width: 140,
//               height: 180,
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: _localRenderer.srcObject != null
//                     ? RTCVideoView(_localRenderer, mirror: _usingFrontCamera)
//                     : const Center(child: CircularProgressIndicator()),
//               ),
//             ),
//           ),

//           // controls
//           Positioned(
//             bottom: 40,
//             left: 0,
//             right: 0,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 Column(
//                   children: [
//                     FloatingActionButton(
//                       heroTag: 'switch-camera',
//                       backgroundColor: const Color.fromARGB(255, 23, 23, 23),
//                       onPressed: _switchCamera,
//                       child: const Icon(Icons.cameraswitch, color: Colors.white),
//                     ),
//                     const SizedBox(height: 6),
//                     const Text("Flip", style: TextStyle(color: Colors.white, fontSize: 12)),
//                   ],
//                 ),
//                 Column(
//                   children: [
//                     FloatingActionButton(
//                       heroTag: 'mute-mic',
//                       backgroundColor: const Color.fromARGB(255, 23, 23, 23),
//                       onPressed: _toggleMic,
//                       child: Icon(_micMuted ? Icons.mic_off : Icons.mic, color: Colors.white),
//                     ),
//                     const SizedBox(height: 6),
//                     Text(_micMuted ? "Unmute" : "Mute", style: const TextStyle(color: Colors.white, fontSize: 12)),
//                   ],
//                 ),
//                 Column(
//                   children: [
//                     FloatingActionButton(
//                       heroTag: 'hang-up',
//                       backgroundColor: const Color.fromARGB(255, 23, 23, 23),
//                       onPressed: _hangUp,
//                       child: const Icon(Icons.call_end, color: Colors.red),
//                     ),
//                     const SizedBox(height: 6),
//                     const Text("Hang Up", style: TextStyle(color: Colors.white, fontSize: 12)),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



// lib/join_page.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_calling_app/services/signaling.dart';
import 'package:video_calling_app/services/signaling_service.dart';

class JoinPage extends StatefulWidget {
  final String roomId;

  const JoinPage({super.key, required this.roomId});

  @override
  State<JoinPage> createState() => _JoinPageState();
}

class _JoinPageState extends State<JoinPage> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  MediaStream? _localStream;
  Signaling? _signaling;
  bool _micMuted = false;
  bool _usingFrontCamera = true;

  bool _initializing = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    // 1️⃣ get camera stream first
    await _initCamera();

    // 2️⃣ start signaling (callee side)
    try {
      debugPrint('📞 JoinPage: connecting to signaling, room=${widget.roomId}');
      _signaling = await SignalingService.startSignaling(
        localRenderer: _localRenderer,
        remoteRenderer: _remoteRenderer,
        roomId: widget.roomId,
        isCaller: false, // this device is the joiner
      );
      debugPrint('✅ JoinPage: signaling started (isCaller=false)');
    } catch (e, st) {
      debugPrint('❌ JoinPage: signaling error: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Signaling error: $e')));
      }
    }

    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) setState(() => _initializing = false);
  }

  Future<void> _initCamera() async {
    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        final cam = await Permission.camera.request();
        final mic = await Permission.microphone.request();

        if (!cam.isGranted || !mic.isGranted) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Camera or Microphone permission denied")),
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

      final stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

      if (!mounted) return;
      setState(() {
        _localStream = stream;
        _localRenderer.srcObject = stream;
      });

      debugPrint('🎥 JoinPage: local stream ready');
    } catch (e) {
      debugPrint('❌ JoinPage: camera error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Camera error: $e')));
      }
    }
  }

  void _toggleMic() {
    if (_localStream == null) return;
    final audioTrack = _localStream!.getAudioTracks().firstWhere(
      (track) => track.kind == 'audio',
      orElse: () => throw StateError('No audio track found'),
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
    try {
      _signaling?.dispose();
    } catch (_) {}
    _localRenderer.srcObject = null;
    _remoteRenderer.srcObject = null;
    _localStream?.getTracks().forEach((t) => t.stop());
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
    if (_initializing) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // remote video (fills background)
          Positioned.fill(
            child: _remoteRenderer.srcObject != null
                ? RTCVideoView(_remoteRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover)
                : Container(color: Colors.black),
          ),

          // local preview overlay
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

          // bottom controls
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
                      heroTag: 'flip',
                      backgroundColor: Colors.grey[900],
                      onPressed: _switchCamera,
                      child: const Icon(Icons.cameraswitch, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    const Text("Flip",
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
                Column(
                  children: [
                    FloatingActionButton(
                      heroTag: 'mic',
                      backgroundColor: Colors.grey[900],
                      onPressed: _toggleMic,
                      child: Icon(
                          _micMuted ? Icons.mic_off : Icons.mic,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(_micMuted ? "Unmute" : "Mute",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
                Column(
                  children: [
                    FloatingActionButton(
                      heroTag: 'hangup',
                      backgroundColor: Colors.grey[900],
                      onPressed: _hangUp,
                      child: const Icon(Icons.call_end, color: Colors.red),
                    ),
                    const SizedBox(height: 6),
                    const Text("Hang Up",
                        style: TextStyle(color: Colors.white, fontSize: 12)),
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
