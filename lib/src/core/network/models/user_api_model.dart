class UserApiModel {
  UserApiModel({
    required this.id,
    required this.identifier,
    required this.email,
    required this.name,
    required this.username,
    required this.image,
    required this.phone,
    required this.type,
    required this.becameAuthor,
    required this.createdAt,
    required this.aboutMe,
    required this.isAuthor,
    required this.emailVerified,
    required this.twoFactorEnabled,
    required this.publishedStories,
    required this.unreadNotifications,
    required this.followers,
    required this.followings,
  });

  final int id;
  final String identifier;
  final String email;
  final String? name;
  final String? username;
  final String? image;
  final String? phone;
  final String type;
  final String? becameAuthor;
  final String? createdAt;
  final String? aboutMe;
  final bool isAuthor;
  final bool emailVerified;
  final bool twoFactorEnabled;
  final int publishedStories;
  final int unreadNotifications;
  final int followers;
  final int followings;

  String get displayName => (name != null && name!.isNotEmpty) ? name! : email;

  /// Used right after an avatar upload to show the just-uploaded filename
  /// immediately, rather than trusting a follow-up `/users/me` fetch that
  /// can race the server's own write and briefly return the old filename.
  UserApiModel copyWithImage(String image) => UserApiModel(
    id: id,
    identifier: identifier,
    email: email,
    name: name,
    username: username,
    image: image,
    phone: phone,
    type: type,
    becameAuthor: becameAuthor,
    createdAt: createdAt,
    aboutMe: aboutMe,
    isAuthor: isAuthor,
    emailVerified: emailVerified,
    twoFactorEnabled: twoFactorEnabled,
    publishedStories: publishedStories,
    unreadNotifications: unreadNotifications,
    followers: followers,
    followings: followings,
  );

  factory UserApiModel.fromJson(Map<String, dynamic> json) => UserApiModel(
    id: json['id'] as int,
    identifier: json['identifier'] as String? ?? '',
    email: json['email'] as String? ?? '',
    name: json['name'] as String?,
    username: json['username'] as String?,
    image: json['image'] as String?,
    phone: json['phone'] as String?,
    type: json['type'] as String? ?? 'user',
    becameAuthor: json['became_author'] as String?,
    createdAt: json['time'] as String?,
    aboutMe: json['about_me'] as String?,
    isAuthor: json['is_author'] as bool? ?? false,
    emailVerified: json['email_verified'] as bool? ?? false,
    twoFactorEnabled: json['two_factor_enabled'] as bool? ?? false,
    publishedStories: json['published_stories'] as int? ?? 0,
    unreadNotifications: json['unread_notifications'] as int? ?? 0,
    followers: json['followers'] as int? ?? 0,
    followings: json['followings'] as int? ?? 0,
  );
}
