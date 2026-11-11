class AuthorApiModel {
  AuthorApiModel({
    required this.id,
    required this.name,
    required this.username,
    required this.image,
    required this.aboutMe,
    required this.location,
    required this.language,
    required this.availability,
    required this.toMyReaders,
    required this.followers,
    required this.followings,
    required this.joinedAt,
    required this.publishedStories,
    this.aboutMyBooks = '',
  });

  final int id;
  final String name;
  final String username;
  final String? image;
  final String aboutMe;
  final String location;
  final String language;
  final String availability;
  final String toMyReaders;
  final int followers;
  final int followings;
  final String joinedAt;
  final int publishedStories;

  /// The author's "About My Books" text from Edit Profile.
  final String aboutMyBooks;

  factory AuthorApiModel.fromJson(Map<String, dynamic> json) => AuthorApiModel(
    id: json['id'] as int,
    name: json['name'] as String? ?? '',
    username: json['username'] as String? ?? '',
    image: json['image'] as String?,
    aboutMe: json['about_me'] as String? ?? '',
    location: json['location'] as String? ?? '',
    language: json['language'] as String? ?? '',
    availability: json['availability'] as String? ?? '',
    toMyReaders: json['to_my_readers'] as String? ?? '',
    followers: json['followers'] as int? ?? 0,
    followings: json['followings'] as int? ?? 0,
    joinedAt: json['joined_at'] as String? ?? '',
    publishedStories: json['published_stories'] as int? ?? 0,
    aboutMyBooks: json['about_my_books'] as String? ?? '',
  );
}
