// lib/config/app_config.dart
import 'package:flutter/foundation.dart';

class AppConfig {
  // Production WebSocket endpoint hosted on Render
  static const String _prodUrl = 'wss://video-calling-app-ernw.onrender.com';

  // Local development URL fallback (optional)
  static const String _devUrl = 'ws://localhost:8080';

  static String get wsUrl {
    // If you run on production (web or mobile build release), use prod URL
    if (kReleaseMode) return _prodUrl;

    // Otherwise in dev, fallback to your local WS
    return _devUrl;
  }
}
