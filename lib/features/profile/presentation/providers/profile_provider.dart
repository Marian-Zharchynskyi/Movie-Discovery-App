import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_discovery_app/core/injection_container.dart';
import 'package:movie_discovery_app/features/profile/domain/entities/profile_entity.dart';
import 'package:movie_discovery_app/features/profile/domain/usecases/get_profile.dart';

// Provider for GetProfile use case
final getProfileProvider = Provider<GetProfile>((ref) {
  return sl<GetProfile>();
});

// State for profile
class ProfileState {
  final ProfileEntity? profile;
  final bool isLoading;
  final String? error;

  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
  });

  const ProfileState.initial() : this();

  ProfileState copyWith({
    ProfileEntity? profile,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Profile Notifier
class ProfileNotifier extends StateNotifier<ProfileState> {
  final GetProfile _getProfile;

  ProfileNotifier({
    required GetProfile getProfile,
  })  : _getProfile = getProfile,
        super(const ProfileState.initial());

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _getProfile();

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
        },
        (profile) {
          state = state.copyWith(
            profile: profile,
            isLoading: false,
            error: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load profile: $e',
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Profile Provider
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(
    getProfile: ref.watch(getProfileProvider),
  );
});
