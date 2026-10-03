import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/models/session_api_model.dart';
import 'package:storryca/src/core/widgets/app_snackbar.dart';
import 'package:storryca/src/core/widgets/error_state.dart';
import 'package:storryca/src/core/widgets/loading_state.dart';
import 'package:storryca/src/features/account/contents/account_settings_content.dart';
import 'package:storryca/src/features/account/presentation/widgets/active_session_item.dart';
import 'package:storryca/src/features/account/presentation/widgets/active_session_signout_modal.dart';

class ActiveSessions extends StatefulWidget {
  const ActiveSessions({super.key});

  @override
  State<ActiveSessions> createState() => _ActiveSessionsState();
}

class _ActiveSessionsState extends State<ActiveSessions> {
  List<SessionApiModel>? _sessions;
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
      setState(() => _error = 'Sign in to see your sessions.');
      return;
    }
    try {
      final sessions = await usersRepository.sessions(token);
      setState(() => _sessions = sessions);
    } on ApiException catch (e) {
      setState(() => _error = e.displayMessage);
    } catch (_) {
      setState(() => _error = 'Could not load your sessions. Try again.');
    }
  }

  Future<void> _revoke(int sessionId) async {
    final token = await authService.getToken();
    if (token == null) return;
    try {
      await usersRepository.revokeSession(sessionId, token);
      await _load();
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.displayMessage);
    }
  }

  Future<void> _revokeOthers() async {
    final token = await authService.getToken();
    if (token == null) return;
    try {
      await usersRepository.revokeOtherSessions(token);
      if (mounted) context.pop();
      await _load();
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.displayMessage);
    }
  }

  String _timeAgo(String dateTime) {
    final date = DateTime.tryParse(dateTime);
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
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
    final current = _sessions?.where((s) => s.isCurrent).firstOrNull;
    final others = _sessions?.where((s) => !s.isCurrent).toList() ?? [];

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
                        'Active Sessions',
                        style: GoogleFonts.playfair(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // HERO CAPTION
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
                  child: Text(
                    activeSessionHeroCaption,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),

                if (_error != null)
                  ErrorState(message: _error!, onRetry: _load, height: 300)
                else if (_sessions == null)
                  const LoadingState(height: 300)
                else ...[
                  // CURRENT SESSION
                  if (current != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        spacing: 8,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Session',
                            style: TextStyle(
                              color: Color(secondaryCOLR),
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Color.fromRGBO(157, 138, 197, 0.2),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              spacing: 8,
                              children: [
                                SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 1,
                                            color: Color.fromRGBO(
                                              131,
                                              67,
                                              213,
                                              0.3,
                                            ),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          gradient: profileIconCardGradientCOLR,
                                        ),
                                        child: Icon(
                                          current.isApp
                                              ? Remix.smartphone_line
                                              : Remix.computer_line,
                                          size: 22,
                                          color: Color(0xffCF7FFA),
                                        ),
                                      ),
                                      Positioned(
                                        right: -1,
                                        top: -1,
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: Color(0xff00FFAA),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    spacing: 2,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        spacing: 8,
                                        children: [
                                          Text(
                                            'This Device',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 4,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 0.5,
                                                color: Color(0xff00FFAA),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              'Current',
                                              style: TextStyle(
                                                color: Color(0xff00FFAA),
                                                fontSize: 8,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        current.platformLabel,
                                        style: TextStyle(
                                          color: Color(primaryTextCOLR),
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '${current.ipAddress} • ${_timeAgo(current.lastSeenAt)}',
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
                        ],
                      ),
                    ),

                  // OTHER ACTIVE SESSION
                  if (others.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        spacing: 8,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Other Active Sessions',
                            style: TextStyle(
                              color: Color(secondaryCOLR),
                              fontSize: 16,
                            ),
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
                                ...others.asMap().entries.map((entry) {
                                  final session = entry.value;
                                  return ActiveSessionItem(
                                    type: session.isApp ? 'phone' : 'computer',
                                    title: session.deviceLabel,
                                    device: session.platformLabel,
                                    location:
                                        '${session.ipAddress} • ${_timeAgo(session.lastSeenAt)}',
                                    isLast: others.length == entry.key + 1,
                                    onLogout: () => _revoke(session.id),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // NOTIFICATION
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 0.5,
                          color: Color(secondaryCOLR),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: Color.fromRGBO(181, 77, 232, 0.1),
                      ),
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
                              Remix.shield_check_fill,
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
                                  'Don’t recognize a session?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  activeSessionNotificationCaption,
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
                  ),

                  // SPACING
                  SizedBox(height: 30),

                  // LOGOUT ACTION
                  if (others.isNotEmpty)
                    Padding(
                      padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
                      child: Column(
                        spacing: 8,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                barrierColor: Color.fromRGBO(
                                  255,
                                  255,
                                  255,
                                  0.15,
                                ),
                                builder: (context) {
                                  return ActiveSessionSignoutModal(
                                    onConfirm: _revokeOthers,
                                  );
                                },
                              );
                            },
                            child: Text(
                              'Log out all other sessions',
                              style: TextStyle(
                                color: Color(secondaryCOLR),
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            'This will log you out from all devices except this one.',
                            style: TextStyle(
                              color: Color(primaryTextCOLR),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
