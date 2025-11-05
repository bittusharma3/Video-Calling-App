// lib/pages/join_page.dart
import 'package:flutter/material.dart';
import 'call_page.dart';

class JoinPage extends StatefulWidget {
  final String? initialRoomId;
  const JoinPage({Key? key, this.initialRoomId}) : super(key: key);

  @override
  State<JoinPage> createState() => _JoinPageState();
}

class _JoinPageState extends State<JoinPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialRoomId ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _join() {
    final room = _controller.text.trim();
    if (room.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a room id")));
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => CallPage(roomId: room, isCaller: false)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Room')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(controller: _controller, decoration: const InputDecoration(labelText: 'Room ID')),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _join, child: const Text('Join as Participant')),
        ]),
      ),
    );
  }
}
