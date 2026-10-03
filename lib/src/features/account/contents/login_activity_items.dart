import 'package:storryca/src/features/account/types/login_activity_type.dart';

List<LoginActivityType> loginActivityItems = [
  LoginActivityType(
    type: 'mobile',
    title: 'iPhone 14 Pro',
    device: 'iPhone 14 Pro • iOS 17.4',
    location: 'Lagos, Nigeria • 2 hours ago',
    isCurrent: true,
    status: 'Success',
  ),
  LoginActivityType(
    type: 'computer',
    title: 'MacBook Pro (macOS)',
    device: 'iPhone 14 Pro • iOS 17.4',
    location: 'Lagos, Nigeria • 2 hours ago',
    isCurrent: false,
    status: 'Success',
  ),
  LoginActivityType(
    type: 'mobile',
    title: 'Samsung Galaxy S23',
    device: 'Android 14 • Samsung Browser',
    location: 'Abuja, Nigeria • Yesterday, 8:15 PM',
    isCurrent: false,
    status: 'Failed',
  ),
  LoginActivityType(
    type: 'unkown',
    title: 'Unknown Device • Chrome',
    device: 'Android 14 • Samsung Browser',
    location: 'Abuja, Nigeria • Yesterday, 8:15 PM',
    isCurrent: false,
    status: 'Failed',
  ),
  LoginActivityType(
    type: 'mobile',
    title: 'iPad Air (5th Gen)',
    device: 'iPadOS 17.2',
    location: 'Delta, Nigeria • Mar 25, 2026, 10:30 AM',
    isCurrent: false,
    status: 'Success',
  ),
];
