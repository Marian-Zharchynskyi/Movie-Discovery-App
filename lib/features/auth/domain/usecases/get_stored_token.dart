import 'package:dartz/dartz.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/auth/domain/repositories/auth_repository.dart';

class GetStoredToken {
  final AuthRepository repository;
  GetStoredToken(this.repository);

  Future<Either<Failure, String?>> call() async {
    return await repository.getStoredToken();
  }
}
