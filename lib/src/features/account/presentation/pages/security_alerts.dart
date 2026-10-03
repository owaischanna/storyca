import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/images.const.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/models/security_alert_api_model.dart';
import 'package:storryca/src/core/widgets/error_state.dart';
import 'package:storryca/src/core/widgets/loading_state.dart';
import 'package:storryca/src/features/account/contents/account_settings_content.dart';
import 'package:storryca/src/features/account/presentation/widgets/security_alert_item.dart';

class SecurityAlerts extends StatefulWidget {
  const SecurityAlerts({super.key});

  @override
  State<SecurityAlerts> createState() => _SecurityAlertsState();
}

class _SecurityAlertsState extends State<SecurityAlerts> {
  List<SecurityAlertApiModel>? _alerts;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    final token = await authService.getToken();
    if (token == null) {
      setState(() => _error = 'Sign in to see your security alerts.');
      return;
    }
    try {
      final alerts = await usersRepository.securityAlerts(token);
      setState(() => _alerts = alerts);
    } on ApiException catch (e) {
      setState(() => _error = e.displayMessage);
    } catch (_) {
      setState(() => _error = 'Could not load your security alerts. Try again.');
    }
  }

  Future<void> _markRead(int alertId) async {
    final token = await authService.getToken();
    if (token == null) return;
    try {
      await usersRepository.markAlertRead(alertId, token);
      _load();
    } on ApiException {
      // A failed mark-as-read isn't worth interrupting the user over.
    }
  }

  Future<void> _markAllRead() async {
    final token = await authService.getToken();
    if (token == null) return;
    try {
      await usersRepository.markAllAlertsRead(token);
      _load();
    } on ApiException {
      // Same as above.
    }
  }

  String _iconType(String alertType) {
    if (alertType.contains('two_factor')) return '2fa';
    if (alertType.contains('email')) return 'email';
    if (alertType == 'password_changed') return 'password';
    return 'lock';
  }

  String _timeAgo(String dateTime) {
    final date = DateTime.tryParse(dateTime);
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    try {
      return DateFormat('MMM d, yyyy').format(date);
    } catch (_) {
      // DateFormat can throw if the device's locale data isn't initialized
      // — never let a date-formatting hiccup blank the whole list.
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF020004),
      body: Container(
        decoration: BoxDecoration(gradient: pageGradientCOLR),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              spacing: 16,
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          context.pop();
                        },
                        icon: Icon(Remix.arrow_left_s_line),
                        color: Colors.white,
                        iconSize: 24,
                      ),
                      Text(
                        'Security Alerts',
                        style: GoogleFonts.playfair(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // SizedBox(width: 40),
                    ],
                  ),
                ),

                // HERO
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
                  child: Row(
                    spacing: 8,
                    children: [
                      Image.asset(securityAlertIMG, width: 70),
                      Expanded(
                        child: Column(
                          spacing: 8,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Stay Protected',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              securityAlertsHeroCaption,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                if (_error != null)
                  ErrorState(message: _error!, onRetry: _load, height: 300)
                else if (_alerts == null)
                  const LoadingState(height: 300)
                else ...[
                  // RECENT ALERTS
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      spacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Alerts',
                              style: TextStyle(
                                color: Color(secondaryCOLR),
                                fontSize: 16,
                              ),
                            ),
                            if (_alerts!.any((a) => !a.isRead))
                              GestureDetector(
                                onTap: _markAllRead,
                                child: Text(
                                  'Mark all as read',
                                  style: TextStyle(
                                    color: Color(secondaryCOLR),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Color.fromRGBO(157, 138, 197, 0.2),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              ..._alerts!.asMap().entries.map((entry) {
                                final item = entry.value;
                                return SecurityAlertItem(
                                  type: _iconType(item.alertType),
                                  title: item.title,
                                  location: '',
                                  message: item.message,
                                  date: _timeAgo(item.createdAt),
                                  isLast: _alerts!.length == entry.key + 1,
                                  isRead: item.isRead,
                                  onTap: item.isRead
                                      ? () {}
                                      : () => _markRead(item.id),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // NOTIFICATION
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 0.5,
                        color: Color.fromRGBO(181, 77, 232, 0.3),
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      spacing: 16,
                      children: [
                        Expanded(
                          child: Row(
                            spacing: 8,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: Color.fromRGBO(131, 67, 213, 0.3),
                                  ),
                                  borderRadius: BorderRadius.circular(40),
                                  gradient: profileIconCardGradientCOLR,
                                ),
                                child: Icon(
                                  Remix.lock_fill,
                                  size: 22,
                                  color: Color(0xffCF7FFA),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  spacing: 4,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Don’t recognize a login?',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      securityAlertsNotificationCaption,
                                      style: TextStyle(
                                        color: Color(primaryTextCOLR),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/change-password'),
                          child: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: defaultGradientTTB,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Change Password',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
