import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/features/account/types/tsv_option_item_type.dart';

List<TsvOptionItemType> tsvOptionItems = [
  TsvOptionItemType(
    icon: Remix.shield_check_fill,
    title: 'Stronger Account Protection',
    caption:
        'Even if someone gets your password, they won’t be able to access your account.',
  ),
  TsvOptionItemType(
    icon: Remix.smartphone_line,
    title: 'Easy Verification',
    caption:
        'A verification code will be sent to your phone or email when you log in.',
  ),
  TsvOptionItemType(
    icon: Remix.user_follow_line,
    title: 'You’re in Control',
    caption: 'You can update your verification method or disable it anytime.',
  ),
];
