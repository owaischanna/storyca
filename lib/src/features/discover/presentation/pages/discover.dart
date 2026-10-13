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
import 'package:storryca/src/features/discover/presentation/widgets/capsule_item.dart';
import 'package:storryca/src/features/discover/presentation/widgets/hero_slide_item.dart';
import 'package:storryca/src/features/discover/presentation/widgets/story_grid_item.dart';
import 'package:storryca/src/features/discover/presentation/widgets/trending_carousel_item.dart';
import 'package:storryca/src/features/discover/types/story_item.typres.dart';

const String _allCategory = 'All';

class Discover extends StatefulWidget {
  const Discover({super.key});

  @override
  State<Discover> createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover> {
  String selectedCategory = _allCategory;

  List<String>? _categories;
  List<StoryItemTypes>? _trending;
  List<StoryItemTypes>? _gridItems;
  int _page = 1;
  bool _hasMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTop();
    _loadGrid();
    // A blocked account's stories leave the server's responses — re-fetch.
    moderationRepository.blocksChanged.addListener(_reloadAfterBlock);
  }

  void _reloadAfterBlock() {
    _loadTop();
    _loadGrid();
  }

  @override
  void dispose() {
    moderationRepository.blocksChanged.removeListener(_reloadAfterBlock);
    super.dispose();
  }

  Future<void> _loadTop() async {
    try {
      final genresList = await storiesRepository.genres();
      final trending = await storiesRepository.catalog(
        sort: 'trending',
        limit: 10,
      );
      setState(() {
        _categories = [_allCategory, ...genresList];
        _trending = trending.items;
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    }
  }

  Future<void> _loadGrid({bool loadMore = false}) async {
    final page = loadMore ? _page + 1 : 1;
    try {
      final paged = await storiesRepository.catalog(
        genre: selectedCategory == _allCategory ? null : selectedCategory,
        page: page,
        limit: 20,
      );
      setState(() {
        _gridItems = loadMore ? [...?_gridItems, ...paged.items] : paged.items;
        _page = paged.pagination.page;
        _hasMore = paged.pagination.hasMore;
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    }
  }

  void updateCategory(String category) {
    setState(() {
      selectedCategory = category;
      _gridItems = null;
    });
    _loadGrid();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF020004),
      body: Container(
        decoration: BoxDecoration(gradient: pageGradientCOLR),
        child: BrandedRefreshIndicator(
          onRefresh: () async {
            await Future.wait([_loadTop(), _loadGrid()]);
          },
          child: SafeArea(
            child: Column(
              spacing: 16,
              children: [
                // APPBAR
                DefaultNavbar(label: 'Discover'),

                if (_error != null)
                  ErrorState(
                    message: _error!,
                    onRetry: () {
                      setState(() => _error = null);
                      _loadTop();
                      _loadGrid();
                    },
                    height: 300,
                  )
                else ...[
                  // HERO SLIDE
                  if (_trending == null)
                    const LoadingState(height: 200)
                  else
                    SizedBox(
                      width: double.infinity,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            spacing: 16,
                            children: [
                              ..._trending!.take(5).map((item) {
                                return HeroSlideItem(
                                  title: item.title,
                                  caption: item.description,
                                  image: item.image,
                                  id: item.id,
                                  rating: item.rating.clamp(0, 5),
                                  badge: '',
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // TRENDING CAROUSEL
                  Column(
                    spacing: 12,
                    children: [
                      // HEADER
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Trending Now',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            InkWell(
                              onTap: () =>
                                  context.push('/see-all-stories/trending'),
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
                      ),

                      // CAROUSEL
                      if (_trending == null)
                        const LoadingState(height: 150)
                      else
                        SizedBox(
                          width: double.infinity,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Row(
                                spacing: 16,
                                children: [
                                  ..._trending!.map((item) {
                                    return TrendingCarouselItem(
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

                  // STORIES GRID
                  Column(
                    spacing: 12,
                    children: [
                      // HEADER
                      if (_categories != null)
                        SizedBox(
                          width: double.infinity,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Row(
                                spacing: 12,
                                children: [
                                  ..._categories!.map((item) {
                                    return CapsuleItem(
                                      selectedCategory: selectedCategory,
                                      category: item,
                                      update: updateCategory,
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // GRID ITEMS
                      if (_gridItems == null)
                        const LoadingState(height: 300)
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            spacing: 12,
                            children: [
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 2,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                    ),
                                itemCount: _gridItems!.length,
                                itemBuilder: (context, index) {
                                  final item = _gridItems![index];
                                  return StoryGridItem(
                                    title: item.title,
                                    image: item.image,
                                    reads: item.reads,
                                    chapters: item.totalChapter,
                                    id: item.id,
                                  );
                                },
                              ),
                              if (_hasMore)
                                TextButton(
                                  onPressed: () => _loadGrid(loadMore: true),
                                  child: Text(
                                    'Load more',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                            ],
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
