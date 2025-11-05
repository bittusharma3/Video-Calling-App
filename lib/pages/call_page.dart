// lib/pages/call_page.dart
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_calling_app/services/signaling_service.dart';

class CallPage extends StatefulWidget {
  final String roomId;
  final bool isCaller;

  const CallPage({Key? key, required this.roomId, required this.isCaller}) : super(key: key);

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> with SingleTickerProviderStateMixin {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  SignalingService? _signaling;

  bool _cameraFront = true;
  bool _mutedAudio = false;
  bool _mutedVideo = false;
  bool _connected = false;
  Timer? _timer;
  int _elapsedSeconds = 0;

  // If true, local is full screen; else remote is full screen.
  bool _localFullScreen = false;

  // Overlay position: we'll manage using top & left (in pixels).
  // Initialize to a default (top-right).
  double _overlayTop = 40;
  double _overlayLeft = 0; // will compute default in didChangeDependencies

  // overlay dimensions
  static const double _overlayWidth = 160;
  static const double _overlayHeight = 220;

  // used for drag gestures
  Offset? _dragStartLocalPosition;
  double? _dragStartLeft;
  double? _dragStartTop;

  @override
  void initState() {
    super.initState();
    _initRenderers().then((_) => _startFlow());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // compute initial top/left: top-right corner with margin
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final defaultLeft = screenWidth - _overlayWidth - 14;
    if (_overlayLeft == 0) _overlayLeft = defaultLeft;
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> _startFlow() async {
    // Ask permissions for mobile
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      final cam = await Permission.camera.request();
      final mic = await Permission.microphone.request();
      if (!cam.isGranted || !mic.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Camera & Microphone permission required')));
        }
        return;
      }
    }

    try {
      _signaling = await SignalingService.startSignaling(
        localRenderer: _localRenderer,
        remoteRenderer: _remoteRenderer,
        roomId: widget.roomId,
        isCaller: widget.isCaller,
      );
      _startConnectionWatcher();
    } catch (e) {
      debugPrint('Signaling start error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to start call: $e')));
      }
    }
  }

  void _startConnectionWatcher() {
    Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (!_connected && _remoteRenderer.srcObject != null) {
        setState(() {
          _connected = true;
          _startTimer();
        });
        t.cancel();
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _elapsedSeconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds++);
    });
  }

  String _elapsedFormatted() {
    final m = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _toggleAudio() async {
    try {
      await _signaling?.muteLocalAudio(!_mutedAudio);
      if (mounted) setState(() => _mutedAudio = !_mutedAudio);
    } catch (e) {
      debugPrint('toggleAudio error: $e');
    }
  }

  Future<void> _toggleVideo() async {
    try {
      await _signaling?.muteVideo(!_mutedVideo);
      if (mounted) setState(() => _mutedVideo = !_mutedVideo);
    } catch (e) {
      debugPrint('toggleVideo error: $e');
    }
  }

  Future<void> _switchCamera() async {
    try {
      await _signaling?.switchCamera();
      if (mounted) setState(() => _cameraFront = !_cameraFront);
    } catch (e) {
      debugPrint('switch camera error: $e');
    }
  }

  Future<void> _endCall() async {
    try {
      await _signaling?.hangUp();
    } catch (e) {
      debugPrint('hangup error: $e');
    } finally {
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _signaling?.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  void _swapScreens() {
    setState(() => _localFullScreen = !_localFullScreen);
  }

  // Drag handlers
  void _onPanStart(DragStartDetails details) {
    _dragStartLocalPosition = details.localPosition;
    _dragStartLeft = _overlayLeft;
    _dragStartTop = _overlayTop;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_dragStartLeft == null || _dragStartTop == null) return;
    final dx = details.localPosition.dx - _dragStartLocalPosition!.dx;
    final dy = details.localPosition.dy - _dragStartLocalPosition!.dy;
    final newLeft = (_dragStartLeft! + dx).clamp(_minLeft(), _maxLeft());
    final newTop = (_dragStartTop! + dy).clamp(_minTop(), _maxTop());
    setState(() {
      _overlayLeft = newLeft;
      _overlayTop = newTop;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    // Reset drag start trackers
    _dragStartLocalPosition = null;
    _dragStartLeft = null;
    _dragStartTop = null;
  }

  double _minLeft() {
    return 8.0;
  }

  double _maxLeft() {
    final w = MediaQuery.of(context).size.width;
    return (w - _overlayWidth - 8.0);
  }

  double _minTop() {
    // keep below status bar / safe area
    final topPadding = MediaQuery.of(context).padding.top;
    return topPadding + 8.0;
  }

  double _maxTop() {
    final h = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return (h - _overlayHeight - bottomPadding - 8.0);
  }

  Widget _buildMainVideo() {
    final RTCVideoRenderer mainRenderer = _localFullScreen ? _localRenderer : _remoteRenderer;
    final bool isLocalMain = _localFullScreen;
    return GestureDetector(
      onTap: () {},
      child: SizedBox.expand(
        child: Container(
          color: Colors.black,
          child: RTCVideoView(
            mainRenderer,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            mirror: isLocalMain ? _cameraFront : false,
          ),
        ),
      ),
    );
  }

  Widget _buildDraggableOverlay() {
    final RTCVideoRenderer overlayRenderer = _localFullScreen ? _remoteRenderer : _localRenderer;
    final bool overlayIsLocal = !_localFullScreen;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 180),
      top: _overlayTop,
      left: _overlayLeft,
      child: GestureDetector(
        onTap: _swapScreens,
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: _overlayWidth,
          height: _overlayHeight,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 8, offset: const Offset(0, 3))],
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: overlayRenderer.srcObject == null
                ? Center(
                    child: Text(
                      overlayIsLocal ? 'You (no preview)' : 'Remote (waiting)',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  )
                : RTCVideoView(
                    overlayRenderer,
                    mirror: overlayIsLocal ? _cameraFront : false,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        color: Colors.black45,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Room: ${widget.roomId}', style: const TextStyle(color: Colors.white)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(widget.isCaller ? 'Caller' : 'Participant', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                Text(_connected ? 'Connected • ${_elapsedFormatted()}' : 'Connecting...', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _controls() {
    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            heroTag: 'mute_audio',
            onPressed: _toggleAudio,
            backgroundColor: _mutedAudio ? Colors.orange : Colors.white,
            child: Icon(_mutedAudio ? Icons.mic_off : Icons.mic, color: Colors.black),
            mini: true,
          ),
          FloatingActionButton(
            heroTag: 'switch_cam',
            onPressed: _switchCamera,
            backgroundColor: Colors.white,
            child: const Icon(Icons.cameraswitch, color: Colors.black),
            mini: true,
          ),
          FloatingActionButton(
            heroTag: 'end_call',
            onPressed: _endCall,
            backgroundColor: Colors.red,
            child: const Icon(Icons.call_end, color: Colors.white),
            elevation: 4,
          ),
          FloatingActionButton(
            heroTag: 'toggle_video',
            onPressed: _toggleVideo,
            backgroundColor: _mutedVideo ? Colors.orange : Colors.white,
            child: Icon(_mutedVideo ? Icons.videocam_off : Icons.videocam, color: Colors.black),
            mini: true,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildMainVideo(),
          _buildDraggableOverlay(),
          _topBar(),
          _controls(),
        ],
      ),
    );
  }
}
