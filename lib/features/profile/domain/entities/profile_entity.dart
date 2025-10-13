import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? role;

  const ProfileEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.role,
  });

  ProfileEntity copyWith({
    String? displayName,
    String? photoUrl,
    String? role,
  }) {
    return ProfileEntity(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [id, email, displayName, photoUrl, role];
}
