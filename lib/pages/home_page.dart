import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:perplexity_clone/services/chat_web_service.dart';
import 'package:perplexity_clone/theme/colors.dart';
import 'package:perplexity_clone/widgets/search_section.dart';
import 'package:perplexity_clone/widgets/side_bar.dart';
import 'package:perplexity_clone/pages/discover_page.dart';
import 'package:perplexity_clone/pages/image_page.dart';

class HomePage extends StatefulWidget {
  final String? prefillQuery;

  const HomePage({super.key, this.prefillQuery});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  @override
  void initState() {
    super.initState();

    if (widget.prefillQuery != null) {
      Future.delayed(Duration(milliseconds: 300), () {
        SearchSection.globalController.text = widget.prefillQuery!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bool isMobile = width < 600;
    final bool isTablet = width >= 600 && width < 1024;
    final bool isDesktop = width >= 1024;

    return Scaffold(
      backgroundColor: AppColors.background,

      // ---- MOBILE/TABLET APPBAR ----
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: AppColors.sideNav,
              leading: IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
              title: const Text(
                "Home",
                style: TextStyle(color: Colors.white),
              ),
              elevation: 0,
            ),

      // ---- DRAWER FOR MOBILE/TABLET ----
      drawer: isDesktop ? null : Drawer(child: SideBar()),

      // ---- BODY ----
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (isDesktop) {
            // ---------------- DESKTOP LAYOUT ----------------
            return Row(
              children: [
                SideBar(onItemSelected: (index) {
                  if (index == 3) {
                    // 🔵 DISCOVER PAGE
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DiscoverPage()),
                    );
                  }

                  if (index == 4) {
                    // 🟣 AI IMAGE GENERATOR PAGE
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ImagePage()),
                    );
                  }
                }),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        const SizedBox(height: 32),

                        // SEARCH SECTION
                        const Expanded(child: SearchSection()),

                        // FOOTER
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            // ---------------- MOBILE & TABLET LAYOUT ----------------
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const Expanded(child: SearchSection()),
                  _buildFooter(),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  // ---- FOOTER LINKS ----
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          _footerItem("Pro"),
          _footerItem("Enterprise"),
          _footerItem("Store"),
          _footerItem("Blog"),
          _footerItem("Careers"),
          _footerItem("English (English)"),
        ],
      ),
    );
  }

  Widget _footerItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: AppColors.footerGrey,
        ),
      ),
    );
  }
}
