class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String imageUrl;
  final String sourceName;
  final String publishedAt;

  NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    required this.imageUrl,
    required this.sourceName,
    required this.publishedAt,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json["title"] ?? "",
      description: json["description"] ?? "",
      url: json["url"] ?? "",
      imageUrl: json["urlToImage"] ?? "",
      sourceName: json["source"]?["name"] ?? "",
      publishedAt: json["publishedAt"] ?? "",
    );
  }
}
