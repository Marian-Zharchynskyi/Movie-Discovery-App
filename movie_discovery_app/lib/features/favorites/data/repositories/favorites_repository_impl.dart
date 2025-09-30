import 'package:dartz/dartz.dart';
import 'package:movie_discovery_app/core/error/exceptions.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/favorites/data/datasources/local/favorites_local_data_source.dart';
import 'package:movie_discovery_app/features/favorites/data/models/favorite_movie_model.dart';
import 'package:movie_discovery_app/features/favorites/domain/entities/favorite_movie_entity.dart';
import 'package:movie_discovery_app/features/favorites/domain/repositories/favorites_repository.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDataSource localDataSource;

  FavoritesRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<FavoriteMovieEntity>>> getFavoriteMovies() async {
    try {
      final movies = await localDataSource.getFavoriteMovies();
      return Right(movies);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> addToFavorites(FavoriteMovieEntity movie) async {
    try {
      final movieModel = FavoriteMovieModel(
        id: movie.id,
        title: movie.title,
        overview: movie.overview,
        posterPath: movie.posterPath,
        backdropPath: movie.backdropPath,
        voteAverage: movie.voteAverage,
        releaseDate: movie.releaseDate,
        genreIds: movie.genreIds,
        dateAdded: DateTime.now(),
      );

      final result = await localDataSource.addToFavorites(movieModel);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> removeFromFavorites(int movieId) async {
    try {
      final result = await localDataSource.removeFromFavorites(movieId);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(int movieId) async {
    try {
      final result = await localDataSource.isFavorite(movieId);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
