import 'package:storryca/src/features/account/types/security_alert_type.dart';

List<SecurityAlertType> securityAlertItems = [
  SecurityAlertType(
    type: 'computer',
    title: 'New device logged in',
    location: 'Lagos, Nigeria',
    date: 'Apr 30, 2026, 07:15 PM',
    message: 'Windows PC • Chrome',
  ),
  SecurityAlertType(
    type: '2fa',
    title: 'Two-Step Verification enabled',
    location: '',
    date: 'Apr 29, 2026, 9:19 PM',
    message: 'Your account is now more secure',
  ),
  SecurityAlertType(
    type: 'password',
    title: 'Password changed',
    location: '',
    date: 'Yesterday, 8:15 PM',
    message: 'Your account password was changed',
  ),
  SecurityAlertType(
    type: 'email',
    title: 'Email address updated',
    location: '',
    date: 'Mar 25, 2026, 10:30 AM',
    message: 'Your email address was updated',
  ),
];
