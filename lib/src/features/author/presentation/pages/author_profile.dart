import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/images.const.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/image_url.dart';
import 'package:storryca/src/core/network/models/author_api_model.dart';
import 'package:storryca/src/core/network/models/follow_api_model.dart';
import 'package:storryca/src/core/network/models/pagination.dart';
import 'package:storryca/src/core/widgets/app_image.dart';
import 'package:storryca/src/core/widgets/app_snackbar.dart';
import 'package:storryca/src/core/widgets/sign_in_redirect.dart';
import 'package:storryca/src/core/widgets/moderation_actions.dart';
import 'package:storryca/src/core/widgets/branded_refresh_indicator.dart';
import 'package:storryca/src/core/widgets/error_state.dart';
import 'package:storryca/src/core/widgets/loading_state.dart';
import 'package:storryca/src/features/author/presentation/widgets/about_author_tab.dart';
import 'package:storryca/src/features/author/presentation/widgets/stories_ap_tab.dart';
import 'package:storryca/src/features/discover/types/story_item.typres.dart';

class AuthorProfile extends StatefulWidget {
  const AuthorProfile({super.key, required this.id});

  final int id;

  @override
  State<AuthorProfile> createState() => _AuthorProfileState();
}

class _AuthorProfileState extends State<AuthorProfile> {
  AuthorApiModel? _author;
  List<StoryItemTypes>? _stories;
  String? _error;

  String? _token;
  FollowStateApiModel? _followState;
  bool _followUpdating = false;
  bool _muted = false;
  bool _blocked = false;

  @override
  void initState() {
    super.initState();
    ModerationActions.isMuted(widget.id).then((muted) {
      if (mounted) setState(() => _muted = muted);
    });
    ModerationActions.isBlocked(widget.id).then((blocked) {
      if (mounted) setState(() => _blocked = blocked);
    });
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _error = null;
    });
    _token = await authService.getToken();
    try {
      final results = await Future.wait([
        authorsRepository.byId(widget.id),
        authorsRepository.storiesByAuthor(widget.id),
        followRepository.state(widget.id, token: _token),
      ]);
      setState(() {
        _author = results[0] as AuthorApiModel;
        _stories = (results[1] as Paged<StoryItemTypes>).items;
        _followState = results[2] as FollowStateApiModel;
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    }
  }

  Future<void> _toggleFollow() async {
    final token = _token;
    if (token == null) {
      goToSignIn(context);
      return;
    }
    final following = _followState?.isFollowing ?? false;
    setState(() => _followUpdating = true);
    try {
      final state = following
          ? await followRepository.unfollow(widget.id, token)
          : await followRepository.follow(widget.id, token);
      setState(() => _followState = state);
    } on ApiException catch (e) {
      if (mounted && !redirectIfSignedOut(context, e)) {
        AppSnackbar.error(context, e.message);
      }
    } finally {
      if (mounted) setState(() => _followUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        backgroundColor: Color.fromRGBO(11, 0, 23, 1),
        body: SafeArea(
          child: ErrorState(message: _error!, onRetry: _load),
        ),
      );
    }
    if (_author == null) {
      return Scaffold(
        backgroundColor: Color.fromRGBO(11, 0, 23, 1),
        body: const SafeArea(child: LoadingState()),
      );
    }
    final author = _author!;
    return Scaffold(
      backgroundColor: Color.fromRGBO(11, 0, 23, 1),
      body: BrandedRefreshIndicator(
        onRefresh: _load,
        child: Column(
          spacing: 16,
          children: [
            // HEADER
            SizedBox(
              height: 238,
              child: Stack(
                children: [
                  Image.asset(
                    userBannerIMG,
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
                                        userId: widget.id,
                                        currentlyMuted: _muted,
                                      );
                                      if (muted != null && mounted) {
                                        setState(() => _muted = muted);
                                      }
                                    } else if (value == 'report') {
                                      ModerationActions.report(
                                        context,
                                        targetType: 'user',
                                        targetId: widget.id,
                                      );
                                    }
                                    if (value == 'block' && context.mounted) {
                                      final blocked = await ModerationActions.toggleBlock(
                                        context,
                                        userId: widget.id,
                                        currentlyBlocked: _blocked,
                                      );
                                      if (blocked != null && mounted) {
                                        setState(() => _blocked = blocked);
                                        // Follow state is dropped server-side; reload counts too.
                                        _load();
                                      }
                                    }
                                  },
                                  itemBuilder: (context) {
                                    return [
                                      PopupMenuItem(
                                        height: 40,
                                        value: 'share',
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
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
                                      if (_followState?.isSelf != true)
                                      PopupMenuItem(
                                        height: 40,
                                        value: 'block',
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          spacing: 8,
                                          children: [
                                            Icon(
                                              Remix.user_unfollow_line,
                                              color: Color(0xffC23B3B),
                                              size: 16,
                                            ),
                                            Text(
                                              _blocked ? 'Unblock User' : 'Block User',
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
                                Stack(
                                  clipBehavior: Clip.none,
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
                                        borderRadius:
                                            BorderRadiusGeometry.circular(84),
                                        child: AppImage(
                                          avatarUrl(author.image),
                                          width: 84,
                                          height: 84,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 10,
                                      bottom: 0,
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 0.5,
                                            color: Color(0xffEECAFF),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Remix.leaf_fill,
                                            size: 14,
                                            color: Color(0xffEECAFF),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  spacing: 6,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          '${author.publishedStories}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'Stories',
                                          style: TextStyle(
                                            color: Color(primaryTextCOLR),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
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
                                        '/network/Followers?userId=${author.id}',
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            '${_followState?.followers ?? author.followers}',
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
                                        '/network/Following?userId=${author.id}',
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            '${_followState?.following ?? author.followings}',
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
                            author.name,
                            style: GoogleFonts.playfair(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '@${author.username}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(primaryTextCOLR),
                            ),
                          ),
                        ],
                      ),
                      if (_followState?.isSelf != true)
                        GestureDetector(
                          onTap: _followUpdating ? null : _toggleFollow,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: (_followState?.isFollowing ?? false)
                                  ? null
                                  : defaultGradientTTB,
                              border: (_followState?.isFollowing ?? false)
                                  ? Border.all(
                                      width: 1,
                                      color: Color.fromRGBO(181, 77, 232, 0.4),
                                    )
                                  : null,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: _followUpdating
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
                                        (_followState?.isFollowing ?? false)
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
                  Text(
                    author.aboutMe,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Row(
                    spacing: 16,
                    children: [
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 0.5,
                            color: Color(0xffFF4DFF),
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Romance',
                          style: TextStyle(
                            color: Color(0xffFF4DFF),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 0.5,
                            color: Color(0xff00B076),
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Thriller',
                          style: TextStyle(
                            color: Color(0xff00B076),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 0.5,
                            color: Color(0xffC384FF),
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Fantasy',
                          style: TextStyle(
                            color: Color(0xffC384FF),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // TABBER AND TAB
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TabBar(
                        dividerColor: Color.fromRGBO(157, 138, 197, 0.2),
                        indicatorColor: Color(secondaryCOLR),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelStyle: TextStyle(
                          color: Color(secondaryCOLR),
                          fontSize: 12,
                        ),
                        unselectedLabelStyle: TextStyle(
                          color: Color(primaryTextCOLR),
                          fontSize: 12,
                        ),
                        tabs: [
                          Tab(
                            child: Row(
                              spacing: 8,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Remix.book_2_fill, size: 14),
                                Text('Stories', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              spacing: 8,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Remix.user_line, size: 14),
                                Text('About', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          StoriesAPTab(
                            authorId: author.id,
                            authorName: author.name,
                            stories: _stories!,
                          ),
                          AboutAuthorTab(author: author),
                        ],
                      ),
                    ),
                  ],
                ),
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
