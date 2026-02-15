# 📹 PeerConnect  
### Flutter WebRTC Video Calling App

A cross-platform **Flutter video calling application** powered by **WebRTC**, built with a custom signaling server and full **STUN/TURN** support.

This project enables two peers to establish a direct real-time audio/video connection across multiple platforms.

---

## 🚀 Features

- 🔗 Peer-to-Peer Video Calling  
- 🎤 Real-time Audio & Video Streaming  
- 🌍 Cross-Platform Support  
  - Android  
  - iOS  
  - Web  
  - Windows  
  - macOS  
  - Linux  
- 🛰️ Custom Signaling Server  
- 🔄 STUN & TURN Integration  
- ⚡ Fast Connection Setup  
- 🧪 Multi-device Testing Support  

---

## 🏗️ Project Structure

```bash
.
├── android/              # Android platform code
├── ios/                  # iOS platform code
├── web/                  # Web build support
├── windows/              # Windows support
├── macos/                # macOS support
├── linux/                # Linux support
├── lib/                  # Flutter application source
├── server/               # Node.js signaling server
├── pubspec.yaml          # Flutter dependencies
```

---

## 🧠 Tech Stack

### 🎨 Frontend
- Flutter
- Dart
- flutter_webrtc

### ⚙️ Backend
- Node.js
- WebSocket (Signaling)

### 🌐 Networking
- WebRTC
- STUN
- TURN

---

## 🔌 How It Works

1. User A joins a room.
2. User B joins the same room.
3. The signaling server exchanges:
   - SDP Offers
   - SDP Answers
   - ICE Candidates
4. A direct peer-to-peer connection is established.
5. Real-time audio & video streaming begins.

---

## 🧪 Testing Instructions

1. Start the signaling server:
   ```bash
   cd server
   npm install
   node server.js
   ```

2. Run the Flutter app:
   ```bash
   flutter pub get
   flutter run
   ```

3. Open the app on two devices.
4. Join using the same Room ID.
5. Allow camera and microphone permissions.
6. Connection should establish automatically.

---

## 🛠️ Future Improvements

- Group video calling
- Screen sharing
- In-call chat
- Call recording
- User authentication
- Room history tracking

---


## 📄 License

This project is open-source and available under the MIT License not completed yet . 
