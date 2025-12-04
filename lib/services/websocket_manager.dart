import 'dart:async';
import 'package:web_socket_client/web_socket_client.dart';

class WebSocketManager {
  static final WebSocketManager _instance = WebSocketManager._internal();
  factory WebSocketManager() => _instance;

  WebSocketManager._internal();

  final Uri _url = Uri.parse("ws://127.0.0.1:8000/ws/chat");

  WebSocket? socket;
  bool _isConnecting = false;

  StreamSubscription? _msgSub;
  StreamSubscription<ConnectionState>? _eventSub;

  void connect({required Function(String) onMessage}) {
    if (_isConnecting || socket != null) return;

    _isConnecting = true;
    print("🔌 Connecting to WebSocket: $_url");

    socket = WebSocket(
      _url,
      backoff: ConstantBackoff(
        Duration(seconds: 2),
      ),
    );

    /// Listen to connection events
    _eventSub = socket!.connection.listen((event) {
      print("WS EVENT: $event");

      if (event is Connected) print("🟢 CONNECTED");
      if (event is Disconnected) print("🔴 DISCONNECTED");
      if (event is Reconnecting) print("🟡 RECONNECTING…");
      if (event is Reconnected) print("🟢 RECONNECTED");
    });

    /// Listen incoming raw messages (String only)
    _msgSub = socket!.messages.listen((msg) {
      if (msg is String) {
        onMessage(msg);
      }
    });

    _isConnecting = false;
  }

  void send(String text) {
    if (socket == null) {
      print("❌ WebSocket not connected, message dropped.");
      return;
    }
    socket!.send(text);
  }

  void dispose() {
    _msgSub?.cancel();
    _eventSub?.cancel();
    socket?.close();
    socket = null;
    print("🧹 WebSocket closed");
  }
}
