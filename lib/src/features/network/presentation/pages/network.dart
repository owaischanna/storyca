import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/models/follow_api_model.dart';
import 'package:storryca/src/core/widgets/app_snackbar.dart';
import 'package:storryca/src/core/widgets/sign_in_redirect.dart';
import 'package:storryca/src/core/widgets/error_state.dart';
import 'package:storryca/src/core/widgets/loading_state.dart';
import 'package:storryca/src/features/network/presentation/widgets/network_tab.dart';
import 'package:storryca/src/features/network/presentation/widgets/network_user_item.dart';
import 'package:storryca/src/features/network/presentation/widgets/no_followers.dart';
import 'package:storryca/src/features/network/presentation/widgets/no_following.dart';

class Network extends StatefulWidget {
  const Network({super.key, this.tab = '', this.userId});

  final String tab;

  /// The profile whose network is being shown. Null means "my network" —
  /// resolved to the signed-in user's own id once the token loads.
  final int? userId;

  @override
  State<Network> createState() => _NetworkState();
}

class _NetworkState extends State<Network> {
  String selectedTab = 'Followers';

  String? _token;
  int? _userId;
  String? _initError;

  List<FollowUserApiModel>? _followers;
  int _followersPage = 1;
  int _followersTotal = 0;
  bool _followersHasMore = false;
  bool _followersLoadingMore = false;
  String? _followersError;

  List<FollowUserApiModel>? _following;
  int _followingPage = 1;
  int _followingTotal = 0;
  bool _followingHasMore = false;
  bool _followingLoadingMore = false;
  String? _followingError;

  final Set<int> _updatingIds = {};

  @override
  void initState() {
    super.initState();
    if (widget.tab.isNotEmpty) {
      selectedTab = widget.tab;
    }
    _init();
  }

  Future<void> _init() async {
    setState(() => _initError = null);
    _token = await authService.getToken();
    var userId = widget.userId;
    if (userId == null) {
      if (_token == null) {
        setState(() => _initError = 'Sign in to see your network.');
        return;
      }
      try {
        final me = await usersRepository.me(_token!);
        userId = me.id;
      } on ApiException catch (e) {
        setState(() => _initError = e.message);
        return;
      }
    }
    setState(() => _userId = userId);
    await Future.wait([_loadFollowers(), _loadFollowing()]);
  }

  Future<void> _loadFollowers({bool loadMore = false}) async {
    if (_userId == null) return;
    setState(() {
      _followersError = null;
      if (loadMore) _followersLoadingMore = true;
    });
    final page = loadMore ? _followersPage + 1 : 1;
    try {
      final paged = await followRepository.followers(
        _userId!,
        page: page,
        token: _token,
      );
      setState(() {
        _followers = loadMore ? [...?_followers, ...paged.items] : paged.items;
        _followersPage = paged.pagination.page;
        _followersTotal = paged.pagination.total;
        _followersHasMore = paged.pagination.hasMore;
      });
    } on ApiException catch (e) {
      setState(() => _followersError = e.message);
    } finally {
      setState(() => _followersLoadingMore = false);
    }
  }

  Future<void> _loadFollowing({bool loadMore = false}) async {
    if (_userId == null) return;
    setState(() {
      _followingError = null;
      if (loadMore) _followingLoadingMore = true;
    });
    final page = loadMore ? _followingPage + 1 : 1;
    try {
      final paged = await followRepository.following(
        _userId!,
        page: page,
        token: _token,
      );
      setState(() {
        _following = loadMore ? [...?_following, ...paged.items] : paged.items;
        _followingPage = paged.pagination.page;
        _followingTotal = paged.pagination.total;
        _followingHasMore = paged.pagination.hasMore;
      });
    } on ApiException catch (e) {
      setState(() => _followingError = e.message);
    } finally {
      setState(() => _followingLoadingMore = false);
    }
  }

  Future<void> _toggleFollow(FollowUserApiModel user, List<FollowUserApiModel> list) async {
    final token = _token;
    if (token == null) {
      goToSignIn(context);
      return;
    }
    setState(() => _updatingIds.add(user.id));
    try {
      final state = user.isFollowing
          ? await followRepository.unfollow(user.id, token)
          : await followRepository.follow(user.id, token);
      final index = list.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        setState(() {
          list[index] = FollowUserApiModel(
            id: user.id,
            name: user.name,
            username: user.username,
            image: user.image,
            aboutMe: user.aboutMe,
            type: user.type,
            followedAt: user.followedAt,
            followers: state.followers,
            isFollowing: state.isFollowing,
            isSelf: state.isSelf,
          );
        });
      }
    } on ApiException catch (e) {
      if (mounted && !redirectIfSignedOut(context, e)) {
        AppSnackbar.error(context, e.message);
      }
    } finally {
      if (mounted) setState(() => _updatingIds.remove(user.id));
    }
  }

  void updateSelectedTab(String tab) {
    setState(() {
      selectedTab = tab;
    });
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
                        'My Network',
                        style: GoogleFonts.playfair(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                if (_initError != null)
                  ErrorState(message: _initError!, onRetry: _init, height: 300)
                else if (_userId == null)
                  const LoadingState(height: 300)
                else ...[
                  // TABBAR
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Color.fromRGBO(145, 16, 222, 0.1),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          NetworkTab(
                            selectedTab: selectedTab,
                            icon: Remix.group_line,
                            label: 'Followers',
                            count: _followersTotal,
                            update: updateSelectedTab,
                          ),
                          NetworkTab(
                            selectedTab: selectedTab,
                            icon: Remix.user_line,
                            label: 'Following',
                            count: _followingTotal,
                            update: updateSelectedTab,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // FOLLOWERS
                  if (selectedTab == 'Followers') _buildFollowersTab(),

                  // FOLLOWING
                  if (selectedTab == 'Following') _buildFollowingTab(),
                ],

                // SPACING
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFollowersTab() {
    if (_followersError != null) {
      return ErrorState(
        message: _followersError!,
        onRetry: () => _loadFollowers(),
        height: 200,
      );
    }
    if (_followers == null) {
      return const LoadingState(height: 200);
    }
    if (_followers!.isEmpty) {
      return const NoFollowers();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        spacing: 16,
        children: [
          ..._followers!.map((user) {
            return NetworkUserItem(
              user: user,
              id: user.id,
              image: user.image,
              name: user.name,
              caption: user.aboutMe,
              isAuthor: user.isAuthor,
              followers: user.followers,
              isFollowing: user.isFollowing,
              isSelf: user.isSelf,
              isUpdating: _updatingIds.contains(user.id),
              onToggleFollow: () => _toggleFollow(user, _followers!),
            );
          }),
          if (_followersHasMore)
            TextButton(
              onPressed: _followersLoadingMore
                  ? null
                  : () => _loadFollowers(loadMore: true),
              child: Text(
                _followersLoadingMore ? 'Loading…' : 'Load more',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFollowingTab() {
    if (_followingError != null) {
      return ErrorState(
        message: _followingError!,
        onRetry: () => _loadFollowing(),
        height: 200,
      );
    }
    if (_following == null) {
      return const LoadingState(height: 200);
    }
    if (_following!.isEmpty) {
      return const NoFollowing();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        spacing: 16,
        children: [
          ..._following!.map((user) {
            return NetworkUserItem(
              user: user,
              id: user.id,
              image: user.image,
              name: user.name,
              caption: user.aboutMe,
              isAuthor: user.isAuthor,
              followers: user.followers,
              isFollowing: user.isFollowing,
              isSelf: user.isSelf,
              isUpdating: _updatingIds.contains(user.id),
              onToggleFollow: () => _toggleFollow(user, _following!),
            );
          }),
          if (_followingHasMore)
            TextButton(
              onPressed: _followingLoadingMore
                  ? null
                  : () => _loadFollowing(loadMore: true),
              child: Text(
                _followingLoadingMore ? 'Loading…' : 'Load more',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
