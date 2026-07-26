import 'package:equatable/equatable.dart';

/// Authenticated user identity (independent of gameplay progression).
class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.displayName,
    this.email,
    this.isGuest = false,
    this.photoUrl,
  });

  final String id;
  final String displayName;
  final String? email;
  final bool isGuest;
  final String? photoUrl;

  AppUser copyWith({
    String? displayName,
    String? email,
    bool? isGuest,
    String? photoUrl,
  }) {
    return AppUser(
      id: id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      isGuest: isGuest ?? this.isGuest,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'email': email,
        'isGuest': isGuest,
        'photoUrl': photoUrl,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        displayName: json['displayName'] as String? ?? 'Coder',
        email: json['email'] as String?,
        isGuest: json['isGuest'] as bool? ?? false,
        photoUrl: json['photoUrl'] as String?,
      );

  @override
  List<Object?> get props => [id, displayName, email, isGuest, photoUrl];
}
