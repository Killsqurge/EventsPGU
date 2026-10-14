class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
  });

  final String id;
  final String name;
  final String email;
  final String? photoUrl;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Студент',
      email: json['email'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
    );
  }
}
