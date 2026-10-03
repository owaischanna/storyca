import 'package:storryca/src/core/widgets/branded_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/images.const.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/models/user_api_model.dart';
import 'package:storryca/src/core/widgets/default_appbar.dart';
import 'package:storryca/src/core/widgets/error_state.dart';
import 'package:storryca/src/core/widgets/loading_state.dart';
import 'package:storryca/src/features/profile/presentation/contents/profile_menu_items.dart';
import 'package:storryca/src/features/profile/presentation/widgets/profile_footer_auth.dart';
import 'package:storryca/src/features/profile/presentation/widgets/profile_header_author.dart';
import 'package:storryca/src/features/profile/presentation/widgets/profile_header_user.dart';
import 'package:storryca/src/features/profile/presentation/widgets/profile_menu_item.dart';
import 'package:storryca/src/features/profile/presentation/widgets/profile_unauthed_header.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool? _loggedIn;
  UserApiModel? _user;
  String? _error;

  // /users/me's own followers/followings fields aren't kept in sync with the
  // real Follow feature — /follow/state is the source of truth for those
  // counts, so it's fetched separately and used instead when available.
  int? _followers;
  int? _followings;

  num? _walletBalance;

  @override
  void initState() {
    super.initState();
    _load();
    // Keeps the Inbox unread badge current when a push arrives or is read.
    pushService.inboxChanged.addListener(_load);
  }

  @override
  void dispose() {
    pushService.inboxChanged.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _error = null);
    final token = await authService.getToken();
    if (!mounted) return;
    if (token == null) {
      setState(() => _loggedIn = false);
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
      } on ApiException {
        // Fall back to /users/me's counts if the dedicated endpoint fails.
      }
      setState(() {
        _loggedIn = true;
        _user = user;
        _followers = followers;
        _followings = followings;
      });
      try {
        final wallet = await walletRepository.getWallet(token);
        if (mounted) setState(() => _walletBalance = wallet.balance);
      } on ApiException {
        // Best-effort — the rest of the profile is still usable without it.
      }
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        // The token's already been cleared by ApiClient.onUnauthorized —
        // reflect that here instead of showing a stale logged-in state the
        // reader would otherwise have to manually sign out of.
        setState(() => _loggedIn = false);
        return;
      }
      setState(() {
        _loggedIn = true;
        _error = e.displayMessage;
      });
    }
  }

  String _sinceLabel(String prefix, String? date) {
    if (date == null || date.isEmpty) return '$prefix unknown';
    final parsed = DateTime.tryParse(date);
    final formatted = parsed == null
        ? date
        : DateFormat('MMM yyyy').format(parsed);
    return '$prefix $formatted';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF020004),
      body: Container(
        decoration: BoxDecoration(gradient: pageGradientCOLR),
        child: BrandedRefreshIndicator(
          onRefresh: _load,
          child: SafeArea(
            child: Column(
              spacing: 16,
              children: [
                // APPBAR
                DefaultNavbar(label: 'Profile'),

                // HEADER
                if (_loggedIn == null)
                  const LoadingState(height: 150)
                else if (_error != null)
                  ErrorState(message: _error!, onRetry: _load, height: 150)
                else if (_loggedIn == false)
                  ProfileUnAuthedHeader()
                else if (_user == null)
                  const LoadingState(height: 150)
                else if (_user!.isAuthor)
                  ProfileHeaderAuthor(
                    image: _user!.image,
                    name: _user!.name,
                    email: _user!.email,
                    identifier: _user!.identifier,
                    authorSinceLabel: _sinceLabel(
                      'Author since',
                      _user!.becameAuthor,
                    ),
                    followers: _followers ?? _user!.followers,
                    followings: _followings ?? _user!.followings,
                    stories: _user!.publishedStories,
                    onEdited: _load,
                  )
                else
                  ProfileHeaderUser(
                    image: _user!.image,
                    name: _user!.name,
                    email: _user!.email,
                    identifier: _user!.identifier,
                    joinedSinceLabel: _sinceLabel(
                      'Joined since',
                      _user!.createdAt,
                    ),
                    followers: _followers ?? _user!.followers,
                    followings: _followings ?? _user!.followings,
                    onEdited: _load,
                  ),

                // WALLET
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Color(0xffB54DE8)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      spacing: 16,
                      children: [
                        Row(
                          spacing: 8,
                          children: [
                            Expanded(
                              child: Row(
                                spacing: 16,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                        color: Color(0xff8343D5),
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      gradient: profileIconCardGradientCOLR,
                                    ),
                                    child: Center(
                                      child: Image.asset(
                                        walletIconIMG,
                                        width: 48,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Wallet Balance',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Color(0xff9D8AC5),
                                            fontSize: 18,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => context.push(
                                            '/transaction-history',
                                          ),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  _walletBalance == null
                                                      ? '—'
                                                      : _walletBalance!.toStringAsFixed(
                                                          _walletBalance! % 1 == 0
                                                              ? 0
                                                              : 1,
                                                        ),
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  'coins',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Icon(
                                                  Remix.arrow_right_s_line,
                                                  color: Color(0xff9D8AC5),
                                                  size: 24,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Image.asset(walletIMG, width: 84),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => context.push('/topup'),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: defaultGradientTTB,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(),
                                Row(
                                  spacing: 8,
                                  children: [
                                    Icon(
                                      Remix.add_circle_line,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    Text(
                                      'Top Up Balance',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(
                                  Remix.arrow_right_s_line,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // MENU
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Text(
                        'Menu',
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
                            ...List.generate(profileMenuItems.length, (index) {
                              final item = profileMenuItems[index];
                              final isAuthor = _user?.isAuthor ?? false;
                              final route =
                                  item.title == 'Author Center' && isAuthor
                                  ? '/author-center'
                                  : item.route;
                              return ProfileMenuItem(
                                image: item.image,
                                title: item.title,
                                caption: item.caption,
                                route: route,
                                inboxCount: _user?.unreadNotifications ?? 0,
                                isLast: profileMenuItems.length == (index + 1),
                                isAuthed: isAuthor,
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // AUTH
                if (_loggedIn == false) ProfileFooterAuth(),
                // ProfileFooterSettings(),

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
