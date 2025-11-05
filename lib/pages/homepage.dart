// lib/pages/homepage.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'call_page.dart';
import 'package:video_calling_app/config/app_config.dart';
import 'package:video_calling_app/utils/theme_controller.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final TextEditingController roomController = TextEditingController();
  bool _loadingMatch = false;

  String _makeRandomRoomId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now % 0xFFFFFF).toRadixString(16).padLeft(6, '0');
  }

  void _createRoomAndCall() {
    final roomId = _makeRandomRoomId();
    Navigator.push(context, MaterialPageRoute(builder: (_) => CallPage(roomId: roomId, isCaller: true)));
  }

  void _joinRoom() {
    final roomId = roomController.text.trim();
    if (roomId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter a room id")));
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => CallPage(roomId: roomId, isCaller: false)));
  }

  Future<void> _randomPair() async {
    setState(() => _loadingMatch = true);
    StreamSubscription? sub;
    try {
      final uri = Uri.parse(AppConfig.wsUrl);
      final channel = WebSocketChannel.connect(uri);
      sub = channel.stream.listen((msg) {
        try {
          final data = jsonDecode(msg);
          final type = data['type'];
          if (type == 'match') {
            final room = data['room'] as String;
            final role = (data['role'] as String?) ?? 'caller';
            channel.sink.close();
            sub?.cancel();
            setState(() => _loadingMatch = false);
            final isCaller = role == 'caller';
            Navigator.push(context, MaterialPageRoute(builder: (_) => CallPage(roomId: room, isCaller: isCaller)));
          } else if (type == 'waiting') {
            // optional UI indicator
          }
        } catch (_) {}
      });

      channel.sink.add(jsonEncode({'type': 'find'}));
      Future.delayed(const Duration(seconds: 12), () {
        if (_loadingMatch) {
          try { channel.sink.close(); sub?.cancel(); } catch (_) {}
          setState(() => _loadingMatch = false);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No match found")));
        }
      });
    } catch (e) {
      setState(() => _loadingMatch = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  void dispose() {
    roomController.dispose();
    super.dispose();
  }

  Widget _themeIconButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      tooltip: isDark ? "Switch to Light Mode" : "Switch to Dark Mode",
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) => RotationTransition(
          turns: child.key == const ValueKey('sun')
              ? Tween(begin: 0.75, end: 1.0).animate(anim)
              : Tween(begin: 0.25, end: 1.0).animate(anim),
          child: FadeTransition(opacity: anim, child: child),
        ),
        child: Icon(
          isDark ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
          key: ValueKey(isDark ? 'sun' : 'moon'),
          color: isDark ? Colors.amberAccent : Colors.deepPurple,
        ),
      ),
      onPressed: () async {
        await ThemeController.toggleTheme();
        setState(() {}); // rebuild to reflect icon change immediately
      },
    );
  }

  Widget _bigButton(String label, {required VoidCallback onTap, Color? color}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
        backgroundColor: color ?? Colors.blueAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
      ),
      child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect - Video Chat'),
        centerTitle: true,
        elevation: 2,
        actions: [
          _themeIconButton(),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('Instant Video Chat', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: roomController,
                    decoration: const InputDecoration(
                      labelText: 'Enter Room ID (paste)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _bigButton('Join Room', onTap: _joinRoom, color: Colors.green)),
                      const SizedBox(width: 10),
                      Expanded(child: _bigButton('Create & Call', onTap: _createRoomAndCall, color: Colors.blueAccent)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _bigButton(_loadingMatch ? 'Finding...' : 'Random Pair (Find Stranger)', onTap: _loadingMatch ? (){} : _randomPair, color: Colors.orange),
                  const SizedBox(height: 14),
                  const Text('Tip: Use Create to generate a simple 6-char room id and share it.', style: TextStyle(fontSize: 12), textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
