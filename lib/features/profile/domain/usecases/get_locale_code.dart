import 'package:dartz/dartz.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/profile/domain/repositories/profile_repository.dart';

class GetLocaleCode {
  final ProfileRepository repository;
  GetLocaleCode(this.repository);

  Future<Either<Failure, String?>> call() async {
    return await repository.getLocaleCode();
  }
}
