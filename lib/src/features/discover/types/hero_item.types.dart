class HeroItemTypes {
  final String title;
  final String caption;
  final String image;
  final int id;
  final int rating;
  final String badge;

  HeroItemTypes({
    required this.title,
    required this.caption,
    required this.image,
    required this.id,
    required this.rating,
    this.badge = '',
  });
}
