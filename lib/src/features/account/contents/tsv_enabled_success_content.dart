import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/features/account/types/tsv_option_item_type.dart';

List<TsvOptionItemType> tsvEnabledSuccessItems = [
  TsvOptionItemType(
    icon: Remix.shield_check_fill,
    title: 'What’s next?',
    caption:
        'You’ll be asked to enter ac code from Google Authenticator when you log in on a new device.',
  ),
  TsvOptionItemType(
    icon: Remix.smartphone_line,
    title: 'Backup your codes (Recommended)',
    caption:
        'Add a backup method to regain access to your account if you ever lose your device.',
  ),
  TsvOptionItemType(
    icon: Remix.settings_3_fill,
    title: 'Manage Settings',
    caption:
        'You can update your 2FA settings or disable it anytime in your account settings.',
  ),
];
