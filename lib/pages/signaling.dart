import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Signaling {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  final RTCVideoRenderer _localRenderer;
  final RTCVideoRenderer _remoteRenderer;

  late WebSocketChannel _channel;
  bool _isCaller = false;

  // ✅ Signaling server (for Android emulator)
  final String wsUrl = 'ws://10.0.2.2:8080';

  // ✅ STUN + TURN
  final Map<String, dynamic> configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {
        'urls': 'turn:openrelay.metered.ca:80',
        'username': 'openrelayproject',
        'credential': 'openrelayproject'
      },
    ]
  };

  Signaling(this._localRenderer, this._remoteRenderer);

  // 🚀 Connect to WebSocket server
  Future<void> connect(String roomId, {bool isCaller = false}) async {
    _isCaller = isCaller;
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    _channel.sink.add(jsonEncode({'type': 'join', 'room': roomId}));

    _channel.stream.listen((message) async {
      final data = jsonDecode(message);
      final type = data['type'];

      switch (type) {
        case 'offer':
          await _createPeerConnection();
          await _peerConnection!.setRemoteDescription(
              RTCSessionDescription(data['sdp'], type));
          final answer = await _peerConnection!.createAnswer();
          await _peerConnection!.setLocalDescription(answer);
          _channel.sink.add(jsonEncode({'type': 'answer', 'sdp': answer.sdp}));
          break;

        case 'answer':
          await _peerConnection!.setRemoteDescription(
              RTCSessionDescription(data['sdp'], type));
          break;

        case 'candidate':
          final candidate = RTCIceCandidate(
            data['candidate'],
            data['sdpMid'],
            data['sdpMLineIndex'], // ✅ corrected property name
          );
          await _peerConnection!.addCandidate(candidate);
          break;
      }
    });

    if (_isCaller) {
      await makeCall();
    }
  }

  // ⚙️ Peer connection setup
  Future<void> _createPeerConnection() async {
    _peerConnection = await createPeerConnection(configuration);

    _localStream = await navigator.mediaDevices
        .getUserMedia({'audio': true, 'video': true});
    _localRenderer.srcObject = _localStream;

    for (var track in _localStream!.getTracks()) {
      _peerConnection!.addTrack(track, _localStream!);
    }

    _peerConnection!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams[0];
        _remoteRenderer.srcObject = _remoteStream;
      }
    };

    _peerConnection!.onIceCandidate = (candidate) {
      if (candidate.candidate != null) {
        _channel.sink.add(jsonEncode({
          'type': 'candidate',
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex, // ✅ fixed here too
        }));
      }
    };
  }

  // 📞 Start call
  Future<void> makeCall() async {
    await _createPeerConnection();
    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    _channel.sink.add(jsonEncode({'type': 'offer', 'sdp': offer.sdp}));
  }

  // 🧹 Cleanup
  void dispose() {
    _localStream?.dispose();
    _remoteStream?.dispose();
    _peerConnection?.close();
    _channel.sink.close();
  }
}
