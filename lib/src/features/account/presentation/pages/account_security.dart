import 'package:storryca/src/core/network/api_client.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:intl/intl.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/models/user_api_model.dart';
import 'package:storryca/src/core/widgets/error_state.dart';
import 'package:storryca/src/core/widgets/loading_state.dart';
import 'package:storryca/src/features/account/contents/security_menu_items.dart';
import 'package:storryca/src/features/account/presentation/widgets/account_menu_item.dart';
import 'package:storryca/src/features/account/presentation/widgets/delete_account_modal.dart';
import 'package:storryca/src/features/account/presentation/widgets/security_menu_item.dart';
import 'package:storryca/src/features/account/types/account_menu_type.dart';
import 'package:storryca/src/features/profile/presentation/widgets/profile_header_user.dart';

class AccountSecurity extends StatefulWidget {
  const AccountSecurity({super.key});

  @override
  State<AccountSecurity> createState() => _AccountSecurityState();
}

class _AccountSecurityState extends State<AccountSecurity> {
  UserApiModel? _user;
  String? _error;

  // /users/me's own followers/followings fields aren't kept in sync with the
  // real Follow feature — /follow/state is the source of truth for those
  // counts, so it's fetched separately and used instead when available.
  int? _followers;
  int? _followings;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_user == null) setState(() => _error = null);
    final token = await authService.getToken();
    if (token == null) {
      setState(() => _error = 'Sign in to see your account.');
      return;
    }
    try {
      final user = await usersRepository.me(token);
      var followers = user.followers;
      var followings = user.followings;
      try {
        final state = await followRepository.state(user.id, token: token);
        followers = state.followers;
        followings = state.following;
      } catch (_) {
        // Fall back to /users/me's counts if the dedicated endpoint fails.
      }
      if (mounted) {
        setState(() {
          _user = user;
          _followers = followers;
          _followings = followings;
        });
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.isUnauthorized) {
        setState(() => _error = 'Sign in to see your account.');
      } else if (_user == null) {
        // Keep showing already-loaded details on a failed refresh; only an
        // empty page gets the error panel.
        setState(() => _error = e.message);
      }
    }
  }

  String _joinedSinceLabel() {
    final date = DateTime.tryParse(_user?.createdAt ?? '');
    return date == null
        ? 'Joined since unknown'
        : 'Joined since ${DateFormat('MMM yyyy').format(date)}';
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
                        'Account & Security',
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

                // PROFILE CARD
                if (_error != null)
                  ErrorState(message: _error!, onRetry: _load, height: 100)
                else if (_user == null)
                  const LoadingState(height: 100)
                else
                  ProfileHeaderUser(
                    image: _user!.image,
                    name: _user!.name,
                    email: _user!.email,
                    identifier: _user!.identifier,
                    joinedSinceLabel: _joinedSinceLabel(),
                    followers: _followers ?? _user!.followers,
                    followings: _followings ?? _user!.followings,
                    onEdited: _load,
                  ),

                // ACCOUNT
                if (_error == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        Text(
                          'Account',
                          style: TextStyle(
                            color: Color(0xffB54DE8),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_user == null)
                          const LoadingState(height: 100)
                        else
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Color.fromRGBO(157, 138, 197, 0.3),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Builder(
                              builder: (context) {
                                final items = [
                                  AccountMenuType(
                                    title: 'Email Address',
                                    caption: _user!.email,
                                    icon: Remix.mail_line,
                                    route: '/edit-profile',
                                  ),
                                  AccountMenuType(
                                    title: 'Phone Number',
                                    caption: (_user!.phone?.isNotEmpty ?? false)
                                        ? _user!.phone!
                                        : 'Not set',
                                    icon: Remix.smartphone_line,
                                    route: '/edit-profile',
                                  ),
                                  AccountMenuType(
                                    title: 'Password',
                                    caption: '***********',
                                    icon: Remix.git_repository_private_line,
                                    route: '/change-password',
                                  ),
                                  AccountMenuType(
                                    title: 'Two-Step Verification',
                                    caption: _user!.twoFactorEnabled
                                        ? 'Enabled'
                                        : 'Disabled',
                                    icon: Remix.shield_check_fill,
                                    // Already on: go straight to turning it
                                    // off, rather than back through the
                                    // "turn it on" intro screen.
                                    route: _user!.twoFactorEnabled
                                        ? '/disable-tsv'
                                        : '/two-step-verification',
                                  ),
                                ];
                                return Column(
                                  children: [
                                    ...List.generate(items.length, (index) {
                                      final item = items[index];
                                      return AccountMenuItem(
                                        icon: item.icon,
                                        title: item.title,
                                        caption: item.caption,
                                        route: item.route,
                                        isLast: items.length == (index + 1),
                                      );
                                    }),
                                  ],
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),

                // SECURITY
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Text(
                        'Security',
                        style: TextStyle(
                          color: Color(0xffB54DE8),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Color.fromRGBO(157, 138, 197, 0.3),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            ...List.generate(securityMenuItems.length, (index) {
                              final item = securityMenuItems[index];
                              return SecurityMenuItem(
                                icon: item.icon,
                                title: item.title,
                                caption: item.caption,
                                route: item.route,
                                isLast: securityMenuItems.length == (index + 1),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ACTIONS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Text(
                        'Actions',
                        style: TextStyle(
                          color: Color(0xffB54DE8),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierColor: Color.fromRGBO(255, 251, 251, 0.15),
                            builder: (context) {
                              return DeleteAccountModal();
                            },
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Color.fromRGBO(157, 138, 197, 0.3),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            spacing: 12,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: Color(0xffC23B3B),
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  color: Color.fromRGBO(194, 59, 59, 0.1),
                                ),
                                child: Icon(
                                  Remix.delete_bin_5_line,
                                  size: 20,
                                  color: Color(0xffC23B3B),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Delete Account',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Color(0xffC23B3B),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Permanently delete your account and data',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Color(0xff9D8AC5),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Remix.arrow_right_s_line,
                                size: 24,
                                color: Color(0xffC23B3B),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // SIGN OUT
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: () async {
                      await authService.logout();
                      if (context.mounted) context.go('/signin');
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(181, 77, 232, 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'Sign Out',
                          style: TextStyle(
                            color: Color(0xffB54DE8),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // SPACING
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
