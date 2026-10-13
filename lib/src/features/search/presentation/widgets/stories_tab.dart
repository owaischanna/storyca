import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/models/pagination.dart';
import 'package:storryca/src/core/widgets/error_state.dart';
import 'package:storryca/src/core/widgets/loading_state.dart';
import 'package:storryca/src/features/discover/types/story_item.typres.dart';
import 'package:storryca/src/features/search/presentation/widgets/more_suggestion_item.dart';
import 'package:storryca/src/features/search/presentation/widgets/stories_item.dart';

const Map<String, String?> _sortOptions = {
  'Relevance': null,
  'Popularity': 'popular',
  'Recent': 'latest',
  'Oldest': 'oldest',
  'Most Reads': 'trending',
  'Most Rating': 'top_rated',
  'Most Liked': 'most_liked',
};

class StoriesTab extends StatefulWidget {
  const StoriesTab({super.key, required this.query});

  final String query;

  @override
  State<StoriesTab> createState() => _StoriesTabState();
}

class _StoriesTabState extends State<StoriesTab> {
  List<String> moreSuggestions = [
    'alpha romance',
    'fated mates',
    'werewolf books',
    'mafia',
  ];

  String selectedItem = 'Relevance';
  List<StoryItemTypes>? _items;
  Pagination? _pagination;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant StoriesTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) _load();
  }

  Future<void> _load() async {
    setState(() {
      _items = null;
      _error = null;
    });
    try {
      final paged = await storiesRepository.catalog(
        q: widget.query,
        sort: _sortOptions[selectedItem],
        limit: 20,
      );
      setState(() {
        _items = paged.items;
        _pagination = paged.pagination;
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADING
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              'About ${_pagination?.total ?? 0} stories for ',
                          style: TextStyle(
                            color: Color(primaryTextCOLR),
                            fontSize: 12,
                          ),
                        ),
                        TextSpan(
                          text: '"${widget.query}"',
                          style: TextStyle(
                            color: Color(0xff9110DE),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  spacing: 4,
                  children: [
                    Text(
                      'Sort by:',
                      style: TextStyle(
                        color: Color(primaryTextCOLR),
                        fontSize: 12,
                      ),
                    ),
                    PopupMenuButton(
                      color: Color.fromRGBO(23, 0, 45, 0.99),
                      menuPadding: EdgeInsets.all(0),
                      shape: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(width: 0),
                      ),
                      position: PopupMenuPosition.under,
                      onSelected: (value) {
                        setState(() => selectedItem = value);
                        _load();
                      },
                      itemBuilder: (context) {
                        return [
                          ..._sortOptions.keys.map((item) {
                            return PopupMenuItem(
                              height: 40,
                              value: item,
                              child: Text(
                                item,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }),
                        ];
                      },
                      child: Row(
                        children: [
                          Text(
                            selectedItem,
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          Icon(
                            Remix.arrow_down_s_line,
                            size: 16,
                            color: Color(0xFF9110DE),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // STORIES
          if (_error != null)
            ErrorState(message: _error!, onRetry: _load, height: 200)
          else if (_items == null)
            const LoadingState(height: 200)
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                spacing: 16,
                children: [
                  ..._items!.map((item) {
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

          // MORE SUGGESTIONS
          Column(
            spacing: 8,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
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
