import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/models/login_activity_api_model.dart';
import 'package:storryca/src/core/widgets/error_state.dart';
import 'package:storryca/src/core/widgets/loading_state.dart';
import 'package:storryca/src/features/account/contents/account_settings_content.dart';
import 'package:storryca/src/features/account/presentation/widgets/login_activity_item.dart';

class LoginActivity extends StatefulWidget {
  const LoginActivity({super.key});

  @override
  State<LoginActivity> createState() => _LoginActivityState();
}

class _LoginActivityState extends State<LoginActivity> {
  List<LoginActivityApiModel>? _items;
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
      setState(() => _error = 'Sign in to see your login activity.');
      return;
    }
    try {
      final items = await usersRepository.loginActivity(token);
      setState(() => _items = items);
    } on ApiException catch (e) {
      setState(() => _error = e.displayMessage);
    } catch (_) {
      setState(() => _error = 'Could not load your login activity. Try again.');
    }
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

  Widget _buildRecentLogins() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Logins',
            style: TextStyle(color: Color(secondaryCOLR), fontSize: 16),
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
                ...List.generate(_items!.length, (index) {
                  final item = _items![index];
                  return LoginActivityItem(
                    isApp: item.isApp,
                    deviceLabel: item.deviceLabel,
                    platformLabel: item.platformLabel,
                    locationAndTime:
                        [
                      if (item.location?.isNotEmpty ?? false) item.location!,
                      if (item.ipAddress.isNotEmpty) item.ipAddress,
                      _timeAgo(item.createdAt),
                    ].join(' • '),
                    isCurrent: item.isCurrent,
                    isSuccess: item.isSuccess,
                    isLast: index == _items!.length - 1,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
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
                        'Login Activity',
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

                // HERO CAPTION
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
                  child: Text(
                    loginActivityHeroCaption,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),

                if (_error != null)
                  ErrorState(message: _error!, onRetry: _load, height: 300)
                else if (_items == null)
                  const LoadingState(height: 300)
                else if (_items!.isEmpty)
                  SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        'No login activity yet.',
                        style: TextStyle(color: Color(primaryTextCOLR)),
                      ),
                    ),
                  )
                else
                  _buildRecentLogins(),

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
                                      loginAcitivityNotificationCaption,
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
