class AppUser {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String targetJobTitle; // used to steer AI suggestions
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.targetJobTitle = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'targetJobTitle': targetJobTitle,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        uid: json['uid'],
        email: json['email'] ?? '',
        displayName: json['displayName'],
        photoUrl: json['photoUrl'],
        targetJobTitle: json['targetJobTitle'] ?? '',
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      );
}
