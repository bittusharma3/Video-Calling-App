import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'call_page.dart';

class StartRoomPage extends StatefulWidget {
  const StartRoomPage({super.key});

  @override
  State<StartRoomPage> createState() => _StartRoomPageState();
}

class _StartRoomPageState extends State<StartRoomPage> {
  final TextEditingController roomController = TextEditingController();
  WebSocketChannel? channel;
  bool isLoading = false;

  void _startRoom() {
    final roomId = roomController.text.trim();
    if (roomId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid Room ID")),
      );
      return;
    }

    setState(() => isLoading = true);

    // Use your server IP here
    final url = 'ws://YOUR_SERVER_IP:8080/rooms';
    print('🌐 Connecting to WebSocket at $url');

    channel = WebSocketChannel.connect(Uri.parse(url));

    // Listen for messages from server
    channel!.stream.listen((message) {
      print('📩 Received from server: $message');
    }, onDone: () {
      print('❌ Connection closed by server');
    }, onError: (error) {
      print('⚠️ WebSocket error: $error');
    });

    // Send initial join message
    final joinMessage = {'type': 'join', 'room': roomId};
    channel!.sink.add(joinMessage.toString());
    print('✅ Sent join message: $joinMessage');

    // Navigate to CallPage
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CallPage(roomId: roomId)),
    );

    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    channel?.sink.close();
    roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Start a New Room")),
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isLoading
              ? const CircularProgressIndicator()
              : Container(
                  width: 350,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Start a New Room",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: roomController,
                        decoration: InputDecoration(
                          labelText: "Enter Room ID",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _startRoom,
                          child: const Text("Confirm & Start"),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Create a new private room to start a secure call.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
