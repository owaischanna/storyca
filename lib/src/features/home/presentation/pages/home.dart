import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/widgets/branded_refresh_indicator.dart';
import 'package:storryca/src/core/widgets/default_appbar.dart';
import 'package:storryca/src/core/widgets/error_state.dart';
import 'package:storryca/src/core/widgets/loading_state.dart';
import 'package:storryca/src/features/discover/presentation/widgets/story_grid_item.dart';
import 'package:storryca/src/features/discover/types/story_item.typres.dart';
import 'package:storryca/src/features/home/presentation/types/author.types.dart';
import 'package:storryca/src/features/home/presentation/widgets/author_item.dart';
import 'package:storryca/src/features/home/presentation/widgets/recommended_carousel_item.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<AuthorTypes>? _authors;
  List<StoryItemTypes>? _newReleases;
  List<StoryItemTypes>? _recommended;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    // A blocked account's stories leave the server's responses — re-fetch.
    moderationRepository.blocksChanged.addListener(_load);
  }

  @override
  void dispose() {
    moderationRepository.blocksChanged.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      // Home is the feed the app pushes at the reader, so it honours mutes —
      // unlike Discover, search, ranking and author profiles.
      final token = await authService.getToken();
      final results = await Future.wait([
        authorsRepository.list(sort: 'popular', limit: 10),
        storiesRepository.catalog(
          sort: 'latest',
          limit: 5,
          hideMuted: true,
          token: token,
        ),
        storiesRepository.catalog(
          sort: 'popular',
          limit: 12,
          hideMuted: true,
          token: token,
        ),
      ]);
      setState(() {
        _authors = results[0].items as List<AuthorTypes>;
        _newReleases = results[1].items as List<StoryItemTypes>;
        _recommended = results[2].items as List<StoryItemTypes>;
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    }
  }

  Widget _sectionHeader(String title, VoidCallback onSeeAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.white, fontSize: 18)),
          InkWell(
            onTap: onSeeAll,
            child: Row(
              spacing: 4,
              children: [
                Text(
                  'See All',
                  style: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 0.7),
                    fontSize: 12,
                  ),
                ),
                Icon(
                  Remix.arrow_right_s_line,
                  color: Color.fromRGBO(255, 255, 255, 0.7),
                  size: 12,
                ),
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
        child: BrandedRefreshIndicator(
          onRefresh: _load,
          child: SafeArea(
            child: Column(
              spacing: 16,
              children: [
                DefaultNavbar(label: 'Home'),

                if (_error != null)
                  ErrorState(message: _error!, onRetry: _load, height: 300)
                else if (_authors == null || _newReleases == null || _recommended == null)
                  const LoadingState(height: 300)
                else ...[
                  // AUTHORS
                  Column(
                    spacing: 12,
                    children: [
                      _sectionHeader(
                        'Authors',
                        () => context.push('/see-all-authors'),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 16,
                              children: [
                                ..._authors!.map((item) {
                                  return AuthorItem(
                                    id: item.id,
                                    name: item.name,
                                    image: item.image,
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // RECOMMENDED
                  Column(
                    spacing: 12,
                    children: [
                      _sectionHeader(
                        'Recommended For You',
                        () => context.push('/see-all-stories/popular'),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              spacing: 16,
                              children: [
                                ..._recommended!.map((item) {
                                  return RecommendedCarouselItem(
                                    id: item.id,
                                    title: item.title,
                                    image: item.image,
                                    reads: item.reads,
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // NEW RELEASES
                  Column(
                    spacing: 12,
                    children: [
                      _sectionHeader(
                        'New Releases',
                        () => context.push('/see-all-stories/latest'),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemCount: _newReleases!.length,
                          itemBuilder: (context, index) {
                            final item = _newReleases![index];
                            return StoryGridItem(
                              title: item.title,
                              image: item.image,
                              reads: item.reads,
                              chapters: item.totalChapter,
                              id: item.id,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
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
}
