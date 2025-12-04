import 'dart:async';
import 'package:flutter/material.dart';
import 'package:perplexity_clone/services/chat_web_service.dart';
import 'package:perplexity_clone/theme/colors.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

class SourcesSection extends StatelessWidget {
  final List sources; // 🔥 TERIMA LIST PER BUBBLE

  const SourcesSection({
    super.key,
    required this.sources,
  });

  Future<void> openURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      print("Failed to launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    double cardWidth = MediaQuery.of(context).size.width < 600 ? 150 : 200;

    if (sources.isEmpty) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Row (asli)
        Row(
          children: [
            Icon(Icons.source_outlined, color: Colors.white70),
            const SizedBox(width: 8),
            Text(
              "Sources",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width < 600 ? 16 : 18,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),

        const SizedBox(height: 16),

        // CARD RESULTS SECTION (asli)
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: sources.map((res) {
            return InkWell(
              onTap: () => openURL(res['url']),
              child: Container(
                width: cardWidth,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      res['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // URL
                    Text(
                      res['url'],
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
