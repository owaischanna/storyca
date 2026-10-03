import 'package:storryca/src/core/constants/images.const.dart';
import 'package:storryca/src/features/profile/types/profile_item_type.dart';

List<ProfileItemType> profileMenuItems = [
  ProfileItemType(
    image: authorCenterIMG,
    title: 'Author Center',
    caption: 'Become an Author',
    route: '/become-author',
  ),
  ProfileItemType(
    image: earnRewardsIconIMG,
    title: 'Earn Rewards',
    caption: 'Complete tasks and earn exciting rewards',
    route: '/earn',
  ),
  ProfileItemType(
    image: inboxIconIMG,
    title: 'Inbox',
    caption: 'View your messages and notifications',
    route: '/inbox',
  ),
  ProfileItemType(
    image: settingsIconIMG,
    title: 'Settings',
    caption: 'Manage your preferences and account',
    route: '/account-security',
  ),
];
