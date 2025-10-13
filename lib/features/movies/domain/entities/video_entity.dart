class VideoEntity {
  final String id;
  final String key;
  final String name;
  final String site;
  final String type;
  final bool official;

  const VideoEntity({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.type,
    required this.official,
  });

  String get youtubeUrl => 'https://www.youtube.com/watch?v=$key';
  String get youtubeThumbnail => 'https://img.youtube.com/vi/$key/hqdefault.jpg';
}
