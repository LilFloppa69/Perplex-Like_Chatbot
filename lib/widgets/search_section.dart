import 'package:flutter/material.dart';
import 'package:perplexity_clone/pages/chat_page.dart';
import 'package:perplexity_clone/theme/colors.dart';

class SearchSection extends StatefulWidget {
  // 🔥 GLOBAL CONTROLLER (bisa diisi dari luar, misal DiscoverPage)
  static TextEditingController globalController = TextEditingController();

  const SearchSection({super.key});

  @override
  State<SearchSection> createState() => _SearchSectionState();
}

class _SearchSectionState extends State<SearchSection> {
  String selectedLLM = "Gemini 2.5";
  bool searchMode = true;

  @override
  void dispose() {
    // ❗ Jangan dispose globalController, nanti homepage ga bisa pakai lagi
    super.dispose();
  }

  void _submitSearch() {
    final query = SearchSection.globalController.text.trim();
    if (query.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(
          question: query,
          initialLLM: selectedLLM,
          initialSearchMode: searchMode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bool isMobile = width < 600;
    final bool isTablet = width >= 600 && width < 1024;

    final double titleFont = isMobile
        ? 28
        : isTablet
            ? 32
            : 40;

    final double barPadding = isMobile ? 12 : 16;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Where knowledge begins',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: titleFont,
            fontWeight: FontWeight.w400,
            height: 1.2,
            letterSpacing: -0.5,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          constraints: const BoxConstraints(maxWidth: 750),
          width: isMobile ? double.infinity : width * 0.65,
          decoration: BoxDecoration(
            color: AppColors.searchBar,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.searchBarBorder,
              width: 1.4,
            ),
          ),
          child: Column(
            children: [
              // TEXTFIELD
              Padding(
                padding: EdgeInsets.all(barPadding),
                child: TextField(
                  controller: SearchSection.globalController,
                  onSubmitted: (_) => _submitSearch(),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search anything...',
                    hintStyle: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: isMobile ? 14 : 16,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: barPadding, vertical: barPadding - 8),
                child: Row(
                  children: [
                    // LLM DROPDOWN
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          dropdownColor: AppColors.cardColor,
                          value: selectedLLM,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                          items: const [
                            DropdownMenuItem(
                                value: "Gemini 2.5", child: Text("Gemini 2.5")),
                            DropdownMenuItem(
                                value: "NoFilterGPT",
                                child: Text("NoFilterGPT")),
                          ],
                          onChanged: (v) => setState(() => selectedLLM = v!),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // SEARCH MODE (TAVILY ON/OFF)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<bool>(
                          dropdownColor: AppColors.cardColor,
                          value: searchMode,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                          items: const [
                            DropdownMenuItem(
                                value: true, child: Text("Search: ON")),
                            DropdownMenuItem(
                                value: false, child: Text("Search: OFF")),
                          ],
                          onChanged: (v) => setState(() => searchMode = v!),
                        ),
                      ),
                    ),

                    const Spacer(),

                    GestureDetector(
                      onTap: _submitSearch,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: EdgeInsets.all(isMobile ? 10 : 12),
                        decoration: BoxDecoration(
                          color: AppColors.submitButton,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          color: AppColors.background,
                          size: isMobile ? 18 : 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
