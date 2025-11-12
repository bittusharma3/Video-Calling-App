// lib/config/app_config.dart
import 'package:flutter/foundation.dart';

class AppConfig {
  // Production WebSocket endpoint hosted on Render
  static const String _prodUrl = 'wss://video-calling-app-ernw.onrender.com/rooms';

  // Local development URL fallback (optional)
  static const String _devUrl = 'ws://192.168.1.9:8080/rooms';

  static String get wsUrl {
    // If you run on production (web or mobile build release), use prod URL
    if (kReleaseMode) return _prodUrl;

    // Otherwise in dev, fallback to your local WS
    return _devUrl;
  }
}
