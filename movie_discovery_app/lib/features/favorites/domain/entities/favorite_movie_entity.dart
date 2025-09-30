import 'package:movie_discovery_app/features/movies/domain/entities/movie_entity.dart';

class FavoriteMovieEntity extends MovieEntity {
  final DateTime dateAdded;

  const FavoriteMovieEntity({
    required super.id,
    required super.title,
    required super.overview,
    super.posterPath,
    super.backdropPath,
    required super.voteAverage,
    required super.releaseDate,
    required super.genreIds,
    required this.dateAdded,
  });
}
