import 'package:flutter_dotenv/flutter_dotenv.dart';

class MovieEntity {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final String releaseDate;
  final List<int> genreIds;

  const MovieEntity({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
    required this.genreIds,
  });

  String get fullPosterPath {
    if (posterPath == null) return '';
    final base = dotenv.env['TMDB_IMAGE_BASE_URL']!;
    final size = dotenv.env['TMDB_POSTER_SIZE']!;
    return '$base$size$posterPath';
  }

  String get fullBackdropPath {
    if (backdropPath == null) return '';
    final base = dotenv.env['TMDB_IMAGE_BASE_URL']!;
    final size = dotenv.env['TMDB_BACKDROP_SIZE']!;
    return '$base$size$backdropPath';
  }
}
