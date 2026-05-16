class MediaItem {
  final String title;
  final String url;
  final String? logoUrl;
  final String? group;
  final bool isSeries;
  final bool isMovie;
  final int? season;
  final int? episode;
  final String? xuiId;
  final String? tvgId;
  final String? tvgName;

  MediaItem({
    required this.title,
    required this.url,
    this.logoUrl,
    this.group,
    this.isSeries = false,
    this.isMovie = false,
    this.season,
    this.episode,
    this.xuiId,
    this.tvgId,
    this.tvgName,
  });

  factory MediaItem.fromEntry(dynamic entry) {
    // Adapter for m3u_nullsafe entry
    // Safely convert attributes to Map<String, String>
    final Map<String, String> attributes = {};
    if (entry.attributes != null && entry.attributes is Map) {
      (entry.attributes as Map).forEach((key, value) {
        if (value != null) {
          attributes[key.toString()] = value.toString();
        }
      });
    }

    return MediaItem(
      title: entry.title ?? 'Sem Título',
      url: entry.link ?? '',
      logoUrl: attributes['tvg-logo'] ?? attributes['logo'],
      group: attributes['group-title'] ?? attributes['tvg-group'] ?? 'Geral',
      xuiId: attributes['xui-id'],
      tvgId: attributes['tvg-id'],
      tvgName: attributes['tvg-name'],
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'url': url,
    'logoUrl': logoUrl,
    'group': group,
    'isSeries': isSeries,
    'isMovie': isMovie,
    'season': season,
    'episode': episode,
    'xuiId': xuiId,
    'tvgId': tvgId,
    'tvgName': tvgName,
  };

  factory MediaItem.fromJson(Map<String, dynamic> json) => MediaItem(
    title: json['title'] ?? 'Sem Título',
    url: json['url'] ?? '',
    logoUrl: json['logoUrl'],
    group: json['group'],
    isSeries: json['isSeries'] ?? false,
    isMovie: json['isMovie'] ?? false,
    season: json['season'],
    episode: json['episode'],
    xuiId: json['xuiId'],
    tvgId: json['tvgId'],
    tvgName: json['tvgName'],
  );
}
