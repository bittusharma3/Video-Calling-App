// lib/services/signaling_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:video_calling_app/config/app_config.dart';
import 'package:flutter/foundation.dart';

class SignalingService {
  final RTCVideoRenderer localRenderer;
  final RTCVideoRenderer remoteRenderer;
  final String roomId;
  final bool isCaller;
  WebSocketChannel? _ws;
  RTCPeerConnection? _pc;
  MediaStream? _localStream;
  final _iceCandidatesQueue = <Map<String, dynamic>>[];
  bool _remoteDescriptionSet = false;

  static Future<SignalingService> startSignaling({
    required RTCVideoRenderer localRenderer,
    required RTCVideoRenderer remoteRenderer,
    required String roomId,
    required bool isCaller,
  }) async {
    final s = SignalingService._(
      localRenderer: localRenderer,
      remoteRenderer: remoteRenderer,
      roomId: roomId,
      isCaller: isCaller,
    );
    await s._init();
    return s;
  }

  SignalingService._({
    required this.localRenderer,
    required this.remoteRenderer,
    required this.roomId,
    required this.isCaller,
  });

  Future<void> _init() async {
    _connectWebSocket();
    await _createPeerConnection();
    await _openUserMedia();
  }

  void _connectWebSocket() {
    final uri = Uri.parse(AppConfig.wsUrl);
    _ws = WebSocketChannel.connect(uri);
    _ws!.stream.listen(_onMessage, onDone: _onDone, onError: _onError);
    _ws!.sink.add(jsonEncode({'type': 'join', 'room': roomId}));
  }

  Future<void> _createPeerConnection() async {
    final configuration = <String, dynamic>{
      'iceServers': AppConfig.iceServers,
      'sdpSemantics': 'unified-plan'
    };
    _pc = await createPeerConnection(configuration);

    _pc!.onIceCandidate = (RTCIceCandidate candidate) {
      if (candidate.candidate != null) {
        _send({
          'type': 'candidate',
          'candidate': {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          }
        });
      }
    };

    _pc!.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        remoteRenderer.srcObject = event.streams[0];
      }
    };

    _pc!.onConnectionState = (RTCPeerConnectionState state) {
      debugPrint('PC connectionState: $state');
    };
  }

  Future<void> _openUserMedia() async {
    final mediaConstraints = {
      'audio': true,
      'video': {
        'facingMode': 'user',
        'width': {'ideal': 1280},
        'height': {'ideal': 720},
        'frameRate': {'ideal': 30}
      }
    };
    try {
      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      localRenderer.srcObject = _localStream;
      debugPrint('Local media obtained: tracks=${_localStream?.getTracks().length}');
      if (_localStream != null && _pc != null) {
        for (var track in _localStream!.getTracks()) {
          await _pc!.addTrack(track, _localStream!);
        }
      }
    } catch (e, st) {
      debugPrint('getUserMedia failed: $e\n$st');
      rethrow;
    }
  }

  void _onMessage(dynamic message) async {
    if (message == null) return;
    dynamic data;
    try {
      data = jsonDecode(message as String);
    } catch (e) {
      debugPrint('Invalid JSON from ws: $e');
      return;
    }

    final type = data['type'];
    if (type == 'joined') {
      if (isCaller) await _createOffer();
    } else if (type == 'match') {
      final role = data['role'] ?? 'caller';
      if (role == 'caller') await _createOffer();
    } else if (type == 'offer') {
      final sdp = data['sdp'];
      if (sdp != null) await _handleOffer(sdp);
    } else if (type == 'answer') {
      final sdp = data['sdp'];
      if (sdp != null) await _handleAnswer(sdp);
    } else if (type == 'candidate') {
      final candidateObj = data['candidate'];
      if (candidateObj != null) await _handleCandidate(candidateObj);
    }
  }

  Future<void> _createOffer() async {
    if (_pc == null) return;
    final offer = await _pc!.createOffer();
    await _pc!.setLocalDescription(offer);
    _send({'type': 'offer', 'sdp': offer.sdp, 'sdpType': offer.type});
  }

  Future<void> _handleOffer(String sdp) async {
    if (_pc == null) await _createPeerConnection();
    final desc = RTCSessionDescription(sdp, 'offer');
    await _pc!.setRemoteDescription(desc);
    _remoteDescriptionSet = true;
    for (var c in _iceCandidatesQueue) {
      await _addCandidateToPc(c);
    }
    _iceCandidatesQueue.clear();
    final answer = await _pc!.createAnswer();
    await _pc!.setLocalDescription(answer);
    _send({'type': 'answer', 'sdp': answer.sdp, 'sdpType': answer.type});
  }

  Future<void> _handleAnswer(String sdp) async {
    if (_pc == null) return;
    final desc = RTCSessionDescription(sdp, 'answer');
    await _pc!.setRemoteDescription(desc);
    _remoteDescriptionSet = true;
    for (var c in _iceCandidatesQueue) {
      await _addCandidateToPc(c);
    }
    _iceCandidatesQueue.clear();
  }

  Future<void> _handleCandidate(Map<String, dynamic> candidateObj) async {
    if (_pc == null || !_remoteDescriptionSet) {
      _iceCandidatesQueue.add(candidateObj);
    } else {
      await _addCandidateToPc(candidateObj);
    }
  }

  Future<void> _addCandidateToPc(Map<String, dynamic> cand) async {
    try {
      final candidateStr = cand['candidate'] as String?;
      final sdpMid = cand['sdpMid'] as String?;
      int? sdpMlineIndex;
      final maybeIdx = cand['sdpMLineIndex'] ?? cand['sdpMlineIndex'];
      if (maybeIdx != null) {
        if (maybeIdx is int) {
          sdpMlineIndex = maybeIdx;
        } else if (maybeIdx is double) {
          sdpMlineIndex = maybeIdx.toInt();
        } else if (maybeIdx is String) {
          sdpMlineIndex = int.tryParse(maybeIdx);
        }
      }

      final candidate = RTCIceCandidate(candidateStr, sdpMid, sdpMlineIndex);
      await _pc?.addCandidate(candidate);
    } catch (e) {
      debugPrint('addCandidate error: $e');
    }
  }

  void _send(Map<String, dynamic> message) {
    try {
      _ws?.sink.add(jsonEncode(message));
    } catch (e) {
      debugPrint('WS send error: $e');
    }
  }

  void _onDone() {
    debugPrint('WS closed');
  }

  void _onError(error) {
    debugPrint('WS error: $error');
  }

  // Public controls
  Future<void> hangUp() async {
    try {
      _send({'type': 'leave'});
    } catch (_) {}
    dispose();
  }

  Future<void> switchCamera() async {
    if (_localStream == null) return;
    for (var track in _localStream!.getVideoTracks()) {
      await Helper.switchCamera(track);
    }
  }

  Future<void> muteLocalAudio(bool mute) async {
    if (_localStream == null) return;
    for (var t in _localStream!.getAudioTracks()) {
      t.enabled = !mute ? true : false;
    }
  }

  Future<void> muteVideo(bool disable) async {
    if (_localStream == null) return;
    for (var t in _localStream!.getVideoTracks()) {
      t.enabled = !disable ? true : false;
    }
  }

  void dispose() {
    try {
      _ws?.sink.close();
    } catch (_) {}
    try {
      _pc?.close();
    } catch (_) {}
    _pc = null;
    try {
      _localStream?.getTracks().forEach((t) => t.stop());
    } catch (_) {}
    _localStream = null;
    try {
      localRenderer.srcObject = null;
      remoteRenderer.srcObject = null;
    } catch (_) {}
  }
}
