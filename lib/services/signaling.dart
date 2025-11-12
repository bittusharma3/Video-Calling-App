// // // // // lib/pages/signaling.dart
// // // // import 'dart:convert';
// // // // import 'package:flutter/foundation.dart';
// // // // import 'package:flutter_webrtc/flutter_webrtc.dart';
// // // // import 'package:web_socket_channel/web_socket_channel.dart';
// // // // import 'package:web_socket_channel/status.dart' as status;

// // // // class Signaling {
// // // //   RTCPeerConnection? _peerConnection;
// // // //   MediaStream? _localStream;
// // // //   MediaStream? _remoteStream;

// // // //   final RTCVideoRenderer _localRenderer;
// // // //   final RTCVideoRenderer _remoteRenderer;
// // // //   late WebSocketChannel _channel;
// // // //   bool _isCaller = false;
// // // //   final String wsUrl;

// // // //   Signaling(this._localRenderer, this._remoteRenderer, {required this.wsUrl});

// // // //   final Map<String, dynamic> configuration = {
// // // //     'iceServers': [
// // // //       {'urls': 'stun:stun.l.google.com:19302'}
// // // //     ]
// // // //   };

// // // //   Future<void> connect(String roomId, {bool isCaller = false}) async {
// // // //     _isCaller = isCaller;
// // // //     _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
// // // //     _channel.sink.add(jsonEncode({'type': 'join', 'room': roomId}));

// // // //     _channel.stream.listen((message) async {
// // // //       try {
// // // //         final data = jsonDecode(message);
// // // //         final type = data['type'];

// // // //         switch (type) {
// // // //           case 'offer':
// // // //             await _createPeerConnection();
// // // //             await _peerConnection!.setRemoteDescription(
// // // //               RTCSessionDescription(data['sdp'], 'offer'),
// // // //             );
// // // //             final answer = await _peerConnection!.createAnswer();
// // // //             await _peerConnection!.setLocalDescription(answer);
// // // //             _channel.sink.add(jsonEncode({'type': 'answer', 'sdp': answer.sdp}));
// // // //             break;

// // // //           case 'answer':
// // // //             if (_peerConnection != null) {
// // // //               await _peerConnection!.setRemoteDescription(
// // // //                 RTCSessionDescription(data['sdp'], 'answer'),
// // // //               );
// // // //             }
// // // //             break;

// // // //           case 'candidate':
// // // //             final cand = data['candidate'];
// // // //             if (cand != null && _peerConnection != null) {
// // // //               await _peerConnection!.addCandidate(
// // // //                 RTCIceCandidate(cand['candidate'], cand['sdpMid'], cand['sdpMLineIndex']),
// // // //               );
// // // //             }
// // // //             break;

// // // //           case 'joined':
// // // //             if (_isCaller) await makeCall();
// // // //             break;
// // // //         }
// // // //       } catch (e) {
// // // //         debugPrint('Signaling parse error: $e');
// // // //       }
// // // //     });
// // // //   }

// // // //   Future<void> _createPeerConnection() async {
// // // //     if (_peerConnection != null) return;

// // // //     _peerConnection = await createPeerConnection(configuration);

// // // //     _localStream ??= await navigator.mediaDevices
// // // //         .getUserMedia({'audio': true, 'video': {'facingMode': 'user'}});

// // // //     _localRenderer.srcObject = _localStream;

// // // //     for (var track in _localStream!.getTracks()) {
// // // //       _peerConnection!.addTrack(track, _localStream!);
// // // //     }

// // // //     _peerConnection!.onTrack = (RTCTrackEvent event) {
// // // //       if (event.streams.isNotEmpty) {
// // // //         _remoteStream = event.streams[0];
// // // //         _remoteRenderer.srcObject = _remoteStream;
// // // //       }
// // // //     };

// // // //     _peerConnection!.onIceCandidate = (RTCIceCandidate? candidate) {
// // // //       if (candidate != null) {
// // // //         _channel.sink.add(jsonEncode({
// // // //           'type': 'candidate',
// // // //           'candidate': {
// // // //             'candidate': candidate.candidate,
// // // //             'sdpMid': candidate.sdpMid,
// // // //             'sdpMLineIndex': candidate.sdpMLineIndex,
// // // //           },
// // // //         }));
// // // //       }
// // // //     };
// // // //   }

// // // //   Future<void> makeCall() async {
// // // //     if (_peerConnection == null) await _createPeerConnection();

// // // //     final offer = await _peerConnection!.createOffer();
// // // //     await _peerConnection!.setLocalDescription(offer);
// // // //     _channel.sink.add(jsonEncode({'type': 'offer', 'sdp': offer.sdp}));
// // // //   }

// // // //   void dispose() {
// // // //     try {
// // // //       _localStream?.getTracks().forEach((t) => t.stop());
// // // //       _remoteStream?.getTracks().forEach((t) => t.stop());
// // // //       _peerConnection?.close();
// // // //       _channel.sink.close(status.normalClosure);
// // // //     } catch (_) {}
// // // //   }
// // // // }





// // // // lib/services/signaling.dart
// // // // lib/services/signaling.dart
// // // import 'dart:convert';
// // // import 'package:flutter/foundation.dart';
// // // import 'package:flutter_webrtc/flutter_webrtc.dart';
// // // import 'package:web_socket_channel/web_socket_channel.dart';
// // // import 'package:web_socket_channel/status.dart' as status;

// // // class Signaling {
// // //   RTCPeerConnection? _peerConnection;
// // //   MediaStream? _localStream;
// // //   MediaStream? _remoteStream;

// // //   final RTCVideoRenderer _localRenderer;
// // //   final RTCVideoRenderer _remoteRenderer;
// // //   late WebSocketChannel _channel;
// // //   bool _isCaller = false;
// // //   final String wsUrl;

// // //   Signaling(this._localRenderer, this._remoteRenderer, {required this.wsUrl});

// // //   final Map<String, dynamic> configuration = {
// // //     'iceServers': [
// // //       {'urls': 'stun:stun.l.google.com:19302'}
// // //     ]
// // //   };

// // //   Future<void> connect(String roomId, {bool isCaller = false}) async {
// // //     _isCaller = isCaller;

// // //     // 🔍 Log which WS URL we are using
// // //     debugPrint('🌐 Connecting to WebSocket at $wsUrl'); // 🔍

// // //     // Connect to WebSocket
// // //     _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

// // //     // ✅ Send join (and log)
// // //     final joinMsg = jsonEncode({'type': 'join', 'room': roomId});
// // //     _channel.sink.add(joinMsg);
// // //     debugPrint('✅ Sent join message: {type: join, room: $roomId}'); // 🔍

// // //     // Listen with error/done handlers 🛠️
// // //     _channel.stream.listen(
// // //       (message) async {
// // //         debugPrint('<< signaling recv: $message'); // 🔍

// // //         try {
// // //           final data = jsonDecode(message);
// // //           final type = data['type'];

// // //           switch (type) {
// // //             case 'offer':
// // //               debugPrint('<< received OFFER'); // 🔍
// // //               await _createPeerConnection();
// // //               await _peerConnection!.setRemoteDescription(
// // //                 RTCSessionDescription(data['sdp'], 'offer'),
// // //               );
// // //               final answer = await _peerConnection!.createAnswer();
// // //               await _peerConnection!.setLocalDescription(answer);
// // //               _channel.sink.add(jsonEncode({'type': 'answer', 'sdp': answer.sdp}));
// // //               debugPrint('>> sent ANSWER'); // 🔍
// // //               break;

// // //             case 'answer':
// // //               debugPrint('<< received ANSWER'); // 🔍
// // //               if (_peerConnection != null) {
// // //                 await _peerConnection!.setRemoteDescription(
// // //                   RTCSessionDescription(data['sdp'], 'answer'),
// // //                 );
// // //               }
// // //               break;

// // //             case 'candidate':
// // //               final cand = data['candidate'];
// // //               debugPrint('<< received CANDIDATE: $cand'); // 🔍
// // //               if (cand != null && _peerConnection != null) {
// // //                 await _peerConnection!.addCandidate(
// // //                   RTCIceCandidate(
// // //                     cand['candidate'],
// // //                     cand['sdpMid'],
// // //                     cand['sdpMLineIndex'],
// // //                   ),
// // //                 );
// // //               }
// // //               break;

// // //             // ✅ Accept both 'joined' and 'peer_joined' events and act if caller
// // //             case 'joined':
// // //             case 'peer_joined':
// // //               debugPrint('<< event: $type'); // 🔍
// // //               if (_isCaller) {
// // //                 debugPrint('Peer joined; caller will start call'); // 🔍
// // //                 await makeCall();
// // //               }
// // //               break;

// // //             default:
// // //               debugPrint('Unknown signaling type: $type'); // 🔍
// // //           }
// // //         } catch (e) {
// // //           debugPrint('Signaling parse error: $e'); // 🛠️
// // //         }
// // //       },
// // //       onError: (err) {
// // //         debugPrint('WebSocket error: $err'); // 🛠️
// // //       },
// // //       onDone: () {
// // //         debugPrint('WebSocket closed by server'); // 🛠️
// // //       },
// // //     );
// // //   }

// // //   Future<void> _createPeerConnection() async {
// // //     if (_peerConnection != null) return;

// // //     _peerConnection = await createPeerConnection(configuration);

// // //     // 🛠️ Add connection state logging
// // //     _peerConnection!.onConnectionState = (RTCPeerConnectionState? state) {
// // //       debugPrint('PeerConnection state: $state'); // 🔍
// // //     };
// // //     _peerConnection!.onIceConnectionState = (RTCIceConnectionState? state) {
// // //       debugPrint('ICE connection state: $state'); // 🔍
// // //     };

// // //     try {
// // //       // Only request local stream if we don't have it already
// // //       _localStream ??= await navigator.mediaDevices.getUserMedia({
// // //         'audio': true,
// // //         'video': {'facingMode': 'user'}
// // //       });

// // //       _localRenderer.srcObject = _localStream;
// // //       debugPrint('✅ got local stream and attached to localRenderer'); // 🔍
// // //     } catch (e) {
// // //       debugPrint('Error accessing camera/mic: $e'); // 🛠️
// // //       return;
// // //     }

// // //     // Add local tracks to peer connection and log them
// // //     _localStream?.getTracks().forEach((track) {
// // //       _peerConnection?.addTrack(track, _localStream!);
// // //       debugPrint('>> added local track: ${track.kind}'); // 🔍
// // //     });

// // //     // Listen for remote tracks
// // //     _peerConnection!.onTrack = (RTCTrackEvent event) {
// // //       debugPrint('onTrack called, streams: ${event.streams.length}'); // 🔍
// // //       if (event.streams.isNotEmpty) {
// // //         _remoteStream = event.streams[0];
// // //         _remoteRenderer.srcObject = _remoteStream;
// // //         debugPrint('✅ Remote stream assigned to renderer'); // 🔍
// // //       }
// // //     };

// // //     // Send ICE candidates to signaling server (and log them)
// // //     _peerConnection!.onIceCandidate = (RTCIceCandidate? candidate) {
// // //       debugPrint('local ICE candidate event: ${candidate?.candidate}'); // 🔍
// // //       if (candidate != null &&
// // //           candidate.candidate != null &&
// // //           candidate.sdpMid != null &&
// // //           candidate.sdpMLineIndex != null) {
// // //         _channel.sink.add(jsonEncode({
// // //           'type': 'candidate',
// // //           'candidate': {
// // //             'candidate': candidate.candidate,
// // //             'sdpMid': candidate.sdpMid,
// // //             'sdpMLineIndex': candidate.sdpMLineIndex,
// // //           },
// // //         }));
// // //         debugPrint('>> candidate sent to signaling server'); // 🔍
// // //       }
// // //     };
// // //   }

// // //   Future<void> makeCall() async {
// // //     if (_peerConnection == null) await _createPeerConnection();

// // //     final offer = await _peerConnection!.createOffer();
// // //     await _peerConnection!.setLocalDescription(offer);
// // //     _channel.sink.add(jsonEncode({'type': 'offer', 'sdp': offer.sdp}));
// // //     debugPrint('>> OFFER sent'); // 🔍
// // //   }

// // //   void dispose() {
// // //     try {
// // //       _localStream?.getTracks().forEach((t) => t.stop());
// // //       _remoteStream?.getTracks().forEach((t) => t.stop());
// // //       _peerConnection?.close();
// // //       _channel.sink.close(status.normalClosure);
// // //       debugPrint('Signaling disposed'); // 🔍
// // //     } catch (_) {}
// // //   }
// // // }



// // // lib/services/signaling.dart
// // import 'dart:convert';
// // import 'package:flutter/foundation.dart';
// // import 'package:flutter_webrtc/flutter_webrtc.dart';
// // import 'package:web_socket_channel/web_socket_channel.dart';
// // import 'package:web_socket_channel/status.dart' as status;

// // class Signaling {
// //   RTCPeerConnection? _peerConnection;
// //   MediaStream? _localStream;
// //   MediaStream? _remoteStream;

// //   final RTCVideoRenderer _localRenderer;
// //   final RTCVideoRenderer _remoteRenderer;
// //   late WebSocketChannel _channel;
// //   bool _isCaller = false;
// //   final String wsUrl;

// //   // 🟢 Persist the room id so all sends include it
// //   late String _roomId; // 🟢

// //   Signaling(this._localRenderer, this._remoteRenderer, {required this.wsUrl});

// //   final Map<String, dynamic> configuration = {
// //     'iceServers': [
// //       {'urls': 'stun:stun.l.google.com:19302'}
// //     ]
// //   };

// //   Future<void> connect(String roomId, {bool isCaller = false}) async {
// //     _isCaller = isCaller;

// //     // 🟢 store room id for later use when sending messages
// //     _roomId = roomId; // 🟢

// //     // 🔍 Log which WS URL we are using
// //     debugPrint('🌐 Connecting to WebSocket at $wsUrl'); // 🔍

// //     // Connect to WebSocket
// //     _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

// //     // ✅ Send join (and log) — join includes room already
// //     final joinMsg = jsonEncode({'type': 'join', 'room': _roomId});
// //     _channel.sink.add(joinMsg);
// //     debugPrint('✅ Sent join message: {type: join, room: $_roomId}'); // 🔍

// //     // Listen with error/done handlers 🛠️
// //     _channel.stream.listen(
// //       (message) async {
// //         debugPrint('<< signaling recv: $message'); // 🔍

// //         try {
// //           final data = jsonDecode(message);
// //           final type = data['type'];

// //           switch (type) {
// //             case 'offer':
// //               debugPrint('<< received OFFER'); // 🔍
// //               await _createPeerConnection();
// //               await _peerConnection!.setRemoteDescription(
// //                 RTCSessionDescription(data['sdp'], 'offer'),
// //               );
// //               final answer = await _peerConnection!.createAnswer();
// //               await _peerConnection!.setLocalDescription(answer);

// //               // 🟡 Always include room when sending answer
// //               _channel.sink.add(jsonEncode({
// //                 'type': 'answer',
// //                 'room': _roomId, // 🟡
// //                 'sdp': answer.sdp,
// //               }));
// //               debugPrint('>> sent ANSWER'); // 🔍
// //               break;

// //             case 'answer':
// //               debugPrint('<< received ANSWER'); // 🔍
// //               if (_peerConnection != null) {
// //                 await _peerConnection!.setRemoteDescription(
// //                   RTCSessionDescription(data['sdp'], 'answer'),
// //                 );
// //               }
// //               break;

// //             case 'candidate':
// //               final cand = data['candidate'];
// //               debugPrint('<< received CANDIDATE: $cand'); // 🔍
// //               if (cand != null && _peerConnection != null) {
// //                 await _peerConnection!.addCandidate(
// //                   RTCIceCandidate(
// //                     cand['candidate'],
// //                     cand['sdpMid'],
// //                     cand['sdpMLineIndex'],
// //                   ),
// //                 );
// //               }
// //               break;

// //             // ✅ Accept both 'joined' and 'peer_joined' events and act if caller
// //             case 'joined':
// //             case 'peer_joined':
// //               debugPrint('<< event: $type'); // 🔍
// //               if (_isCaller) {
// //                 debugPrint('Peer joined; caller will start call'); // 🔍
// //                 await makeCall();
// //               }
// //               break;

// //             default:
// //               debugPrint('Unknown signaling type: $type'); // 🔍
// //           }
// //         } catch (e) {
// //           debugPrint('Signaling parse error: $e'); // 🛠️
// //         }
// //       },
// //       onError: (err) {
// //         debugPrint('WebSocket error: $err'); // 🛠️
// //       },
// //       onDone: () {
// //         debugPrint('WebSocket closed by server'); // 🛠️
// //         // 🔵 Optional: ensure local cleanup when WS closes
// //         try {
// //           dispose();
// //         } catch (_) {}
// //       },
// //     );
// //   }

// //   Future<void> _createPeerConnection() async {
// //     if (_peerConnection != null) return;

// //     _peerConnection = await createPeerConnection(configuration);

// //     // 🛠️ Add connection state logging
// //     _peerConnection!.onConnectionState = (RTCPeerConnectionState? state) {
// //       debugPrint('PeerConnection state: $state'); // 🔍
// //     };
// //     _peerConnection!.onIceConnectionState = (RTCIceConnectionState? state) {
// //       debugPrint('ICE connection state: $state'); // 🔍
// //     };

// //     try {
// //       // Only request local stream if we don't have it already
// //       _localStream ??= await navigator.mediaDevices.getUserMedia({
// //         'audio': true,
// //         'video': {'facingMode': 'user'}
// //       });

// //       _localRenderer.srcObject = _localStream;
// //       debugPrint('✅ got local stream and attached to localRenderer'); // 🔍
// //     } catch (e) {
// //       debugPrint('Error accessing camera/mic: $e'); // 🛠️
// //       return;
// //     }

// //     // Add local tracks to peer connection and log them
// //     _localStream?.getTracks().forEach((track) {
// //       _peerConnection?.addTrack(track, _localStream!);
// //       debugPrint('>> added local track: ${track.kind}'); // 🔍
// //     });

// //     // Listen for remote tracks
// //     _peerConnection!.onTrack = (RTCTrackEvent event) {
// //       debugPrint('onTrack called, streams: ${event.streams.length}'); // 🔍
// //       if (event.streams.isNotEmpty) {
// //         _remoteStream = event.streams[0];
// //         _remoteRenderer.srcObject = _remoteStream;
// //         debugPrint('✅ Remote stream assigned to renderer'); // 🔍
// //       }
// //     };

// //     // Send ICE candidates to signaling server (and log them)
// //     _peerConnection!.onIceCandidate = (RTCIceCandidate? candidate) {
// //       debugPrint('local ICE candidate event: ${candidate?.candidate}'); // 🔍
// //       if (candidate != null &&
// //           candidate.candidate != null &&
// //           candidate.sdpMid != null &&
// //           candidate.sdpMLineIndex != null) {
// //         // 🟡 Include room in candidate messages too
// //         _channel.sink.add(jsonEncode({
// //           'type': 'candidate',
// //           'room': _roomId, // 🟡
// //           'candidate': {
// //             'candidate': candidate.candidate,
// //             'sdpMid': candidate.sdpMid,
// //             'sdpMLineIndex': candidate.sdpMLineIndex,
// //           },
// //         }));
// //         debugPrint('>> candidate sent to signaling server'); // 🔍
// //       }
// //     };
// //   }

// //   Future<void> makeCall() async {
// //     if (_peerConnection == null) await _createPeerConnection();

// //     final offer = await _peerConnection!.createOffer();
// //     await _peerConnection!.setLocalDescription(offer);

// //     // 🟡 Include room when sending the offer
// //     _channel.sink.add(jsonEncode({
// //       'type': 'offer',
// //       'room': _roomId, // 🟡
// //       'sdp': offer.sdp,
// //     }));
// //     debugPrint('>> OFFER sent'); // 🔍
// //   }

// //   void dispose() {
// //     try {
// //       _localStream?.getTracks().forEach((t) => t.stop());
// //       _remoteStream?.getTracks().forEach((t) => t.stop());
// //       _peerConnection?.close();

// //       // Close the websocket safely if open
// //       try {
// //         _channel.sink.close(status.normalClosure);
// //       } catch (_) {}

// //       debugPrint('Signaling disposed'); // 🔍
// //     } catch (_) {}
// //   }
// // }


// // lib/services/signaling.dart
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:web_socket_channel/status.dart' as status;

// class Signaling {
//   RTCPeerConnection? _peerConnection;
//   MediaStream? _localStream;
//   MediaStream? _remoteStream;

//   final RTCVideoRenderer _localRenderer;
//   final RTCVideoRenderer _remoteRenderer;
//   late WebSocketChannel _channel;

//   bool _isCaller = false;
//   bool _callStarted = false; // 🚫 Prevent duplicate offers
//   late String _roomId; // 🏠 Store room ID
//   final String wsUrl;

//   Signaling(this._localRenderer, this._remoteRenderer, {required this.wsUrl});

//   final Map<String, dynamic> configuration = {
//     'iceServers': [
//       {'urls': 'stun:stun.l.google.com:19302'},
//     ],
//   };

//   Future<void> connect(String roomId, {bool isCaller = false}) async {
//     _isCaller = isCaller;
//     _roomId = roomId;

//     debugPrint('🌐 Connecting to WebSocket at $wsUrl');
//     _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

//     final joinMsg = jsonEncode({'type': 'join', 'room': _roomId});
//     _channel.sink.add(joinMsg);
//     debugPrint('✅ Sent join message: {type: join, room: $_roomId}');

//     _channel.stream.listen(
//       (message) async {
//         debugPrint('<< signaling recv: $message');
//         try {
//           final data = jsonDecode(message);
//           final type = data['type'];

//           switch (type) {
//             case 'offer':
//               debugPrint('<< received OFFER');
//               await _createPeerConnection();
//               await _peerConnection!.setRemoteDescription(
//                 RTCSessionDescription(data['sdp'], 'offer'),
//               );
//               final answer = await _peerConnection!.createAnswer();
//               await _peerConnection!.setLocalDescription(answer);
//               _channel.sink.add(jsonEncode({
//                 'type': 'answer',
//                 'room': _roomId,
//                 'sdp': answer.sdp,
//               }));
//               debugPrint('>> sent ANSWER');
//               break;

//             case 'answer':
//               debugPrint('<< received ANSWER');
//               if (_peerConnection != null) {
//                 await _peerConnection!.setRemoteDescription(
//                   RTCSessionDescription(data['sdp'], 'answer'),
//                 );
//               }
//               break;

//             case 'candidate':
//               final cand = data['candidate'];
//               debugPrint('<< received CANDIDATE: $cand');
//               if (cand != null && _peerConnection != null) {
//                 await _peerConnection!.addCandidate(
//                   RTCIceCandidate(
//                     cand['candidate'],
//                     cand['sdpMid'],
//                     cand['sdpMLineIndex'],
//                   ),
//                 );
//               }
//               break;

//             case 'joined':
//               final peers = (data['peers'] is int)
//                   ? data['peers']
//                   : int.tryParse('${data['peers']}') ?? 1;
//               debugPrint('<< event: joined, peers=$peers');
//               if (_isCaller && peers > 1 && !_callStarted) {
//                 _callStarted = true;
//                 debugPrint('Peer present; caller starting call');
//                 await makeCall();
//               }
//               break;

//             case 'peer_joined':
//               debugPrint('<< event: peer_joined');
//               if (_isCaller && !_callStarted) {
//                 _callStarted = true;
//                 debugPrint('Peer joined; caller starting call');
//                 await makeCall();
//               }
//               break;

//             default:
//               debugPrint('Unknown signaling type: $type');
//           }
//         } catch (e) {
//           debugPrint('Signaling parse error: $e');
//         }
//       },
//       onError: (err) => debugPrint('WebSocket error: $err'),
//       onDone: () {
//         debugPrint('WebSocket closed by server');
//         dispose();
//       },
//     );
//   }

//   Future<void> _createPeerConnection() async {
//     if (_peerConnection != null) return;
//     _peerConnection = await createPeerConnection(configuration);

//     _peerConnection!.onConnectionState = (RTCPeerConnectionState? state) {
//       debugPrint('PeerConnection state: $state');
//     };
//     _peerConnection!.onIceConnectionState = (RTCIceConnectionState? state) {
//       debugPrint('ICE connection state: $state');
//     };

//     try {
//       _localStream ??= await navigator.mediaDevices.getUserMedia({
//         'audio': true,
//         'video': {'facingMode': 'user'}
//       });
//       _localRenderer.srcObject = _localStream;
//       debugPrint('✅ got local stream');
//     } catch (e) {
//       debugPrint('Error accessing camera/mic: $e');
//       return;
//     }

//     for (var track in _localStream!.getTracks()) {
//       await _peerConnection!.addTrack(track, _localStream!);
//       debugPrint('>> added local track: ${track.kind}');
//     }

//     _peerConnection!.onTrack = (RTCTrackEvent event) {
//       if (event.streams.isNotEmpty) {
//         _remoteStream = event.streams[0];
//         _remoteRenderer.srcObject = _remoteStream;
//         debugPrint('✅ Remote stream received');
//       }
//     };

//     _peerConnection!.onIceCandidate = (RTCIceCandidate? candidate) {
//       if (candidate != null &&
//           candidate.candidate != null &&
//           candidate.sdpMid != null &&
//           candidate.sdpMLineIndex != null) {
//         _channel.sink.add(jsonEncode({
//           'type': 'candidate',
//           'room': _roomId,
//           'candidate': {
//             'candidate': candidate.candidate,
//             'sdpMid': candidate.sdpMid,
//             'sdpMLineIndex': candidate.sdpMLineIndex,
//           },
//         }));
//         debugPrint('>> candidate sent');
//       }
//     };
//   }

//   Future<void> makeCall() async {
//     if (_peerConnection == null) await _createPeerConnection();
//     final offer = await _peerConnection!.createOffer();
//     await _peerConnection!.setLocalDescription(offer);
//     _channel.sink.add(jsonEncode({
//       'type': 'offer',
//       'room': _roomId,
//       'sdp': offer.sdp,
//     }));
//     debugPrint('>> OFFER sent');
//   }

//   void dispose() {
//     _callStarted = false;
//     _localStream?.getTracks().forEach((t) => t.stop());
//     _remoteStream?.getTracks().forEach((t) => t.stop());
//     _peerConnection?.close();
//     try {
//       _channel.sink.close(status.normalClosure);
//     } catch (_) {}
//     debugPrint('Signaling disposed');
//   }
// }


// lib/services/signaling.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class Signaling {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  final RTCVideoRenderer _localRenderer;
  final RTCVideoRenderer _remoteRenderer;
  late WebSocketChannel _channel;
  bool _isCaller = false;
  final String wsUrl;

  // persist the room id so all messages include it
  late String _roomId;

  Signaling(this._localRenderer, this._remoteRenderer, {required this.wsUrl});

  final Map<String, dynamic> configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'}
    ]
  };

  Future<void> connect(String roomId, {bool isCaller = false}) async {
    _isCaller = isCaller;
    _roomId = roomId;

    debugPrint('🌐 Connecting to WebSocket at $wsUrl');

    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    } catch (e) {
      debugPrint('WebSocket connection failed: $e');
      rethrow;
    }

    // send join
    final joinMsg = jsonEncode({'type': 'join', 'room': _roomId});
    _channel.sink.add(joinMsg);
    debugPrint('✅ Sent join message: {type: join, room: $_roomId}');

    _channel.stream.listen(
      (message) async {
        debugPrint('<< signaling recv: $message');
        try {
          final data = jsonDecode(message);
          final type = data['type'] as String?;

          if (type == null) {
            debugPrint('Signaling message without type');
            return;
          }

          switch (type) {
            case 'offer':
              debugPrint('<< received OFFER');
              await _createPeerConnection();
              await _peerConnection!.setRemoteDescription(
                RTCSessionDescription(data['sdp'] as String, 'offer'),
              );
              final answer = await _peerConnection!.createAnswer();
              await _peerConnection!.setLocalDescription(answer);

              _channel.sink.add(jsonEncode({
                'type': 'answer',
                'room': _roomId,
                'sdp': answer.sdp,
              }));
              debugPrint('>> sent ANSWER');
              break;

            case 'answer':
              debugPrint('<< received ANSWER');
              if (_peerConnection != null) {
                await _peerConnection!.setRemoteDescription(
                  RTCSessionDescription(data['sdp'] as String, 'answer'),
                );
              }
              break;

            case 'candidate':
              final cand = data['candidate'];
              debugPrint('<< received CANDIDATE: $cand');
              if (cand != null && _peerConnection != null) {
                await _peerConnection!.addCandidate(
                  RTCIceCandidate(
                    cand['candidate'] as String?,
                    cand['sdpMid'] as String?,
                    cand['sdpMLineIndex'] as int?,
                  ),
                );
              }
              break;

            case 'joined':
            case 'peer_joined':
              debugPrint('<< event: $type');
              // if we are caller start the call (caller creates offer)
              if (_isCaller) {
                debugPrint('Peer joined; caller will start call');
                await makeCall();
              }
              break;

            default:
              debugPrint('Unknown signaling type: $type');
          }
        } catch (e, st) {
          debugPrint('Signaling parse error: $e\n$st');
        }
      },
      onError: (err) {
        debugPrint('WebSocket error: $err');
      },
      onDone: () {
        debugPrint('WebSocket closed by server');
        // cleanup local resources
        try {
          dispose();
        } catch (_) {}
      },
    );
  }

  Future<void> _createPeerConnection() async {
    if (_peerConnection != null) return;

    _peerConnection = await createPeerConnection(configuration);

    _peerConnection!.onConnectionState = (RTCPeerConnectionState? state) {
      debugPrint('PeerConnection state: $state');
    };
    _peerConnection!.onIceConnectionState = (RTCIceConnectionState? state) {
      debugPrint('ICE connection state: $state');
    };

    // getMedia if needed
    try {
      _localStream ??= await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {'facingMode': 'user'}
      });

      _localRenderer.srcObject = _localStream;
      debugPrint('✅ got local stream and attached to localRenderer');
    } catch (e) {
      debugPrint('Error accessing camera/mic: $e');
      return;
    }

    // add local tracks
    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
      debugPrint('>> added local track: ${track.kind}');
    });

    // onTrack — robust: some browsers send tracks inside event.streams, others not
    _peerConnection!.onTrack = (RTCTrackEvent event) async {
      debugPrint('onTrack called, streams: ${event.streams.length}, track kind: ${event.track?.kind}');
      try {
        if (event.streams.isNotEmpty) {
          _remoteStream = event.streams[0];
          _remoteRenderer.srcObject = _remoteStream;
          debugPrint('✅ Remote stream assigned to renderer (streams[0])');
        } else {
          // fallback: create stream from track
          if (_remoteStream == null) {
            _remoteStream = await createLocalMediaStream('remoteStream');
          }
          if (event.track != null) {
            _remoteStream!.addTrack(event.track!);
            _remoteRenderer.srcObject = _remoteStream;
            debugPrint('✅ Remote track added to created stream');
          }
        }
      } catch (e) {
        debugPrint('Error in onTrack handling: $e');
      }
    };

    // send ICE candidates (include room)
    _peerConnection!.onIceCandidate = (RTCIceCandidate? candidate) {
      debugPrint('local ICE candidate event: ${candidate?.candidate}');
      if (candidate != null &&
          candidate.candidate != null &&
          candidate.sdpMid != null &&
          candidate.sdpMLineIndex != null) {
        _channel.sink.add(jsonEncode({
          'type': 'candidate',
          'room': _roomId,
          'candidate': {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          },
        }));
        debugPrint('>> candidate sent to signaling server');
      }
    };
  }

  Future<void> makeCall() async {
    if (_peerConnection == null) await _createPeerConnection();

    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    _channel.sink.add(jsonEncode({
      'type': 'offer',
      'room': _roomId,
      'sdp': offer.sdp,
    }));
    debugPrint('>> OFFER sent');
  }

  void dispose() {
    try {
      _localStream?.getTracks().forEach((t) => t.stop());
      _remoteStream?.getTracks().forEach((t) => t.stop());
      _peerConnection?.close();
      try {
        _channel.sink.close(status.normalClosure);
      } catch (_) {}
      debugPrint('Signaling disposed');
    } catch (_) {}
  }
}

