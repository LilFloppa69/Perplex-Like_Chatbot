import 'package:flutter/material.dart';
import 'package:perplexity_clone/theme/colors.dart';
import 'package:perplexity_clone/widgets/side_bar_button.dart';
import 'package:perplexity_clone/widgets/settings_modal.dart';
import 'package:perplexity_clone/pages/discover_page.dart';
import 'package:perplexity_clone/pages/image_page.dart';

class SideBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int)? onItemSelected;

  const SideBar({
    super.key,
    this.selectedIndex = 0,
    this.onItemSelected,
  });

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  bool isCollapsed = true;

  final List<Map<String, dynamic>> menuItems = [
    {"icon": Icons.add, "text": "Home"},
    {"icon": Icons.search, "text": "Search"},
    {"icon": Icons.image, "text": "AI Image"},
    {"icon": Icons.auto_awesome, "text": "Discover"},

    // 🔥 replaced Library → Settings
    {"icon": Icons.settings, "text": "Settings"},
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      width: isCollapsed ? 65 : 180,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.sideNav.withOpacity(0.95),
        border: Border(
          right: BorderSide(color: Colors.white12, width: 1),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 12),

          Icon(
            Icons.auto_awesome_mosaic,
            color: Colors.white,
            size: isCollapsed ? 32 : 48,
          ),

          const SizedBox(height: 20),

          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final item = menuItems[index];

                return SideBarButton(
                  isCollapsed: isCollapsed,
                  icon: item["icon"],
                  text: item["text"],
                  isSelected: widget.selectedIndex == index,
                  onTap: () {
                    if (item["text"] == "Settings") {
                      showDialog(
                        context: context,
                        builder: (_) => SettingsModal(),
                      );
                    } else if (item["text"] == "AI Image") {
                      // 🔥 NEW
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ImagePage()),
                      );
                    } else if (item["text"] == "Discover") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DiscoverPage()),
                      );
                    } else {
                      widget.onItemSelected?.call(index);
                    }

                    setState(() {});
                  },
                );
              },
            ),
          ),

          // collapse button
          GestureDetector(
            onTap: () {
              setState(() => isCollapsed = !isCollapsed);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.white.withOpacity(0.1),
              ),
              child: Icon(
                isCollapsed
                    ? Icons.keyboard_arrow_right
                    : Icons.keyboard_arrow_left,
                color: Colors.white70,
                size: 22,
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
