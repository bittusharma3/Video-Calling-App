// lib/pages/signaling.dart
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

  Signaling(this._localRenderer, this._remoteRenderer, {required this.wsUrl});

  final Map<String, dynamic> configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'}
    ]
  };

  Future<void> connect(String roomId, {bool isCaller = false}) async {
    _isCaller = isCaller;
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    _channel.sink.add(jsonEncode({'type': 'join', 'room': roomId}));

    _channel.stream.listen((message) async {
      try {
        final data = jsonDecode(message);
        final type = data['type'];

        switch (type) {
          case 'offer':
            await _createPeerConnection();
            await _peerConnection!.setRemoteDescription(
              RTCSessionDescription(data['sdp'], 'offer'),
            );
            final answer = await _peerConnection!.createAnswer();
            await _peerConnection!.setLocalDescription(answer);
            _channel.sink.add(jsonEncode({'type': 'answer', 'sdp': answer.sdp}));
            break;

          case 'answer':
            if (_peerConnection != null) {
              await _peerConnection!.setRemoteDescription(
                RTCSessionDescription(data['sdp'], 'answer'),
              );
            }
            break;

          case 'candidate':
            final cand = data['candidate'];
            if (cand != null && _peerConnection != null) {
              await _peerConnection!.addCandidate(
                RTCIceCandidate(cand['candidate'], cand['sdpMid'], cand['sdpMLineIndex']),
              );
            }
            break;

          case 'joined':
            if (_isCaller) await makeCall();
            break;
        }
      } catch (e) {
        debugPrint('Signaling parse error: $e');
      }
    });
  }

  Future<void> _createPeerConnection() async {
    if (_peerConnection != null) return;

    _peerConnection = await createPeerConnection(configuration);

    _localStream ??= await navigator.mediaDevices
        .getUserMedia({'audio': true, 'video': {'facingMode': 'user'}});

    _localRenderer.srcObject = _localStream;

    for (var track in _localStream!.getTracks()) {
      _peerConnection!.addTrack(track, _localStream!);
    }

    _peerConnection!.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams[0];
        _remoteRenderer.srcObject = _remoteStream;
      }
    };

    _peerConnection!.onIceCandidate = (RTCIceCandidate? candidate) {
      if (candidate != null) {
        _channel.sink.add(jsonEncode({
          'type': 'candidate',
          'candidate': {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          },
        }));
      }
    };
  }

  Future<void> makeCall() async {
    if (_peerConnection == null) await _createPeerConnection();

    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    _channel.sink.add(jsonEncode({'type': 'offer', 'sdp': offer.sdp}));
  }

  void dispose() {
    try {
      _localStream?.getTracks().forEach((t) => t.stop());
      _remoteStream?.getTracks().forEach((t) => t.stop());
      _peerConnection?.close();
      _channel.sink.close(status.normalClosure);
    } catch (_) {}
  }
}
