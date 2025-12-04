import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:perplexity_clone/pages/chat_page.dart';
import 'package:perplexity_clone/widgets/side_bar.dart';
import 'package:perplexity_clone/theme/colors.dart';

class ImagePage extends StatefulWidget {
  const ImagePage({super.key});

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  final TextEditingController promptController = TextEditingController();

  bool isLoading = false;
  Uint8List? generatedImage;

  /// Default chat settings if sent to ChatPage
  final String defaultLLM = "Gemini 2.5";
  final bool defaultSearchMode = false;

  /// 🔥 Aspect Ratio State
  String selectedAspect = "1:1";
  String selectedModel = "ultra";

  Future<void> _saveImage() async {
    if (generatedImage == null) return;

    try {
      if (kIsWeb) {
        // WEB DOWNLOAD
        final base64Data = base64Encode(generatedImage!);
        final anchor = html.AnchorElement(
          href: "data:image/webp;base64,$base64Data",
        )
          ..download = "generated_image.webp"
          ..click();
        return;
      }

      // MOBILE + DESKTOP
      final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(generatedImage!),
        quality: 100,
        name: "generated_image_${DateTime.now().millisecondsSinceEpoch}",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image saved!")),
      );

      print("SAVE RESULT → $result");
    } catch (e) {
      print("SAVE ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save image")),
      );
    }
  }

  Future<void> _generateImage({String mode = "normal"}) async {
    final prompt = promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      isLoading = true;
      generatedImage = null;
    });

    try {
      final res = await http.post(
        Uri.parse("http://127.0.0.1:8000/generate/image"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "prompt": prompt,
          "aspect_ratio": selectedAspect,
          "model": selectedModel,
          "mode": mode, // 🔥 kirim mode ke backend
        }),
      );

      if (res.statusCode == 200) {
        final map = json.decode(res.body);
        final base64img = map["image_base64"];
        setState(() {
          generatedImage = base64Decode(base64img);
        });
      } else {
        print("Image error: ${res.body}");
      }
    } catch (e) {
      print("Image exception: $e");
    }

    setState(() => isLoading = false);
  }

  void _sendToChat() {
    final prompt = promptController.text.trim();
    if (prompt.isEmpty || generatedImage == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(
          question: prompt,
          initialLLM: defaultLLM,
          initialSearchMode: defaultSearchMode,
          initialImageBytes: generatedImage, // 🔥 Send image to ChatPage
        ),
      ),
    );
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
              title: const Text(
                "AI Image Generator",
                style: TextStyle(color: Colors.white),
              ),
            ),
      drawer: isDesktop ? null : Drawer(child: const SideBar()),
      body: Row(
        children: [
          if (isDesktop) const SideBar(),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 120 : 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Generate Stunning AI Images",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // PROMPT FIELD
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.searchBar,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.searchBarBorder),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: promptController,
                        maxLines: 2,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Describe the image you want...",
                          hintStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🔥 ASPECT RATIO DROPDOWN
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            "Aspect Ratio:",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(width: 12),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              dropdownColor: AppColors.cardColor,
                              value: selectedAspect,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                              items: const [
                                DropdownMenuItem(
                                    value: "1:1", child: Text("1:1 Square")),
                                DropdownMenuItem(
                                    value: "16:9",
                                    child: Text("16:9 Landscape")),
                                DropdownMenuItem(
                                    value: "9:16",
                                    child: Text("9:16 Portrait")),
                                DropdownMenuItem(
                                    value: "4:5",
                                    child: Text("4:5 Portrait Tall")),
                                DropdownMenuItem(
                                    value: "21:9",
                                    child: Text("21:9 Ultrawide")),
                              ],
                              onChanged: (value) {
                                setState(() => selectedAspect = value!);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 🔥 MODEL SELECTOR DROPDOWN
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            "Model:",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(width: 12),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              dropdownColor: AppColors.cardColor,
                              value: selectedModel,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                              items: const [
                                DropdownMenuItem(
                                    value: "ultra", child: Text("Ultra")),
                                DropdownMenuItem(
                                    value: "core", child: Text("Core")),
                                DropdownMenuItem(
                                    value: "flux", child: Text("Flux")),
                              ],
                              onChanged: (value) {
                                setState(() => selectedModel = value!);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // GENERATE BUTTON
                    GestureDetector(
                      onTap: isLoading
                          ? null
                          : () => _generateImage(mode: "normal"),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: isLoading
                              ? AppColors.submitButton.withOpacity(0.6)
                              : AppColors.submitButton,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isLoading) ...[
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                            Text(
                              isLoading ? "Generating..." : "Generate Image",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // GENERATED IMAGE + ACTIONS
                    if (generatedImage != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.memory(
                          generatedImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Save (placeholder)
                          ElevatedButton(
                            onPressed: () {
                              // TODO: implement save feature
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                            child: const Text("Save"),
                          ),

                          const SizedBox(width: 12),

                          // Variation
                          ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () => _generateImage(
                                    mode: "variation"), // 🔥 VARIATION
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.cardColor,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Variation"),
                          ),

                          const SizedBox(width: 12),

                          // Upscale 2x
                          ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () => _generateImage(
                                    mode: "upscale"), // 🔥 UPSCALE
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.cardColor,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Upscale 2x"),
                          ),

                          const SizedBox(width: 12),

                          // Send to Chat
                          ElevatedButton(
                            onPressed: _sendToChat,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.submitButton,
                              foregroundColor: Colors.black,
                            ),
                            child: const Text("Send to Chat"),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
