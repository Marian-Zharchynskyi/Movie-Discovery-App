import 'package:dartz/dartz.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/favorites/domain/repositories/favorites_repository.dart';

class GetFavoritesCount {
  final FavoritesRepository repository;
  GetFavoritesCount(this.repository);

  Future<Either<Failure, int>> call() async {
    final res = await repository.getFavoriteMovies();
    return res.fold(
      (l) => Left(l),
      (list) => Right(list.length),
    );
  }
}
