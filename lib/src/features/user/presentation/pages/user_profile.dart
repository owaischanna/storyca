import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/images.const.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/image_url.dart';
import 'package:storryca/src/core/network/models/follow_api_model.dart';
import 'package:storryca/src/core/widgets/app_image.dart';
import 'package:storryca/src/core/widgets/app_snackbar.dart';
import 'package:storryca/src/core/widgets/sign_in_redirect.dart';
import 'package:storryca/src/core/widgets/moderation_actions.dart';

/// There is no public endpoint yet to fetch a non-author reader's profile by
/// id, so this uses exactly what the Followers/Following list already
/// carries for [user] — real data, in the same layout the page always had.
/// The one extra field it doesn't carry — how many people this reader
/// follows — is fetched separately from /follow/state, which returns both
/// counts for any user id.
class UserProfile extends StatefulWidget {
  const UserProfile({super.key, required this.user});

  final FollowUserApiModel user;

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  bool _muted = false;
  bool _blocked = false;
  late FollowUserApiModel _user = widget.user;
  bool _updating = false;
  int? _following;

  @override
  void initState() {
    super.initState();
    ModerationActions.isMuted(_user.id).then((muted) {
      if (mounted) setState(() => _muted = muted);
    });
    ModerationActions.isBlocked(_user.id).then((blocked) {
      if (mounted) setState(() => _blocked = blocked);
    });
    _loadFollowState();
  }

  Future<void> _loadFollowState() async {
    try {
      final token = await authService.getToken();
      final state = await followRepository.state(_user.id, token: token);
      if (!mounted) return;
      // The list row this page was opened from can be stale (followed from
      // elsewhere since) — the button, counts and is_self come from here.
      setState(() {
        _following = state.following;
        _user = FollowUserApiModel(
          id: _user.id,
          name: _user.name,
          username: _user.username,
          image: _user.image,
          aboutMe: _user.aboutMe,
          type: _user.type,
          followedAt: _user.followedAt,
          followers: state.followers,
          isFollowing: state.isFollowing,
          isSelf: state.isSelf,
        );
      });
    } on ApiException {
      // Following count is a nice-to-have here; keep the rest of the page.
    }
  }

  Future<void> _toggleFollow() async {
    final token = await authService.getToken();
    if (token == null) {
      if (mounted) goToSignIn(context);
      return;
    }
    setState(() => _updating = true);
    try {
      final state = _user.isFollowing
          ? await followRepository.unfollow(_user.id, token)
          : await followRepository.follow(_user.id, token);
      setState(() {
        _user = FollowUserApiModel(
          id: _user.id,
          name: _user.name,
          username: _user.username,
          image: _user.image,
          aboutMe: _user.aboutMe,
          type: _user.type,
          followedAt: _user.followedAt,
          followers: state.followers,
          isFollowing: state.isFollowing,
          isSelf: state.isSelf,
        );
      });
    } on ApiException catch (e) {
      if (mounted && !redirectIfSignedOut(context, e)) {
        AppSnackbar.error(context, e.message);
      }
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    return Scaffold(
      backgroundColor: Color.fromRGBO(11, 0, 23, 1),
      body: SingleChildScrollView(
        child: Column(
          spacing: 16,
          children: [
            // HEADER
            SizedBox(
              height: 238,
              child: Stack(
                children: [
                  Image.asset(
                    userBannerPhotoIMG,
                    width: double.infinity,
                    height: 238,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    height: 238,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromRGBO(11, 0, 23, 0),
                          Color.fromRGBO(11, 0, 23, 1),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 16,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () => context.pop(),
                                  child: Icon(
                                    Remix.arrow_left_s_line,
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                ),
                                PopupMenuButton(
                                  icon: Icon(
                                    Remix.more_2_line,
                                    size: 24,
                                    color: Color.fromRGBO(255, 251, 251, 0.5),
                                  ),
                                  color: Color.fromRGBO(23, 0, 45, 0.9),
                                  menuPadding: EdgeInsets.all(0),
                                  shape: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(width: 0),
                                  ),
                                  position: PopupMenuPosition.under,
                                  onSelected: (value) async {
                                    if (value == 'mute') {
                                      final muted = await ModerationActions.toggleMute(
                                        context,
                                        userId: _user.id,
                                        currentlyMuted: _muted,
                                      );
                                      if (muted != null && mounted) {
                                        setState(() => _muted = muted);
                                      }
                                    } else if (value == 'report') {
                                      ModerationActions.report(
                                        context,
                                        targetType: 'user',
                                        targetId: _user.id,
                                      );
                                    }
                                    if (value == 'block' && context.mounted) {
                                      final blocked =
                                          await ModerationActions.toggleBlock(
                                            context,
                                            userId: _user.id,
                                            currentlyBlocked: _blocked,
                                          );
                                      if (blocked != null && mounted) {
                                        setState(() => _blocked = blocked);
                                        // Any follow between them is dropped
                                        // server-side — reload the button.
                                        _loadFollowState();
                                      }
                                    }
                                  },
                                  itemBuilder: (context) {
                                    return [
                                      PopupMenuItem(
                                        height: 40,
                                        value: 'share',
                                        child: Row(
                                          spacing: 8,
                                          children: [
                                            Icon(
                                              Remix.share_line,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                            Text(
                                              'Share',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        height: 40,
                                        value: 'mute',
                                        child: Row(
                                          spacing: 8,
                                          children: [
                                            Icon(
                                              Remix.notification_off_line,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                            Text(
                                              _muted ? 'Unmute Updates' : 'Mute Updates',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        height: 40,
                                        value: 'report',
                                        child: Row(
                                          spacing: 8,
                                          children: [
                                            Icon(
                                              Remix.flag_line,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                            Text(
                                              'Report',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Same row as the author profile's.
                                      // Not offered on the reader's own.
                                      if (!_user.isSelf)
                                        PopupMenuItem(
                                          height: 40,
                                          value: 'block',
                                          child: Row(
                                            spacing: 8,
                                            children: [
                                              Icon(
                                                Remix.user_unfollow_line,
                                                color: Color(0xffC23B3B),
                                                size: 16,
                                              ),
                                              Text(
                                                _blocked
                                                    ? 'Unblock User'
                                                    : 'Block User',
                                                style: TextStyle(
                                                  color: Color(0xffC23B3B),
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ];
                                  },
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 84,
                                  height: 84,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 2,
                                      color: Color(0xff520E92),
                                    ),
                                    borderRadius: BorderRadius.circular(84),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadiusGeometry.circular(
                                      84,
                                    ),
                                    child: AppImage(
                                      avatarUrl(user.image),
                                      width: 84,
                                      height: 84,
                                    ),
                                  ),
                                ),
                                Row(
                                  spacing: 6,
                                  children: [
                                    GestureDetector(
                                      onTap: () => context.push(
                                        '/network/Followers?userId=${user.id}',
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            '${user.followers}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            'Followers',
                                            style: TextStyle(
                                              color: Color(primaryTextCOLR),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 40,
                                      child: VerticalDivider(
                                        color: Color.fromRGBO(
                                          157,
                                          138,
                                          197,
                                          0.2,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => context.push(
                                        '/network/Following?userId=${user.id}',
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            _following == null
                                                ? '—'
                                                : '$_following',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            'Following',
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
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // INFO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                spacing: 16,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: GoogleFonts.playfair(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '@${user.username}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(primaryTextCOLR),
                            ),
                          ),
                        ],
                      ),
                      if (!user.isSelf)
                        GestureDetector(
                          onTap: _updating ? null : _toggleFollow,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: user.isFollowing
                                  ? null
                                  : defaultGradientTTB,
                              border: user.isFollowing
                                  ? Border.all(
                                      width: 1,
                                      color: Color.fromRGBO(181, 77, 232, 0.4),
                                    )
                                  : null,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: _updating
                                ? SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    spacing: 8,
                                    children: [
                                      Icon(
                                        Remix.group_line,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        user.isFollowing
                                            ? 'Following'
                                            : 'Follow',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                    ],
                  ),
                  if (user.aboutMe.isNotEmpty)
                    Text(
                      user.aboutMe,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                ],
              ),
            ),

            // SPACING
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
