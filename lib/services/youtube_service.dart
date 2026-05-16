import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/media_item.dart';

class YoutubeService {
  final _yt = YoutubeExplode();

  /// Parse user input URL, extract Playlist ID if present, and fetch videos.
  Future<List<MediaItem>> fetchPlaylist(String url) async {
    try {
      dynamic id;

      // 1. Try to extract 'list' parameter if it's a watch URL
      final uri = Uri.tryParse(url);
      if (uri != null && uri.queryParameters.containsKey('list')) {
        id = PlaylistId(uri.queryParameters['list']!);
      } else {
        // 2. Try parsing as a direct playlist URL or ID
        id = PlaylistId.parsePlaylistId(url); // Can handle URL or ID usually
      }

      // If id is still null or failed?
      // PlaylistId constructor throws or 'parsePlaylistId' might throw/return null?
      // 'parsePlaylistId' returns PlaylistId?
      // Actually youtube_explode_dart documentation says it throws ArgumentError if invalid.
      // We will assume if we got here we have a valid ID attempt.

      // 3. Fetch Videos
      // getVideos returns a Stream. We convert to List.
      final List<MediaItem> items = [];

      await for (final video in _yt.playlists.getVideos(id)) {
        items.add(
          MediaItem(
            title: video.title,
            // Store the full URL to be compatible, OR just the ID if we prefer.
            // Storing full URL is safer for generic players.
            url: video.url,
            logoUrl: video.thumbnails.highResUrl,
            group: 'YouTube Playlist',
          ),
        );
      }

      return items;
    } catch (e) {
      // If parsing as playlist failed, check if it is a single video URL?
      // User asked for "Check structure of THIS LIST", so we focus on playlist.
      // But maybe good fallback.
      print('Erro YouTube Service: $e');
      throw Exception(
        'Não foi possível carregar a playlist do YouTube. Verifique o link.',
      );
    }
  }

  void dispose() {
    _yt.close();
  }
}
