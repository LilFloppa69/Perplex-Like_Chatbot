import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:perplexity_clone/theme/colors.dart';
import 'package:perplexity_clone/widgets/side_bar.dart';
import 'package:perplexity_clone/services/chat_web_service.dart';
import 'package:perplexity_clone/widgets/sources_section.dart';

class ChatPage extends StatefulWidget {
  final String question;
  final String initialLLM;
  final bool initialSearchMode;

  final Uint8List? initialImageBytes; // 🔥 NEW: image from ImagePage

  const ChatPage({
    super.key,
    required this.question,
    required this.initialLLM,
    required this.initialSearchMode,
    this.initialImageBytes,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Map<String, dynamic>> messages = [];
  List<List> allSources = [];

  TextEditingController inputController = TextEditingController();

  String selectedLLM = "Gemini 2.5";
  bool searchMode = true;

  @override
  void initState() {
    super.initState();

    selectedLLM = widget.initialLLM;
    searchMode = widget.initialSearchMode;

    // 1) user bubble pertama
    messages.add({
      "role": "user",
      "type": "text",
      "content": widget.question,
    });
    allSources.add([]);

    // 2) assistant bubble pertama
    if (widget.initialImageBytes != null) {
      // 🔥 If this chat came from ImagePage → show image bubble first
      messages.add({
        "role": "assistant",
        "type": "image",
        "image_bytes": widget.initialImageBytes,
      });
    } else {
      messages.add({
        "role": "assistant",
        "type": "text",
        "content": "",
      });
    }

    allSources.add([]);

    _listenStreams();

    // 🔥 Hanya kirim query ke LLM jika ini bukan image_chat
    if (widget.initialImageBytes == null) {
      ChatWebService().chat(
        widget.question,
        selectedLLM,
        messages,
        searchMode,
      );
    }
  }

  void _listenStreams() {
    ChatWebService().contentStream.listen((data) {
      final chunk = data["data"] as String;

      final idx = _findLastAssistantIndex();
      if (idx == -1) return;

      // only append to text messages
      if (messages[idx]["type"] == "text") {
        messages[idx]["content"] = (messages[idx]["content"] ?? "") + chunk;
      }

      setState(() {});
    });

    ChatWebService().searchResultStream.listen((data) {
      final idx = _findLastAssistantIndex();
      if (idx != -1) {
        allSources[idx] = data["data"] as List;
      }
      setState(() {});
    });
  }

  int _findLastAssistantIndex() {
    for (int i = messages.length - 1; i >= 0; i--) {
      if (messages[i]["role"] == "assistant") return i;
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: AppColors.sideNav,
              title: const Text("Chat", style: TextStyle(color: Colors.white)),
            ),
      drawer: isDesktop ? null : Drawer(child: const SideBar()),
      body: Row(
        children: [
          if (isDesktop) const SideBar(),
          Expanded(
            child: Column(
              children: [
                Expanded(child: _buildConversation()),
                const SizedBox(height: 10),
                _buildInputBar(),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // CHAT LIST
  // =====================================================

  Widget _buildConversation() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: messages.asMap().entries.map((entry) {
          final index = entry.key;
          final msg = entry.value;
          final role = msg["role"];
          final type = msg["type"];
          final sources = allSources[index];

          if (role == "assistant") {
            if (type == "image") {
              return _aiImageBubble(msg["image_bytes"]);
            } else {
              return _aiTextBubble(msg["content"], sources);
            }
          }

          return _userBubble(msg["content"]);
        }).toList(),
      ),
    );
  }

  // =====================================================
  // BUBBLES
  // =====================================================

  Widget _userBubble(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade700,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _aiTextBubble(String text, List sources) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (sources.isNotEmpty)
              Column(
                children: [
                  SourcesSection(sources: sources),
                  const SizedBox(height: 12),
                ],
              ),
            Text(text,
                style: const TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _aiImageBubble(Uint8List? bytes) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(bytes!, width: 300, fit: BoxFit.cover),
        ),
      ),
    );
  }

  // =====================================================
  // INPUT BAR
  // =====================================================

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.searchBar,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.searchBarBorder),
      ),
      child: Row(
        children: [
          // MODEL DROPDOWN
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                dropdownColor: AppColors.cardColor,
                value: selectedLLM,
                style: const TextStyle(color: Colors.white),
                items: const [
                  DropdownMenuItem(
                      value: "Gemini 2.5", child: Text("Gemini 2.5")),
                  DropdownMenuItem(
                      value: "NoFilterGPT", child: Text("NoFilterGPT")),
                ],
                onChanged: (v) => setState(() => selectedLLM = v!),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // SEARCH MODE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<bool>(
                dropdownColor: AppColors.cardColor,
                value: searchMode,
                style: const TextStyle(color: Colors.white),
                items: const [
                  DropdownMenuItem(value: true, child: Text("Search: ON")),
                  DropdownMenuItem(value: false, child: Text("Search: OFF")),
                ],
                onChanged: (v) => setState(() => searchMode = v!),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: TextField(
              controller: inputController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Type a message...",
                hintStyle: TextStyle(color: AppColors.textGrey),
                border: InputBorder.none,
              ),
            ),
          ),

          GestureDetector(
            onTap: _sendMessage,
            child: Icon(Icons.send, color: AppColors.submitButton),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = inputController.text.trim();
    if (text.isEmpty) return;

    // Add user bubble
    messages.add({"role": "user", "type": "text", "content": text});
    allSources.add([]);

    // Add new assistant bubble (text)
    messages.add({"role": "assistant", "type": "text", "content": ""});
    allSources.add([]);

    inputController.clear();

    ChatWebService().chat(text, selectedLLM, messages, searchMode);

    setState(() {});
  }
}
