import 'dart:async';
import 'dart:convert';
import 'package:perplexity_clone/services/websocket_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatWebService {
  static final ChatWebService _instance = ChatWebService._internal();
  factory ChatWebService() => _instance;

  ChatWebService._internal();

  final _searchResultStream =
      StreamController<Map<String, dynamic>>.broadcast();
  final _contentStream = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get searchResultStream =>
      _searchResultStream.stream;

  Stream<Map<String, dynamic>> get contentStream => _contentStream.stream;

  void connect() {
    WebSocketManager().connect(
      onMessage: _handleMessage,
    );
  }

  void _handleMessage(String raw) {
    try {
      final data = json.decode(raw);

      if (data['type'] == 'search_results') {
        _searchResultStream.add(data);
      } else if (data['type'] == 'content') {
        _contentStream.add(data);
      }
    } catch (e) {
      print("WS decode error: $e");
    }
  }

  /// Chat ke backend dengan:
  /// - query: teks user
  /// - llm: nama model (Gemini 2.5 / NoFilterGPT / dll)
  /// - history: seluruh riwayat pesan (user+assistant)
  /// - searchMode: true = pakai Tavily, false = no web search
  Future<void> chat(String query, String llm,
      List<Map<String, dynamic>> history, bool searchMode) async {
    final socket = WebSocketManager().socket;

    if (socket == null) {
      print("❌ WebSocket not connected.");
      return;
    }

    // Load saved personality settings
    final prefs = await SharedPreferences.getInstance();
    final customInstruction = prefs.getString("custom_instruction") ?? "";
    final behaviorMode = prefs.getString("behavior_mode") ?? "Default";

    // Build payload for backend
    final payload = json.encode({
      'query': query,
      'llm': llm,
      'history': history,
      'search_mode': searchMode,
      'instruction': customInstruction,
      'behavior': behaviorMode,
    });

    socket.send(payload);

    print("➡ SENT QUERY: $payload");
  }

  void dispose() {
    _searchResultStream.close();
    _contentStream.close();
  }
}
