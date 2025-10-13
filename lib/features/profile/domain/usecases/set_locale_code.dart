import 'package:dartz/dartz.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/profile/domain/repositories/profile_repository.dart';

class SetLocaleCode {
  final ProfileRepository repository;
  SetLocaleCode(this.repository);

  Future<Either<Failure, void>> call(String? code) async {
    return await repository.setLocaleCode(code);
  }
}
