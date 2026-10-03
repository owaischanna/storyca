import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/models/pagination.dart';
import 'package:storryca/src/core/widgets/error_state.dart';
import 'package:storryca/src/core/widgets/loading_state.dart';
import 'package:storryca/src/features/home/presentation/types/author.types.dart';
import 'package:storryca/src/features/search/presentation/widgets/author_tab_author_item.dart';
import 'package:storryca/src/features/search/presentation/widgets/more_suggestion_item.dart';

class AuthorsTab extends StatefulWidget {
  const AuthorsTab({super.key, required this.query});

  final String query;

  @override
  State<AuthorsTab> createState() => _AuthorsTabState();
}

class _AuthorsTabState extends State<AuthorsTab> {
  List<String> moreSuggestions = [
    'alpha romance',
    'fated mates',
    'werewolf books',
    'mafia',
  ];

  List<AuthorTypes>? _items;
  Pagination? _pagination;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant AuthorsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) _load();
  }

  Future<void> _load() async {
    setState(() {
      _items = null;
      _error = null;
    });
    try {
      final paged = await authorsRepository.list(q: widget.query, limit: 20);
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
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'About ${_pagination?.total ?? 0} authors for ',
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

          // AUTHORS
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
                    return AuthorTabAuthorItem(
                      id: item.id,
                      image: item.image,
                      category: item.category,
                      description: item.description,
                      followers: item.followers,
                      name: item.name,
                      rating: item.rating,
                      stories: item.stories,
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
