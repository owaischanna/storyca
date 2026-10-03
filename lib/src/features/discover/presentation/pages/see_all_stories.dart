import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/widgets/branded_refresh_indicator.dart';
import 'package:storryca/src/core/widgets/error_state.dart';
import 'package:storryca/src/core/widgets/loading_state.dart';
import 'package:storryca/src/features/discover/presentation/widgets/capsule_item.dart';
import 'package:storryca/src/features/discover/presentation/widgets/story_grid_item.dart';
import 'package:storryca/src/features/discover/types/story_item.typres.dart';

const String _allCategory = 'All';

/// Generic "see all" grid for a single catalog sort — backs Home's
/// Authors/Recommended/New Releases and Discover's Trending Now links.
class SeeAllStories extends StatefulWidget {
  const SeeAllStories({super.key, required this.title, required this.sort});

  final String title;
  final String sort;

  @override
  State<SeeAllStories> createState() => _SeeAllStoriesState();
}

class _SeeAllStoriesState extends State<SeeAllStories> {
  List<StoryItemTypes>? _items;
  List<String>? _categories;
  String _selectedCategory = _allCategory;
  int _page = 1;
  bool _hasMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _load();
  }

  Future<void> _loadCategories() async {
    try {
      final list = await storiesRepository.genresWithCounts();
      setState(() {
        _categories = [_allCategory, ...list.map((g) => g['name'] as String)];
      });
    } on ApiException catch (_) {
      // genre chips are a filter convenience; fail quietly and keep the list
    }
  }

  void _updateCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _items = null;
    });
    _load();
  }

  Future<void> _load({bool loadMore = false}) async {
    setState(() => _error = null);
    final page = loadMore ? _page + 1 : 1;
    try {
      final paged = await storiesRepository.catalog(
        sort: widget.sort,
        genre: _selectedCategory == _allCategory ? null : _selectedCategory,
        page: page,
        limit: 20,
      );
      setState(() {
        _items = loadMore ? [...?_items, ...paged.items] : paged.items;
        _page = paged.pagination.page;
        _hasMore = paged.pagination.hasMore;
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF020004),
      body: Container(
        decoration: BoxDecoration(gradient: pageGradientCOLR),
        child: SafeArea(
          child: Column(
            spacing: 16,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  spacing: 12,
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(Remix.arrow_left_s_line),
                      color: Colors.white,
                      iconSize: 24,
                    ),
                    Text(
                      widget.title,
                      style: GoogleFonts.playfair(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),

              // GENRE FILTER
              if (_categories != null)
                SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        spacing: 12,
                        children: [
                          ..._categories!.map((item) {
                            return CapsuleItem(
                              selectedCategory: _selectedCategory,
                              category: item,
                              update: _updateCategory,
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),

              Expanded(
                child: BrandedRefreshIndicator(
                  onRefresh: () => _load(),
                  child: _error != null
                      ? ErrorState(message: _error!, onRetry: () => _load())
                      : _items == null
                      ? const LoadingState()
                      : Padding(
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
                                itemCount: _items!.length,
                                itemBuilder: (context, index) {
                                  final item = _items![index];
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
                                  onPressed: () => _load(loadMore: true),
                                  child: Text(
                                    'Load more',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              SizedBox(height: 32),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
