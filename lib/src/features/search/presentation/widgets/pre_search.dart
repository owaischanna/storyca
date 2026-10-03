import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/local/recent_searches_store.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/widgets/error_state.dart';
import 'package:storryca/src/core/widgets/loading_state.dart';
import 'package:storryca/src/features/discover/types/story_item.typres.dart';
import 'package:storryca/src/features/home/presentation/types/author.types.dart';
import 'package:storryca/src/features/search/presentation/widgets/popular_author_item.dart';
import 'package:storryca/src/features/search/presentation/widgets/recent_searches_item.dart';
import 'package:storryca/src/features/search/presentation/widgets/recommended_for_you.dart';
import 'package:storryca/src/features/search/presentation/widgets/trending_search_item.dart';

class PreSearch extends StatefulWidget {
  const PreSearch({super.key, required this.onSelectQuery});

  final void Function(String query) onSelectQuery;

  @override
  State<PreSearch> createState() => _PreSearchState();
}

class _PreSearchState extends State<PreSearch> {
  List<String> _recentSearches = [];

  List<String>? _genres;
  List<StoryItemTypes>? _recommended;
  List<AuthorTypes>? _popularAuthors;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _load();
  }

  Future<void> _loadRecentSearches() async {
    final list = await RecentSearchesStore.load();
    if (mounted) setState(() => _recentSearches = list);
  }

  Future<void> _deleteRecentSearch(String query) async {
    await RecentSearchesStore.remove(query);
    _loadRecentSearches();
  }

  Future<void> _clearRecentSearches() async {
    await RecentSearchesStore.clear();
    setState(() => _recentSearches = []);
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        storiesRepository.genresWithCounts(),
        storiesRepository.catalog(sort: 'popular', limit: 10),
        authorsRepository.list(sort: 'popular', limit: 10),
      ]);
      setState(() {
        _genres = (results[0] as List<Map<String, dynamic>>)
            .map((g) => g['name'] as String)
            .toList();
        _recommended = (results[1] as dynamic).items as List<StoryItemTypes>;
        _popularAuthors = (results[2] as dynamic).items as List<AuthorTypes>;
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return ErrorState(message: _error!, onRetry: _load, height: 300);
    }
    if (_genres == null || _recommended == null || _popularAuthors == null) {
      return const LoadingState(height: 300);
    }
    return Column(
      spacing: 32,
      children: [
        // TRENDING SEARCHES
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🔥 Trending Searches',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Wrap(
                  runSpacing: 12,
                  spacing: 12,
                  children: [
                    ..._genres!.map((item) {
                      return TrendingSearchItem(
                        item: item,
                        onTap: () => widget.onSelectQuery(item),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),

        // RECENT SEARCHES
        if (_recentSearches.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              spacing: 8,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      spacing: 4,
                      children: [
                        Icon(
                          Remix.time_line,
                          color: Color(secondaryCOLR),
                          size: 16,
                        ),
                        Text(
                          'Recent Searches',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: _clearRecentSearches,
                      child: Row(
                        spacing: 4,
                        children: [
                          Text(
                            'Clear All',
                            style: TextStyle(
                              color: Color(secondaryCOLR),
                              fontSize: 12,
                            ),
                          ),
                          Icon(
                            Remix.arrow_right_s_line,
                            color: Color(secondaryCOLR),
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.fromRGBO(157, 138, 197, 0.2),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      ...List.generate(_recentSearches.length, (index) {
                        final item = _recentSearches[index];
                        return RecentSearchesItem(
                          label: item,
                          isLast: _recentSearches.length == (index + 1),
                          onTap: () => widget.onSelectQuery(item),
                          onDelete: () => _deleteRecentSearch(item),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // RECOMMENDED FOR YOU
        Column(
          spacing: 8,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                spacing: 4,
                children: [
                  Icon(Remix.star_fill, color: Color(secondaryCOLR), size: 16),
                  Text(
                    'Recommended For You',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._recommended!.map((item) {
                      return RecommendedForYouItem(
                        id: item.id,
                        image: item.image,
                        title: item.title,
                        genre: item.category,
                        rating: item.rating,
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),

        // POPULAR AUTHOR
        Column(
          spacing: 8,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                spacing: 4,
                children: [
                  Icon(Remix.group_fill, color: Color(secondaryCOLR), size: 16),
                  Text(
                    'Popular Authors',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._popularAuthors!.map((item) {
                      return PopularAuthorItem(
                        id: item.id,
                        image: item.image,
                        name: item.name,
                        stories: item.stories,
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
