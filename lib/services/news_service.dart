import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:perplexity_clone/models/news_article.dart';

class NewsService {
  static const String apiKey = "ade1fafd8ac2424791e7115383edc803";
  static const String baseUrl =
      "https://newsapi.org/v2/top-headlines?country=us";

  static const String cacheKey = "news_cache_data";
  static const String cacheTimeKey = "news_cache_time";

  /// berapa lama cache valid? → 10 menit
  static const Duration cacheDuration = Duration(minutes: 10);

  Future<List<NewsArticle>> fetchTopNews() async {
    // 1) Cek cache dulu
    final prefs = await SharedPreferences.getInstance();

    final cachedJson = prefs.getString(cacheKey);
    final cachedTime = prefs.getInt(cacheTimeKey);

    if (cachedJson != null && cachedTime != null) {
      final diff = DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(cachedTime));

      // still valid cache
      if (diff < cacheDuration) {
        final cachedMap = json.decode(cachedJson);
        final articles = (cachedMap["articles"] as List)
            .map((a) => NewsArticle.fromJson(a))
            .toList();

        print("⚡ Loaded news from CACHE");
        return articles;
      }
    }

    // 2) Fetch dari API
    final url = Uri.parse("$baseUrl&apiKey=$apiKey");
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final map = json.decode(res.body);

      // simpan cache
      await prefs.setString(cacheKey, res.body);
      await prefs.setInt(cacheTimeKey, DateTime.now().millisecondsSinceEpoch);

      print("🌐 Loaded news from API (cache updated)");

      final articles = (map["articles"] as List)
          .map((a) => NewsArticle.fromJson(a))
          .toList();

      return articles;
    } else {
      throw Exception("Failed to fetch news");
    }
  }
}
