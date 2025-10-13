import 'package:dartz/dartz.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/profile/domain/entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> getProfile();

  Future<Either<Failure, String?>> getThemeMode(); // light|dark|system
  Future<Either<Failure, void>> setThemeMode(String mode);

  Future<Either<Failure, String?>> getLocaleCode(); // e.g. en|uk|null
  Future<Either<Failure, void>> setLocaleCode(String? code);
}
