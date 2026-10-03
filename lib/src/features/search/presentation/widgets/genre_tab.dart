import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/widgets/error_state.dart';
import 'package:storryca/src/core/widgets/loading_state.dart';
import 'package:storryca/src/features/search/presentation/widgets/genre_tab_item.dart';
import 'package:storryca/src/features/search/presentation/widgets/more_suggestion_item.dart';

class GenreTab extends StatefulWidget {
  const GenreTab({super.key, required this.query});

  final String query;

  @override
  State<GenreTab> createState() => _GenreTabState();
}

class _GenreTabState extends State<GenreTab> {
  List<String> moreSuggestions = [
    'alpha romance',
    'fated mates',
    'werewolf books',
    'mafia',
  ];

  List<Map<String, dynamic>>? _genres;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant GenreTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) _load();
  }

  Future<void> _load() async {
    setState(() {
      _genres = null;
      _error = null;
    });
    try {
      final all = await storiesRepository.genresWithCounts();
      final q = widget.query.toLowerCase();
      setState(() {
        _genres = all
            .where((g) => (g['name'] as String).toLowerCase().contains(q))
            .toList();
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
                    text: 'About ${_genres?.length ?? 0} genres for ',
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

          // GENRES
          if (_error != null)
            ErrorState(message: _error!, onRetry: _load, height: 200)
          else if (_genres == null)
            const LoadingState(height: 200)
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                spacing: 16,
                children: [
                  ..._genres!.map((item) {
                    return GenreTabItem(
                      label: item['name'] as String,
                      description: '',
                      stories: item['total'] as int,
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
