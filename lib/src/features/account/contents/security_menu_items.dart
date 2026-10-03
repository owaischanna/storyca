import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/features/account/types/security_menu_type.dart';

List<SecurityMenuType> securityMenuItems = [
  SecurityMenuType(
    title: 'Active Sessions',
    caption: 'Manage devices logged into your account',
    icon: Remix.computer_line,
    route: '/active-sessions',
  ),
  SecurityMenuType(
    title: 'Login Activity',
    caption: 'View recent logins and account activity',
    icon: Remix.key_2_line,
    route: '/login-activity',
  ),
  SecurityMenuType(
    title: 'Security Alerts',
    caption: 'Manage alerts and notifications',
    icon: Remix.shield_cross_fill,
    route: '/security-alerts',
  ),
];
