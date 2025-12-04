import 'package:flutter/material.dart';
import 'package:perplexity_clone/theme/colors.dart';
import 'package:perplexity_clone/services/news_service.dart';
import 'package:perplexity_clone/models/news_article.dart';
import 'package:perplexity_clone/pages/home_page.dart';
import 'package:perplexity_clone/services/weather_service.dart';
import 'package:perplexity_clone/models/weather_info.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  List<NewsArticle> articles = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  IconData _getWeatherIcon(String code) {
    switch (code) {
      case "0":
        return Icons.wb_sunny; // clear
      case "1":
      case "2":
      case "3":
        return Icons.cloud; // partly cloudy
      case "45":
      case "48":
        return Icons.foggy;
      case "51":
      case "61":
      case "80":
        return Icons.water_drop; // rain
      case "71":
      case "73":
      case "75":
        return Icons.ac_unit; // snow
      default:
        return Icons.wb_cloudy;
    }
  }

  Future<void> _loadNews() async {
    try {
      final data = await NewsService().fetchTopNews();
      setState(() {
        articles = data;
        loading = false;
      });
    } catch (e) {
      print("NEWS ERROR: $e");
      setState(() => loading = false);
    }
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
              title:
                  const Text("Discover", style: TextStyle(color: Colors.white)),
            ),
      body: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.explore, color: Colors.white, size: 32),
                      const SizedBox(width: 10),
                      Text(
                        "Discover",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isDesktop ? 34 : 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      _tab("Top", true),
                      const SizedBox(width: 12),
                      _tab("Topics", false),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _buildMainNewsSection(),
                  const SizedBox(height: 28),
                  Text(
                    "More Stories",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSmallNewsSection(),
                ],
              ),
            ),
          ),
          if (isDesktop) _rightSidebar(),
        ],
      ),
    );
  }

  // =============================
  // UI COMPONENTS
  // =============================

  Widget _tab(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: active ? Colors.black : Colors.white70,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ===== MAIN NEWS =====

  Widget _buildMainNewsSection() {
    if (loading) return _bigNewsSkeleton();
    if (articles.isEmpty) return _bigNewsEmpty();

    final a = articles[0];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE + MENU
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          a.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // ⭐ FETCH MENU
                      PopupMenuButton(
                        color: AppColors.cardColor,
                        icon: const Icon(Icons.more_vert,
                            color: Colors.white70, size: 22),
                        onSelected: (value) {
                          if (value == "fetch") {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HomePage(prefillQuery: a.title),
                              ),
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: "fetch",
                            child: Text("Fetch",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    a.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Image.network(
                a.imageUrl,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: Colors.grey.shade800,
                  child: const Icon(Icons.broken_image, color: Colors.white38),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bigNewsSkeleton() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _bigNewsEmpty() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child:
            Text("No news available.", style: TextStyle(color: Colors.white70)),
      ),
    );
  }

  // ===== SMALL NEWS GRID =====

  Widget _buildSmallNewsSection() {
    if (loading) return _smallNewsSkeleton();

    if (articles.length <= 1) {
      return const Text("No additional stories.",
          style: TextStyle(color: Colors.white70));
    }

    final smallNews = articles.skip(1).take(6).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: smallNews.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) => _smallNewsCard(smallNews[index]),
    );
  }

  Widget _smallNewsSkeleton() {
    return SizedBox(
      height: 300,
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  Widget _smallNewsCard(NewsArticle a) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE FIXED HEIGHT
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: SizedBox(
              height: 120,
              width: double.infinity,
              child: Image.network(
                a.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade800,
                  child: const Center(
                    child: Icon(Icons.image_not_supported,
                        color: Colors.white38, size: 40),
                  ),
                ),
              ),
            ),
          ),

          // TITLE + MENU
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    a.title,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14, height: 1.2),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton(
                  color: AppColors.cardColor,
                  icon: const Icon(Icons.more_vert,
                      color: Colors.white70, size: 18),
                  onSelected: (value) {
                    if (value == "fetch") {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HomePage(prefillQuery: a.title),
                        ),
                      );
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: "fetch",
                      child:
                          Text("Fetch", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rightSidebar() {
    return FutureBuilder(
      future: WeatherService().fetchWeather(),
      builder: (context, snapshot) {
        final weather = snapshot.data;

        return Container(
          width: 280,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: Colors.white12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Weather",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),

              // LOADING
              if (!snapshot.hasData)
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),

              // WEATHER DATA
              if (weather != null) ...[
                Row(
                  children: [
                    Icon(
                      _getWeatherIcon(weather.weatherCode),
                      color: Colors.yellow,
                      size: 40,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "${weather.temperature}°C",
                      style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "Wind: ${weather.windspeed} km/h",
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
