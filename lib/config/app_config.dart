// lib/config/app_config.dart
class AppConfig {
  // Set this to your signaling server
  // For local LAN testing: 'ws://192.168.x.y:8080'
  // For ngrok: 'wss://xxxxx.ngrok.io'
  // For production: 'wss://yourdomain.com'
  static const String wsUrl = 'ws://YOUR_SIGNALING_SERVER:8080';

  // ICE servers (add your TURN credentials here)
  static const List<Map<String, dynamic>> iceServers = [
    { 'urls': 'stun:stun.l.google.com:19302' },
    {
      'urls': 'turn:YOUR_PUBLIC_IP:3478',
      'username': 'turnuser',
      'credential': 'turnpassword'
    },
    // Optionally secure TURN:
    // {
    //   'urls': 'turns:yourdomain.com:5349',
    //   'username': 'turnuser',
    //   'credential': 'turnpassword'
    // }
  ];
}
