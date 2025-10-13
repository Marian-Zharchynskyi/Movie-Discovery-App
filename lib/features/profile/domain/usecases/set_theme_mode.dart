import 'package:dartz/dartz.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/profile/domain/repositories/profile_repository.dart';

class SetThemeMode {
  final ProfileRepository repository;
  SetThemeMode(this.repository);

  Future<Either<Failure, void>> call(String mode) async {
    return await repository.setThemeMode(mode);
  }
}
