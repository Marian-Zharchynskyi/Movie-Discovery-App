import 'package:movie_discovery_app/features/favorites/domain/entities/favorite_movie_entity.dart';
import 'package:movie_discovery_app/features/movies/domain/entities/movie_entity.dart';

class FavoriteMovieModel extends FavoriteMovieEntity {
  const FavoriteMovieModel({
    required super.id,
    required super.title,
    required super.overview,
    super.posterPath,
    super.backdropPath,
    required super.voteAverage,
    required super.releaseDate,
    required super.genreIds,
    required super.dateAdded,
  });

  factory FavoriteMovieModel.fromMovieEntity(MovieEntity movie, DateTime dateAdded) {
    return FavoriteMovieModel(
      id: movie.id,
      title: movie.title,
      overview: movie.overview,
      posterPath: movie.posterPath,
      backdropPath: movie.backdropPath,
      voteAverage: movie.voteAverage,
      releaseDate: movie.releaseDate,
      genreIds: movie.genreIds,
      dateAdded: dateAdded,
    );
  }

  factory FavoriteMovieModel.fromJson(Map<String, dynamic> json) {
    return FavoriteMovieModel(
      id: json['id'] as int,
      title: json['title'] as String,
      overview: json['overview'] as String,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num).toDouble(),
      releaseDate: json['release_date'] as String,
      genreIds: List<int>.from(json['genre_ids'] as List<dynamic>),
      dateAdded: DateTime.parse(json['date_added'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'vote_average': voteAverage,
      'release_date': releaseDate,
      'genre_ids': genreIds,
      'date_added': dateAdded.toIso8601String(),
    };
  }
}
