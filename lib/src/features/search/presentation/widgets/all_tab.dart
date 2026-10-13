import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/widgets/error_state.dart';
import 'package:storryca/src/core/widgets/loading_state.dart';
import 'package:storryca/src/features/discover/types/story_item.typres.dart';
import 'package:storryca/src/features/home/presentation/types/author.types.dart';
import 'package:storryca/src/features/search/presentation/widgets/all_tab_authors.dart';
import 'package:storryca/src/features/search/presentation/widgets/more_suggestion_item.dart';
import 'package:storryca/src/features/search/presentation/widgets/recommended_for_you.dart';
import 'package:storryca/src/features/search/presentation/widgets/stories_item.dart';

class AllTab extends StatefulWidget {
  const AllTab({super.key, required this.query});

  final String query;

  @override
  State<AllTab> createState() => _AllTabState();
}

class _AllTabState extends State<AllTab> {
  List<String> moreSuggestions = [
    'alpha romance',
    'fated mates',
    'werewolf books',
    'mafia',
  ];

  List<StoryItemTypes>? _topResults;
  List<StoryItemTypes>? _stories;
  List<AuthorTypes>? _authors;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant AllTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) _load();
  }

  Future<void> _load() async {
    setState(() {
      _topResults = null;
      _stories = null;
      _authors = null;
      _error = null;
    });
    try {
      final results = await Future.wait([
        storiesRepository.catalog(q: widget.query, limit: 8),
        storiesRepository.catalog(q: widget.query, limit: 3),
        authorsRepository.list(q: widget.query, limit: 8),
      ]);
      setState(() {
        _topResults = (results[0] as dynamic).items as List<StoryItemTypes>;
        _stories = (results[1] as dynamic).items as List<StoryItemTypes>;
        _authors = (results[2] as dynamic).items as List<AuthorTypes>;
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
    if (_topResults == null || _stories == null || _authors == null) {
      return const LoadingState(height: 300);
    }
    return SingleChildScrollView(
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADING
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Results for ',
                    style: TextStyle(
                      color: Color(primaryTextCOLR),
                      fontSize: 12,
                    ),
                  ),
                  TextSpan(
                    text: '"${widget.query}"',
                    style: TextStyle(color: Color(0xff9110DE), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          // TOP RESULTS
          Column(
            spacing: 8,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  spacing: 4,
                  children: [
                    Icon(
                      Remix.vip_crown_fill,
                      color: Color(secondaryCOLR),
                      size: 16,
                    ),
                    Text(
                      'Top Results',
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
                      ..._topResults!.map((item) {
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

          // STORIES
          Column(
            spacing: 8,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  spacing: 4,
                  children: [
                    Icon(
                      Remix.book_2_fill,
                      color: Color(secondaryCOLR),
                      size: 16,
                    ),
                    Text(
                      'Stories',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    spacing: 16,
                    children: [
                      ..._stories!.map((item) {
                        return StoriesItem(
                          id: item.id,
                          image: item.image,
                          title: item.title,
                          category: item.category,
                          description: item.description,
                          reads: item.reads,
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // AUTHORS
          Column(
            spacing: 8,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  spacing: 4,
                  children: [
                    Icon(
                      Remix.group_fill,
                      color: Color(secondaryCOLR),
                      size: 16,
                    ),
                    Text(
                      'Authors',
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
                      ..._authors!.map((item) {
                        return AllTabAuthors(
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

          // MORE SUGGESTIONS
          Column(
            spacing: 8,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  spacing: 4,
                  children: [
                    Icon(
                      Remix.sparkling_2_fill,
                      color: Color(secondaryCOLR),
                      size: 16,
                    ),
                    Text(
                      'More Suggestions',
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
                      MoreSuggestionItem(
                        hasIcon: true,
                        icon: Remix.search_2_line,
                      ),
                      ...List.generate(moreSuggestions.length, (index) {
                        final item = moreSuggestions[index];
                        return MoreSuggestionItem(item: item);
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // SPACING
          SizedBox(height: 50),
        ],
      ),
    );
  }
}
