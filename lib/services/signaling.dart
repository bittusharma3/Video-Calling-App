

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

// //    late String _roomId;

// //   Signaling(this._localRenderer, this._remoteRenderer, {required this.wsUrl});

// //   final Map<String, dynamic> configuration = {
// //     'iceServers': [
// //       {'urls': 'stun:stun.l.google.com:19302'}
// //     ]
// //   };

// //   Future<void> connect(String roomId, {bool isCaller = false}) async {
// //     _isCaller = isCaller;
// //     _roomId = roomId;

// //     debugPrint('🌐 Connecting to WebSocket at $wsUrl');

// //     try {
// //       _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
// //     } catch (e) {
// //       debugPrint('WebSocket connection failed: $e');
// //       rethrow;
// //     }

// //      final joinMsg = jsonEncode({'type': 'join', 'room': _roomId});
// //     _channel.sink.add(joinMsg);
// //     debugPrint('✅ Sent join message: {type: join, room: $_roomId}');

// //     _channel.stream.listen(
// //       (message) async {
// //         debugPrint('<< signaling recv: $message');
// //         try {
// //           final data = jsonDecode(message);
// //           final type = data['type'] as String?;

// //           if (type == null) {
// //             debugPrint('Signaling message without type');
// //             return;
// //           }

// //           switch (type) {
// //             case 'offer':
// //               debugPrint('<< received OFFER');
// //               await _createPeerConnection();
// //               await _peerConnection!.setRemoteDescription(
// //                 RTCSessionDescription(data['sdp'] as String, 'offer'),
// //               );
// //               final answer = await _peerConnection!.createAnswer();
// //               await _peerConnection!.setLocalDescription(answer);

// //               _channel.sink.add(jsonEncode({
// //                 'type': 'answer',
// //                 'room': _roomId,
// //                 'sdp': answer.sdp,
// //               }));
// //               debugPrint('>> sent ANSWER');
// //               break;

// //             case 'answer':
// //               debugPrint('<< received ANSWER');
// //               if (_peerConnection != null) {
// //                 await _peerConnection!.setRemoteDescription(
// //                   RTCSessionDescription(data['sdp'] as String, 'answer'),
// //                 );
// //               }
// //               break;

// //             case 'candidate':
// //               final cand = data['candidate'];
// //               debugPrint('<< received CANDIDATE: $cand');
// //               if (cand != null && _peerConnection != null) {
// //                 await _peerConnection!.addCandidate(
// //                   RTCIceCandidate(
// //                     cand['candidate'] as String?,
// //                     cand['sdpMid'] as String?,
// //                     cand['sdpMLineIndex'] as int?,
// //                   ),
// //                 );
// //               }
// //               break;

// //             case 'joined':
// //             case 'peer_joined':
// //               debugPrint('<< event: $type');
// //                if (_isCaller) {
// //                 debugPrint('Peer joined; caller will start call');
// //                 await makeCall();
// //               }
// //               break;

// //             default:
// //               debugPrint('Unknown signaling type: $type');
// //           }
// //         } catch (e, st) {
// //           debugPrint('Signaling parse error: $e\n$st');
// //         }
// //       },
// //       onError: (err) {
// //         debugPrint('WebSocket error: $err');
// //       },
// //       onDone: () {
// //         debugPrint('WebSocket closed by server');
// //          try {
// //           dispose();
// //         } catch (_) {}
// //       },
// //     );
// //   }

// //   Future<void> _createPeerConnection() async {
// //     if (_peerConnection != null) return;

// //     _peerConnection = await createPeerConnection(configuration);

// //     _peerConnection!.onConnectionState = (RTCPeerConnectionState? state) {
// //       debugPrint('PeerConnection state: $state');
// //     };
// //     _peerConnection!.onIceConnectionState = (RTCIceConnectionState? state) {
// //       debugPrint('ICE connection state: $state');
// //     };

// //      try {
// //       _localStream ??= await navigator.mediaDevices.getUserMedia({
// //         'audio': true,
// //         'video': {'facingMode': 'user'}
// //       });

// //       _localRenderer.srcObject = _localStream;
// //       debugPrint('✅ got local stream and attached to localRenderer');
// //     } catch (e) {
// //       debugPrint('Error accessing camera/mic: $e');
// //       return;
// //     }

// //      _localStream?.getTracks().forEach((track) {
// //       _peerConnection?.addTrack(track, _localStream!);
// //       debugPrint('>> added local track: ${track.kind}');
// //     });

// //      _peerConnection!.onTrack = (RTCTrackEvent event) async {
// //       debugPrint('onTrack called, streams: ${event.streams.length}, track kind: ${event.track?.kind}');
// //       try {
// //         if (event.streams.isNotEmpty) {
// //           _remoteStream = event.streams[0];
// //           _remoteRenderer.srcObject = _remoteStream;
// //           debugPrint('✅ Remote stream assigned to renderer (streams[0])');
// //         } else {
// //            if (_remoteStream == null) {
// //             _remoteStream = await createLocalMediaStream('remoteStream');
// //           }
// //           if (event.track != null) {
// //             _remoteStream!.addTrack(event.track!);
// //             _remoteRenderer.srcObject = _remoteStream;
// //             debugPrint('✅ Remote track added to created stream');
// //           }
// //         }
// //       } catch (e) {
// //         debugPrint('Error in onTrack handling: $e');
// //       }
// //     };

// //      _peerConnection!.onIceCandidate = (RTCIceCandidate? candidate) {
// //       debugPrint('local ICE candidate event: ${candidate?.candidate}');
// //       if (candidate != null &&
// //           candidate.candidate != null &&
// //           candidate.sdpMid != null &&
// //           candidate.sdpMLineIndex != null) {
// //         _channel.sink.add(jsonEncode({
// //           'type': 'candidate',
// //           'room': _roomId,
// //           'candidate': {
// //             'candidate': candidate.candidate,
// //             'sdpMid': candidate.sdpMid,
// //             'sdpMLineIndex': candidate.sdpMLineIndex,
// //           },
// //         }));
// //         debugPrint('>> candidate sent to signaling server');
// //       }
// //     };
// //   }

// //   Future<void> makeCall() async {
// //     if (_peerConnection == null) await _createPeerConnection();

// //     final offer = await _peerConnection!.createOffer();
// //     await _peerConnection!.setLocalDescription(offer);

// //     _channel.sink.add(jsonEncode({
// //       'type': 'offer',
// //       'room': _roomId,
// //       'sdp': offer.sdp,
// //     }));
// //     debugPrint('>> OFFER sent');
// //   }

// //   void dispose() {
// //     try {
// //       _localStream?.getTracks().forEach((t) => t.stop());
// //       _remoteStream?.getTracks().forEach((t) => t.stop());
// //       _peerConnection?.close();
// //       try {
// //         _channel.sink.close(status.normalClosure);
// //       } catch (_) {}
// //       debugPrint('Signaling disposed');
// //     } catch (_) {}
// //   }
// // }









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

  // Persist the room id so all sends include it
  late String _roomId;

  // Guard to ensure caller makes only one offer per remote join
  bool _callStarted = false;

  Signaling(this._localRenderer, this._remoteRenderer, {required String wsUrl}) {
    _wsUrl = wsUrl;
  }

  final Map<String, dynamic> configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ]
  };

  late final String _wsUrl;

  Future<void> connect(String roomId, {bool isCaller = false}) async {
    _isCaller = isCaller;
    _roomId = roomId;

    debugPrint('🌐 Connecting to WebSocket at $_wsUrl');

    // connect (throws if invalid)
    _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));

    // send join
    final joinMsg = jsonEncode({'type': 'join', 'room': _roomId});
    _channel.sink.add(joinMsg);
    debugPrint('✅ Sent join message: {type: join, room: $_roomId}');

    // listen
    _channel.stream.listen(
      (message) async {
        debugPrint('<< signaling recv: $message');

        try {
          final data = jsonDecode(message as String);
          final type = data['type'];

          switch (type) {
            case 'offer':
              debugPrint('<< received OFFER');
              await _createPeerConnection();
              await _peerConnection!.setRemoteDescription(
                RTCSessionDescription(data['sdp'], 'offer'),
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
                  RTCSessionDescription(data['sdp'], 'answer'),
                );
              }
              break;

            case 'candidate':
              final cand = data['candidate'];
              debugPrint('<< received CANDIDATE: $cand');
              if (cand != null && _peerConnection != null) {
                await _peerConnection!.addCandidate(
                  RTCIceCandidate(
                    cand['candidate'],
                    cand['sdpMid'],
                    cand['sdpMLineIndex'],
                  ),
                );
              }
              break;

            case 'joined':
              debugPrint('<< event: joined (peers=${data['peers']})');
              // if caller and there are already other peers, start call
              if (_isCaller && (data['peers'] ?? 0) > 1 && !_callStarted) {
                debugPrint('Peer(s) present; caller will start call');
                await makeCall();
              }
              break;

            case 'peer_joined':
              debugPrint('<< event: peer_joined');
              // ensure caller only starts once
              if (_isCaller && !_callStarted) {
                debugPrint('Peer joined; caller will start call');
                await makeCall();
              }
              break;

            case 'peer_left':
              debugPrint('<< event: peer_left');
              // if peer left, cleanup peer connection (optional)
              // close existing connection so rejoin works later
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
        // safe cleanup
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

    // get local stream if not present
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

    // add tracks
    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
      debugPrint('>> added local track: ${track.kind}');
    });

    _peerConnection!.onTrack = (RTCTrackEvent event) {
      debugPrint('onTrack called, streams: ${event.streams.length}');
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams[0];
        _remoteRenderer.srcObject = _remoteStream;
        debugPrint('✅ Remote stream assigned to renderer');
      }
    };

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
    if (_callStarted) {
      debugPrint('MakeCall called but _callStarted already true — ignoring duplicate call');
      return;
    }

    if (_peerConnection == null) await _createPeerConnection();

    _callStarted = true; // set guard BEFORE creating offer to avoid race

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
      _callStarted = false;
      _localStream?.getTracks().forEach((t) => t.stop());
      _remoteStream?.getTracks().forEach((t) => t.stop());
    } catch (_) {}
    try {
      _peerConnection?.close();
      _peerConnection = null;
    } catch (_) {}
    try {
      _channel.sink.close(status.normalClosure);
    } catch (_) {}
    debugPrint('Signaling disposed');
  }
}



























// // lib/services/signaling.dart
// import 'dart:async';
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

//   // Persist the room id so all sends include it
//   late String _roomId;

//   // Guard to avoid sending offers multiple times
//   bool _callStarted = false;

//   // If we want to avoid creating peer connection multiple times
//   bool _pcCreating = false;

//   final String wsUrl;

//   Signaling(this._localRenderer, this._remoteRenderer, {required this.wsUrl});

//   final Map<String, dynamic> configuration = {
//     'iceServers': [
//       {'urls': 'stun:stun.l.google.com:19302'}
//     ]
//   };

//   Future<void> connect(String roomId, {bool isCaller = false}) async {
//     _isCaller = isCaller;
//     _roomId = roomId;

//     debugPrint('🌐 Signaling.connect -> wsUrl=$wsUrl room=$_roomId isCaller=$_isCaller');

//     // connect websocket
//     _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

//     // Send join message immediately (include room)
//     final joinMsg = jsonEncode({'type': 'join', 'room': _roomId});
//     _channel.sink.add(joinMsg);
//     debugPrint('✅ Sent join message: $joinMsg');

//     // listen
//     _channel.stream.listen(
//       (message) async {
//         debugPrint('<< signaling recv: $message');

//         try {
//           final data = jsonDecode(message as String);
//           final type = data['type'];

//           switch (type) {
//             case 'offer':
//               debugPrint('<< received OFFER');
//               await _createPeerConnection();
//               await _peerConnection!.setRemoteDescription(RTCSessionDescription(data['sdp'], 'offer'));

//               final answer = await _peerConnection!.createAnswer();
//               await _peerConnection!.setLocalDescription(answer);

//               // include room
//               _channel.sink.add(jsonEncode({
//                 'type': 'answer',
//                 'room': _roomId,
//                 'sdp': answer.sdp,
//               }));
//               debugPrint('>> sent ANSWER');
//               break;

//             case 'answer':
//               debugPrint('<< received ANSWER');
//               if (_peerConnection != null && data['sdp'] != null) {
//                 await _peerConnection!.setRemoteDescription(RTCSessionDescription(data['sdp'], 'answer'));
//               }
//               break;

//             case 'candidate':
//               final cand = data['candidate'];
//               debugPrint('<< received CANDIDATE: $cand');
//               if (cand != null && _peerConnection != null) {
//                 await _peerConnection!.addCandidate(RTCIceCandidate(
//                   cand['candidate'],
//                   cand['sdpMid'],
//                   cand['sdpMLineIndex'],
//                 ));
//               }
//               break;

//             case 'joined':
//               debugPrint('<< event: joined, peers=${data['peers']}');
//               // if caller and there is already someone, start call once
//               if (_isCaller && !_callStarted && (data['peers'] ?? 0) > 1) {
//                 _callStarted = true;
//                 debugPrint('Peer present at join; caller will start call');
//                 await makeCall();
//               }
//               break;

//             case 'peer_joined':
//               debugPrint('<< event: peer_joined');
//               if (_isCaller && !_callStarted) {
//                 _callStarted = true;
//                 debugPrint('Peer joined; caller will start call');
//                 await makeCall();
//               }
//               break;

//             case 'peer_left':
//               debugPrint('<< event: peer_left');
//               // optional: you could hang up or show UI
//               break;

//             default:
//               debugPrint('Unknown signaling type: $type');
//           }
//         } catch (e, st) {
//           debugPrint('Signaling parse error: $e\n$st');
//         }
//       },
//       onError: (err) {
//         debugPrint('WebSocket error: $err');
//       },
//       onDone: () {
//         debugPrint('WebSocket closed by server');
//         try {
//           dispose();
//         } catch (_) {}
//       },
//       cancelOnError: true,
//     );
//   }

//   Future<void> _createPeerConnection() async {
//     if (_peerConnection != null || _pcCreating) return;
//     _pcCreating = true;

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
//       debugPrint('✅ got local stream and attached to localRenderer');
//     } catch (e) {
//       debugPrint('Error accessing camera/mic: $e');
//       _pcCreating = false;
//       return;
//     }

//     _localStream?.getTracks().forEach((track) {
//       _peerConnection?.addTrack(track, _localStream!);
//       debugPrint('>> added local track: ${track.kind}');
//     });

//     _peerConnection!.onTrack = (RTCTrackEvent event) {
//       debugPrint('onTrack called, streams: ${event.streams.length}');
//       if (event.streams.isNotEmpty) {
//         _remoteStream = event.streams[0];
//         _remoteRenderer.srcObject = _remoteStream;
//         debugPrint('✅ Remote stream assigned to renderer');
//       }
//     };

//     _peerConnection!.onIceCandidate = (RTCIceCandidate? candidate) {
//       debugPrint('local ICE candidate event: ${candidate?.candidate}');
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
//         debugPrint('>> candidate sent to signaling server');
//       }
//     };

//     _pcCreating = false;
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
//     try {
//       _callStarted = false;
//       _localStream?.getTracks().forEach((t) => t.stop());
//       _remoteStream?.getTracks().forEach((t) => t.stop());
//       _peerConnection?.close();
//       _peerConnection = null;

//       try {
//         _channel.sink.close(status.normalClosure);
//       } catch (_) {}

//       debugPrint('Signaling disposed');
//     } catch (e) {
//       debugPrint('Error during signaling dispose: $e');
//     }
//   }
// }
