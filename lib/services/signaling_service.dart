// // lib/services/signaling_service.dart
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:video_calling_app/config/app_config.dart';
// import 'package:video_calling_app/services/signaling.dart';

// class SignalingService {
//   /// Initializes and connects the signaling for WebRTC calls.
//   static Future<Signaling> startSignaling({
//     required RTCVideoRenderer localRenderer,
//     required RTCVideoRenderer remoteRenderer,
//     required String roomId,
//     required bool isCaller,
//   }) async {
//     final wsUrl = AppConfig.wsUrl; // Single source of truth from config

//     final signaling = Signaling(localRenderer, remoteRenderer, wsUrl: wsUrl);
//     await signaling.connect(roomId, isCaller: isCaller);
//     return signaling;
//   }
// }


import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../config/app_config.dart';
import 'signaling.dart';

class SignalingService {
  /// Initializes and connects the signaling for WebRTC calls.
  static Future<Signaling> startSignaling({
    required RTCVideoRenderer localRenderer,
    required RTCVideoRenderer remoteRenderer,
    required String roomId,
    required bool isCaller,
  }) async {
    // Use the wsUrl from AppConfig
    final wsUrl = AppConfig.wsUrl;

    final signaling = Signaling(
      localRenderer,
      remoteRenderer,
      wsUrl: wsUrl,
    );

    await signaling.connect(roomId, isCaller: isCaller);

    return signaling;
  }
}
