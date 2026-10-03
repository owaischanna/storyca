class FollowStateApiModel {
  FollowStateApiModel({
    required this.userId,
    required this.followers,
    required this.following,
    required this.isFollowing,
    required this.isSelf,
  });

  final int userId;
  final int followers;
  final int following;
  final bool isFollowing;
  final bool isSelf;

  factory FollowStateApiModel.fromJson(Map<String, dynamic> json) =>
      FollowStateApiModel(
        userId: json['user_id'] as int,
        followers: json['followers'] as int? ?? 0,
        following: json['following'] as int? ?? 0,
        isFollowing: json['is_following'] as bool? ?? false,
        isSelf: json['is_self'] as bool? ?? false,
      );
}

class FollowUserApiModel {
  FollowUserApiModel({
    required this.id,
    required this.name,
    required this.username,
    required this.image,
    required this.aboutMe,
    required this.type,
    required this.followedAt,
    required this.followers,
    required this.isFollowing,
    required this.isSelf,
  });

  final int id;
  final String name;
  final String username;
  final String? image;
  final String aboutMe;
  final String type;
  final String followedAt;
  final int followers;
  final bool isFollowing;
  final bool isSelf;

  bool get isAuthor => type == 'author';

  factory FollowUserApiModel.fromJson(Map<String, dynamic> json) =>
      FollowUserApiModel(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        username: json['username'] as String? ?? '',
        image: json['image'] as String?,
        aboutMe: json['about_me'] as String? ?? '',
        type: json['type'] as String? ?? 'user',
        followedAt: json['followed_at'] as String? ?? '',
        followers: json['followers'] as int? ?? 0,
        isFollowing: json['is_following'] as bool? ?? false,
        isSelf: json['is_self'] as bool? ?? false,
      );
}
