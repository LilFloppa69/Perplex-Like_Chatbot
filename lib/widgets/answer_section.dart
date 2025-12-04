import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:perplexity_clone/services/chat_web_service.dart';
import 'package:perplexity_clone/theme/colors.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AnswerSection extends StatefulWidget {
  const AnswerSection({super.key});

  @override
  State<AnswerSection> createState() => _AnswerSectionState();
}

class _AnswerSectionState extends State<AnswerSection> {
  bool isLoading = true;
  String fullResponse = "";

  late StreamSubscription _sub;

  @override
  void initState() {
    super.initState();

    // Listen to streaming content from WebSocket
    _sub = ChatWebService().contentStream.listen((data) {
      if (!mounted) return; // Prevent setState after dispose

      if (isLoading) {
        fullResponse = "";
      }

      setState(() {
        fullResponse += data['data'];
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _sub.cancel(); // Prevent zombie listener
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double titleSize = MediaQuery.of(context).size.width < 600 ? 16 : 18;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Perplexity',
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        // Skeleton while loading
        Skeletonizer(
          enabled: isLoading,
          child: Markdown(
            data:
                fullResponse.isEmpty && isLoading ? "Loading..." : fullResponse,
            shrinkWrap: true,
            styleSheet:
                MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
              codeblockDecoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(10),
              ),
              code: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
