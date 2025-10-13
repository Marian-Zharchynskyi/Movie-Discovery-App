import 'package:dartz/dartz.dart';
import 'package:movie_discovery_app/core/error/failures.dart';
import 'package:movie_discovery_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:movie_discovery_app/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:movie_discovery_app/features/profile/domain/entities/profile_entity.dart';
import 'package:movie_discovery_app/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final AuthRepository authRepository;
  final ProfileLocalDataSource localDataSource;

  ProfileRepositoryImpl({
    required this.authRepository,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    final current = await authRepository.getCurrentUser();
    return current.fold(
      (l) => Left(l),
      (user) {
        if (user == null) {
          return Left(const CacheFailure('No authenticated user'));
        }
        return Right(
          ProfileEntity(
            id: user.id,
            email: user.email,
            displayName: user.displayName,
            photoUrl: user.photoUrl,
            role: user.role,
          ),
        );
      },
    );
  }

  @override
  Future<Either<Failure, String?>> getLocaleCode() async {
    try {
      return Right(localDataSource.getLocaleCode());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String?>> getThemeMode() async {
    try {
      return Right(localDataSource.getThemeMode());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setLocaleCode(String? code) async {
    try {
      await localDataSource.setLocaleCode(code);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setThemeMode(String mode) async {
    try {
      await localDataSource.setThemeMode(mode);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
