import 'package:equatable/equatable.dart';

/// Entity class for authenticated user
class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String? displayName;
  final String? username;
  final String? photoUrl;
  final bool isEmailVerified;
  final DateTime? createdAt;
  final DateTime? lastSignInAt;
  final String? phone;

  const UserEntity({
    required this.uid,
    required this.email,
    this.displayName,
    this.username,
    this.photoUrl,
    this.isEmailVerified = false,
    this.createdAt,
    this.lastSignInAt,
    this.phone,
  });

  @override
  List<Object?> get props => [
        uid,
        email,
        displayName,
        username,
        photoUrl,
        isEmailVerified,
        createdAt,
        lastSignInAt,
        phone,
      ];

  /// Create a copy of the user entity with updated fields
  UserEntity copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? username,
    String? photoUrl,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? lastSignInAt,
    String? phone,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      photoUrl: photoUrl ?? this.photoUrl,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
      phone: phone ?? this.phone,
    );
  }

  /// Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'username': username,
      'photoUrl': photoUrl,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt?.toIso8601String(),
      'lastSignInAt': lastSignInAt?.toIso8601String(),
      'phone': phone,
    };
  }

  /// Create from map for deserialization
  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'],
      username: map['username'],
      photoUrl: map['photoUrl'],
      isEmailVerified: map['isEmailVerified'] ?? false,
      createdAt:
          map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      lastSignInAt: map['lastSignInAt'] != null
          ? DateTime.parse(map['lastSignInAt'])
          : null,
      phone: map['phone'],
    );
  }
}
