import 'package:dartz/dartz.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/auth/domain/repositories/auth_repository.dart';

class SignOut {
  final AuthRepository repository;

  SignOut(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.signOut();
  }
}
