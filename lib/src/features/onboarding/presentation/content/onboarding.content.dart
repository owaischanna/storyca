import 'package:storryca/src/core/constants/images.const.dart';
import 'package:storryca/src/features/onboarding/presentation/types/onboard.types.dart';

List<OnboardType> onboardingContent = [
  OnboardType(
    plainTitle: 'Discover Stories',
    highlightTitle: 'You\'ll Love',
    caption:
        'Explore a world of captivating stories across romance, fantasy, thriller, and more.',
    image: onboardingHero1IMG,
  ),
  OnboardType(
    plainTitle: 'Write Your',
    highlightTitle: 'Own Story',
    caption:
        'Bring your ideas to life. Create, write, and publish you stories for the world to read.',
    image: onboardingHero2IMG,
  ),
  OnboardType(
    plainTitle: 'Connect &',
    highlightTitle: 'Be Inspired',
    caption:
        'Join a community of readers and writers. Share, review, and get inspired every day.',
    image: onboardingHero3IMG,
  ),
];
